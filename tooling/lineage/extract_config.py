#!/usr/bin/env python3
"""
Config-layer lineage extractor (trd-configs).

Builds the screen-side half of end-to-end lineage:

    clickhouse table -> pivot -> model -> screen (tab/section/view)
                                    viewdefn -> screen

Sources parsed:
  uidefn/conf/*.confdefn   app shell: tabs/sections/views wiring model+views
  uidefn/model/*.modeldefn model -> pivotDefn binding (filename = identity;
                           internal ids are unreliable copy-paste)
  uidefn/view/*.viewdefn   presentation defns (metric columns recorded)
  pivot/*.pivotdefn        FreeMarker-templated CH SQL; <#include> closure
                           resolved against pivot/include/*.ftl
  Session temp tables (X_${SESSION_ID}) are pivot-internal — the pivot is
  linked to the union of real tables in its include closure.

Outputs:  lineage/config_graph.json, lineage/config_coverage.json

Usage:    python3 lineage/extract_config.py [--repo PATH]
"""
import argparse
import json
import re
import sys
import time
from collections import defaultdict
from pathlib import Path

# ---------------------------------------------------------------- helpers ---
COMMENT_RE = re.compile(r"^\s*//.*$", re.M)
TRAILING_COMMA_RE = re.compile(r",(\s*[}\]])")


def load_jsonish(path: Path):
    """confdefn/viewdefn/modeldefn are JSON, occasionally with // comments
    or trailing commas."""
    text = path.read_text(errors="replace")
    for attempt in (text,
                    COMMENT_RE.sub("", text),
                    TRAILING_COMMA_RE.sub(r"\1", COMMENT_RE.sub("", text))):
        try:
            return json.loads(attempt)
        except json.JSONDecodeError:
            continue
    return None


INCLUDE_RE = re.compile(r'<#include\s+"([^"]+)"')
FROM_RE = re.compile(r"\b(?:from|join)\s+([A-Za-z_$][A-Za-z0-9_.${}]*)", re.I)
CREATE_RE = re.compile(
    r"\bcreate\s+(?:temporary\s+)?table\s+(?:if\s+not\s+exists\s+)?"
    r"([A-Za-z_$][A-Za-z0-9_.${}]*)", re.I)
CTE_RE = re.compile(r"\b(?:with\s+)?([A-Za-z_][A-Za-z0-9_]*)\s+as\s*\(", re.I)
VAR_RE = re.compile(r"\$\{([A-Za-z_]+)\}")
NOT_TABLES = {"seq", "select", "numbers", "system", "values", "final", "dual",
              "if"}


def norm_ref(raw: str, client: str):
    """Normalize a templated table ref to a stable name, or None to skip.
    ${TENANT_ID}_x -> trd_x ; x_${SESSION_ID} -> x ; ${SOME_VAR} alone -> None
    """
    name = raw.strip().rstrip(";,)")
    name = re.sub(r"^\$\{TENANT_ID\}_?", client + "_", name, flags=re.I)
    name = VAR_RE.sub("\0", name)             # remaining vars -> marker
    name = name.replace("\0", "").strip("_").lower()
    name = name.split(".")[-1]
    if (not name or name in NOT_TABLES or len(name) <= 2
            or not re.fullmatch(r"[a-z_][a-z0-9_]*", name)):
        return None
    return name


def real_tables(text: str, client: str):
    """External table dependencies of templated SQL: all FROM/JOIN refs
    minus tables the SQL itself CREATEs minus CTE aliases."""
    created = {norm_ref(m.group(1), client) for m in CREATE_RE.finditer(text)}
    ctes = {m.group(1).lower() for m in CTE_RE.finditer(text)}
    out = set()
    for m in FROM_RE.finditer(text):
        name = norm_ref(m.group(1), client)
        if name and name not in created and name not in ctes:
            out.add(name)
    return out


# ------------------------------------------------------------------ graph ---
class G:
    def __init__(self):
        self.nodes, self.edges = {}, {}

    def node(self, kind, name, **meta):
        nid = f"{kind}.{name}"
        if nid not in self.nodes:
            self.nodes[nid] = {"id": nid, "name": name, "engine": kind,
                               "kind": kind, **meta}
        return nid

    def edge(self, src, dst, etype, prov=None):
        key = (src, dst, etype)
        if key not in self.edges:
            self.edges[key] = {"src": src, "dst": dst, "type": etype,
                               "provenance": [{"script": prov}] if prov else []}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=str(Path(__file__).resolve().parent.parent))
    ap.add_argument("--client", default="trd",
                    help="tenant prefix substituted for ${TENANT_ID}")
    args = ap.parse_args()
    repo = Path(args.repo).resolve()
    out = repo / "lineage"
    out.mkdir(exist_ok=True)

    g = G()
    problems = []
    stats = defaultdict(int)

    # ---- pivots: include closure -> CH tables -----------------------------
    include_dir = repo / "pivot" / "include"
    ftl_cache = {}

    def closure_text(path: Path, seen):
        if path in seen:
            return ""
        seen.add(path)
        if path in ftl_cache:
            base = ftl_cache[path]
        else:
            base = path.read_text(errors="replace") if path.exists() else ""
            ftl_cache[path] = base
            if not base and path.suffix:
                problems.append({"kind": "missing_include", "ref": str(path)})
        text = base
        for m in INCLUDE_RE.finditer(base):
            inc = include_dir / m.group(1)
            if not inc.exists():
                inc = path.parent / m.group(1)
            text += "\n" + closure_text(inc, seen)
        return text

    pivots = {}
    for p in sorted((repo / "pivot").glob("*.pivotdefn")):
        stats["pivotdefn"] += 1
        name = p.stem
        text = closure_text(p, set())
        tables = real_tables(text, args.client)
        pivots[name] = tables
        pn = g.node("pivot", name)
        for t in tables:
            tn = g.node("clickhouse", t)
            g.edge(tn, pn, "queried_by", f"pivot/{p.name}")

    # ---- models: filename -> pivotDefn ------------------------------------
    models = {}
    for p in sorted((repo / "uidefn" / "model").glob("*.modeldefn")):
        stats["modeldefn"] += 1
        d = load_jsonish(p)
        if d is None:
            problems.append({"kind": "unparsed_model", "ref": p.name})
            continue
        name = p.stem
        pivot = d.get("pivotDefn")
        models[name] = pivot
        mn = g.node("model", name)
        if pivot:
            if pivot in pivots:
                g.edge(f"pivot.{pivot}", mn, "feeds", f"uidefn/model/{p.name}")
            else:
                problems.append({"kind": "missing_pivot", "ref": p.name,
                                 "pivot": pivot})
        if d.get("id") and d["id"] != name:
            stats["id_filename_mismatch"] += 1

    # ---- views: record metric columns -------------------------------------
    views = {}
    for p in sorted((repo / "uidefn" / "view").glob("*.viewdefn")):
        stats["viewdefn"] += 1
        d = load_jsonish(p)
        if d is None:
            problems.append({"kind": "unparsed_view", "ref": p.name})
            continue
        cols = []
        def walk(x):
            if isinstance(x, dict):
                if "dataIndex" in x:
                    cols.append({"dataIndex": x.get("dataIndex"),
                                 "text": x.get("text"),
                                 "formula": x.get("formula")})
                for v in x.values():
                    walk(v)
            elif isinstance(x, list):
                for v in x:
                    walk(v)
        walk(d)
        views[p.stem] = cols
        g.node("view", p.stem, columns=len(cols))

    # ---- confdefns: screens wiring ----------------------------------------
    for p in sorted((repo / "uidefn" / "conf").glob("*.confdefn")):
        stats["confdefn"] += 1
        d = load_jsonish(p)
        if d is None:
            problems.append({"kind": "unparsed_conf", "ref": p.name})
            continue
        conf_id = d.get("id", p.stem)

        def walk_conf(x, path):
            if isinstance(x, dict):
                nid = x.get("id")
                here = path + [nid] if isinstance(nid, str) else path
                props = x.get("componentProps") or {}
                defns = props.get("defns")
                if isinstance(defns, dict):
                    screen = "/".join([conf_id] + [s for s in here if s])
                    sn = g.node("screen", screen,
                                title=props.get("title"),
                                conf=p.name)
                    model = defns.get("model")
                    if model:
                        if model in models:
                            g.edge(f"model.{model}", sn, "feeds",
                                   f"uidefn/conf/{p.name}")
                        else:
                            problems.append({"kind": "missing_model",
                                             "ref": screen, "model": model})
                    vlist = defns.get("view") or []
                    sub = defns.get("subheader") or {}
                    for v in list(vlist) + [sub.get("groupBy"), sub.get("sortBy")]:
                        if not v:
                            continue
                        if v in views:
                            g.edge(f"view.{v}", sn, "presents",
                                   f"uidefn/conf/{p.name}")
                        else:
                            problems.append({"kind": "missing_view",
                                             "ref": screen, "view": v})
                for val in x.values():
                    walk_conf(val, here)
            elif isinstance(x, list):
                for v in x:
                    walk_conf(v, path)

        walk_conf(d, [])

    # ---- write -------------------------------------------------------------
    screens = [n for n in g.nodes.values() if n["engine"] == "screen"]
    graph = {
        "meta": {"generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                 "repo": repo.name, "stats": dict(stats),
                 "node_count": len(g.nodes), "edge_count": len(g.edges),
                 "screens": len(screens)},
        "nodes": sorted(g.nodes.values(), key=lambda n: n["id"]),
        "edges": sorted(g.edges.values(), key=lambda e: (e["src"], e["dst"])),
    }
    (out / "config_graph.json").write_text(json.dumps(graph, indent=1))

    cov = {"generated_at": graph["meta"]["generated_at"],
           "files": dict(stats), "problem_count": len(problems),
           "problems": problems[:300]}
    (out / "config_coverage.json").write_text(json.dumps(cov, indent=1))

    print(f"nodes={len(g.nodes)} edges={len(g.edges)} screens={len(screens)} "
          f"problems={len(problems)}")


if __name__ == "__main__":
    main()
