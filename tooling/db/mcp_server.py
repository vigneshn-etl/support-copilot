#!/usr/bin/env python3
"""
Read-only database MCP server — queries Postgres / ClickHouse / Vertica
on remote VMs over SSH. Zero dependencies (stdlib only).

Security model:
  - Uses YOUR existing ssh keys/config (no credentials stored here).
  - Only statements starting with SELECT / WITH / SHOW / EXPLAIN /
    DESCRIBE / DESC are executed. Everything else is refused.
  - Row cap enforced (default 200) and ssh-level timeout (default 60s).
  - Every query is visible in the Claude conversation log.

Connections are defined per customer in
  customers/<CLIENT>/db/connections.json:

{
  "qa": {
    "postgres":   { "ssh": "opc@qa-app-vm",  "cmd": "psql -d torrid -X -A -F'\t'  -c {SQL}" },
    "clickhouse": { "ssh": "opc@qa-ch-vm",   "cmd": "clickhouse-client --format TabSeparatedWithNames --query {SQL}" },
    "vertica":    { "ssh": "opc@qa-vert-vm", "cmd": "vsql -A -F'\t' -c {SQL}" }
  },
  "staging": { ... }
}

`{SQL}` is replaced with the (shell-quoted) statement. `ssh` may be any
alias from your ~/.ssh/config (ProxyJump/bastion supported for free).

Tools exposed:
  db_targets()                          list configured client/env/engine
  db_query(client, env, engine, sql, max_rows=200)
"""
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path

HUB = Path(__file__).resolve().parent.parent.parent
READONLY_RE = re.compile(r"^\s*(select|with|show|explain|describe|desc)\b", re.I)
FORBIDDEN_RE = re.compile(
    r"\b(insert|update|delete|truncate|drop|alter|create|grant|revoke|copy"
    r"|attach|detach|optimize|rename|set\s)\b", re.I)
SSH_TIMEOUT = 60


def connections():
    out = {}
    for f in HUB.glob("customers/*/db/connections.json"):
        client = f.parent.parent.name
        try:
            out[client] = json.loads(f.read_text())
        except Exception as e:
            out[client] = {"_error": str(e)}
    return out


def check_sql(sql: str) -> str:
    s = sql.strip().rstrip(";")
    if ";" in s:
        raise ValueError("multiple statements are not allowed")
    if not READONLY_RE.match(s):
        raise ValueError("only SELECT/WITH/SHOW/EXPLAIN/DESCRIBE allowed")
    if FORBIDDEN_RE.search(s):
        raise ValueError("statement contains a forbidden keyword")
    return s


def tool_targets(_args):
    lines = []
    for client, envs in connections().items():
        for env, engines in envs.items():
            if env.startswith("_"):
                continue
            for eng in engines:
                lines.append(f"{client} / {env} / {eng}")
    return "\n".join(lines) or ("no connections configured — create "
                                "customers/<CLIENT>/db/connections.json")


def tool_query(args):
    client, env, engine = args["client"], args["env"], args["engine"]
    max_rows = min(int(args.get("max_rows", 200)), 2000)
    conf = connections().get(client, {}).get(env, {}).get(engine)
    if not conf:
        return f"no connection for {client}/{env}/{engine} — call db_targets"
    sql = check_sql(args["sql"])
    # crude but effective row cap for bare SELECTs without LIMIT
    if re.match(r"^\s*select\b", sql, re.I) and not re.search(r"\blimit\s+\d+", sql, re.I):
        sql = f"{sql} LIMIT {max_rows}"
    remote_cmd = conf["cmd"].replace("{SQL}", shlex.quote(sql))
    cmd = ["ssh", "-o", "BatchMode=yes",
           "-o", f"ConnectTimeout=10", conf["ssh"], remote_cmd]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True,
                           timeout=SSH_TIMEOUT)
    except subprocess.TimeoutExpired:
        return f"error: query timed out after {SSH_TIMEOUT}s"
    if r.returncode != 0:
        return f"error (exit {r.returncode}):\n{r.stderr[-2000:]}"
    out = r.stdout
    lines = out.splitlines()
    if len(lines) > max_rows + 5:
        out = "\n".join(lines[:max_rows + 5]) + f"\n... truncated at {max_rows} rows"
    return out or "(no rows)"


TOOLS = [
    {"name": "db_targets",
     "description": "List configured database connections (client/env/engine).",
     "inputSchema": {"type": "object", "properties": {}},
     "fn": tool_targets},
    {"name": "db_query",
     "description": "Run a READ-ONLY query (SELECT/SHOW/EXPLAIN/DESCRIBE) "
                    "against a customer database over SSH. Lower envs only "
                    "unless the user explicitly approves prod.",
     "inputSchema": {"type": "object",
                     "required": ["client", "env", "engine", "sql"],
                     "properties": {
                         "client": {"type": "string", "description": "e.g. TRD"},
                         "env": {"type": "string", "description": "e.g. qa"},
                         "engine": {"type": "string",
                                    "enum": ["postgres", "clickhouse", "vertica"]},
                         "sql": {"type": "string"},
                         "max_rows": {"type": "integer", "default": 200}}},
     "fn": tool_query},
]
TOOL_BY_NAME = {t["name"]: t for t in TOOLS}


def handle(msg):
    m = msg.get("method")
    if m == "initialize":
        return {"protocolVersion": msg["params"].get("protocolVersion",
                                                     "2024-11-05"),
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "db-readonly", "version": "1.0.0"}}
    if m == "tools/list":
        return {"tools": [{k: t[k] for k in ("name", "description",
                                             "inputSchema")} for t in TOOLS]}
    if m == "tools/call":
        t = TOOL_BY_NAME.get(msg["params"]["name"])
        if not t:
            raise ValueError(f"unknown tool {msg['params']['name']}")
        try:
            text = t["fn"](msg["params"].get("arguments") or {})
            return {"content": [{"type": "text", "text": text}],
                    "isError": False}
        except Exception as e:
            return {"content": [{"type": "text", "text": f"error: {e}"}],
                    "isError": True}
    if m == "ping":
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
        if "id" not in msg:
            continue
        try:
            resp = {"jsonrpc": "2.0", "id": msg["id"], "result": handle(msg)}
        except Exception as e:
            resp = {"jsonrpc": "2.0", "id": msg["id"],
                    "error": {"code": -32603, "message": str(e)}}
        sys.stdout.write(json.dumps(resp) + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
