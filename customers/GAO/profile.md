# GAO — Gap Outlet

Brand of GAP Inc. (group overview: `customers/GAP/profile.md`). Live.
Confirmed by user 2026-11-16.

- **QA UI:** https://qa.gapoutlet.oci.s5stratos.com/
- **Config repo:** `s5-stratos/gao-configs`, prod branch `assortment_planning`
  (GitHub default is `main` — do not branch from main).
- **QA live config:** bucket `internal-qa-config` (us-chicago-1), prefix `gao/asst/`.
- **ClickHouse db:** `gao` (QA) — db_query client `GAO`, verified 2026-11-16 (tables prefixed `gao_`).
- **Postgres/Vertica (QA):** wired via the gate as `s5_copilot_ro` (read-only, not superuser), tested 2026-11-18.
  Vertica: SELECT on all 168 `public` tables. PG: all 162 `public` + 17 `target_setting` tables readable (re-granted as `psql`, retested 2026-11-18).
- ETL repo: `s5-stratos/etl-gao-batch`, prod branch `etl_assortment_planning_prod` (temporary; see repos.json).
