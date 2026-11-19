"""Execute composed SQL through the shared read-only gate (same path as the db MCP)."""
import re, subprocess, sys, time
from pathlib import Path

HUB = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(HUB / "tooling" / "db"))
import mcp_server                                  # connections(), SSH_TIMEOUT
from readonly_guard import check_sql               # single source of truth for read-only


def query(client, env, sql, engine="clickhouse", timeout=None):
    """-> (columns, rows[list[str]], ms). Raises on error. No row cap (the gate's
    max_rows wrapper truncates; validation needs every row)."""
    conf = mcp_server.connections().get(client, {}).get(env, {}).get(engine)
    if not conf:
        raise RuntimeError(f"no connection for {client}/{env}/{engine}")
    sql = check_sql(sql)
    if conf.get("gate"):
        gate_cmd = conf.get("gate_cmd", "python3 ~/.s5_ro/s5_ro_gate.py")
        remote_cmd, stdin = f"{gate_cmd} {conf['gate']} {engine}", sql
    else:
        import shlex
        remote_cmd, stdin = conf["cmd"].replace("{SQL}", shlex.quote(sql)), None
    cmd = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", "-o", "RemoteCommand=none",
           "-T", conf["ssh"], remote_cmd]
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True, input=stdin,
                       timeout=timeout or max(getattr(mcp_server, "SSH_TIMEOUT", 120), 330))   # gate stops at 300s
    ms = int((time.time() - t0) * 1000)
    if r.returncode != 0:
        err = r.stderr or r.stdout
        m = re.search(r"(Code: \d+.*?)(?:\n|$)", err)          # ClickHouse's own message first
        raise RuntimeError(f"query failed (exit {r.returncode}): " +
                           (m.group(1)[:1200] if m else err[-1500:]))
    lines = r.stdout.rstrip("\n").split("\n") if r.stdout.strip() else []
    if not lines:
        return [], [], ms
    cols = lines[0].split("\t")
    rows = [ln.split("\t") for ln in lines[1:]]
    return cols, rows, ms


def num(v):
    if v in ("", "\\N", "nan", "inf", "-inf"):
        return None if v in ("", "\\N") else v
    try:
        f = float(v)
        return int(f) if f.is_integer() and "." not in v and "e" not in v.lower() else f
    except ValueError:
        return v


# ---------------------------------------------------------------- typed fetch, any size
# The remote gate truncates output at 2,100 lines. fetch() asks for names+types first; if
# the gate truncated, it re-runs the query as ONE row (groupArray of tuples) and parses
# ClickHouse's literal text locally.
TRUNC = "... truncated at"


def _unescape_tsv(v):
    return re.sub(r"\\(.)", lambda m: {"t": "\t", "n": "\n", "r": "\r", "0": "\0"}.get(m.group(1), m.group(1)), v)


def parse_ch_literal(s):
    """ClickHouse text of arrays/tuples/scalars -> Python."""
    i = 0

    def ws():
        nonlocal i
        while i < len(s) and s[i] in " \n\t":
            i += 1

    def value():
        nonlocal i
        ws()
        c = s[i]
        if c == "[" or c == "(":
            close = "]" if c == "[" else ")"
            i += 1
            out = []
            ws()
            if s[i] == close:
                i += 1
                return out if close == "]" else tuple(out)
            while True:
                out.append(value())
                ws()
                if s[i] == ",":
                    i += 1
                    continue
                if s[i] == close:
                    i += 1
                    return out if close == "]" else tuple(out)
                raise ValueError(f"bad literal near {s[i:i + 20]!r}")
        if c == "'":
            i += 1
            buf = []
            while s[i] != "'":
                if s[i] == "\\":
                    buf.append({"t": "\t", "n": "\n", "r": "\r", "0": "\0"}.get(s[i + 1], s[i + 1]))
                    i += 2
                else:
                    buf.append(s[i])
                    i += 1
            i += 1
            return "".join(buf)
        m = re.compile(r"-?(?:inf|nan)|-?\d+(?:\.\d+)?(?:e[+-]?\d+)?|NULL|true|false", re.I).match(s, i)
        if not m:
            raise ValueError(f"bad literal near {s[i:i + 20]!r}")
        i = m.end()
        t = m.group(0)
        if t.upper() == "NULL":
            return None
        if t in ("true", "false"):
            return t == "true"
        f = float(t)
        return int(f) if re.fullmatch(r"-?\d+", t) else f

    v = value()
    return v


def typed(v, t):
    if v == "\\N":
        return None
    base = re.sub(r"^(Nullable|LowCardinality)\((.*)\)$", r"\2", t)
    base = re.sub(r"^(Nullable|LowCardinality)\((.*)\)$", r"\2", base)
    if re.match(r"^(U?Int)", base):
        return int(v)
    if re.match(r"^(Float|Decimal)", base):
        return float(v)
    if base.startswith(("Array", "Tuple", "Map")):
        return parse_ch_literal(v)
    return _unescape_tsv(v)


def fetch(client, env, sql):
    """-> (cols, types, rows as Python values, ms). Works past the gate's line cap."""
    body = sql.rstrip().rstrip(";")
    cols, rows, ms = query(client, env, body + "\nFORMAT TSVWithNamesAndTypes")
    if not cols:
        return [], [], [], ms
    types, data = rows[0], rows[1:]
    if data and data[-1] and data[-1][0].startswith(TRUNC):
        sel = ", ".join(f"`{c}`" for c in cols)
        agg = f"groupArray(tuple({sel}))" if len(cols) > 1 else f"groupArray(`{cols[0]}`)"
        _, r2, ms2 = query(client, env, f"SELECT {agg} AS rows FROM (\n{body}\n)\nFORMAT TSVWithNames")
        vals = parse_ch_literal(r2[0][0]) if r2 else []
        rows_ = [list(x) if isinstance(x, tuple) else [x] for x in vals]
        return cols, types, rows_, ms + ms2
    return cols, types, [[typed(v, t) for v, t in zip(r, types)] for r in data], ms
