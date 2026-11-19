# ONV — Old Navy

Brand of GAP Inc. (group overview: `customers/GAP/profile.md`). Live.
Confirmed by user 2026-11-16.

- **QA UI:** https://qa.oldnavy.oci.s5stratos.com
- **Config repo:** `s5-stratos/onv-configs`, prod branch `assortment_planning`.
- **QA live config:** bucket `internal-qa-config` (us-chicago-1), prefix **`on/asst/`** (not `onv`).
- **ClickHouse db:** `onv` (QA) — db_query client `ONV`. **Not working yet** (2026-11-16): default CH user `onv` fails auth; needs an `ONV` clickhouse entry in the gate's targets.json on qa-processor.
- **Postgres/Vertica (QA):** wired via the gate as `s5_copilot_ro` (read-only, not superuser), tested 2026-11-18.
  Vertica: SELECT on all 206 `public` tables. PG: all 189 `public` + 20 `target_setting` tables readable (re-granted as `psql`, retested 2026-11-18). PG table prefix is also `on_`.
- **Table prefix is `on_`** (e.g. `on_h_prodstd`), not `onv_`. ONV Vertica also holds a `gao_h_prodstd_existing` table (shared host or stray copy — unconfirmed).
- ETL repo: `s5-stratos/etl-onv-batch`, prod branch `etl_assortment_planning`.
