# System map — how the four repos interact

> Filled from code analysis of all four repos. The triage skill reads this
> on every ticket.

## The four repos

| Repo | Owns | Typical ticket smells |
|---|---|---|
| **ETL** (`etl-trd-batch`) | Inbound files → Vertica → Postgres → ClickHouse batch flows, per client | "data missing/wrong/stale", "batch failed", "file not loaded", metric values wrong *everywhere* |
| **Config** (`<client>-configs`) | Per-client config: confdefn/view/model/pivot, metrics, filters, size ranges | "metric not showing", "wrong display name", "column missing in view", wrong *for one view/screen* |
| **Frontend** (`assortmentui`) | React/TS screens, grids, filters, workflows; config-driven, AG Grid | "doesn't refresh", "filter broken", "UI shows X after clicking Y", visual/interaction issues |
| **Backend** (`darwin`, Java) | Executes pivots (FreeMarker→CH), serves config, builds filter options, member resolution, plugins | "filter values are codes not labels", pivot/aggregation execution, config-cache staleness, `SystemBrokenException`/`DB::Exception` in API logs |

## Contracts between repos (verified from code)

- **ETL → config (the big one):** ETL loads ClickHouse local tables
  `trd_x_tbl`; config pivots query the wrapper `trd_x`. The pivots'
  `params.BASE_*` SQL blocks mirror the ETL's session tables built in
  `ch/weekly/510_ch_am_prep_final_with_style.sql` (same columns, `_x`
  suffix). ~84 ClickHouse tables join the two repos — see
  `trd-configs/lineage/combined_graph.json` for the exact screen↔table map.
- **Config chain:** confdefn (screen) → modeldefn (`pivotDefn` binding) →
  pivotdefn + ftl includes (generates CH SQL; `bottomLevels` = grain) →
  ClickHouse. `attribute:*`/`member:*` fields resolve via `conf/M_Meta.conf`
  hierarchies → Postgres tables (`trd_h_prodstd`, `trd_h_locstd`, …) which
  ETL populates.
- **End-to-end example (12 hops):** `S5ProdMaster_*.csv` → vertica
  `trd_in_prd_master` → `trd_d_product` → `trd_h_prodstd` → file →
  postgres `trd_h_prodstd` → `trd_ma_stylecolorchannelattributes` → file →
  clickhouse same → pivot `AssortmentFitStyle` → model `AssortmentSummary`
  → screen Style Review / Summary View.
- **Config/frontend → backend (darwin):** the frontend calls
  `/asst/api/...`; darwin loads the confdefn/view/model/pivot
  (`ConfigDefnLoaderTransportImpl`), expands FreeMarker, orders and runs
  the pivot's temp-table SQL against ClickHouse (`PivotScheduler` /
  `PivotExecutor`), and assembles filter options
  (`PivotFilterHandler`). Session temp tables are named
  `tenantId_pivotId_dimension_sessionId`. Log class `com.darwin.*` maps
  directly to a source file. See `knowledge/backend/darwin-primer.md`.

## Decision guide for triage

1. Same wrong number on *every* screen that shows it → ETL (trace with lineage).
2. Metric/column missing or mislabeled on *one* view → config layer.
3. Data correct via SQL but wrong/stale on screen → frontend (or serving-table refresh timing).
4. Works for other clients, broken for one → client config or client ETL step.
5. Filter values show as codes not labels, or wrong pivot/aggregation
   execution, or config change not taking effect (cache) → backend
   (darwin). Confirm behavior in darwin source, not by inference.
6. `SystemBrokenException` / `DB::Exception` / FreeMarker error in the
   assortment-api logs → backend executing a pivot; read the failing SQL
   in the log, trace to the pivotdefn.
