#!/usr/bin/env python3
"""
Query the pivot lineage graph (pivot_graph.json).

Answers the triage questions the pivot DAG exists for:
  pivots [text]              list pivots (optionally filter by name)
  show <Pivot>              the pivot's intra-temp DAG summary (roots, temps, output)
  upstream <Pivot> <temp>   what feeds a temp table (walk to base tables)
  downstream <Pivot> <temp> what a temp feeds (impact within the pivot)
  find <temp-substring>     which pivots build a temp matching this name
  roots <Pivot>            the real CH base tables + scope this pivot reads

<Pivot> = pivotdefn stem (e.g. AssortmentFitStyle). <temp> = temp table
name without the temp. prefix.
"""
import argparse, json, sys
from collections import defaultdict
from pathlib import Path

def load(p):
    return json.loads(Path(p).read_text())

def pivot_edges(g, pivot):
    pid = pivot if pivot.startswith('pivot.') else f'pivot.{pivot}'
    return [e for e in g['edges'] if e['pivot'] == pid], pid

def cmd_pivots(g, a):
    ps = sorted({e['pivot'].split('.',1)[1] for e in g['edges']})
    if a.text: ps = [p for p in ps if a.text.lower() in p.lower()]
    for p in ps: print(p)
    print(f"\n({len(ps)} pivots)")

def cmd_find(g, a):
    hits = defaultdict(list)
    for e in g['edges']:
        for nid in (e['src'], e['dst']):
            if nid.startswith('temp.') and a.text.lower() in nid.lower():
                hits[e['pivot'].split('.',1)[1]].append(nid.split('.',1)[1])
    for p, temps in sorted(hits.items()):
        print(f"{p}: {sorted(set(temps))[:6]}")
    if not hits: print("no match")

def _node_kind(g):
    return {n['id']: n['kind'] for n in g['nodes']}

def cmd_show(g, a):
    edges, pid = pivot_edges(g, a.pivot)
    if not edges: sys.exit(f"no pivot {a.pivot}")
    kind = _node_kind(g)
    temps = sorted({n.split('.',1)[1] for e in edges for n in (e['src'],e['dst']) if n.startswith('temp.')})
    roots = sorted({e['src'].split('.',1)[1] for e in edges if e['src'].startswith('clickhouse.')})
    scope = sorted({e['src'].split('.',1)[1] for e in edges if e['src'].startswith('scope.')})
    outs  = sorted({e['src'].split('.',1)[1] for e in edges if e['type']=='pivot_output'})
    dyn   = sum(1 for e in edges if e.get('dynamic'))
    print(f"{pid}:  {len(temps)} temp tables, {len(roots)} CH base roots, "
          f"{len(scope)} scope roots, {len(outs)} output temps, {dyn} dynamic edges")
    print(f"\n  CH base tables (roots): {roots}")
    print(f"\n  scope roots: {scope}")
    print(f"\n  output temps (feed the pivot result): {outs}")

def _walk(edges, start, key_from, key_to, depth):
    adj = defaultdict(list)
    for e in edges: adj[e[key_from]].append(e)
    seen = {start: 0}; q = [start]; out = []
    while q:
        cur = q.pop(0)
        if seen[cur] >= depth: continue
        for e in adj[cur]:
            nxt = e[key_to]
            out.append((seen[cur]+1, e))
            if nxt not in seen:
                seen[nxt] = seen[cur]+1; q.append(nxt)
    return out

def _resolve(g, pivot, temp):
    for pref in ('temp.', 'clickhouse.', 'scope.'):
        nid = pref + temp
        if any(nid in (e['src'], e['dst']) for e in pivot_edges(g,pivot)[0]):
            return nid
    return 'temp.' + temp

def cmd_dir(g, a, up):
    edges, pid = pivot_edges(g, a.pivot)
    if not edges: sys.exit(f"no pivot {a.pivot}")
    start = _resolve(g, a.pivot, a.temp)
    kf, kt = ('dst','src') if up else ('src','dst')
    hops = _walk(edges, start, kf, kt, a.depth)
    label = 'upstream of' if up else 'downstream of'
    print(f"{label} {start} in {pid} (depth {a.depth}):\n")
    by = defaultdict(list)
    for d, e in hops: by[d].append(e)
    for d in sorted(by):
        print(f"  -- {d} hop{'s' if d>1 else ''} --")
        for e in by[d]:
            other = e[kt]
            flag = ' ⚡dynamic' if e.get('dynamic') else ''
            flag += ' ?cond' if e.get('conditional') else ''
            prov = (e.get('provenance') or [{}])[0]
            print(f"  {other:52s} {e['type']:12s} [{prov.get('stage','')}]{flag}")

def cmd_roots(g, a):
    edges, pid = pivot_edges(g, a.pivot)
    if not edges: sys.exit(f"no pivot {a.pivot}")
    roots = sorted({e['src'] for e in edges if e['src'].startswith(('clickhouse.','scope.','dictionary.'))})
    print(f"{pid} reads {len(roots)} external sources:")
    for r in roots: print(f"  {r}")

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--graph', default='workspaces/TRD/pivot_graph.json')
    sub = ap.add_subparsers(dest='cmd', required=True)
    p=sub.add_parser('pivots'); p.add_argument('text', nargs='?', default='')
    p=sub.add_parser('find'); p.add_argument('text')
    p=sub.add_parser('show'); p.add_argument('pivot')
    p=sub.add_parser('roots'); p.add_argument('pivot')
    for name in ('upstream','downstream'):
        p=sub.add_parser(name); p.add_argument('pivot'); p.add_argument('temp'); p.add_argument('-d','--depth',type=int,default=3)
    a = ap.parse_args()
    g = load(a.graph)
    {'pivots':cmd_pivots,'find':cmd_find,'show':cmd_show,'roots':cmd_roots,
     'upstream':lambda g,a:cmd_dir(g,a,True),'downstream':lambda g,a:cmd_dir(g,a,False)}[a.cmd](g,a)

if __name__ == '__main__':
    main()
