#!/usr/bin/env python3
"""
Scope-aware subgraph over the unified graph (ETL + config + pivot).

The three UI scopes are FILTERS on the one unified DB:

  etl  — the ETL data plane only: vertica/postgres/clickhouse tables + files.
         (This is exactly the original ETL tool's view.)
  pivot— the pivot plane only: pivots, their temp tables, scope/dict roots,
         and the CH base tables they read. Per-pivot temp DAGs.
  e2e  — everything, with pivots COLLAPSED to their pivot node by default;
         `expand` a pivot to reveal its internal temp chain.

Node kinds in the unified graph:
  ETL plane:   engine ∈ {vertica, postgres, clickhouse}; kind ∈ {table, inbound_file}; file.*
  config plane: kind ∈ {pivot, model, view, screen}
  pivot plane: kind ∈ {pivot_temp, scope, dictionary}; pivot.*; clickhouse.* roots
"""
from __future__ import annotations
import sqlite3
from pathlib import Path

MAXDEPTH_FULL = 100
ETL_KINDS   = {'table', 'file', 'inbound_file'}
ETL_ENGINES = {'vertica', 'postgres', 'clickhouse', 'file'}
PIVOT_KINDS = {'pivot', 'pivot_temp', 'scope', 'dictionary', 'table'}  # table = CH roots

def connect_ro(db_path):
    con = sqlite3.connect(f"file:{Path(db_path).resolve()}?mode=ro&immutable=1", uri=True)
    con.row_factory = sqlite3.Row
    return con

def _in_scope(node, scope):
    if scope == 'e2e':
        return True
    if scope == 'etl':
        return node['engine'] in ETL_ENGINES and node['kind'] in ETL_KINDS
    if scope == 'pivot':
        return node['kind'] in PIVOT_KINDS
    return True

def _walk(con, target, direction, maxd, pivot_filter=None):
    """BFS over edges. pivot_filter restricts to one pivot's edges (temps are
    shared by name across pivots, so a single-pivot view must scope edges)."""
    up = direction == 'upstream'
    col_to, col_from = ('src_id', 'dst_id') if up else ('dst_id', 'src_id')
    pf = ""
    args_extra = []
    if pivot_filter:
        # keep this pivot's edges OR non-pivot (ETL/config) edges
        pf = " AND (pivot = ? OR pivot IS NULL)"
        args_extra = [pivot_filter]
    seen = {target}; frontier = [target]; d = 0
    while frontier and d < maxd:
        ph = ','.join('?' * len(frontier))
        rows = con.execute(
            f"SELECT {col_to} nxt FROM edge WHERE {col_from} IN ({ph})" + pf,
            frontier + args_extra).fetchall()
        nxt = [r['nxt'] for r in rows if r['nxt'] not in seen]
        seen.update(nxt); frontier = nxt; d += 1
    return seen

def subgraph(con, target, direction='upstream', depth=1, scope='e2e', expand=None):
    """Scope-filtered lineage subgraph. `expand` = set of pivot ids to expand
    in e2e scope (reveal their internal temps); others stay collapsed."""
    # clear message if the unified DB wasn't built (no schema)
    if not con.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='node'").fetchone():
        return {"error": "unified DB not built — run: python3 unified_load.py "
                         "--graph workspaces/<CID>/unified_graph.json --out <unified_db>"}
    if not con.execute("SELECT 1 FROM node WHERE id=?", (target,)).fetchone():
        return {"error": f"node not found: {target}"}
    maxd = MAXDEPTH_FULL if depth == 'full' else int(depth)
    # In pivot scope, a pivot target views ONE pivot's DAG (temps are shared
    # by name across pivots) — restrict the walk + edges to that pivot.
    pivot_filter = target if (scope == 'pivot' and target.startswith('pivot.')) else None
    ids = _walk(con, target, direction, maxd, pivot_filter)
    # load nodes, apply scope
    ph = ','.join('?' * len(ids))
    nrows = con.execute(f"SELECT id,name,engine,kind FROM node WHERE id IN ({ph})", list(ids)).fetchall()
    nmap = {r['id']: dict(id=r['id'], name=r['name'], engine=r['engine'], kind=r['kind']) for r in nrows}
    inscope = {i for i, n in nmap.items() if _in_scope(n, scope)}

    # in e2e, hide temps of pivots that aren't expanded (collapse)
    expand = expand or set()
    if scope == 'e2e':
        drop = set()
        for i, n in nmap.items():
            if n['kind'] in ('pivot_temp', 'scope', 'dictionary'):
                # keep only if some expanded pivot owns an edge to/from it
                owners = {r['pivot'] for r in con.execute(
                    "SELECT DISTINCT pivot FROM edge WHERE (src_id=? OR dst_id=?) AND pivot IS NOT NULL",
                    (i, i))}
                if not (owners & expand):
                    drop.add(i)
        inscope -= drop
    elif scope == 'pivot':
        pass  # PIVOT_KINDS already restricts

    # edges fully within scope
    if direction == 'upstream':
        cond = "dst_id IN ({p}) AND src_id IN ({p})"
    else:
        cond = "src_id IN ({p}) AND dst_id IN ({p})"
    ip = ','.join('?' * len(inscope)) or "''"
    il = list(inscope)
    erows = con.execute(
        f"SELECT * FROM edge WHERE {cond.format(p=ip)}", il + il).fetchall() if il else []
    # in pivot scope keep only pivot-origin edges; in etl keep non-pivot
    def edge_ok(e):
        if scope == 'pivot':
            if e['origin'] != 'pivot': return False
            if pivot_filter and e['pivot'] != pivot_filter: return False
            return True
        if scope == 'etl':   return e['origin'] != 'pivot'
        return True
    out_edges, used = [], set()
    for e in erows:
        if not edge_ok(e): continue
        prov = con.execute("SELECT sql_file,script,line,stage FROM provenance WHERE edge_id=? LIMIT 3",
                            (e['id'],)).fetchall()
        out_edges.append(dict(src=e['src_id'], dst=e['dst_id'], type=e['type'],
                              origin=e['origin'], pivot=e['pivot'],
                              dynamic=bool(e['dynamic']), conditional=bool(e['conditional']),
                              provenance=[dict(loc=(p['sql_file'] or p['script'] or '?'),
                                               line=p['line'], stage=p['stage']) for p in prov]))
        used.add(e['src_id']); used.add(e['dst_id'])
    used.add(target)
    nodes = [dict(**nmap[i], is_target=(i == target),
                  expandable=(nmap[i]['kind'] == 'pivot' and scope == 'e2e'))
             for i in used if i in nmap]
    return dict(nodes=nodes, edges=out_edges,
                meta=dict(target=target, direction=direction, depth=depth,
                          scope=scope, node_count=len(nodes), edge_count=len(out_edges)))

def list_nodes(con, kind, limit=1000):
    """List nodes of a kind for the scope's default dropdown.
    pivot scope -> kind='pivot' (pivot file names); e2e -> kind='screen'."""
    rows = con.execute(
        "SELECT id,name,engine,kind FROM node WHERE kind=? ORDER BY name LIMIT ?",
        (kind, limit)).fetchall()
    return [{"id": r["id"], "name": r["name"], "engine": r["engine"],
             "kind": r["kind"], "label": r["name"]} for r in rows]


def search(con, text, scope='e2e', limit=40):
    rows = con.execute(
        "SELECT id,name,engine,kind FROM node WHERE id LIKE ? ORDER BY id LIMIT 400",
        (f"%{text.lower()}%",)).fetchall()
    out = []
    for r in rows:
        n = dict(id=r['id'], name=r['name'], engine=r['engine'], kind=r['kind'])
        if _in_scope(n, scope):
            out.append({**n, 'label': f"{n['engine']}.{n['name']}"})
        if len(out) >= limit: break
    return out
