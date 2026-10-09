# Read-only SSH gate

`s5_ro_gate.py` runs on the QA host, re-checks every query, and holds the
read-only credentials. Two ways to reach it:

| Mode | How | ssh-level enforcement |
|---|---|---|
| **Login** *(current)* | your normal key: `ssh qa-processor "python3 ~/.s5_ro/s5_ro_gate.py TRD postgres" < q.sql` | none — the copilot's code path always calls the gate, but the key itself still has a shell |
| **Forced command** *(parked)* | dedicated key bound to the gate in authorized_keys | the key can run nothing else |

Login mode needs no new key and no authorized_keys change. Every query the
copilot generates still goes: local `check_sql` → gate `check_sql` →
read-only session → read-only role.

```
hub mcp_server ── check_sql ──ssh (key: s5_copilot_ro)──▶ qa-processor
                                 forced command: s5_ro_gate.py
                                   ├─ "<CLIENT> <engine>" only (regex)
                                   ├─ check_sql again (same readonly_guard.py)
                                   ├─ creds from ~/.s5_ro/targets.json (600), via env
                                   ├─ real binaries, not /usr/local/bin wrappers
                                   ├─ read-only session (PG / Vertica / CH)
                                   └─ audit → ~/.s5_ro/audit.log
                                        ▼
                               DB role s5_copilot_ro (no write grants)
```

| Layer | Stops |
|---|---|
| `restrict` + `command=` in authorized_keys | shell, scp/sftp, port/agent/X11 forwarding, pty |
| command regex | anything but `TRD postgres` style calls |
| `check_sql()` on host | writes, DDL, multi-statement, `\!` / `\o` meta-commands |
| read-only session | writes even if the guard had a gap |
| DB role | writes even if everything above failed |

No passwords on the laptop, none in any command line (`ps`), none in git.

## Setup — login mode (once per host)

1. Copy the gate: `tooling/db/remote/install.sh qa-processor`
2. On the host, fill `~/.s5_ro/targets.json` (keep mode 600). Template:
   `targets.example.json`.
3. `customers/<CLIENT>/db/connections.json`:
   ```json
   { "qa": {
       "postgres": { "ssh": "qa-processor", "gate": "TRD" },
       "vertica":  { "ssh": "qa-processor", "gate": "TRD" } } }
   ```
4. Verify: `db_whoami` → `s5_copilot_ro`, superuser off; a `DROP` → `blocked`.

## Setup — forced-command mode (parked)

Same as above plus `install.sh qa-processor --authorize` (creates
`~/.ssh/s5_copilot_ro`, adds its restricted authorized_keys line), the
`qa-processor-ro` ssh alias the installer prints, and `"ssh": "qa-processor-ro"`.

Update the gate after changing `readonly_guard.py`: rerun step 1.

## Limits

- The key is bound to **your** unix account, so `targets.json` is readable by
  anything running as you on that host (and by root). Stronger: a dedicated
  unix user (e.g. `s5ro`) owning `~/.s5_ro`, with each teammate's key in that
  user's authorized_keys — needs host admin.
- Login mode: gating is enforced by the copilot's code path + the DB role,
  not by ssh. Forced-command mode closes that gap.
- ClickHouse (`clickhouse-0.public:9000`, db `trd`) is wired but untested until
  the `s5_copilot_ro` CH user exists. The gate passes only `--readonly 1`
  (ClickHouse rejects other settings in readonly mode), so timeouts / memory /
  row caps must live in the user's server-side settings profile.
