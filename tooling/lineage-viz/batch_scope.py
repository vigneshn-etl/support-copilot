#!/usr/bin/env python3
"""
Batch script lineage — walk each batch's main orchestrator (.sh) and build the
execution DAG: ordered .sh -> .sh calls and .sh -> .sql "runs" edges (with the
engine), plus which scripts/SQL each batch actually reaches.

This gives:
  * a script-level view per batch (daily / weekly / intraday / ...)
  * TRUE orchestrator-rooted batch membership (replaces the extractor's
    directory-derived `flows`)

    python3 batch_scope.py --db <lineage.db> --repo <repo> --registry registry/customers.json --customer TRD

New SQLite tables written:
  exec_node(path, kind, engine)                  -- kind: shell | sql
  exec_edge(batch, caller, callee, kind, ord)    -- kind: calls | runs_sql
  batch_membership(batch, sql_file)              -- sql reached by a batch
"""
from __future__ import annotations

import argparse
import json
import re
import sqlite3
from pathlib import Path

# a token ending in .sh, optional $VAR/ or ./ prefix
RE_SH = re.compile(r'(?:^|[\s"\'])((?:\$\{?[A-Za-z_]+\}?/)?[\w./-]+\.sh)\b')
# a .sql run via -f file.sql  or  < file.sql (covers -mn < x.sql)
RE_SQL_F = re.compile(r'-f\s+"?((?:\$\{?[A-Za-z_]+\}?/)?[\w./-]+\.sql)"?')
RE_SQL_IN = re.compile(r'<\s*"?((?:\$\{?[A-Za-z_]+\}?/)?[\w./-]+\.sql)"?')
ENGINE_CMD = {"vsql": "vertica", "psql": "postgres", "clickhouse-client": "clickhouse"}
ENGINE_DIR = {"vsql": "vertica", "pgsql": "postgres", "ch": "clickhouse"}

SCHEMA = """
CREATE TABLE IF NOT EXISTS exec_node (path TEXT PRIMARY KEY, kind TEXT, engine TEXT);
CREATE TABLE IF NOT EXISTS exec_edge (
  batch TEXT, caller TEXT, callee TEXT, kind TEXT, ord INTEGER,
  PRIMARY KEY (batch, caller, callee, kind));
CREATE TABLE IF NOT EXISTS batch_membership (
  batch TEXT, sql_file TEXT, PRIMARY KEY (batch, sql_file));
CREATE INDEX IF NOT EXISTS idx_exec_edge_batch ON exec_edge(batch);
"""


def strip_var(p: str) -> str:
    return re.sub(r"\$\{?[A-Za-z_]+\}?/?", "", p).lstrip("./").strip("'\"")


def resolve(raw: str, repo: Path) -> str | None:
    rel = strip_var(raw)
    if (repo / rel).is_file():
        return rel
    hits = [p for p in repo.rglob(Path(rel).name) if p.is_file()
            and "deprecated" not in str(p).lower()]
    return hits[0].relative_to(repo).as_posix() if len(hits) == 1 else None


def engine_for_sql(line: str, sql_rel: str) -> str:
    for cmd, eng in ENGINE_CMD.items():
        if cmd in line:
            return eng
    for part in sql_rel.split("/"):
        if part in ENGINE_DIR:
            return ENGINE_DIR[part]
    return "unknown"


def walk(main_rel: str, repo: Path):
    """DFS from the main script; return (nodes, edges) for this batch."""
    nodes: dict[str, tuple[str, str | None]] = {}   # path -> (kind, engine)
    edges: list[tuple[str, str, str, int]] = []      # caller, callee, kind, ord
    seen: set[str] = set()

    def visit(script_rel: str):
        if script_rel in seen:
            return
        seen.add(script_rel)
        nodes.setdefault(script_rel, ("shell", None))
        text = (repo / script_rel).read_text(errors="ignore")
        for ln, line in enumerate(text.splitlines(), 1):
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            # .sql runs
            for rx in (RE_SQL_F, RE_SQL_IN):
                for m in rx.finditer(line):
                    sql_rel = resolve(m.group(1), repo)
                    if sql_rel and sql_rel.endswith(".sql"):
                        eng = engine_for_sql(line, sql_rel)
                        nodes.setdefault(sql_rel, ("sql", eng))
                        edges.append((script_rel, sql_rel, "runs_sql", ln))
            # .sh invocations: distinguish `source`/`.` (env/setup) from real calls
            is_source = bool(re.match(r"(source|\.)\s", s))
            for m in RE_SH.finditer(line):
                callee = resolve(m.group(1), repo)
                if callee and callee.endswith(".sh") and callee != script_rel:
                    edges.append((script_rel, callee, "source" if is_source else "calls", ln))
                    visit(callee)
    if not (repo / main_rel).is_file():
        return nodes, edges, False
    visit(main_rel)
    return nodes, edges, True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True, type=Path)
    ap.add_argument("--repo", required=True, type=Path)
    ap.add_argument("--registry", required=True, type=Path)
    ap.add_argument("--customer", required=True)
    a = ap.parse_args()

    reg = json.loads(a.registry.read_text())
    cust = next(c for c in reg["customers"] if c["id"] == a.customer)
    repo = a.repo.resolve()

    con = sqlite3.connect(a.db)
    con.executescript(SCHEMA)
    con.execute("DELETE FROM exec_edge"); con.execute("DELETE FROM exec_node")
    con.execute("DELETE FROM batch_membership")

    summary = []
    for batch, cfg in cust.get("batches", {}).items():
        main_rel = cfg["main_script"]
        nodes, edges, ok = walk(main_rel, repo)
        if not ok:
            summary.append((batch, main_rel, "MISSING", 0, 0, 0))
            continue
        for path, (kind, eng) in nodes.items():
            con.execute("INSERT OR REPLACE INTO exec_node(path,kind,engine) VALUES(?,?,?)",
                        (path, kind, eng))
        for caller, callee, kind, ordn in edges:
            con.execute("INSERT OR IGNORE INTO exec_edge(batch,caller,callee,kind,ord) VALUES(?,?,?,?,?)",
                        (batch, caller, callee, kind, ordn))
        sqls = {p for p, (k, _) in nodes.items() if k == "sql"}
        for sq in sqls:
            con.execute("INSERT OR IGNORE INTO batch_membership(batch,sql_file) VALUES(?,?)",
                        (batch, sq))
        n_sh = sum(1 for _, (k, _) in nodes.items() if k == "shell")
        summary.append((batch, main_rel, "ok", n_sh, len(sqls), len(edges)))
    con.commit(); con.close()

    print(f"{'batch':12} {'main':28} {'status':8} {'scripts':>8} {'sql':>5} {'edges':>6}")
    for b, m, st, sh, sq, e in summary:
        print(f"{b:12} {m:28} {st:8} {sh:>8} {sq:>5} {e:>6}")


if __name__ == "__main__":
    main()
