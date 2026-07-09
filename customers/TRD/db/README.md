# TRD Postgres — schema knowledge (from postgres_schema.sql)

Snapshot: internal-qa, db `trd`, server 14.17, dumped 2026-07-09.
Contents: 423 tables, 54 triggers, 62 functions, 20 views, 6 materialized
views across schemas `public`, `mfp`, `mfp_td`, `target_setting`.
Grep the dump for full bodies; this file is the map.

## The hidden business-logic layer: triggers

PG triggers implement lifecycle logic that exists in NO repo — a
UI/ETL update can mutate other columns/tables server-side. When a value
"changes by itself," look here first.

### trd_ma_stylecolorchannelattributes — 8 triggers (the hot spot)

| Trigger (function) | Fires on | Does |
|---|---|---|
| `trigger_for_time_indx_insert` (`update_week_indxes`) | week-field changes | Recomputes irw/dbtwk/relaunch/mdstart/lastdcorder/exitdate **indexes** from `trd_d_time`; derives `initrcptwk` from `trd_ma_dptflrsetattributes.irw_debut_offset` via `trd_h_prodstd.ancestor3`; lastdcorder = mdstart − 4; roll-forward logic |
| `trigger_lifecycle_plan_update` (`lifecycle_plan_update`) | lifecycle changes | Plan-side sync on lifecycle edits |
| `md_trigger_on_update` / `exit_trigger_on_update` / `dbt_trigger_on_update` / `ca_1_trigger_on_update` | dbt_wk/exitdate/mkdn changes with WHEN guards | Validity checks of week ordering (dbt < md < exit); `store_eligibility_trigger` when dates re-become valid |
| `trigger_sizerangecode_isvalid` / `_validsizes_members` | sizerange changes | Validate/expand size range codes into valid sizes members |
| `set_timestamp_styleclrchannel` (`trigger_set_timestamp`) | any update | updated_at maintenance (pattern used on ~15 tables) |

Note `pg_trigger_depth() = 0` guards everywhere — triggers suppress
cascading; the ETL's `alter table ... enable/disable trigger` calls
(seen in migrations) interact with these during bulk loads.

### Other notable triggers

- `trd_d_product` → `update_name_description`: name/desc propagation on
  product updates.
- `trd_ma_stylecolorattributes` → `update_color_change`: color-family
  sync on color edits.
- `trd_p_itemprice` → `itemprice_fetchdepartment`, `update_eff_aur`
  (effective AUR recompute).
- `trd_p_stylecolor_worklist` → publish/unpublish removal logic;
  `trd_p_stylecolor_store_worklist` → allocation qty sync
  (`trg_sum_override_array`, `trg_sync_alloc_and_override`).
- `pivot_execution` / `plan_queue` → **LISTEN/NOTIFY** (`notify_*_change`)
  — the backend's eventing for pivot runs and plan queue processing.

## Materialized views (the MFP serving layer)

`mfp.actuals_wide_denorm`, `mfp.sys_gen_wide_denorm` and their `mfp_td` /
`target_setting` twins. These are what the ETL's
`ch/weekly/mfp/05_refresh_dimension_hierarchy.sql` REFRESHes (previously
an unparsed-coverage item — now explained: PG MVs, refreshed by batch,
serving MFP reads).

## Triage implications

- "Field changed without anyone editing it" → trigger map above (esp.
  channelattributes week/index triggers).
- "Bulk update behaves differently than UI edit" → trigger_depth guards
  + enable/disable trigger handling in the loading scripts.
- "MFP numbers stale" → MV refresh step in weekly mfp flow.
- updated_at is trigger-maintained — reliable for freshness checks on
  the ~15 tables with `trigger_set_timestamp`.

## Refresh

Re-dump per `knowledge/runbooks/db-schema-snapshot.md`; diff against this
file's dump to catch manual DDL drift. ClickHouse + Vertica dumps still
pending (CH one unlocks MV-based lineage edges).
