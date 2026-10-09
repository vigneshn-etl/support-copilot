#!/usr/bin/env python3
"""
s5_ro_gate — SSH forced-command gate for read-only DB queries.

Installed on the QA host (e.g. qa-processor) under ~/.s5_ro/ and bound to a
DEDICATED ssh key via authorized_keys:

  restrict,command="/usr/bin/python3 ~/.s5_ro/s5_ro_gate.py" ssh-ed25519 AAAA... s5-copilot-ro

So that key can run NOTHING but this script: no shell, no port/agent/X11
forwarding, no pty. The caller sends:

  ssh qa-processor-ro "<CLIENT> <engine>"   < query.sql

Login mode (no dedicated key; your normal login runs the gate explicitly):

  ssh qa-processor "python3 ~/.s5_ro/s5_ro_gate.py <CLIENT> <engine>" < query.sql

  - the command must be exactly "<CLIENT> <engine>"
  - the SQL arrives on stdin
  - SQL is re-checked here with readonly_guard.check_sql (same rules as the hub)
  - credentials come from ~/.s5_ro/targets.json (must be mode 600) and are
    passed to the DB client via environment, never argv
  - the real client binaries are called directly (bypassing the host's
    /usr/local/bin psql/vsql wrappers that inject admin accounts)
  - Postgres runs with default_transaction_read_only=on; Vertica runs
    SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY first;
    ClickHouse runs with readonly=1
  - every call is appended to ~/.s5_ro/audit.log

Layers, outermost first: ssh forced command -> this gate's SQL check ->
read-only session -> read-only DB role (s5_copilot_ro).
"""
import datetime
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE))
from readonly_guard import check_sql, SqlNotAllowed  # noqa: E402

TARGETS = BASE / "targets.json"
AUDIT = BASE / "audit.log"
MAX_SQL_BYTES = 200_000
MAX_OUT_LINES = 2_100          # hub caps at 2000 rows; a little slack for headers
TIMEOUT = 90

BIN = {
    "postgres": "/usr/bin/psql",
    "vertica": "/opt/vertica/bin/vsql",
    "clickhouse": "/usr/bin/clickhouse-client",
}


def die(msg, code=2):
    sys.stderr.write(f"s5_ro_gate: {msg}\n")
    sys.exit(code)


def audit(**rec):
    rec["ts"] = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")
    rec["from"] = (os.environ.get("SSH_CLIENT") or "").split(" ")[0]
    try:
        fd = os.open(AUDIT, os.O_WRONLY | os.O_APPEND | os.O_CREAT, 0o660)
        with os.fdopen(fd, "a") as f:
            f.write(json.dumps(rec) + "\n")
    except OSError:
        pass  # never let audit failure open a hole; the query is still gated


def load_targets():
    try:
        st = TARGETS.stat()
    except FileNotFoundError:
        die(f"{TARGETS} missing")
    # 600 (personal) or 640 (shared group dir); never world-accessible or group-writable
    if st.st_mode & (stat.S_IRWXO | stat.S_IWGRP | stat.S_IXGRP):
        die(f"{TARGETS} must be mode 600 or 640 (chmod 640 {TARGETS})")
    try:
        return json.loads(TARGETS.read_text())
    except ValueError as e:
        die(f"{TARGETS} is not valid JSON: {e}")


def build(engine, t, sql):
    """Return (argv, env, stdin_text) for the engine."""
    env = {"PATH": "/usr/bin:/bin", "LANG": "C.UTF-8", "HOME": str(Path.home())}
    host, user = t["host"], t["user"]
    port, db = str(t.get("port", "")), t.get("database", "")
    pw = t.get("password", "")

    if engine == "postgres":
        env["PGPASSWORD"] = pw
        env["PGOPTIONS"] = (f"-c default_transaction_read_only=on "
                            f"-c statement_timeout={TIMEOUT * 1000}")
        argv = [BIN["postgres"], "-h", host, "-U", user, "-d", db, "-X", "-A",
                "-F", "\t", "-v", "ON_ERROR_STOP=1", "-c", sql]
        if port:
            argv[1:1] = ["-p", port]
        return argv, env, None

    if engine == "vertica":
        env["VSQL_PASSWORD"] = pw
        argv = [BIN["vertica"], "-h", host, "-U", user, "-X", "-q", "-A",
                "-F", "\t", "-v", "ON_ERROR_STOP=1"]
        if port:
            argv += ["-p", port]
        if db:
            argv += ["-d", db]
        # read-only session first; sql already proven single-statement, no '\'
        script = "SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY;\n" + sql + ";\n"
        return argv, env, script

    if engine == "clickhouse":
        env["CLICKHOUSE_PASSWORD"] = pw
        argv = [BIN["clickhouse"], "--host", host, "--user", user,
                "--readonly", "1",  # no other settings: readonly=1 rejects them; limits live in the CH profile
                "--format", "TabSeparatedWithNames", "--query", sql]
        if port:
            argv += ["--port", port]
        if db:
            argv += ["--database", db]
        return argv, env, None

    die(f"unsupported engine {engine!r}")


def main():
    # login mode: args on argv; forced-command mode: SSH_ORIGINAL_COMMAND
    orig = " ".join(sys.argv[1:]) or (os.environ.get("SSH_ORIGINAL_COMMAND") or "").strip()
    orig = re.sub(r"^\S*python3\s+\S*s5_ro_gate\.py\s+", "", orig)
    m = re.fullmatch(r"([A-Za-z][A-Za-z0-9_-]{0,31}) (postgres|vertica|clickhouse)", orig)
    if not m:
        audit(verdict="bad-command", command=orig[:200])
        die('usage: ssh <host> "<CLIENT> <postgres|vertica|clickhouse>" < query.sql')
    client, engine = m.group(1).upper(), m.group(2)

    raw = sys.stdin.buffer.read(MAX_SQL_BYTES + 1)
    if len(raw) > MAX_SQL_BYTES:
        die("query too large")
    try:
        sql = check_sql(raw.decode("utf-8"))
    except (SqlNotAllowed, UnicodeDecodeError) as e:
        audit(verdict="blocked", client=client, engine=engine, reason=str(e),
              sql=raw[:500].decode("utf-8", "replace"))
        die(f"blocked: {e}", 3)

    targets = load_targets()
    t = targets.get(client, {}).get(engine)
    if t is None:  # fall back to _default template; {client} -> lowercase client id
        d = targets.get("_default", {}).get(engine)
        if d:
            t = {k: (v.replace("{client}", client.lower()) if isinstance(v, str) else v)
                 for k, v in d.items()}
    if not t:
        die(f"no target {client}/{engine} in {TARGETS}")
    argv, env, stdin_text = build(engine, t, sql)

    digest = hashlib.sha256(sql.encode()).hexdigest()[:16]
    try:
        r = subprocess.run(argv, env=env, input=stdin_text, capture_output=True,
                           text=True, timeout=TIMEOUT + 10)
    except subprocess.TimeoutExpired:
        audit(verdict="timeout", client=client, engine=engine, sql_sha=digest, sql=sql[:500])
        die(f"timed out after {TIMEOUT}s", 4)

    audit(verdict="ran", client=client, engine=engine, exit=r.returncode,
          sql_sha=digest, sql=sql[:500])
    lines = r.stdout.splitlines()
    out = "\n".join(lines[:MAX_OUT_LINES])
    if len(lines) > MAX_OUT_LINES:
        out += f"\n... truncated at {MAX_OUT_LINES} lines by gate"
    sys.stdout.write(out + ("\n" if out else ""))
    if r.stderr:
        # psql's "extra argument ignored" noise etc.; never contains our password
        sys.stderr.write(r.stderr[-4000:])
    sys.exit(r.returncode)


if __name__ == "__main__":
    main()
