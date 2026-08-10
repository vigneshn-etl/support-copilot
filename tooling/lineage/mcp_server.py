#!/usr/bin/env python3
"""
Lineage MCP server — exposes the repo's lineage graph as tools that any
MCP client (Claude Code, Claude Desktop, Cowork, custom agents) can call.

Zero dependencies (stdlib only). Registered for the whole team via the
repo-root .mcp.json, so anyone opening this repo in Claude Code gets:

  lineage_find        fuzzy-find tables/files
  lineage_upstream    what feeds a node
  lineage_downstream  what a node feeds
  lineage_impact      full blast radius + scripts to review
  lineage_path        how data flows from A to B
  lineage_node        one node's edges with script:line provenance
  lineage_stats       graph + parse-coverage summary

Speaks JSON-RPC over stdio (one message per line). Reloads graph.json
automatically when the extractor regenerates it.
"""
import io
import json
import sys
import types
from contextlib import redirect_stdout
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import query  # noqa: E402  (lineage/query.py)

_graph_cache = {"mtime": None, "graph": None}


def graph():
    f = query.resolve_graph()
    if not f.exists():
        raise RuntimeError(f"no lineage graph found ({f}) — run the extractor/merge")
    m = f.stat().st_mtime
    if _graph_cache["mtime"] != m:
        _graph_cache.update(mtime=m, graph=json.loads(f.read_text()))
    return _graph_cache["graph"]


def run(fn, _fn_kwargs=None, **kw) -> str:
    buf = io.StringIO()
    defaults = {"all": True, "depth": 3}
    defaults.update(kw)
    args = types.SimpleNamespace(**defaults)
    try:
        with redirect_stdout(buf):
            fn(graph(), args, **(_fn_kwargs or {}))
    except SystemExit as e:          # query.py uses sys.exit for "not found"
        return str(e)
    return buf.getvalue() or "(no output)"


def tool_node(node: str) -> str:
    g = graph()
    ids = query.resolve(g, node)
    if not ids:
        return f"no node matches '{node}'"
    out = []
    for nid in ids[:5]:
        n = next(x for x in g["nodes"] if x["id"] == nid)
        ins = [e for e in g["edges"] if e["dst"] == nid]
        outs = [e for e in g["edges"] if e["src"] == nid]
        out.append(f"{nid}  [{n['kind']}]  {len(ins)} upstream / {len(outs)} downstream")
        for e in ins:
            out.append(f"  <- {e['src']}  ({e['type']}, {query.prov_str(e)})")
        for e in outs:
            out.append(f"  -> {e['dst']}  ({e['type']}, {query.prov_str(e)})")
        out.append("")
    return "\n".join(out)


TOOLS = [
    {"name": "lineage_find",
     "description": "Fuzzy-find tables/files in the ETL lineage graph. "
                    "Node ids look like vertica.trd_h_prodstd, postgres.x, "
                    "clickhouse.y, file.z.csv.",
     "inputSchema": {"type": "object", "required": ["text"],
                     "properties": {"text": {"type": "string"}}},
     "fn": lambda a: run(query.cmd_find, text=a["text"])},
    {"name": "lineage_upstream",
     "description": "What feeds this table/file (its data sources), with the "
                    "script:line that creates each edge. Use for 'where does "
                    "X come from' and root-causing wrong/stale data.",
     "inputSchema": {"type": "object", "required": ["node"],
                     "properties": {"node": {"type": "string"},
                                    "depth": {"type": "integer", "default": 3}}},
     "fn": lambda a: run(query.direction, {"up": True}, node=a["node"],
                         depth=a.get("depth", 3))},
    {"name": "lineage_downstream",
     "description": "What this table/file feeds (its consumers), with "
                    "provenance. Use for 'what reads X'.",
     "inputSchema": {"type": "object", "required": ["node"],
                     "properties": {"node": {"type": "string"},
                                    "depth": {"type": "integer", "default": 3}}},
     "fn": lambda a: run(query.direction, {"up": False}, node=a["node"],
                         depth=a.get("depth", 3))},
    {"name": "lineage_impact",
     "description": "Full blast radius of changing a table: every downstream "
                    "node grouped by engine, plus every script/SQL file to "
                    "review. ALWAYS call before modifying a table or its "
                    "populating SQL.",
     "inputSchema": {"type": "object", "required": ["node"],
                     "properties": {"node": {"type": "string"}}},
     "fn": lambda a: run(query.cmd_impact, node=a["node"])},
    {"name": "lineage_path",
     "description": "Shortest data-flow path from one node to another, "
                    "including intermediate files (cross-database hops).",
     "inputSchema": {"type": "object", "required": ["src", "dst"],
                     "properties": {"src": {"type": "string"},
                                    "dst": {"type": "string"}}},
     "fn": lambda a: run(query.cmd_path, src=a["src"], dst=a["dst"])},
    {"name": "lineage_node",
     "description": "All direct upstream and downstream edges of one node "
                    "with script:line provenance.",
     "inputSchema": {"type": "object", "required": ["node"],
                     "properties": {"node": {"type": "string"}}},
     "fn": lambda a: tool_node(a["node"])},
    {"name": "lineage_stats",
     "description": "Graph summary and parse coverage. Coverage below 99% "
                    "means recent scripts broke conventions.",
     "inputSchema": {"type": "object", "properties": {}},
     "fn": lambda a: run(query.cmd_stats)},
]
TOOL_BY_NAME = {t["name"]: t for t in TOOLS}


def handle(msg):
    method = msg.get("method")
    if method == "initialize":
        return {"protocolVersion": msg["params"].get("protocolVersion",
                                                     "2024-11-05"),
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "lineage", "version": "1.0.0"}}
    if method == "tools/list":
        return {"tools": [{k: t[k] for k in
                           ("name", "description", "inputSchema")}
                          for t in TOOLS]}
    if method == "tools/call":
        name = msg["params"]["name"]
        args = msg["params"].get("arguments") or {}
        t = TOOL_BY_NAME.get(name)
        if not t:
            raise ValueError(f"unknown tool {name}")
        try:
            text = t["fn"](args)
            return {"content": [{"type": "text", "text": text}],
                    "isError": False}
        except Exception as e:
            return {"content": [{"type": "text", "text": f"error: {e}"}],
                    "isError": True}
    if method == "ping":
        return {}
    return None


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue
        if "id" not in msg:                 # notification — no reply
            continue
        try:
            result = handle(msg)
            resp = {"jsonrpc": "2.0", "id": msg["id"], "result": result}
        except Exception as e:
            resp = {"jsonrpc": "2.0", "id": msg["id"],
                    "error": {"code": -32603, "message": str(e)}}
        sys.stdout.write(json.dumps(resp) + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
