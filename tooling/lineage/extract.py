#!/usr/bin/env python3
"""
Static lineage extractor for shell+SQL ETL repos (Vertica / Postgres / ClickHouse).

Walks every .sh and .sql file, extracts table-level lineage including
cross-database hand-offs done via intermediate files (tsv/csv), and writes:

    lineage/graph.json      - nodes (tables/files) + edges, with provenance
    lineage/coverage.json   - what was parsed vs. skipped (CI gate material)

Usage:  python3 lineage/extract.py [--repo PATH] [--out DIR]

Conventions this parser understands (see CLAUDE.md):
  vsql  -f file.sql | -c "SQL" [-o out.tsv]        -> engine=vertica
  psql  -f file.sql | -c "SQL"                     -> engine=postgres
  clickhouse-client --query="SQL" [< in.tsv]       -> engine=clickhouse
  vsql/psql meta: \\o ./file.csv  (redirect), \\copy tbl from|to 'file'
  SQL: INSERT..SELECT, CREATE TABLE|VIEW..AS, UPDATE..FROM, COPY..FROM,
       INTO OUTFILE 'file', EXPORT TO
  table_mappings*.json: inbound file prefix -> Vertica staging table
"""
import argparse
import json
import os
import re
import sys
import time
from collections import defaultdict
from pathlib import Path

try:
    import sqlglot
    from sqlglot import exp
except ImportError:
    sys.exit("sqlglot is required:  pip install sqlglot")

# ---------------------------------------------------------------- config ---
DEFAULT_CONFIG = {
    "client_prefix": "trd",
    # directories (glob-ish, matched on path parts) excluded from the graph
    "exclude_dirs": ["database_changes", "documentation", "Deployments",
                     ".git", "lineage", ".claude"],
    "exclude_patterns": ["deprecated"],   # any path containing these
    "engine_dirs": {"vsql": "vertica", "pgsql": "postgres", "ch": "clickhouse"},
}

ENGINE_CMDS = {"vsql": "vertica", "psql": "postgres",
               "clickhouse-client": "clickhouse"}

# ------------------------------------------------------------- utilities ---
def norm_file(p: str) -> str:
    """Normalize a data-file path to a stable node id (basename, lowercase)."""
    p = p.strip().strip("'\"")
    p = re.sub(r"\$\{?[A-Za-z_]+\}?/?", "", p)      # drop env-var prefixes
    base = os.path.basename(p).lower()
    return base


def norm_table(name: str) -> str:
    name = name.strip().strip('"').lower()
    name = name.split(".")[-1]                       # drop schema qualifier
    return name


def load_config(repo: Path) -> dict:
    cfg = dict(DEFAULT_CONFIG)
    f = repo / "lineage" / "config.json"
    if f.exists():
        cfg.update(json.loads(f.read_text()))
    return cfg


def is_excluded(path: Path, repo: Path, cfg: dict) -> bool:
    rel = path.relative_to(repo).as_posix().lower()
    parts = set(Path(rel).parts)
    if parts & set(d.lower() for d in cfg["exclude_dirs"]):
        return True
    return any(pat in rel for pat in cfg["exclude_patterns"])


# ---------------------------------------------------------- shell parsing ---
CONT = re.compile(r"\\\n")

def logical_commands(text: str):
    """Split shell text into logical commands, respecting quotes.
    Yields (line_no, command_string)."""
    text = CONT.sub(" ", text)
    cmds, buf, line_no, start = [], [], 1, 1
    q = None
    i = 0
    while i < len(text):
        ch = text[i]
        if ch == "\n":
            line_no += 1
        if q:
            buf.append(ch)
            if ch == q and text[i - 1] != "\\":
                q = None
        else:
            if ch == "#" and (not buf or buf[-1] in " \t"):
                # comment: skip to end of line (apostrophes in comments must
                # not open quote state)
                while i + 1 < len(text) and text[i + 1] != "\n":
                    i += 1
            elif ch in "\"'":
                q = ch
                buf.append(ch)
            elif ch in "\n;":
                s = "".join(buf).strip()
                if s and not s.startswith("#"):
                    cmds.append((start, s))
                buf = []
                start = line_no
            else:
                buf.append(ch)
        i += 1
    s = "".join(buf).strip()
    if s and not s.startswith("#"):
        cmds.append((start, s))
    return cmds


RE_QUERY = re.compile(r'--query\s*=\s*"((?:[^"\\]|\\.)*)"', re.S)
RE_QUERY_SQ = re.compile(r"--query\s*=\s*'([^']*)'", re.S)
RE_DASH_C = re.compile(r'\s-[A-Za-z]*c\s+"((?:[^"\\]|\\.)*)"', re.S)
RE_DASH_C_SQ = re.compile(r"\s-[A-Za-z]*c\s+'([^']*)'", re.S)
RE_DASH_F = re.compile(r'\s-f\s+"?([^\s;"]+\.sql)"?')
RE_DASH_O = re.compile(r'\s-o\s+"?([^\s;"]+)"?')
RE_STDIN = re.compile(r'<\s*"?([^\s;"<>]+)"?\s*$')
RE_SH_CALL = re.compile(r'(?:^|[\s"])((?:\$\{?[A-Za-z_]+\}?/)?[\w./-]+\.sh)\b')
RE_PY_CALL = re.compile(r'python3?\s+"?((?:\$\{?[A-Za-z_]+\}?/)?[\w./-]+\.py)"?')
RE_OUTFILE = re.compile(r"INTO\s+OUTFILE\s+'([^']+)'", re.I)


def resolve_path(raw: str, script: Path, repo: Path):
    """Resolve a $SCRIPT_DIR-style or relative path to a repo file."""
    raw = raw.strip().strip('"').strip("'")
    cleaned = re.sub(r"\$\{?[A-Za-z_]+\}?/?", "", raw).lstrip("./")
    for cand in (repo / cleaned, script.parent / cleaned):
        if cand.exists():
            return cand
    # fallback: unique basename search
    base = os.path.basename(cleaned)
    hits = [p for p in repo.rglob(base) if p.is_file()]
    if len(hits) == 1:
        return hits[0]
    return None


# ------------------------------------------------------------ SQL parsing ---
DIALECT = {"vertica": "postgres", "postgres": "postgres",
           "clickhouse": "clickhouse"}

RE_FALLBACK_TARGET = re.compile(
    r"(?:insert\s+into|create\s+(?:local\s+temp(?:orary)?\s+)?table(?:\s+if\s+not\s+exists)?|create\s+(?:or\s+replace\s+)?view|update|merge\s+into)\s+"
    r'("?[\w.]+"?)', re.I)
RE_FALLBACK_SRC = re.compile(r'(?:from|join)\s+("?[\w.]+"?)', re.I)
KEYWORDS = {"select", "values", "dual", "lateral", "unnest", "final"}


def sql_statement_tables(stmt):
    """Return (targets, sources, kind) for one parsed sqlglot statement."""
    targets, sources, kind = set(), set(), None
    ctes = {c.alias_or_name.lower() for c in stmt.find_all(exp.CTE)}
    ctes |= {t.alias_or_name.lower() for t in stmt.find_all(exp.Subquery)
             if t.alias_or_name}

    def tbl(node):
        return norm_table(node.name) if node is not None and node.name else None

    if isinstance(stmt, exp.Insert):
        kind = "insert"
        t = stmt.find(exp.Table)
        if t is not None:
            targets.add(tbl(t))
    elif isinstance(stmt, exp.Create) and stmt.kind in ("TABLE", "VIEW"):
        kind = "create_view" if stmt.kind == "VIEW" else "create_table_as"
        t = stmt.find(exp.Table)
        if t is not None:
            targets.add(tbl(t))
        if stmt.expression is None:          # bare DDL, no SELECT -> no edge
            return targets, set(), "ddl"
    elif isinstance(stmt, exp.Update):
        kind = "update"
        t = stmt.this if isinstance(stmt.this, exp.Table) else stmt.find(exp.Table)
        if t is not None:
            targets.add(tbl(t))
    elif isinstance(stmt, exp.Merge):
        kind = "merge"
        t = stmt.this if isinstance(stmt.this, exp.Table) else stmt.find(exp.Table)
        if t is not None:
            targets.add(tbl(t))
    elif isinstance(stmt, exp.Select) or stmt.find(exp.Select):
        kind = "select"
    else:
        return set(), set(), None            # truncate/delete/grant/etc.

    for t in stmt.find_all(exp.Table):
        n = tbl(t)
        if n and n not in ctes and n not in targets and n not in KEYWORDS:
            sources.add(n)
    return targets, sources, kind


def parse_sql_text(text: str, engine: str, coverage: list, origin: str):
    """Parse a blob of SQL (may contain vsql/psql meta commands).
    Returns list of dicts: {targets, sources, kind, out_file, in_file, line}."""
    results = []
    # -- handle meta commands (\o, \copy) by scanning lines ------------------
    out_redirect = None
    plain_lines = []
    for ln, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if s.startswith("\\o"):
            arg = s[2:].strip()
            out_redirect = norm_file(arg) if arg else None
            plain_lines.append(("__SPLIT__", ln, out_redirect))
            continue
        m = re.match(r"\\copy\s+\(", s, re.I)
        if m:  # \copy (select ...) to 'file'
            mt = re.search(r"\)\s+to\s+'([^']+)'", s, re.I)
            body = s[s.index("(") + 1: s.rindex(")")] if ")" in s else s
            results.append({"raw_sql": body, "line": ln,
                            "out_file": norm_file(mt.group(1)) if mt else None,
                            "in_file": None, "meta": "copy_to"})
            continue
        m = re.match(r"\\copy\s+([\w.\"]+)\s+(from|to)\s+'?([^\s']+)'?", s, re.I)
        if m:
            tblname, direction, fname = norm_table(m.group(1)), m.group(2).lower(), norm_file(m.group(3))
            if direction == "from":
                results.append({"targets": {tblname}, "sources": set(),
                                "kind": "copy_from", "in_file": fname,
                                "out_file": None, "line": ln})
            else:
                results.append({"targets": set(), "sources": {tblname},
                                "kind": "copy_to", "out_file": fname,
                                "in_file": None, "line": ln})
            continue
        if s.startswith("\\"):               # other meta: \a \pset \echo ...
            continue
        plain_lines.append((line, ln, out_redirect))

    # -- group plain SQL into statements split by ';' ------------------------
    segments, cur, cur_line, cur_out = [], [], None, None
    for line, ln, redirect in plain_lines:
        if line == "__SPLIT__":
            if cur and "".join(cur).strip():
                segments.append(("\n".join(cur), cur_line, cur_out))
                cur = []
            cur_out = redirect
            cur_line = None
            continue
        if cur_line is None:
            cur_line = ln
        cur.append(line)
    if cur and "".join(cur).strip():
        segments.append(("\n".join(cur), cur_line, cur_out))

    for seg_text, seg_line, seg_out in segments:
        for raw in split_sql(seg_text):
            if not raw.strip():
                continue
            results.append({"raw_sql": raw, "line": seg_line,
                            "out_file": seg_out, "in_file": None})

    # -- run sqlglot / fallback on raw sql -----------------------------------
    final = []
    for r in results:
        if "raw_sql" not in r:
            final.append(r)
            continue
        raw = r["raw_sql"]
        # lineage-irrelevant statements: don't parse, don't count as misses
        head = re.sub(r"(--[^\n]*\n|/\*.*?\*/|\s)+", " ", raw, flags=re.S).strip().lower()
        if not head or head.split(" ")[0] in (
                "drop", "truncate", "alter", "grant", "set", "call",
                "analyze", "vacuum", "optimize", "comment", "commit", "begin"):
            continue
        outfile = r.get("out_file")
        m = RE_OUTFILE.search(raw)
        if m:
            outfile = norm_file(m.group(1))
            raw = RE_OUTFILE.sub("", raw)
        targets, sources, kind, how = set(), set(), None, "sqlglot"
        try:
            for stmt in sqlglot.parse(raw, read=DIALECT[engine]):
                if stmt is None:
                    continue
                t, s, k = sql_statement_tables(stmt)
                targets |= t
                sources |= s
                kind = kind or k
        except Exception:
            how = "regex"
            for m2 in RE_FALLBACK_TARGET.finditer(raw):
                targets.add(norm_table(m2.group(1)))
                kind = kind or "regex_dml"
            for m2 in RE_FALLBACK_SRC.finditer(raw):
                n = norm_table(m2.group(1))
                if n not in targets and n not in KEYWORDS:
                    sources.add(n)
            if not targets and not sources:
                coverage.append({"origin": origin, "line": r.get("line"),
                                 "sql": raw[:200]})
        sources = {s for s in sources - KEYWORDS if len(s) > 2}
        targets = {t for t in targets if len(t) > 2}
        final.append({"targets": targets, "sources": sources, "kind": kind,
                      "out_file": outfile, "in_file": r.get("in_file"),
                      "line": r.get("line"), "how": how})
    return final


def split_sql(text: str):
    """Split SQL text on ';' outside quotes/comments."""
    out, buf, q = [], [], None
    i, n = 0, len(text)
    while i < n:
        ch = text[i]
        if q:
            buf.append(ch)
            if q == "--" and ch == "\n":
                q = None
            elif q == "/*" and ch == "/" and text[i - 1] == "*":
                q = None
            elif ch == q:
                q = None
            i += 1
            continue
        if ch in "'\"":
            q = ch
            buf.append(ch)
        elif ch == "-" and text[i:i + 2] == "--":
            q = "--"
            buf.append(ch)
        elif ch == "/" and text[i:i + 2] == "/*":
            q = "/*"
            buf.append(ch)
        elif ch == ";":
            out.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
        i += 1
    out.append("".join(buf))
    return out


# ------------------------------------------------------------------ graph ---
class Graph:
    def __init__(self, cfg):
        self.cfg = cfg
        self.nodes = {}                       # id -> node dict
        self.edges = {}                       # (src,dst,type) -> edge dict
        self.script_calls = []                # orchestration edges

    def table_node(self, engine, name):
        name = norm_table(name)
        nid = f"{engine}.{name}"
        self.nodes.setdefault(nid, {"id": nid, "name": name, "engine": engine,
                                    "kind": "table"})
        return nid

    def file_node(self, fname):
        fname = norm_file(fname)
        nid = f"file.{fname}"
        self.nodes.setdefault(nid, {"id": nid, "name": fname,
                                    "engine": "file", "kind": "file"})
        return nid

    def add_edge(self, src, dst, etype, script, sql_file=None, line=None):
        if src == dst:
            return
        key = (src, dst, etype)
        e = self.edges.get(key)
        prov = {"script": script, "sql_file": sql_file, "line": line}
        if e is None:
            self.edges[key] = {"src": src, "dst": dst, "type": etype,
                               "provenance": [prov]}
        elif len(e["provenance"]) < 5 and prov not in e["provenance"]:
            e["provenance"].append(prov)


def pipeline_of(path: Path, repo: Path) -> str:
    rel = path.relative_to(repo).parts
    if len(rel) >= 2 and rel[0] in ("bash", "vsql", "pgsql", "ch"):
        return rel[1] if len(rel) > 2 or rel[1] != path.name else rel[0]
    name = path.stem
    for p in ("daily", "weekly", "intraday", "nightly", "cyclic",
              "allocation", "fullload", "mfp"):
        if p in name.lower():
            return p
    return "other"


# ------------------------------------------------------------------- main ---
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=str(Path(__file__).resolve().parent.parent))
    ap.add_argument("--out", default=None)
    args = ap.parse_args()
    repo = Path(args.repo).resolve()
    outdir = Path(args.out) if args.out else repo / "lineage"
    outdir.mkdir(exist_ok=True)

    cfg = load_config(repo)
    g = Graph(cfg)
    unparsed = []
    stats = defaultdict(int)
    sql_engine_hint = {}                       # sql file -> engine (from caller)
    sql_callers = defaultdict(set)             # rel sql file -> {caller scripts}
    processed_sql = set()

    sh_files = [p for p in repo.rglob("*.sh") if not is_excluded(p, repo, cfg)]
    sql_files = [p for p in repo.rglob("*.sql") if not is_excluded(p, repo, cfg)]

    # -- pass 1: shell scripts ------------------------------------------------
    for sh in sorted(sh_files):
        rel_sh = sh.relative_to(repo).as_posix()
        pipeline = pipeline_of(sh, repo)
        try:
            text = sh.read_text(errors="replace")
        except Exception:
            continue
        for line_no, cmd in logical_commands(text):
            # orchestration: script -> script
            for m in RE_SH_CALL.finditer(cmd):
                callee = resolve_path(m.group(1), sh, repo)
                if callee and callee != sh and callee.suffix == ".sh":
                    g.script_calls.append(
                        {"src": rel_sh,
                         "dst": callee.relative_to(repo).as_posix(),
                         "line": line_no})
            for m in RE_PY_CALL.finditer(cmd):
                stats["python_calls"] += 1

            engine = next((e for c, e in ENGINE_CMDS.items()
                           if re.search(rf"\b{c}\b", cmd)), None)
            if not engine:
                continue
            stats["engine_commands"] += 1

            # referenced .sql files inherit engine, parsed in pass 2
            for m in RE_DASH_F.finditer(cmd):
                sqlp = resolve_path(m.group(1), sh, repo)
                if sqlp:
                    if sqlp not in sql_engine_hint:
                        sql_engine_hint[sqlp] = (engine, rel_sh, pipeline)
                    sql_callers[sqlp.relative_to(repo).as_posix()].add(rel_sh)
                else:
                    unparsed.append({"origin": rel_sh, "line": line_no,
                                     "sql": f"unresolved -f {m.group(1)}"})
            # clickhouse-client -mn < file.sql   (sql via stdin)
            mstdin = RE_STDIN.search(cmd)
            if mstdin and mstdin.group(1).endswith(".sql"):
                sqlp = resolve_path(mstdin.group(1), sh, repo)
                if sqlp:
                    if sqlp not in sql_engine_hint:
                        sql_engine_hint[sqlp] = (engine, rel_sh, pipeline)
                    sql_callers[sqlp.relative_to(repo).as_posix()].add(rel_sh)
                mstdin = None

            # inline SQL
            inline = None
            for rx in (RE_QUERY, RE_QUERY_SQ, RE_DASH_C, RE_DASH_C_SQ):
                m = rx.search(cmd)
                if m:
                    inline = m.group(1)
                    break
            out_f = RE_DASH_O.search(cmd)
            in_f = mstdin.group(1) if mstdin and not mstdin.group(1).endswith(".sql") else None

            if not inline:
                continue
            stats["inline_sql"] += 1
            for r in parse_sql_text(inline, engine, unparsed, rel_sh):
                emit(g, r, engine, rel_sh, None,
                     extra_out=norm_file(out_f.group(1)) if out_f else None,
                     extra_in=norm_file(in_f) if in_f else None)
                stats["statements"] += 1

    # -- pass 2: sql files ----------------------------------------------------
    for sqlp in sorted(sql_files):
        rel = sqlp.relative_to(repo).as_posix()
        if sqlp in sql_engine_hint:
            engine, caller, pipeline = sql_engine_hint[sqlp]
        else:
            top = sqlp.relative_to(repo).parts[0]
            engine = cfg["engine_dirs"].get(top)
            caller = None
            if engine is None:
                stats["sql_files_orphan"] += 1
                continue
        processed_sql.add(sqlp)
        stats["sql_files"] += 1
        try:
            text = sqlp.read_text(errors="replace")
        except Exception:
            continue
        for r in parse_sql_text(text, engine, unparsed, rel):
            emit(g, r, engine, caller, rel)
            stats["statements"] += 1

    # -- pass 3: table_mappings*.json  (inbound file -> vertica table) --------
    for tm in sorted(repo.glob("table_mappings*.json")):
        try:
            mapping = json.loads(tm.read_text())
        except Exception:
            continue
        for prefix, info in mapping.items():
            tbl = info.get("TableName") if isinstance(info, dict) else None
            if not tbl:
                continue
            f = g.file_node(prefix.lower().rstrip("_") + "_*.csv")
            g.nodes[f]["kind"] = "inbound_file"
            t = g.table_node("vertica", tbl)
            g.add_edge(f, t, "inbound_load", tm.name)
            stats["inbound_mappings"] += 1

    # -- pass 4: tag edges with the batch flow(s) that produce them -----------
    # Roots = orchestrators never called by another script (daily.sh,
    # weekly.sh, intraday.sh, ...). Flow membership = reachability through
    # the script call graph. database_changes/ is already excluded
    # (Liquibase DDL deployment, not batch flow).
    callees = defaultdict(set)
    called = set()
    for c in g.script_calls:
        callees[c["src"]].add(c["dst"])
        called.add(c["dst"])
    all_scripts = set(callees) | called
    roots = [s for s in all_scripts if s not in called and "/" not in s]
    script_flows = defaultdict(set)
    for root in roots:
        flow = Path(root).stem
        stack = [root]
        seen_s = set()
        while stack:
            cur = stack.pop()
            if cur in seen_s:
                continue
            seen_s.add(cur)
            script_flows[cur].add(flow)
            stack.extend(callees.get(cur, ()))
    def flows_of_script(s):
        if s in script_flows:
            return set(script_flows[s])
        if s.startswith("table_mappings"):     # inbound mapping json
            suffix = Path(s).stem.replace("table_mappings", "").strip("_")
            return {suffix or "weekly"}
        return {Path(s).stem}

    for e in g.edges.values():
        flows = set()
        for p in e["provenance"]:
            s, f = p.get("script"), p.get("sql_file")
            if f and sql_callers.get(f):       # all scripts that run this sql
                for c in sql_callers[f]:
                    flows |= flows_of_script(c)
            elif s:
                flows |= flows_of_script(s)
            elif f:
                parts = Path(f).parts
                if len(parts) >= 2:
                    flows.add(parts[1])
        if flows:
            e["flows"] = sorted(flows)

    # -- write outputs ---------------------------------------------------------
    graph = {
        "meta": {
            "generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "repo": repo.name,
            "client_prefix": cfg["client_prefix"],
            "stats": dict(stats),
            "node_count": len(g.nodes),
            "edge_count": len(g.edges),
        },
        "nodes": sorted(g.nodes.values(), key=lambda n: n["id"]),
        "edges": sorted(g.edges.values(), key=lambda e: (e["src"], e["dst"])),
        "script_calls": g.script_calls,
    }
    (outdir / "graph.json").write_text(json.dumps(graph, indent=1))

    total = stats["statements"] or 1
    coverage = {
        "generated_at": graph["meta"]["generated_at"],
        "statements_total": stats["statements"],
        "statements_unparsed": len(unparsed),
        "parse_rate_pct": round(100 * (1 - len(unparsed) / total), 1),
        "unparsed": unparsed[:200],
    }
    (outdir / "coverage.json").write_text(json.dumps(coverage, indent=1))

    # self-contained interactive viewer (embeds graph.json)
    tpl = Path(__file__).parent / "viewer_template.html"
    if tpl.exists():
        html = tpl.read_text().replace(
            "/*__GRAPH_JSON__*/",
            json.dumps(graph).replace("</", "<\\/"))
        (outdir / "lineage.html").write_text(html)

    print(f"nodes={len(g.nodes)}  edges={len(g.edges)}  "
          f"statements={stats['statements']}  unparsed={len(unparsed)}  "
          f"parse_rate={coverage['parse_rate_pct']}%")
    print(f"wrote {outdir/'graph.json'} and {outdir/'coverage.json'}")


def emit(g: Graph, r: dict, engine: str, script, sql_file,
         extra_out=None, extra_in=None):
    """Turn one parsed statement record into graph edges."""
    targets = {t for t in r.get("targets", set()) if t}
    sources = {s for s in r.get("sources", set()) if s}
    out_file = r.get("out_file") or extra_out
    in_file = r.get("in_file") or extra_in
    line = r.get("line")
    kind = r.get("kind") or "sql"

    tnodes = [g.table_node(engine, t) for t in targets]
    snodes = [g.table_node(engine, s) for s in sources]

    # table -> table (same engine)
    for t in tnodes:
        for s in snodes:
            g.add_edge(s, t, kind, script, sql_file, line)

    # sources/select -> output file  (export)
    if out_file:
        f = g.file_node(out_file)
        for s in snodes:
            g.add_edge(s, f, "export", script, sql_file, line)

    # input file -> targets  (load)
    if in_file:
        f = g.file_node(in_file)
        for t in tnodes:
            g.add_edge(f, t, "load", script, sql_file, line)


if __name__ == "__main__":
    main()
