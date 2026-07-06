#!/usr/bin/env python3
"""
Merge the ETL lineage graph (etl-trd-batch/lineage/graph.json) with the
config-layer graph (trd-configs/lineage/config_graph.json) into ONE
end-to-end graph:

    inbound file -> vertica -> file -> postgres/clickhouse -> pivot
                 -> model -> screen

Join key: normalized ClickHouse table names. ETL session tables
(*_casessionid12345) and config references to the same tables are
normalized by stripping the session suffix.

Usage:
  python3 lineage/merge_graphs.py --etl-graph <path-to-etl graph.json>
Outputs:
  lineage/combined_graph.json, lineage/lineage_e2e.html (if template found)
"""
import argparse
import json
import re
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
SESSION_SUF = re.compile(r"_casessionid\d+$", re.I)


def norm(nid: str) -> str:
    kind, _, name = nid.partition(".")
    if kind == "clickhouse":
        name = SESSION_SUF.sub("", name.lower())
        # ETL loads local `x_tbl`; pivots read the distributed/view wrapper
        # `x` (DDL lives in migrations, outside both graphs). Same logical
        # table -> merge the two names.
        if name.endswith("_tbl"):
            name = name[:-4]
    return f"{kind}.{name}"


def load(p):
    return json.loads(Path(p).read_text())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--etl-graph", required=True)
    ap.add_argument("--config-graph", default=str(HERE / "config_graph.json"))
    args = ap.parse_args()

    etl, cfg = load(args.etl_graph), load(args.config_graph)

    nodes, edges = {}, {}
    for src_graph, origin in ((etl, "etl"), (cfg, "config")):
        for n in src_graph["nodes"]:
            nid = norm(n["id"])
            if nid not in nodes:
                m = dict(n)
                m["id"] = nid
                m["name"] = nid.split(".", 1)[1]
                m["origin"] = origin
                nodes[nid] = m
            else:
                nodes[nid]["origin"] = "both"
        for e in src_graph["edges"]:
            key = (norm(e["src"]), norm(e["dst"]), e["type"])
            if key[0] == key[1]:
                continue
            if key not in edges:
                edges[key] = {"src": key[0], "dst": key[1], "type": e["type"],
                              "provenance": e.get("provenance", [])[:3]}

    joined = sum(1 for n in nodes.values() if n.get("origin") == "both")
    graph = {
        "meta": {"generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                 "repo": "etl-trd-batch + trd-configs",
                 "node_count": len(nodes), "edge_count": len(edges),
                 "join_nodes": joined,
                 "stats": {"etl_nodes": len(etl["nodes"]),
                           "config_nodes": len(cfg["nodes"]),
                           "joined_ch_tables": joined}},
        "nodes": sorted(nodes.values(), key=lambda n: n["id"]),
        "edges": sorted(edges.values(), key=lambda e: (e["src"], e["dst"])),
    }
    out = HERE / "combined_graph.json"
    out.write_text(json.dumps(graph, indent=1))
    print(f"combined: nodes={len(nodes)} edges={len(edges)} "
          f"joined_ch_tables={joined}")

    tpl = HERE / "viewer_template_e2e.html"
    if tpl.exists():
        html = tpl.read_text().replace("/*__GRAPH_JSON__*/",
                                       json.dumps(graph).replace("</", "<\\/"))
        (HERE / "lineage_e2e.html").write_text(html)
        print(f"wrote {HERE/'lineage_e2e.html'}")


if __name__ == "__main__":
    main()
