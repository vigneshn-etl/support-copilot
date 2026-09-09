# AssortmentFit.pivotdefn — full walkthrough

Backs modeldefn `AssortmentFit` (+ `AssortmentFitWithLY`, `_quick`, `AssortmentAnalysisFit`,
`AddtoAssortmentAssortmentFit` …). These are the **Assortment Build / Analysis → Style Color**
screens: Summary View, Grid View, Flow Type (SUP-4628 items 1-3), plus the Add-to-Assortment
picker. File is `belk-configs/pivot/AssortmentFit.pivotdefn`, 3326 lines.

---

## 0. What a `.pivotdefn` is

Darwin's pivot engine takes this file and does three things, in order:

1. **FreeMarker template pass** — resolves every `${...}` and `<#if>` using the *scope* of the
   current UI request (what the user filtered/selected, where they are in the hierarchy, what
   grain the grid wants).
2. **Runs the SQL** — a chain of `CREATE TABLE … ENGINE = Memory` statements against
   **ClickHouse**, each building on the previous. All tables are suffixed `_${SESSION_ID}` so
   one request never sees another's temp tables.
3. **Returns one wide result set** — rows = one per grid row (at the requested grain),
   columns = every metric the screen can show. Darwin hands that to the frontend; the
   `.viewdefn` decides which columns to display and in what order (the "wrench").

### The engine contract — placeholders darwin injects

| Placeholder | Meaning |
|---|---|
| `${TENANT_ID}` | `blk` |
| `${SESSION_ID}` | unique per request — makes temp tables private |
| `${LEAF_TIME}` `${LEAF_PRODLIFE}` `${LEAF_CLUSTER}` `${LEAF_FLOW_STATUS}` | the user's filter selections (week range, price-status, grade, flow status) |
| `${SCOPED_PRODUCT}` / `${SCOPED_PRODUCT_LEVEL}` / `${TOP_MEMBERS}` / `${BREADCRUMB}` | where the user is in the product hierarchy (e.g. "department = 501") |
| `${SCOPED_LOCATION}` / `${SCOPED_LOCATION_LEVEL}` | where they are in the location hierarchy |
| `${LEAF_DIMENSION_GROUPS}` / `${LEAF_DIMENSION_GROUPS_COMMA}` | the leaf grain columns (`stylecolor, location, cluster, prodlife, time`) |
| `${AGGREGATION_PRODUCTS}` / `${AGGREGATION_LOCATIONS}` / `${AGGREGATION_GROUPS}` | the **grain the grid wants back** (e.g. just `department`, or `stylecolor`) |
| `${MAYBE_GROUP_BY}` | literally `GROUP BY` or empty, depending on level |
| `${AGG_PRODUCT_LEVEL_COMMA}` | hierarchy columns above the leaf (department, class, subclass…) |
| `params.X="""…"""` | a **named, reusable column list**. `${X}` elsewhere pastes it in verbatim. This is how ~10 base tables all share one 160-column definition. |
| `prologueSQL`, `prologueSQLs[]`, `aggregationSQLs[]`, `reverseAggSQLs[]`, `epilogueSQL` | **execution phases** darwin runs in sequence (below). |

### The source fact

`${TENANT_ID}_p_assort` — the ClickHouse assortment fact table. Grain:
**`x_product` (stylecolor) × `location` × `time` (week) × `prodlife` × `cluster`**, with an
`updated_at` column so each assortment "version" is a separate snapshot. Columns are raw
additive measures: `wo_shp_u/r/c`, `omni_shp_*`, `wo_ret_*`, `dmd_*`, `eoh_u`, `*_intransit_*`,
`rec_*`, `*_margin`, `strcntwk` (store-weeks), `flow_flag`, etc.
On-order comes from `${TENANT_ID}_p_onorder_agg` / `p_onorder`.

`prodlife` values include `'FP'` (full / regular price) — **the entire "FP" metric family is
just `p_assort` filtered to `prodlife = 'FP'`.**

---

## 1. Execution phases (the actual flow)

### Phase A — `prologueSQL`: resolve the member scope

Includes `filtered_members_create_sclr.ftl` + `assortment_products_table_sclr.ftl`.

| Table built | What it is |
|---|---|
| `${PRODUCT_TABLENAME}` | stylecolors where `${SCOPED_PRODUCT_LEVEL} = ${SCOPED_PRODUCT}` (e.g. all CCs in the selected department), latest `updated_at`, plus any attribute conditions the user added |
| `${LOCATION_TABLENAME}` | locations under the selected location node, latest row per location |
| `${PRODUCT_TABLENAME}_channel` | ↑ intersected with `ma_stylecolorchannelattributes` for the scoped channel, `record_state = 0` |

Output: the raw "what stylecolors / what stores is the user looking at" sets.

### Phase B — `prologueSQLs[0]`: time spine + hierarchy + final product qualification

**`filtered_time_period.ftl`:**
- `blk_ty_ly_week_<sid>`, `blk_ly_lly_week_<sid>`, `blk_ty_ly_lly_week_<sid>` — for every
  in-scope TY week, its matching **LY** and **LLY** week id. Output: a 3-column week calendar
  `(ty_week_id, ly_week_id, lly_week_id)`.
- `blk_FILTERED_RCPT_START_END_<sid>`, `blk_FILTERED_SALES_START_END_<sid>` — resolve the
  optional "receipt weeks" / "sales weeks" sub-filters into concrete start/end week ids
  (fall back to min/max of the selected range if not set). Also `rcpt_filter_enabled` flag.
- `blk_ty_ly_lly_receipt_weeks_<sid>` — the week set to use for receipt-based metrics.

**`assortment_base_tables.ftl`:**
- `blk_LOCATION_<sid>` — in-scope **STORE** locations only.
- `blk_INV_LOCATION_<sid>` — stores **+ warehouses/DCs**, with every store attribute joined on.
  Inventory metrics read this (stock sits in DCs too); sell-through reads `blk_LOCATION` (stores).

**`assortment_product_ty.ftl`:**
| Table | Purpose |
|---|---|
| `blk_product_hier_attr_<sid>` / `blk_sku_hier_attr_<sid>` | product-hierarchy rows (department→class→subclass→style→stylecolor) for the scope, latest `updated_at`, `record_state = 0` |
| `blk_RECORD_STATE_PRODUCTS_<sid>` | stylecolors with a live (`record_state=0`) channel-attr row |
| `blk_PRODLIST_<sid>` / `blk_ASST_PRODUCT_MAX_<sid>` | per stylecolor: the `max(updated_at)` = the assortment version to read; plus lifetime `dmd_u` / `shp_u` / `eoh_u`. `HAVING (avg(dmd_u)>0 or … or avg(eoh_u)>0)` drops dead products |
| `blk_PRODUCT_FLOW_<sid>` | per stylecolor: `s5flowstatus` ∈ {0,1,2} (flowed / partial / not-yet) derived from `sku_assort_flow_flag` |
| `blk_PRE_FILTER_PRODUCT_<sid>` | flow-status filter (`${LEAF_FLOW_STATUS}`) ∩ has-onorder-or-activity |
| `blk_TIME_FILTERED_PRODUCT_<sid>` | ∩ has a row in the receipt week-window (respects `rcpt_filter_enabled`) |
| **`blk_PRODUCT_<sid>`** | **the FINAL in-scope product list.** Every base table in Phase C joins to this. |

Output of Phase B: the fully-qualified "universe" for this request — which stylecolors, which
stores/DCs, which weeks (TY/LY/LLY), which product version, each product's flow status.

### Phase C — `prologueSQLs[1]`: the 8 base-metric tables (the heavy lifting)

Eight `CREATE TABLE` statements, each reading `p_assort` (or `p_onorder_agg`) and
`sum()`-aggregating to the **leaf grain** `${LEAF_DIMENSION_GROUPS}`. All share the same WHERE
shape: `x_product IN blk_PRODUCT_<sid>` · correct `updated_at` · `time IN` the right week set ·
`prodlife IN ${LEAF_PRODLIFE}` · `location IN` stores-or-DCs · `cluster IN ${LEAF_CLUSTER}` ·
`strcntwk > 0`.

| # | Table | Reads | Weeks | Owns these measures | Column-list param |
|---|---|---|---|---|---|
| 1 | `BASE_SUM_SALES_METRICS` | `p_assort` | all TY | `wo_/omni_ shp/ret`, `dmd`, `*_margin`, `strcntwk`, `funded_*` | `BASE_SUM_SALES_METRICS` (`:15`) |
| 2 | `BASE_FP_SALES_METRICS` | `p_assort` **WHERE `prodlife = 'FP'`** | all TY | same numbers, **regular-price only** → aliased `fp_wo_shp_u_x` etc. | `BASE_SUM_FP_SALES_METRICS` (`:1184`) |
| 3 | `BASE_SUM_INV_METRICS` | `p_assort` | all TY | `sum_boh/eoh_*`, `*_intransit_*`, `xfer_*`, `inv_adjustment_*`, `dc_to_str_rct_*` | `BASE_SUM_INV_METRICS` (`:182`) |
| 4 | `BASE_SUM_RCPT_METRICS` | `p_assort` | **receipt window** | `rec_u/r/c` | `BASE_SUM_RCPT_METRICS` (`:349`) |
| 5 | `BASE_SUM_OO_METRICS` | `p_onorder_agg` | — | `on_order_*` incl. 4wk / 13wk buckets | `BASE_SUM_OO_METRICS` (`:516`) |
| 6 | `BASE_FIRST_INV_METRICS` | `p_assort` | **`min` week only** | `first_value_boh_*` (beginning-of-period snapshot) | `BASE_FIRST_INV_METRICS` (`:683`) |
| 7 | `BASE_LAST_INV_METRICS` | `p_assort` | **`max` week only** | `last_value_eoh_*` (end-of-period snapshot) — **the ST% / WOH inventory** | `BASE_LAST_INV_METRICS` (`:850`) |
| 8 | `BASE_COUNT_STD_METRICS` | `p_assort` | all TY | `weekcount_x = count(distinct time)`, `cccount_x`, `stylecount_x`, `ttl_storecount_x` | `BASE_COUNT_STD_METRICS` (`:1017`) |

(There are also `BASE_*_FP_INV_METRICS` param blocks `:1352`–`:1856` — the FP counterparts of
the inventory/count tables — currently defined but the FP family that actually feeds a UI
column is the sales one.)

**Critical trick:** every one of the 8 tables emits the **same full ~160-column list** (that's
why the param blocks are so long). Each fills only the columns it owns; every other column is
`CAST(0 as Float32) as <col>_x`. This makes them `UNION ALL`-compatible.

Output: 8 leaf-grain tables, union-compatible, each carrying one "slice" of the fact.

### Phase D — `prologueSQLs[2]`: `ALL_BASE` — stitch the 8 into one row per leaf

```sql
CREATE TABLE blk_ALL_BASE_<sid> AS
SELECT s5flowstatus, <leaf dims>, {BASE_METRICS_UNION}
FROM ( table1 UNION ALL table2 UNION ALL … UNION ALL table8 ) x
ANY LEFT JOIN blk_PRODUCT_<sid> USING (product)
GROUP BY s5flowstatus, <leaf dims>;
```

`BASE_METRICS_UNION` (`:2024`) = the re-aggregation rule per column:
- **`sum(col_x) as col`** for additive measures — the 7 zero-filled copies vanish, the 1 real
  value survives.
- **`max(col_x) as col`** for `weekcount`, `ttl_storecount`, `funded_weekcount`,
  `fp_weekcount`, `funded_ttl_storecount` — you never *sum* a count-of-weeks across the union.
  *(This is the SUP-4378 sum-vs-max rollup rule — already correct here.)*

Output: **one row per `(stylecolor × store × week × prodlife × cluster)`** with every raw
additive metric — TY sales, FP sales, inventory, receipts, on-order, counts — side by side.

### Phase E — `prologueSQLs[3]`: `BASE_ATTR_AGG` — roll leaf → requested grain

A 6-deep nested `SELECT` that collapses **one dimension per layer**, joining that dimension's
hierarchy/attribute view at each step, so a rollup member ("department X", "cluster Root") gets
its own aggregated row:

```
leaf rows
  → group products to ${AGGREGATION_PRODUCTS}      (join sku_hier_attr)
  → group locations to ${AGGREGATION_LOCATIONS}    (join store_hier_attr)   [SUM variant if location is itself leaf]
  → group clusters   to ${AGGREGATION_CLUSTERS}    (join cluster_view)
  → group prodlifes  to ${AGGREGATION_PRODLIFES}   (join prodlife_view)
  → group times      to ${AGGREGATION_TIMES}       (join time_attributes)
```

Each layer uses `BASE_METRICS_AGG_UNION` (`:2191`) — same idea as `BASE_METRICS_UNION` but the
inputs are already-named columns (`sum(wo_shp_u) as wo_shp_u`), `max()` still for weekcount.
`BASE_METRICS_AGG_UNION_SUM` (`:2359`) is used only at the location layer when location is a
leaf group.

Output: one row per `(requested product grain × requested location grain × cluster × prodlife
× time)` — still **only raw additive metrics**, now at the grain the grid asked for.

### Phase F — `prologueSQLs[4]`: `BASE_ATTR_AGG_FILTER` — final grain + **COMPUTED_METRICS**

```sql
CREATE TABLE blk_BASE_ATTR_AGG_FILTER_<sid> AS
SELECT s5flowstatus, ${AGGREGATION_GROUPS_COMMA}
       {BASE_METRICS_AGG_UNION}      -- raw sums again, at final grain
       {COMPUTED_METRICS}            -- ← every ratio / derived metric
FROM blk_BASE_ATTR_AGG_<sid>
GROUP BY s5flowstatus, ${AGGREGATION_GROUPS};
```

**`COMPUTED_METRICS` (`:2526`–`:2662`) is the layer SUP-4628 edits.** It's ~140 lines of
`, CASE WHEN <denom> > 0 THEN round(<expr>, 4) ELSE 0 end as <metric>`. Relevant rows:

```
:2547  net_sls_u      = shp_u - ret_u
:2650  fp_net_sls_u   = fp_shp_u - fp_ret_u                        (from BASE_FP_SALES_METRICS)
:2616  avail_inv_u    = last_value_eoh_u + last_value_eoh_intransit_u + (shp_u - ret_u)
                        ← already the SUP-4378 "agnostic" total-available-inventory
:2623  sell_thru_pct  = (shp_u - ret_u) / (last_value_eoh_u + (shp_u - ret_u))
                        ← OLD: denominator drops intransit.  FIX → / avail_inv_u
:2658  fp_sell_thru_pct = fp_net_sls_u / (fp_last_value_eoh_u + fp_net_sls_u)
                        ← BUG: FP-only inventory (same defect as SUP-4378 ETL).  FIX → fp_net_sls_u / avail_inv_u
       woh / fp_woh   = DO NOT EXIST → ADD:
                        woh    = avail_inv_u / ((shp_u - ret_u) / weekcount)
                        fp_woh = avail_inv_u / (fp_net_sls_u    / weekcount)
                        weekcount is already here (max(weekcount_x), plain count(distinct time))
```

Output: the near-final grid — one row per screen row, every metric column present.

### Phase G — `prologueSQLs[5]`–`[8]`: band / rating tables

- `PARETO_BAND` — cumulative-sales Pareto rank per product.
- `NET_SLS_U_BAND`, `NET_SLS_R_BAND`, `NET_SLS_MARGIN_R_BAND`, `NET_SLS_MARGIN_PCT_BAND`,
  `SELLTHRU_PCT_BAND` — each sorts products by that metric and buckets into **quintiles 1-5**
  (`k <= 0.2*cnt → 1`, `<= 0.4 → 2`, …); zero-value rows get band 0.
- `PRE_COMPOSITE_BAND` — pivots those into one row per product and computes
  `temp_comp_band = 0.5*net_sls_u_band + 0.3*net_sls_margin_pct_band + 0.2*sell_thru_pct_band`.
- `COMPOSITE_BAND` — re-quintiles `temp_comp_band` into `composite_band`.
- `ALL_CONSOLIDATED_BAND` — joins all bands together, maps band 0 → 1.
- `BASE_ATTR_AGG_FILTER_RANK_BAND` — the grid from Phase F **+** all band columns + `ccperf`.
- `PRICE_STATUS` — current `prodlife` per stylecolor at the latest assortment week.
- `SLSRNK` — the `slsrnk` sales-rank attribute per stylecolor.

*(This is exactly the machinery `AssortmentAnalysisGrid` uses for its ST% "rating" — SUP-4628
item 8 needs a parallel `fp_sell_thru_pct_band` cloned through all of Phase G there.)*

### Phase H — `reverseAggSQLs[]`: what darwin SELECTs for the screen

`aggregationSQLs = []` is empty → darwin uses `reverseAggSQLs` for **every** level.

- **`reverseAggSQLs[0]`** (rolled-up / non-leaf rows): reads
  `BASE_ATTR_AGG_FILTER_RANK_BAND`, **re-runs `BASE_METRICS_AGG_UNION` + `COMPUTED_METRICS` at
  the group grain**, `avg()`s the band integers, joins `PRICE_STATUS` + `SLSRNK`.
  → a `COMPUTED_METRICS` formula must be correct at **both** leaf and group grain, because it
  executes in Phase F *and* here.
- **`reverseAggSQLs[1]`** (leaf rows): thinner passthrough of the same select.

### Phase I — `epilogueSQL`: empty.

---

## 2. One-line mental model

```
p_assort  (stylecolor × store × week fact, + prodlife='FP' slice)
  │  Phase C
  ▼
8 base tables   (one per metric shape; all emit the same 160-col shape, zero-filled)
  │  Phase D  — UNION ALL + sum() / max(weekcount)
  ▼
ALL_BASE        (one row per LEAF grain, raw additive metrics)
  │  Phase E  — collapse each dimension to the grid's grain
  ▼
BASE_ATTR_AGG   (one row per REQUESTED grain, still raw)
  │  Phase F  — GROUP BY final grain + COMPUTED_METRICS   ←── SUP-4628 edits here
  ▼
BASE_ATTR_AGG_FILTER   (grid + every ratio)
  │  Phase G  — quintile band tables, PRICE_STATUS, SLSRNK
  ▼
BASE_ATTR_AGG_FILTER_RANK_BAND
  │  Phase H  — reverseAggSQLs: re-compute at display grain, attach bands
  ▼
result set → frontend → .viewdefn picks & orders columns (the wrench)
```

---

## 3. Why AssortmentFit is "LOW effort" for SUP-4628

- `avail_inv_u` (agnostic base) — **already computed**, `:2616`.
- `fp_net_sls_u` and its `fp_shp_u/fp_ret_u` components — **already flow through** from
  `BASE_FP_SALES_METRICS` (Phase C table #2) → `BASE_METRICS_UNION` (`:2121`+) → COMPUTED.
- `weekcount` — **already here**, plain `count(distinct time)` with `max()` rollup; no
  `tot_weekcount_x` plumbing needed (unlike the Hindsighting side in SUP-4378).
- So the change is **3 edits inside `COMPUTED_METRICS` only**: fix 2 denominators, add
  `woh` + `fp_woh`. `reverseAggSQLs` inherits it automatically (same `${COMPUTED_METRICS}`
  token).
- The other four Assortment pivots (`AssortmentFitTYLY`, `…TYLYTranspose`,
  `AssortmentAggregateViewsNestedAttribute*`, `AssortmentAnalysisGrid`) have **no
  `BASE_FP_SALES_METRICS` table at all** → the whole Phase C #2 table + its threading through
  Phases D/E has to be built first → "HIGH effort".

---

## 4. Cross-check anchors (line numbers, `SUP-4628` branch)

| Thing | Line |
|---|---|
| `id="AssortmentFit"`, `bottomLevels` | 1–9 |
| `params.BASE_SUM_SALES_METRICS` | 15 |
| `params.BASE_SUM_FP_SALES_METRICS` | 1184 |
| FP sales real re-sum (`sum(wo_shp_u) as fp_wo_shp_u_x`) | ~1282 |
| `params.BASE_METRICS_UNION` (fp_ cols start) | 2024 (2121) |
| `params.BASE_METRICS_AGG_UNION` | 2191 |
| `params.COMPUTED_METRICS` | 2526 |
| `avail_inv_u` | 2616 |
| `sell_thru_pct` (OLD) | 2623 |
| `fp_net_sls_u` | 2650 |
| `fp_sell_thru_pct` (BUG) | 2658 |
| `prologueSQLs` phases begin | 2673 |
| 8 base `CREATE TABLE`s | 2707–2868 |
| `ALL_BASE` | 2871 |
| `BASE_ATTR_AGG` (6-layer rollup) | 2903 |
| `BASE_ATTR_AGG_FILTER` (+ COMPUTED_METRICS) | 3003 |
| band tables | 3018–3199 |
| `BASE_ATTR_AGG_FILTER_RANK_BAND` | 3202 |
| `reverseAggSQLs` | 3270–3323 |
