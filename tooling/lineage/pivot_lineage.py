#!/usr/bin/env python3
"""
Pivot Lineage extractor — intra-pivot temp-table dependency DAG.

Implements Pivot-Lineage-Tool-Proposal.md: parse a pivotdefn's ordered
stages, resolve <#include> fragments, expand FreeMarker to the dependency
SUPERSET (union <#if> branches; <#list>-created tables = dynamic nodes),
substitute params.*, split into statements, extract provided/modified/
dependency tables per darwin PivotScheduler rules, and build the DAG.

Output node ids join the combined ETL+config graph:
  temp.<name>        a session temp table (pivot_temp)
  clickhouse.<name>  a real CH base table (dependency never provided in-pivot)
  scope.<VAR>        a runtime scope table (${SCOPED_*}/${*_TABLENAME})
  dictionary.<name>  a joinGet/dictGet source
  pivot.<Filename>   the pivot itself (matches config graph)

Usage:
  python3 pivot_lineage.py --configs <trd-configs> [--pivot NAME] [--out pivot_graph.json]
"""
from __future__ import annotations
import argparse, json, re, time
from collections import defaultdict
from pathlib import Path

# ----- DSL parsing: key="""...""" | key=[ """...""",... ] | key={} ----------
TRIPLE = '"""'

def parse_pivotdefn(text: str):
    """Return {stage_key: [sql,...]} for the ordered stages + a params dict."""
    stages = {}            # prologueSQL, prologueSQLs, aggregationSQLs, ...
    params = {}            # params.NAME -> sql fragment
    i, n = 0, len(text)
    line_starts = _line_index(text)
    while i < n:
        m = re.match(r'[ \t]*([A-Za-z_][A-Za-z0-9_.]*)\s*=', text[i:])
        if not m:
            nl = text.find('\n', i)
            i = n if nl < 0 else nl + 1
            continue
        key = m.group(1)
        j = i + m.end()
        # skip whitespace
        while j < n and text[j] in ' \t\r\n':
            j += 1
        if text[j:j+1] == '[':                     # array of triple-quoted
            arr, j = _read_array(text, j)
            _assign(stages, params, key, arr, _lineno(line_starts, i))
            i = j
        elif text.startswith(TRIPLE, j):            # single triple-quoted
            val, j = _read_triple(text, j)
            _assign(stages, params, key, [val], _lineno(line_starts, i))
            i = j
        else:                                       # scalar ({} , number, id)
            nl = text.find('\n', j)
            i = n if nl < 0 else nl + 1
    return stages, params

def _read_triple(text, j):
    start = j + len(TRIPLE)
    end = text.find(TRIPLE, start)
    if end < 0:
        return text[start:], len(text)
    return text[start:end], end + len(TRIPLE)

def _read_array(text, j):
    # j at '['. Collect triple-quoted strings until matching ']'
    out, k, depth = [], j + 1, 1
    while k < len(text) and depth:
        if text.startswith(TRIPLE, k):
            val, k = _read_triple(text, k)
            out.append(val)
        elif text[k] == '[':
            depth += 1; k += 1
        elif text[k] == ']':
            depth -= 1; k += 1
        else:
            k += 1
    return out, k

def _assign(stages, params, key, vals, lineno):
    if key.startswith('params.'):
        params[key[len('params.'):]] = "\n".join(vals)
    else:
        stages[key] = [(v, lineno) for v in vals]

def _line_index(text):
    idx, pos = [0], text.find('\n')
    while pos >= 0:
        idx.append(pos + 1); pos = text.find('\n', pos + 1)
    return idx

def _lineno(idx, pos):
    import bisect
    return bisect.bisect_right(idx, pos)

# ----- FreeMarker: resolve includes + expand to superset --------------------
INCLUDE = re.compile(r'<#include\s+"([^"]+)"\s*/?>')
FM_LIST_OPEN = re.compile(r'<#list\b[^>]*>', re.I)
FM_TAG = re.compile(r'</?#(?:if|elseif|else|list|assign|macro|items|sep|nested|return|local|global|attempt|recover|compress|escape|noescape|t|lt|rt|nt)\b[^>]*>', re.I)
VAR = re.compile(r'\$\{([A-Za-z_][A-Za-z0-9_.]*)\}')

def resolve_includes(sql, include_dir, seen=None, depth=0):
    seen = seen or set()
    if depth > 5:
        return sql
    def repl(m):
        name = m.group(1)
        if name in seen:
            return ''
        seen.add(name)
        f = include_dir / name
        if f.exists():
            return resolve_includes(f.read_text(errors='replace'), include_dir, seen, depth+1)
        return f'/*MISSING_INCLUDE:{name}*/'
    return INCLUDE.sub(repl, sql)

def expand_superset(sql, params, mark):
    """Strip FreeMarker to the dependency superset. `mark` collects flags."""
    # note loop regions BEFORE stripping (tables created here are dynamic)
    if FM_LIST_OPEN.search(sql):
        mark['dynamic'] = True
    if re.search(r'<#(if|elseif|else)\b', sql, re.I):
        mark['conditional'] = True
    # substitute params.* recursively (fragments referenced as ${NAME})
    for _ in range(6):
        def sub(m):
            k = m.group(1)
            return params.get(k, m.group(0))   # leave scope/tenant/session vars
        new = VAR.sub(sub, sql)
        if new == sql:
            break
        sql = new
    # remove FreeMarker directive tags, keep bodies (union of branches)
    sql = FM_TAG.sub(' ', sql)
    # custom macro calls <@ch.foo .../> -> drop
    sql = re.sub(r'<@[^>]*>', ' ', sql)
    return sql

# ----- statement splitting + table role extraction --------------------------
CREATE = re.compile(r'\bcreate\s+(?:temporary\s+)?table\s+(?:if\s+not\s+exists\s+)?([`"\w${}.]+)', re.I)
INSERT = re.compile(r'\binsert\s+into\s+(?:table\s+)?([`"\w${}.]+)', re.I)
ALTER  = re.compile(r'\balter\s+table\s+([`"\w${}.]+)', re.I)
TRUNC  = re.compile(r'\btruncate\s+table\s+([`"\w${}.]+)', re.I)
DROP   = re.compile(r'\bdrop\s+table\s+(?:if\s+exists\s+)?([`"\w${}.]+)', re.I)
FROMJOIN = re.compile(r'\b(?:from|join)\s+([`"\w${}.]+)', re.I)
JOINGET = re.compile(r'\b(?:joinGet|dictGet\w*)\s*\(\s*[\'"]([\w.]+)', re.I)
CTE_AS = re.compile(r'\b([A-Za-z_]\w*)\s+as\s*\(', re.I)
SQLKW = {'select','where','and','or','on','as','by','group','order','from',
         'join','union','all','distinct','case','when','then','else','end',
         'final','using','settings','format','prewhere','having','limit',
         'array','left','inner','any','outer','global','table','if'}

STMT_START = re.compile(r'(?i)(?<![\w.])(create\s+(?:temporary\s+)?table|insert\s+into|drop\s+table|truncate\s+table|alter\s+table)\b')

def split_statements(sql):
    # 1) split on ; outside quotes
    parts, buf, q, i = [], [], None, 0
    while i < len(sql):
        c = sql[i]
        if q:
            buf.append(c)
            if c == q: q = None
        elif c in "'\"":
            q = c; buf.append(c)
        elif c == ';':
            parts.append(''.join(buf)); buf = []
        else:
            buf.append(c)
        i += 1
    if ''.join(buf).strip():
        parts.append(''.join(buf))
    # 2) within each part, start a NEW statement at each top-level statement
    #    keyword (templated stages often omit ; between statements)
    out = []
    for p in parts:
        starts = [m.start() for m in STMT_START.finditer(p)]
        if len(starts) <= 1:
            out.append(p); continue
        starts = starts if starts[0] == 0 else [0] + starts
        for a, b in zip(starts, starts[1:] + [len(p)]):
            seg = p[a:b]
            if seg.strip():
                out.append(seg)
    return out

def norm_table(raw, client='trd'):
    """Normalize a raw (possibly templated) table ref to (kind, id-name)."""
    t = raw.strip().strip('`"')
    tl = t
    # pure scope var: ${SCOPED_x} / ${x_TABLENAME}
    m = re.fullmatch(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}', tl)
    if m:
        v = m.group(1)
        if v in ('SESSION_ID', 'TENANT_ID'):
            return None
        return ('scope', v.lower())
    # strip ${TENANT_ID}_ prefix and client prefix
    tl = re.sub(r'^\$\{TENANT_ID\}_?', '', tl, flags=re.I)
    tl = re.sub(rf'^{client}_', '', tl, flags=re.I)
    # drop session suffix in any form
    tl = re.sub(r'_?\$\{SESSION_ID\}$', '', tl, flags=re.I)
    tl = re.sub(r'_?case?sessionid\w*$', '', tl, flags=re.I)
    # any remaining ${...} interpolation in the middle -> dynamic marker
    dynamic = bool(VAR.search(tl))
    tl = VAR.sub('X', tl)
    tl = tl.split('.')[-1].strip().lower()
    if not tl or tl in SQLKW or not re.match(r'^[a-z_]', tl):
        return None
    return ('temp', tl, dynamic)     # caller decides temp-vs-base later

def statement_tables(stmt, client='trd'):
    """Return provided, modified, dependency, drops, dicts (sets of raw refs)."""
    provided, modified, dep, drops, dicts = set(), set(), set(), set(), set()
    for m in CREATE.finditer(stmt): provided.add(m.group(1))
    for m in INSERT.finditer(stmt): modified.add(m.group(1))
    for m in ALTER.finditer(stmt):  modified.add(m.group(1))
    for m in TRUNC.finditer(stmt):  modified.add(m.group(1))
    for m in DROP.finditer(stmt):   drops.add(m.group(1))
    ctes = {c.group(1).lower() for c in CTE_AS.finditer(stmt)}
    for m in FROMJOIN.finditer(stmt):
        r = m.group(1)
        if r.lower().strip('`"') not in ctes:
            dep.add(r)
    for m in JOINGET.finditer(stmt): dicts.add(m.group(1))
    return provided, modified, dep, drops, dicts

# ----- build one pivot's DAG ------------------------------------------------
STAGE_ORDER = ['prologueSQL', 'prologueSQLs', 'aggregationSQLs',
               'reverseAggSQLs', 'epilogueSQL']

def build_pivot_graph(path: Path, include_dir: Path, client='trd'):
    text = path.read_text(errors='replace')
    stages, params = parse_pivotdefn(text)
    pivot_id = f"pivot.{path.stem}"
    elements = []          # ordered list of statements with their table roles
    coverage = {'statements': 0, 'unparsed': 0}
    for stage in STAGE_ORDER:
        for sql, lineno in stages.get(stage, []):
            mark = {}
            sql2 = expand_superset(resolve_includes(sql, include_dir), params, mark)
            for stmt in split_statements(sql2):
                if not stmt.strip():
                    continue
                prov, mod, dep, drops, dicts = statement_tables(stmt, client)
                if not (prov or mod or dep or drops or dicts):
                    if re.search(r'\bselect\b', stmt, re.I):
                        coverage['unparsed'] += 1
                    continue
                coverage['statements'] += 1
                elements.append(dict(stage=stage, line=lineno, mark=mark,
                                     provided=prov, modified=mod, dep=dep,
                                     drops=drops, dicts=dicts, sql=stmt[:200]))
    return _schedule(pivot_id, elements, client, coverage)

def _schedule(pivot_id, elements, client, coverage):
    """darwin PivotScheduler rules: provides<-depends, DROP=cut point."""
    # collect all tables ever provided/modified in this pivot -> those are temps
    provided_names = set()
    for e in elements:
        for raw in e['provided'] | e['modified']:
            nt = norm_table(raw, client)
            if nt and nt[0] == 'temp':
                provided_names.add(nt[1])

    nodes, edges = {}, {}
    def node(nid, name, kind, **meta):
        nodes.setdefault(nid, dict(id=nid, name=name, engine='pivot', kind=kind, **meta))
        return nid
    def edge(src, dst, etype, e, dyn=False, cond=False):
        if not src or not dst or src == dst: return
        key = (src, dst, etype)
        prov = dict(pivot=pivot_id, sql_file=None, stage=e['stage'], line=e['line'])
        ed = edges.get(key)
        if ed is None:
            edges[key] = dict(src=src, dst=dst, type=etype, pivot=pivot_id,
                              dynamic=dyn, conditional=cond, provenance=[prov])
        else:
            if dyn: ed['dynamic'] = True
            if cond: ed['conditional'] = True

    def resolve(raw):
        nt = norm_table(raw, client)
        if nt is None: return None
        if nt[0] == 'scope':
            return node(f"scope.{nt[1]}", nt[1], 'scope')
        name, dyn = nt[1], nt[2]
        if name in provided_names:
            return node(f"temp.{name}", name, 'pivot_temp', dynamic=dyn)
        # dependency never provided in-pivot -> real CH base table (joins combined graph)
        return node(f"clickhouse.{name}", name, 'table')

    node(pivot_id, pivot_id.split('.',1)[1], 'pivot')
    for e in elements:
        dyn = bool(e['mark'].get('dynamic'))
        cond = bool(e['mark'].get('conditional'))
        targets = [resolve(t) for t in (e['provided'] | e['modified'])]
        targets = [t for t in targets if t]
        # dependency edges: dep table -> this statement's target(s)
        for d in e['dep']:
            s = resolve(d)
            for t in targets:
                etype = 'create_from' if e['provided'] else 'insert_into'
                edge(s, t, etype, e, dyn, cond)
        for dic in e['dicts']:
            s = node(f"dictionary.{dic.split('.')[-1].lower()}", dic, 'dictionary')
            for t in targets:
                edge(s, t, 'reads', e, dyn, cond)
    # terminal temps (provided, never used as a dependency) feed the pivot output
    used = {k[0] for k in edges}
    for nid, nd in list(nodes.items()):
        if nd['kind'] == 'pivot_temp' and nid not in used:
            edge(nid, pivot_id, 'pivot_output', {'stage':'output','line':0})

    return dict(pivot=pivot_id, nodes=list(nodes.values()),
                edges=list(edges.values()), coverage=coverage)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--configs', required=True)
    ap.add_argument('--client', default='trd')
    ap.add_argument('--pivot', help='single pivotdefn stem (else all)')
    ap.add_argument('--out', default='pivot_graph.json')
    a = ap.parse_args()
    root = Path(a.configs)
    include_dir = root / 'pivot' / 'include'
    files = ([root/'pivot'/f'{a.pivot}.pivotdefn'] if a.pivot
             else sorted(root.glob('pivot/*.pivotdefn')))
    files = [f for f in files if f.exists() and not re.search(r'_(working|loft|OG|copy|LG\d?)$', f.stem)]

    all_nodes, all_edges = {}, {}
    stats = dict(pivots=0, statements=0, unparsed=0, temp_nodes=0, dynamic_edges=0)
    for f in files:
        g = build_pivot_graph(f, include_dir, a.client)
        stats['pivots'] += 1
        stats['statements'] += g['coverage']['statements']
        stats['unparsed'] += g['coverage']['unparsed']
        for nd in g['nodes']:
            all_nodes.setdefault(nd['id'], nd)
        for ed in g['edges']:
            all_edges[(ed['src'], ed['dst'], ed['type'], ed['pivot'])] = ed
    stats['temp_nodes'] = sum(1 for n in all_nodes.values() if n['kind']=='pivot_temp')
    stats['dynamic_edges'] = sum(1 for e in all_edges.values() if e.get('dynamic'))
    total = stats['statements'] + stats['unparsed'] or 1
    out = dict(meta=dict(generated_at=time.strftime('%Y-%m-%d %H:%M:%S'),
                         repo=root.name, stats=stats,
                         parse_rate_pct=round(100*stats['statements']/total, 1),
                         node_count=len(all_nodes), edge_count=len(all_edges)),
               nodes=sorted(all_nodes.values(), key=lambda n:n['id']),
               edges=sorted(all_edges.values(), key=lambda e:(e['pivot'],e['src'],e['dst'])))
    Path(a.out).write_text(json.dumps(out, indent=1))
    print(f"pivots={stats['pivots']} nodes={len(all_nodes)} edges={len(all_edges)} "
          f"temps={stats['temp_nodes']} dynamic={stats['dynamic_edges']} "
          f"parse_rate={out['meta']['parse_rate_pct']}%")
    print(f"wrote {a.out}")


if __name__ == '__main__':
    main()
