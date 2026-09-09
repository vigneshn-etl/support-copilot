# Data-Validation POC — TRD / Hindsighting (scope + grounded analysis)

Goal: prove the validation approach on ONE module (Hindsighting) for TRD
(Torrid). Everything below is grounded from the actual repos/dumps (not
recalled). Runtime-dependent items are marked **[needs live log]**.

## The Hindsighting chain (grounded)

**Screens.** `AssortmentUiConf.confdefn` → tab `Hindsighting` → **41 screens**
with `defns`. Core screens + their model:
- Collection/Canvas/Summary/Grid/FlowType → **HistoryFit** (stylecolor grain)
- same set (style) → **HistorySummary** → pivot `HistoryFitStyle`
- Top TY vs LY → **HistoryTYLY** → pivot `HistoryFitTYLY`
- TY/LY Grid → **HistoryTYLYTranspose** → `HistoryFitTYLYTranspose`
- Category Recap → `HistoryAggregateViewsNestedAttribute_for_CatRecap`,
  `HistoryProductivity`
- **31 distinct pivotdefns** are referenced by `History*` models.

**Model → pivot** (from `uidefn/model/*.modeldefn` `pivotDefn`):
`HistoryFit→HistoryFit`, `HistorySummary→HistoryFitStyle`,
`HistoryTYLY→HistoryFitTYLY`, `HistoryStyleTYLY→HistoryFitStyleTYLY`,
`HistoryTYLYTranspose→HistoryFitTYLYTranspose`. (Note: model `id:` fields are
stale — resolved via filename + pivotDefn, per config conventions.)

**Pivot → CH base tables** (read via ARRAY JOIN inside pivot params, NOT a
literal FROM — the analyzer must expand params/FreeMarker):
- `trd_p_history_loc_arr` — stylecolor-grain, array-packed base **TABLE**
  (columns `product,time,style,arr_location[],arr_prodlife[],arr_cluster[],
  arr_dmd_r[],arr_dmd_u[]…`). Pivots `ARRAY JOIN` it to rows.
- `trd_p_history_sku_loc_arr` — sku-grain sibling.

**Grain (bottomLevels)** — HistoryFit: `ProdStd:${AGGREGATION_PRODUCTS}`,
`LocStd:Store`, `TimeStd:Week`, `ProdLifeStd:MerchCat`, `ClusterStd:Grade`.
`HistoryFitStyle` pins `ProdStd:Style`. `${AGGREGATION_PRODUCTS}` is
runtime-resolved **[needs live log]** (expected: stylecolor).

**Mandatory conditions (the criteria that must be in a faithful query)** —
identical across HistoryFit / HistoryFitStyle / HistoryFitTYLY /
HistoryFitStyleTYLY:
- `FLOW_TABLE_SELECTION_CRITERIA = (avg(dmd_u) > 10 or avg(shp_u) > 10 or avg(eoh_u) > 5)`
- `HIST_TABLE_SELECTION_CRITERIA = (sum(dmd_u) > 10 or sum(shp_u) > 10 or sum(eoh_u) > 5)`
(Same criteria family as AEO SUP-4486, where one pivot dropped it → count
mismatch. TRD baseline here is consistent — which itself is the first
**invariant** to assert.)

**CH → ETL** (loaders, grounded): `bash/weekly/12.4_ch_load_phistory_stylecolor_locarr.sh`
loads `trd_p_history_loc_arr`; `ch/weekly/510_ch_am_prep_final_with_style.sql`
preps it. Upstream Vertica/PG feeds trace via the unified graph.

End-to-end: **inbound history files → Vertica → CH `trd_p_history_*_loc_arr`
→ pivot (ARRAY JOIN, grain Store×Week×MerchCat×Grade×prod, + FLOW/HIST
criteria) → model → 41 Hindsighting screens.**

## First validation targets (why these)

1. **Invariant — criteria consistency.** All History pivots reading the same
   base must apply the same FLOW/HIST criteria. Static, graph+pivot only, no DB.
   (Catches the SUP-4486 class.)
2. **Invariant — Fit vs TYLY reconciliation.** HistoryFit and HistoryFitTYLY
   share the base + grain + criteria → their in-scope stylecolor population must
   reconcile for the same scope.
3. **Spec-composed value check.** From the metric spec (e.g. choice count =
   distinct stylecolor in scope; net sales units = sum(shp_u)), compose a query
   over `trd_p_history_loc_arr` (ARRAY JOIN, grain, + criteria) independently of
   the pivot, run read-only, compare to the UI value.

## Open items / what's needed

- **[needs live log]** Generated pivot SQL + request params for 2–3 Hindsighting
  screens (Collection View, Grid View, Top TY vs LY) → resolves
  `${AGGREGATION_PRODUCTS}` and other runtime vars, the exact member/time/cluster
  filters applied, which criteria actually ran, and the on-screen numbers
  (the known-good to validate the composer against).
- **[infra]** Read-only ClickHouse access to actually run composed queries
  (create-readonly-accounts runbook exists; status?).
- **Analyzer note:** base tables + criteria live inside pivot `params.*` +
  FreeMarker, not literal SQL — the view/pivot analyzer must expand params, not
  grep `FROM`.

## Runtime facts (from app logs — trd_sample_ui_logs.txt, qa+prod Torrid)

The UI request **is** the scope spec — this solves filter parity. Pivot data
loads via:

    GET /asst/api/pivot3/listData?aggBy=<levels>&appName=Assortment
        &defnId=<pivot>&flowStatus=<v>&topMembers=<member,…>

- **`aggBy` = grain + nesting** (URL-encoded `:`=%3A, `,`=%2C). Tokens:
  `level:<lvl>` and `attribute:<attr>:name`, comma-joined for nested grids.
  Observed: `level:stylecolor` (HistoryFit), `level:class:name`
  (CatRecapProductivity), `level:department:name,attribute:class_name:name,
  attribute:subclass_name:name,level:stylecolor` (nested grid). This maps
  directly to the composer's GROUP BY.
- **`flowStatus`** = the flow-status filter (empty = all; `0` = a specific
  status) → a WHERE predicate.
- **`topMembers=DP-48`** = scope member(s), e.g. department id → WHERE.
- **`defnId`** = the pivot → selects base table + criteria.
- **`${AGGREGATION_PRODUCTS}` resolves from `aggBy`** — confirmed values:
  stylecolor / style / class / subclass / department / product / prodrootlevel.
  (Closes the "runtime grain var" open item.)
- **Runtime base table = `trd_p_history_agg`** — an agg **VIEW** that does the
  ARRAY JOIN over `trd_p_history_loc_arr` *internally*, so the executed query is
  `FROM trd_p_history_agg` + criteria + GROUP BY (no ARRAY JOIN in the pivot
  SQL itself). **⇒ the composer should target `trd_p_history_agg` directly** to
  match the pivot; the view→_arr resolution is only needed to go to the physical
  table.
- **Per-session temp tables:** `trd_<Pivot>_PRODUCT_<sessionhash>` (materialized
  intermediates) and `X_<session>` — these are exactly what Tool-1/Tool-2
  bypass by querying `trd_p_history_agg` directly.
- **Criteria seen live:** `>10/>5` (HistoryFit family) and `>0` variants
  (others) — confirms criteria vary per pivot; read them from the pivotdefn.

**Design implication:** capture a `pivot3/listData` request (from the network
tab or these logs) → parse `aggBy/flowStatus/topMembers` into a scope → the
composer builds an INDEPENDENT query over `trd_p_history_agg` with the same
scope + the pivot's criteria, and compares to the UI value. Copy the *inputs*
(scope), compute the *output* independently.

## POC deliverables (proposed)

1. `pivot-analyzer` — expand a Hindsighting pivotdefn → {base tables, grain,
   metrics, mandatory criteria} contract.
2. `view-contract` + linter — per view: columns/dataIndex/formula/groupBy +
   mandatory-condition check (flag missing criteria; grain-vs-count check).
3. `metric-specs/` — canonical defs for ~5 history metrics (independent oracle).
4. `composer` (deterministic) — spec + contract + scope → SQL over base tables.
5. Prove on Top TY vs LY vs Collection View using a live log as known-good.
