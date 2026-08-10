#!/usr/bin/env python3
"""
Phase P2 — fold the pivot temp-table DAG into the combined ETL+config graph.

Produces one end-to-end graph:
  inbound file → ETL → CH base table → pivot temp chain → pivot → model → screen

Join keys (both already present in the combined graph):
  - pivot.* nodes  → each pivot's temp DAG hangs off its existing pivot node
  - clickhouse.*   → temp-DAG roots connect to ETL-produced CH tables

Normalization: `_tbl` (local) vs wrapper collapse — same as merge_graphs.py.
CH base tables the pivot extractor found that the combined graph lacked are
ADDED as roots (the pivot extractor has deeper CH coverage than the original
config extractor).

Usage:
  python3 merge_pivot.py --combined <combined_graph.json> --pivot <pivot_graph.json> --out <unified.json>
"""
import argparse, json, time
from pathlib import Path

CLIENT = 'trd'  # set via --client

def norm(nid):
    """Unify CH node identity across the ETL and pivot extractors:
    strip the tenant prefix (clickhouse.trd_x -> clickhouse.x) and the
    `_tbl` local-table suffix (clickhouse.x_tbl -> clickhouse.x). The ETL
    graph keeps `trd_`; the pivot extractor strips it — this reconciles them."""
    if nid.startswith('clickhouse.'):
        body = nid[len('clickhouse.'):]
        if body.startswith(CLIENT + '_'):
            body = body[len(CLIENT) + 1:]
        if body.endswith('_tbl'):
            body = body[:-4]
        return 'clickhouse.' + body
    return nid

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--combined', required=True)
    ap.add_argument('--pivot', required=True)
    ap.add_argument('--out', required=True)
    a = ap.parse_args()
    cg = json.loads(Path(a.combined).read_text())
    pv = json.loads(Path(a.pivot).read_text())

    nodes = {}
    for n in cg['nodes']:
        nid = norm(n['id']); n = dict(n, id=nid); nodes.setdefault(nid, n)
    edges = {}
    def add_edge(e, origin):
        s, d = norm(e['src']), norm(e['dst'])
        if s == d: return
        # keep pivot scope in the key so per-pivot temp DAGs stay distinct
        key = (s, d, e['type'], e.get('pivot'))
        if key not in edges:
            edges[key] = dict(src=s, dst=d, type=e['type'], origin=origin,
                              pivot=e.get('pivot'),
                              dynamic=e.get('dynamic', False),
                              conditional=e.get('conditional', False),
                              provenance=e.get('provenance', [])[:3])
    for e in cg['edges']:
        add_edge(e, 'combined')

    # fold pivot graph
    joined_pivots = added_ch = added_temp = 0
    for n in pv['nodes']:
        nid = norm(n['id'])
        if nid in nodes:
            if n['kind'] == 'pivot': joined_pivots += 1
            continue
        nodes[nid] = dict(n, id=nid)
        if n['kind'] == 'table': added_ch += 1
        elif n['kind'] == 'pivot_temp': added_temp += 1
    for e in pv['edges']:
        add_edge(e, 'pivot')

    unified = dict(
        meta=dict(generated_at=time.strftime('%Y-%m-%d %H:%M:%S'),
                  sources=[Path(a.combined).name, Path(a.pivot).name],
                  node_count=len(nodes), edge_count=len(edges),
                  folded=dict(pivots_joined=joined_pivots,
                              ch_roots_added=added_ch, temp_nodes_added=added_temp)),
        nodes=sorted(nodes.values(), key=lambda n: n['id']),
        edges=sorted(edges.values(), key=lambda e: (e['src'], e['dst'])))
    Path(a.out).write_text(json.dumps(unified, indent=1))
    print(f"unified: nodes={len(nodes)} edges={len(edges)} | "
          f"pivots joined={joined_pivots} ch-roots added={added_ch} "
          f"temp nodes added={added_temp}")
    print(f"wrote {a.out}")

if __name__ == '__main__':
    main()
