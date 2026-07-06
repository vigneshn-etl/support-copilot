# System map — how the three repos interact

> Partially filled from code analysis (ETL + trd-configs); frontend repo
> pending. The triage skill reads this on every ticket.

## The three repos

| Repo | Owns | Typical ticket smells |
|---|---|---|
| **ETL** (this repo) | Inbound files → Vertica → Postgres → ClickHouse batch flows, per client | "data missing/wrong/stale", "batch failed", "file not loaded", metric values wrong *everywhere* |
| **Configuration layer** | Client onboarding config: view definitions, metrics, pivots, size ranges, validations | "metric not showing", "wrong display name", "column missing in view", wrong *for one view/screen* |
| **Frontend application** | Screens, grids, filters, workflows (Assortment/Allocation/MFP UI) | "doesn't refresh", "filter broken", "UI shows X after clicking Y", visual/interaction issues |

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
- Frontend repo: pending connection.

## Decision guide for triage

1. Same wrong number on *every* screen that shows it → ETL (trace with lineage).
2. Metric/column missing or mislabeled on *one* view → config layer.
3. Data correct via SQL but wrong/stale on screen → frontend (or serving-table refresh timing).
4. Works for other clients, broken for one → client config or client ETL step.
