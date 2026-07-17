# Runbook: create read-only DB accounts (per client env)

For the db-readonly MCP (`tooling/db/mcp_server.py`). One account per
engine, name `s5_copilot_ro`. Learned on TRD internal-qa (2026-07) —
includes the ClickHouse discovery chain so you don't repeat it.

## Postgres (as the `psql` admin, per client DB)

```sql
CREATE ROLE s5_copilot_ro LOGIN PASSWORD '<pwd>' CONNECTION LIMIT 5;
ALTER ROLE s5_copilot_ro SET statement_timeout = '60s';
ALTER ROLE s5_copilot_ro SET default_transaction_read_only = on;
GRANT CONNECT ON DATABASE <db> TO s5_copilot_ro;
GRANT USAGE ON SCHEMA public, mfp, mfp_td, target_setting TO s5_copilot_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public, mfp, mfp_td, target_setting TO s5_copilot_ro;
-- future tables: run AS THE TABLE-OWNING ROLE (check pg_tables.tableowner):
ALTER DEFAULT PRIVILEGES FOR ROLE <owner> IN SCHEMA public
  GRANT SELECT ON TABLES TO s5_copilot_ro;
```

## Vertica (as dbadmin)

```sql
CREATE USER s5_copilot_ro IDENTIFIED BY '<pwd>' RUNTIMECAP '60 seconds';
GRANT USAGE ON SCHEMA public TO s5_copilot_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO s5_copilot_ro;
```

**Trap:** ETL drops/recreates tables weekly → grants vanish. Fix with
inherited schema privileges if the version supports it:
`ALTER SCHEMA public DEFAULT INCLUDE SCHEMA PRIVILEGES;` +
`GRANT SELECT ON SCHEMA public TO s5_copilot_ro;` — otherwise re-run the
GRANT at the end of weekly.sh. Optional isolation: dedicated resource
pool (MEMORYSIZE '1G', MAXCONCURRENCY 2).

## ClickHouse (21.4 — the obstacle course)

What we found on internal-qa, in order:

1. Client env users (e.g. `trd`) CANNOT `CREATE USER` → error 497
   "necessary to have grant CREATE USER ON *.*".
2. `clickhouse-client` on the processor VM is a WRAPPER that injects
   `--user` (error: "--user cannot be specified more than once") —
   bypass with `\clickhouse-client` or `/usr/bin/clickhouse-client`.
3. A passwordless `default` user exists, LOCALHOST-ONLY on the CH node —
   but its grants (SHOW/SELECT/INSERT/ALTER/CREATE/DROP/...) do NOT
   include access management: **CH's `CREATE` ≠ `CREATE USER`** and no
   GRANT OPTION. So `default` cannot create users either.
4. Conclusion: user management is XML-only here → infra request.

**The infra request** (hot-reloaded, no restart, additive):
place as `/etc/clickhouse-server/users.d/s5_copilot_ro.xml`,
owner clickhouse:clickhouse, mode 600, ON EVERY CH NODE:

```xml
<yandex>
  <profiles>
    <copilot_readonly>
      <readonly>1</readonly>
      <max_execution_time>60</max_execution_time>
      <max_result_rows>100000</max_result_rows>
      <max_memory_usage>2000000000</max_memory_usage>
    </copilot_readonly>
  </profiles>
  <users>
    <s5_copilot_ro>
      <password_sha256_hex>SHA256_OF_PASSWORD</password_sha256_hex>
      <profile>copilot_readonly</profile>
      <quota>default</quota>
      <networks><ip>::/0</ip></networks>
      <databases><database><client_db></database></databases>
    </s5_copilot_ro>
  </users>
</yandex>
```

Hash: `echo -n '<pwd>' | sha256sum` (plain sha256; the SQL
`sha256_hash ... SALT` format is different — don't reuse).

## Verify (all engines, from the VM the MCP connects from)

```bash
psql -U s5_copilot_ro -d <db> -c "select 1"                      # works
psql -U s5_copilot_ro -d <db> -c "delete from <tbl>"             # FAILS
vsql -U s5_copilot_ro -c "select 1"                              # works
/usr/bin/clickhouse-client -h <ch-host> -u s5_copilot_ro --password '<pwd>' \
  -q "select 1"                                                  # works
...same with a TRUNCATE                                          # FAILS
```

Then fill `customers/<CLIENT>/db/connections.json` (gitignored) and smoke
test via Claude Code: "list db targets", "query <client> qa postgres:
select 1".

## Security findings to report while you're in there

- Passwordless `default` CH user = anyone with SSH to the CH node has
  data-admin rights (INSERT/DROP/TRUNCATE on everything). Localhost-only
  softens it; still worth an infra ticket, especially for prod.
- Never paste real passwords/hashes into chats or commits;
  connections.json is gitignored for a reason.
