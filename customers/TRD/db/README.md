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
file's dump to catch manual DDL drift. All three engine schemas now
captured (PG + Vertica + ClickHouse sections below).

---

# TRD Vertica — schema knowledge (from vertica_schema.sql)

Snapshot: QA, DB `trd`, dumped 2026-08 (EXPORT_OBJECTS). 284 tables,
275 projections, 1 function. Vertica is the ETL staging + transform layer
(inbound files land here, get transformed, then export to PG/CH).

## Table families (the naming convention = the pipeline stage)

| Prefix | Count | Role |
|---|---|---|
| `TRD_IN_*` | 87 | **Inbound staging** — raw loaded from S5* files (per table_mappings*.json). First landing zone. |
| `TRD_REF_*` / `trd_ref_*` | 12 | Reference/mapping tables (e.g. `TRD_REF_S5_CLIENT_ID_MAPPING` — the id-translation table; `TRD_REF_PRD_MEMBERMASTER`). Built early in 010_products.sql. |
| `trd_d_*` | 11 | Dimensions (trd_d_product, trd_d_location, trd_d_time, trd_d_prodlife). |
| `trd_h_*` | 13 | Hierarchies (trd_h_prodstd, trd_h_locstd). |
| `trd_ma_*` | 19 | Master attributes (styleattributes, stylecolorattributes, sizeattributes). |
| `trd_p_*` | 14 | Plan/fact tables (history, onorder, dc_adj). |
| `trd_l_*` | 8 | Lookup tables. |
| `trd_int_*` | 11 | Intermediate transform tables. |
| `*_existing` | 23 | **The round-trip preservation tables** — current PG state exported back to Vertica, MERGEd with fresh build to preserve user edits + rows dropped from the feed (see weekly-product-master-lineage.md). First suspect for "record disappeared after batch". |
| `temp_*` | 3 | Session/temp transform scratch. |

## Notes for triage

- Vertica is where inbound data first lands (`TRD_IN_*`) and gets shaped —
  so "data wrong/missing everywhere" that traces to a bad transform lives
  in the vsql/ scripts operating on these tables.
- Almost no stored logic in Vertica (1 function) — unlike Postgres (54
  triggers). Vertica is pure batch transform; the business-logic-in-DB
  concern is a Postgres thing.
- Projections (275) are Vertica's storage/query-optimization layer; rarely
  relevant to data-correctness tickets, but a missing/wrong projection can
  cause query performance issues.
- Grep this dump for a table's exact columns/DDL when a transform question
  needs the real shape.

---

# TRD ClickHouse — schema knowledge (from clickhouse_schema.sql)

Snapshot: QA, DB `trd`, dumped 2026-08. **1,267 tables/views.** Engines:
MergeTree 1077, ReplicatedMergeTree 79, **Distributed 73**, **PostgreSQL 21**,
Memory 9, ReplacingMergeTree 8. 79 VIEWs. **0 materialized views.**

## Correction: there are NO materialized views feeding the `*_agg` tables

Earlier docs (config CLAUDE.md "known gaps") assumed CH `*_agg` tables were
fed by materialized views whose DDL lived in `database_changes/`. **The dump
disproves this** — there are 0 MVs in `trd`. What look like `*_agg` are
plain **VIEWs**. Example (the SUP-4202 metric root):

- `trd.trd_p_history_agg` is a **VIEW**: `... AS SELECT ... FROM
  trd.trd_p_history_loc_arr_tbl ARRAY JOIN arr_location, arr_prodlife,
  arr_cluster, arr_dmd_r, …` — it **unnests the array-packed
  `trd_p_history_loc_arr_tbl`** (which the ETL loads) into row-per-
  location/prodlife/cluster. So every pivot that reads `trd_p_history_agg`
  actually reads `trd_p_history_loc_arr_tbl`.

**Lineage implication:** pivot roots like `trd_p_history_agg` that showed
"no upstream" in the graph are VIEWs → their real source is the base `_tbl`
the ETL loads. The 79 view definitions in this dump are the missing bridge
between pivot-read names and ETL-loaded names. (Next enrichment: parse these
views → `view → base_tbl` edges and fold into the unified graph — closes
the pivot-root gaps.)

## The three physical layers (naming = layer)

| Layer | Engine | Naming | Who uses it |
|---|---|---|---|
| **Local** | MergeTree/ReplicatedMergeTree | `trd_x_tbl` (183) | ETL loads here (`bash/*/11_ch_*`) |
| **Distributed wrapper** | Distributed (73) | `trd_x` | what pivots read (config side) |
| **View** | VIEW (79) | `trd_x` / `s5_analytics_tenant_*` | reshape/unnest over base tables (e.g. array-unnest, PG denorm) |
| **PG proxy** | PostgreSQL (21) | `*_in_ch`, `target_setting_*` | LIVE window into Postgres (not ETL-loaded) — `trd_d_product_in_ch`, `trd_h_prodstd_in_ch` |

The `_tbl`↔wrapper split is why lineage normalizes `_tbl` away (same logical
table). The **PostgreSQL-engine tables are a direct CH→PG link** (bypass the
file export) — relevant when a CH value tracks PG live, not the batch.

## Triage notes

- "Metric wrong in a pivot, data right in the base table" → check the VIEW
  in between (it may reshape/alias columns — see the `x_*`→base aliasing in
  `trd_p_history_agg`).
- A CH table ending `_in_ch` or under `target_setting_*` = PostgreSQL engine
  = reads PG live; its "freshness" is PG's, not the batch's.
- Grep this dump for a table's `CREATE` to see engine + columns + (for
  views) the exact SELECT/source.
