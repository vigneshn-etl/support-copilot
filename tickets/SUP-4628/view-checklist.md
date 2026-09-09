# SUP-4628 — Assortment view rollout checklist

Metrics for THIS ticket: **FP ST%** (all 10 groups), **FP WOH + WOH** (groups 1-5 only;
6-10 are "ST metrics only"). Plus: update existing **ST%** so its inventory denominator
is price-status agnostic.

Confirmed formula set (from SUP-4378, Nicole-approved 2026-09-01), mapped to Belk
Assortment field names (no `tot_` prefix here — the bare fields ARE the totals; FP is
the `fp_`-prefixed parallel family):

```
avail_inv_u  = last_value_eoh_u + last_value_eoh_intransit_u + (shp_u - ret_u)   -- already exists in most pivots
sell_thru_pct = (shp_u - ret_u) / avail_inv_u          -- FIX: today's denom omits intransit
fp_st_pct     = fp_net_sls_u    / avail_inv_u          -- FIX/ADD: today fp uses fp_last_value_eoh_u (FP-only) — the SUP-4378 bug
woh           = avail_inv_u / ((shp_u - ret_u) / weekcount)
fp_woh        = avail_inv_u / (fp_net_sls_u      / weekcount)
weekcount     = max( count(distinct time) )            -- Assortment weekcount is PLAIN (no strcntwk>0, no prodlife) — simpler than Hindsighting; rollup already max()
```

Divide-by-zero: wrap in `CASE WHEN <denom> > 0 THEN round(...,4) ELSE 0 END` (matches
every sibling metric).

Wrench order (this ticket — NOT the SUP-4378 consecutive block):
- **FP ST%** immediately after **ST%**
- **FP WOH** immediately before **BOH U**
- **WOH** immediately after **FP WOH**

Paths relative to `belk-configs/`. Edit clone: `/Users/vigneshn/Desktop/JIRAs/SUP-4628/belk-configs/` (branch `SUP-4628`).

## Per-pivot audit (verified 2026-09-02 against belk-configs@assortment-planning / SUP-4628 branch)

| # | View group | Pivot | `avail_inv_u` present | current `sell_thru_pct` | FP raw family | `fp_sell_thru_pct` | woh/fp_woh | rollup wk | Effort | Status |
|---|---|---|---|---|---|---|---|---|---|---|
| 1,2,3 | Summary / Grid / Flow Type (StyleColor) | `AssortmentFit` | ✅ `:2616` | OLD, no intransit `:2623` | ✅ full `BASE_SUM_FP_SALES/INV_METRICS` param family | **BUG** `:2658` (`fp_last_value_eoh_u` denom) | ❌ add both | `max` ✅ | **LOW** | not started |
| 4 | Top TY vs LY (StyleColor) | `AssortmentFitTYLY` | ✅ `:1380` | OLD `:1387` | ❌ none | ❌ none | ❌ | `max` ✅ | **HIGH** — build FP family | not started |
| 5 | TY/LY Grid View Tabs | `AssortmentFitTYLYTranspose` | ✅ `ty_`/`ly_` `:1763/:1970` | ✅ already agnostic `:1772` | ❌ none | ❌ none | ❌ | `max(weekcount_x)`; `sum(avail_inv_u)` at transpose | **HIGH** — FP family + ty/ly transpose dup | not started |
| 6 | Cat Summary Tabs — ST only | `AssortmentAggregateViewsNestedAttribute_for_CatRecap` | ✅ TY only (`ly_`/`lly_` zero-filled `:1610/:1820`) | OLD `:1198` | ❌ none | ❌ none | n/a | `sum(weekcount)` `:728` — pre-existing, irrelevant to ST-only | **MED** | not started |
| 7 | Nested Attr Tabs — ST only | `AssortmentAggregateViewsNestedAttribute` | same as 6 | OLD `:1198` | ❌ none | ❌ none | n/a | `sum` | **MED** | not started |
| 8 | Nested View Tabs — ST only + FP ST% Rating | `AssortmentAnalysisGrid` | ✅ `:1182` | OLD `:1189` | ❌ none | ❌ none | n/a | `max` ✅ | **HIGH** — FP family + parallel `fp_sell_thru_pct_band` composite block (`:1614` weights 0.5/0.3/0.2, `:1734` band→color) + "FP ST% Rating" column + re-point existing ST% rating | not started |
| 9 | Nested Over Time — ST only (FP ST% col already present) | `NestedOverTime` | ❌ uses `eoh_u + net_sls_u` | n/a — only `avail_sell_thru_pct` `:32` | ❌ none | **broken**: `AssortmentBuildNestedOvertime.viewdefn:39-40` "FP ST %" → `dataIndex sell_thru_pct` (no such field) | n/a | n/a | **MED** — add `fp_avail_sell_thru_pct` mirroring existing shape; re-point the broken column | not started — **H4 decision needed** |
| 10 | Style Color over Time — ST only | `NestedStyleOverTime` | ❌ uses `eoh_u` | OLD `:507` + `:549` (2 layers) | ❌ none | ❌ none | n/a | n/a | **MED** — lighter pivot, 2 layers | not started |
| — | Style Pane (not a named item — H5) | `StyleChannelReview` | ✅ `:2975` | — | has fp (per SUP-4378) | **BUG** `~:2985` (FP-only denom) | n/a | `max` ✅ | **LOW** — 1 formula fix | not started — **H5 user OK needed** |

Dead / out of scope (confirmed):
- `AssortmentFitStyle.pivotdefn`, `AssortmentFitStyleTYLY.pivotdefn`, all plain-Style viewdefns — `StyleReview` section `hidden:true` + `inPerspectives:[]` at confdefn `:773` and `:4206`.
- Top-Down for items 5 & 10 — no TD view id in confdefn (`TopTYLYGridView :4127`, `NestedStyleOvertime :7204` both `bottom-up` only). Out of scope per ticket wording ("where view exists in Top Down").

## Cost summary

- **LOW** (formula fix + add woh/fp_woh + wrench): AssortmentFit (items 1-3), StyleChannelReview.
- **MED** (FP ST% plumb, no WOH): items 6, 7, 9, 10.
- **HIGH** (build full parallel FP sales family following AssortmentFit's `BASE_SUM_FP_SALES_METRICS` pattern — filtered base table + union/agg threading): items 4, 5, 8. Item 8 also needs the composite-band clone.

## Open decisions (ask Nicole / user before FIX)

1. **Item 9 approach** — re-point "FP ST %" to a new `fp_avail_sell_thru_pct = fp_net_sls_u/(eoh_u+net_sls_u)` matching the view's existing lighter shape (recommended), or rebuild NestedOverTime onto the full agnostic `avail_inv_u` base?
2. **StyleChannelReview fp bug (H5)** — fix in this ticket or split to its own?
3. **Items 5 & 10 Top-Down** — confirm no new TD wiring expected.
4. **Items 6/7 LY & LLY FP ST%** — `ly_avail_inv_u` / `lly_avail_inv_u` are zero-filled in these pivots today, so LY/LLY FP ST% would render 0 unless real inventory is plumbed for those years. JIRA says "same logic for LY as TY... if not possible, discuss." → discuss.
