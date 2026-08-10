#!/usr/bin/env python3
"""
Query the lineage graph from the terminal (or from Claude via the
impact-analysis skill).

Usage:
  python3 lineage/query.py find <text>                 fuzzy-find nodes
  python3 lineage/query.py upstream <node> [-d N]      what feeds it
  python3 lineage/query.py downstream <node> [-d N]    what it feeds (blast radius)
  python3 lineage/query.py impact <node>               full downstream + scripts to review
  python3 lineage/query.py path <src> <dst>            how data flows between two nodes
  python3 lineage/query.py stats                       graph summary + coverage

<node> can be a bare table name (trd_eohdata_stylecolor), an id
(vertica.trd_eohdata_stylecolor), or a file (trd_h_prodstd.csv).
"""
import argparse
import json
import sys
from collections import defaultdict, deque
from pathlib import Path

HERE = Path(__file__).resolve().parent
HUB = HERE.parent.parent   # support-copilot/


def resolve_graph():
    """Pick the lineage graph, richest first, per-customer.
    Priority: $LINEAGE_GRAPH → customers/$LINEAGE_CLIENT/lineage/unified →
    combined → graph.json → tooling/lineage/graph.json (ETL-only fallback)."""
    import os
    if os.environ.get("LINEAGE_GRAPH"):
        return Path(os.environ["LINEAGE_GRAPH"])
    client = os.environ.get("LINEAGE_CLIENT", "TRD")
    base = HUB / "customers" / client / "lineage"
    for name in ("unified_graph.json", "combined_graph.json", "graph.json"):
        f = base / name
        if f.exists():
            return f
    return HERE / "graph.json"


def load():
    f = resolve_graph()
    if not f.exists():
        sys.exit(f"no lineage graph found ({f}) — run the extractor/merge first")
    return json.loads(f.read_text())


def build_adj(g):
    out_adj, in_adj = defaultdict(list), defaultdict(list)
    for e in g["edges"]:
        out_adj[e["src"]].append(e)
        in_adj[e["dst"]].append(e)
    return out_adj, in_adj


def resolve(g, name):
    name = name.lower().strip()
    ids = [n["id"] for n in g["nodes"]]
    if name in ids:
        return [name]
    exact = [i for i in ids if i.split(".", 1)[1] == name]
    if exact:
        return exact
    part = [i for i in ids if name in i]
    return part


def fmt(g, nid):
    n = next((x for x in g["nodes"] if x["id"] == nid), None)
    return f"{nid}" + (f"  [{n['kind']}]" if n and n["kind"] != "table" else "")


def walk(adj, roots, key, depth):
    seen = {r: 0 for r in roots}
    q = deque(roots)
    hops = []
    while q:
        cur = q.popleft()
        d = seen[cur]
        if d >= depth:
            continue
        for e in adj[cur]:
            nxt = e[key]
            hops.append((d + 1, cur, e))
            if nxt not in seen:
                seen[nxt] = d + 1
                q.append(nxt)
    return seen, hops


def prov_str(e):
    p = (e.get("provenance") or [{}])[0]
    src = p.get("sql_file") or p.get("script") or "?"
    return f"{src}" + (f":{p['line']}" if p.get("line") else "")


def cmd_find(g, args):
    hits = resolve(g, args.text)
    for h in hits[:40]:
        print(fmt(g, h))
    if not hits:
        print("no match")


def direction(g, args, up):
    out_adj, in_adj = build_adj(g)
    roots = resolve(g, args.node)
    if not roots:
        sys.exit(f"no node matches '{args.node}'")
    if len(roots) > 1 and not args.all:
        print(f"'{args.node}' is ambiguous ({len(roots)} matches) — "
              "pick one, or pass --all:")
        for r in roots[:15]:
            print("  " + r)
        return
    adj, key = (in_adj, "src") if up else (out_adj, "dst")
    seen, hops = walk(adj, roots, key, args.depth)
    label = "upstream of" if up else "downstream of"
    print(f"{label} {', '.join(roots)}  (depth {args.depth}):\n")
    by_depth = defaultdict(set)
    for nid, d in seen.items():
        if d > 0:
            by_depth[d].add(nid)
    if not by_depth:
        print("  none")
    for d in sorted(by_depth):
        print(f"  -- {d} hop{'s' if d > 1 else ''} --")
        for nid in sorted(by_depth[d]):
            edge = next(e for dd, c, e in hops if e[key] == nid and dd == d)
            print(f"  {fmt(g, nid):55s} via {edge['type']:14s} {prov_str(edge)}")


def cmd_impact(g, args):
    out_adj, _ = build_adj(g)
    roots = resolve(g, args.node)
    if not roots:
        sys.exit(f"no node matches '{args.node}'")
    seen, hops = walk(out_adj, roots, "dst", 99)
    affected = {n for n, d in seen.items() if d > 0}
    scripts = set()
    for _, _, e in hops:
        for p in e.get("provenance", []):
            scripts.add(p.get("sql_file") or p.get("script"))
    engines = defaultdict(list)
    for n in affected:
        engines[n.split(".", 1)[0]].append(n)
    flows = set()
    for _, _, e in hops:
        flows |= set(e.get("flows", []))
    print(f"IMPACT if you change {', '.join(roots)}:")
    print(f"  {len(affected)} downstream nodes across "
          f"{len([e for e in engines if e != 'file'])} engines")
    if flows:
        print(f"  batch flows involved: {', '.join(sorted(flows))}")
    print()
    for eng in ("vertica", "postgres", "clickhouse", "file"):
        if engines.get(eng):
            print(f"  {eng} ({len(engines[eng])}):")
            for n in sorted(engines[eng]):
                print(f"    {n.split('.',1)[1]}")
    print(f"\n  scripts/SQL to review ({len(scripts)}):")
    for s in sorted(x for x in scripts if x):
        print(f"    {s}")


def cmd_path(g, args):
    out_adj, _ = build_adj(g)
    srcs, dsts = resolve(g, args.src), resolve(g, args.dst)
    if not srcs or not dsts:
        sys.exit("src or dst not found")
    src, dst = srcs[0], dsts[0]
    prev = {src: None}
    q = deque([src])
    while q:
        cur = q.popleft()
        if cur == dst:
            break
        for e in out_adj[cur]:
            if e["dst"] not in prev:
                prev[e["dst"]] = (cur, e)
                q.append(e["dst"])
    if dst not in prev:
        print(f"no path {src} -> {dst}")
        return
    chain = []
    cur = dst
    while prev[cur]:
        parent, e = prev[cur]
        chain.append((parent, e, cur))
        cur = parent
    print(f"path {src} -> {dst}:")
    for parent, e, child in reversed(chain):
        print(f"  {parent}  --{e['type']}-->  {child}    ({prov_str(e)})")


def cmd_stats(g, args):
    from collections import Counter
    m = g.get("meta", {})
    print(f"graph: {resolve_graph()}")
    print(f"repo={m.get('repo','?')}  generated={m.get('generated_at','?')}")
    print(f"nodes={m.get('node_count', len(g.get('nodes',[])))}  "
          f"edges={m.get('edge_count', len(g.get('edges',[])))}")
    kinds = Counter(n.get('kind','?') for n in g.get('nodes', []))
    print("node kinds:", dict(kinds))
    for k, v in sorted((m.get("stats") or {}).items()):
        print(f"  {k}: {v}")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("find");        p.add_argument("text")
    for name in ("upstream", "downstream"):
        p = sub.add_parser(name)
        p.add_argument("node")
        p.add_argument("-d", "--depth", type=int, default=3)
        p.add_argument("--all", action="store_true")
    p = sub.add_parser("impact");      p.add_argument("node")
    p = sub.add_parser("path")
    p.add_argument("src"); p.add_argument("dst")
    sub.add_parser("stats")
    args = ap.parse_args()

    g = load()
    if args.cmd == "find":       cmd_find(g, args)
    elif args.cmd == "upstream":   direction(g, args, up=True)
    elif args.cmd == "downstream": direction(g, args, up=False)
    elif args.cmd == "impact":     cmd_impact(g, args)
    elif args.cmd == "path":       cmd_path(g, args)
    elif args.cmd == "stats":      cmd_stats(g, args)


if __name__ == "__main__":
    main()
