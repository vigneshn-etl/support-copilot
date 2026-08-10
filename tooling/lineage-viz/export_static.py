#!/usr/bin/env python3
"""
Export a self-contained HTML snapshot of one table's lineage — opens in any
browser with no server. Handy for sharing a specific lineage view.

    python3 export_static.py --db workspaces/TRD/lineage_trd.db \
        --table clickhouse.trd_p_history_sales_dmd_tbl \
        --direction upstream --depth full --out snapshot.html
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import graph_service as gs

TEMPLATE = """<!DOCTYPE html><html><head><meta charset="utf-8"><title>Lineage — __TITLE__</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.30.2/cytoscape.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dagre/0.8.5/dagre.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape-dagre/2.5.0/cytoscape-dagre.min.js"></script>
<style>body{margin:0;font:13px system-ui,sans-serif;background:#0f1420;color:#dfe6f2;height:100vh;display:flex;flex-direction:column}
header{padding:10px 14px;background:#171e2e;border-bottom:1px solid #2a3550;display:flex;gap:12px;flex-wrap:wrap;align-items:center}
#legend{display:flex;gap:10px;margin-left:auto;color:#8a96b0;font-size:12px}#legend i{width:20px;height:3px;display:inline-block;border-radius:2px;margin-right:3px}
#main{flex:1;display:flex;min-height:0}#cy{flex:1}#side{width:320px;border-left:1px solid #2a3550;background:#171e2e;padding:12px;overflow:auto}
code{background:#0d1322;padding:1px 5px;border-radius:4px;color:#b9c6e6}.badge{padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600;color:#0d1322}
.prov div{margin:3px 0;color:#8a96b0;font-size:12px;word-break:break-all}.hint{color:#8a96b0}</style></head>
<body><header><b>Lineage snapshot</b><span>__META__</span>
<div id="legend"><span><i style="background:#e0673a"></i>full</span><span><i style="background:#3aa0e0"></i>incremental</span>
<span><i style="background:#8a7bd8"></i>file move</span><span><i style="background:#4fb477"></i>view</span><span><i style="background:#9aa3b5"></i>unknown</span></div></header>
<div id="main"><div id="cy"></div><div id="side"><div class="hint">Hover a node or edge for details.</div></div></div>
<script>
const G=__DATA__;
const EC={full:'#e0673a',incremental:'#3aa0e0',file_move:'#8a7bd8',view:'#4fb477',unknown:'#9aa3b5'};
const NC={vertica:'#3f7f6f',postgres:'#3a5fa0',clickhouse:'#a06a2c',file:'#555f77'};
const els=[];
for(const n of G.nodes)els.push({data:{id:n.id,label:n.name,engine:n.engine,kind:n.kind,target:n.is_target}});
for(const e of G.edges)els.push({data:{id:e.src+'::'+e.dst+'::'+e.type,source:e.src,target:e.dst,type:e.type,load_mode:e.load_mode,prov:e.provenance,batches:e.batches}});
const cy=cytoscape({container:document.getElementById('cy'),elements:els,style:[
{selector:'node',style:{'background-color':n=>NC[n.data('engine')]||'#556','label':'data(label)','color':'#dfe6f2','font-size':10,'text-wrap':'wrap','text-max-width':150,'text-valign':'center','text-halign':'center','width':'label','height':22,'padding':'6px','shape':'round-rectangle','border-width':1,'border-color':'#0d1322'}},
{selector:'node[?target]',style:{'border-width':3,'border-color':'#ffcf4d','font-weight':'bold'}},
{selector:'node[kind = "file"]',style:{'shape':'ellipse','background-opacity':0.5,'border-style':'dashed'}},
{selector:'edge',style:{'width':2,'line-color':e=>EC[e.data('load_mode')]||'#667','target-arrow-color':e=>EC[e.data('load_mode')]||'#667','target-arrow-shape':'triangle','curve-style':'bezier','arrow-scale':0.9}}],
layout:{name:'dagre',rankDir:G.meta.direction==='upstream'?'RL':'LR',nodeSep:18,rankSep:70}});
const side=document.getElementById('side');
cy.on('mouseover','node',ev=>{const d=ev.target.data();side.innerHTML=`<b>${d.label}</b><br>engine: <code>${d.engine}</code><br>kind: <code>${d.kind}</code>`;});
cy.on('mouseover','edge',ev=>{const d=ev.target.data();const prov=(d.prov||[]).map(p=>`<div>📄 ${p.loc}${p.line?':'+p.line:''}</div>`).join('')||'<div>— dynamic / no static SQL —</div>';
side.innerHTML=`${d.source.split('.').pop()} → <b>${d.target.split('.').pop()}</b><br>transform: <code>${d.type}</code><br>load: <span class="badge" style="background:${EC[d.load_mode]}">${d.load_mode}</span><br>batches: ${(d.batches||[]).map(b=>'<code>'+b+'</code>').join(' ')||'—'}<div class="prov"><br><b>Provenance</b>${prov}</div>`;});
</script></body></html>"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--table", required=True)
    ap.add_argument("--direction", default="upstream")
    ap.add_argument("--depth", default="full")
    ap.add_argument("--batch", default=None)
    ap.add_argument("--out", required=True, type=Path)
    a = ap.parse_args()
    depth = "full" if a.depth == "full" else int(a.depth)
    with gs.connect_ro(a.db) as con:
        g = gs.subgraph(con, a.table, a.direction, depth, a.batch)
    if "error" in g:
        raise SystemExit(g["error"])
    meta = f"{a.table} · {a.direction} · {a.depth} · {g['meta']['node_count']} nodes / {g['meta']['edge_count']} edges"
    html = (TEMPLATE.replace("__DATA__", json.dumps(g))
            .replace("__TITLE__", a.table).replace("__META__", meta))
    a.out.write_text(html)
    print(f"Wrote {a.out}  ({g['meta']['node_count']} nodes, {g['meta']['edge_count']} edges)")


if __name__ == "__main__":
    main()
