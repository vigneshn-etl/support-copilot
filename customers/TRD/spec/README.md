# TRD metric spec: the independent definition of what screens should show

The validation engine (`tooling/validation/core/spec.py`) builds its query **only** from
these files. It never reads the pivot. That matters because the pivot is what is under
test, so if the pivot is wrong, the spec disagrees and the validation shows it. Edit the
files in the Data Validation Studio (**Spec** tab) rather than by hand.

| File | One row is | Example |
|---|---|---|
| `sources.csv` | a fact table and its keys | `history` = `trd_p_history_agg` (product × location × week) |
| `measures.csv` | one aggregate on one table | `eoh_u_last` = EOH units at the **last** week (a snapshot, never summed over weeks) |
| `metrics.csv` | what a screen shows | `net_sls_margin_pct` = ratio `net_sls_margin_r / net_sls_r` (0 when the denominator ≤ 0) |
| `populations.csv` | a rule for which items are in | `HIST_STD.hist`: `sum(dmd_u) > 10 OR sum(shp_u) > 10 OR sum(eoh_u) > 5` over the selected weeks |
| `screens.csv` | a data call → population and weeks | `HistoryFit` → `HIST_STD`, history weeks, rows split by flow status |
| `bindings.csv` | a screen column → metric, plus the screen's rollup | `HistoryRollUp.net_sls_u` → `net_sls_u`, rollup `sum(shp_u) - sum(ret_u)` |
| `changelog.csv` | every add, edit, approve and retire | who, when, before → after |

## Measure fields that carry business rules

- **`agg`**:
  - `sum`
  - `count_distinct`
  - `snapshot_last` (stock at the end of the window)
  - `snapshot_first` (BOH)
  - `max`, `min`, `avg`
- **`filter`**: a row condition, e.g. `prodlife = 'FP'` for a full-price numerator, or `strcntwk > 0`.
- **`time_window`**: `selected` (the scope's weeks), `receipt` (the receipt-week filter, else selected), or `none`.
- **`location_set`**: which stores count. Only `scope` exists today; `scope+dc` comes next (SUP-4854 was a stores-vs-DC bug).
- **`rollup`**: how the value combines across items. `sum`, or `max` for week and store counts (SUP-4378 was a sum-vs-max bug).

## LY and LLY

- **A screen column for another year:** a binding's `period` is `ty` (default), `ly` or `lly`.
  For example, `net_sls_r_ly` binds to metric `net_sls_r` with period `ly`. With no binding, a column
  named `<metric>_ly` / `<metric>_lly` is inferred (the provenance says so).
- **Formulas across years:** write `name@ly`, e.g. a variance `net_sls_r - net_sls_r@ly`. Plain
  names mean "the period this column is in". `@` is for metric formulas and screen rollups only.
- **LY weeks:** the calendar weeks whose `cctytime` is in the TY window (one per week; 53-week
  years shift by a week). LLY maps from LY the same way. LY weeks picked on screen
  (`ly_sales_weeks`, `ly_rcpt_weeks`) override the calendar.
- **Population per year:** each year re-runs the population rules on its own weeks, so an item
  can be in LY and not in TY (and gets its own LY flow status).

## Which items are a screen's rows

- **`row_periods`** (screens): `ty` by default. `ty,ly` makes the rows TY items plus LY-only items, as on the
  TY/LY grids; an LY-only row shows 0 for TY columns. Each row keeps TY's flow status, else LY's.
- **`row_filter`** (screens): a condition on the screen's metrics at its grain, e.g.
  `avail_inv_u > 0 OR strcntwk > 0 OR avail_inv_u@ly > 0 OR strcntwk@ly > 0`.
- **Panels and limits (validation request):** `"period": "ly"` checks a TY/LY screen's LY panel (same
  columns, LY rows), and `"top": {"n": 100, "by": "R$ Sales"}` matches the screen's Limit and Sort By, so
  the rollup covers only those rows (Top TY vs LY).
- **Receipt filter:** population rules can use `rcpt_filter_enabled`. It is 1 when receipt weeks are picked on
  screen, else 0, the same as QA's `FILTERED_RCPT_START_END`.

## Lifecycle

`draft` → `approved` (by the approver) → `retired` (kept for history). Any content edit
bumps `version` and returns the row to `draft`. Validation runs on drafts too, but the
result's provenance says `draft`, so you always know what was trusted.

All rows were seeded on 2026-10-13 from TRD as observed, then verified against the UI
(Summary View, 048. Wovens and 123. Lovesick: MATCH). They are `draft` until approved.

## Adding a metric for a ticket (e.g. a new KPI)

1. **Spec → Measures:** add any new base aggregate. Lint checks the columns against ClickHouse.
2. **Spec → Metrics:** write the formula from the **requirement**, then use **Preview on scope** to see the value before the pivot exists.
3. **Coverage:** once the dev adds the screen column, press **+ Create metric**, or bind it to the metric you made.
4. **Validate:** a MISMATCH plus **Diagnose** says whether the pivot differs from the spec or the platform or data differs from the pivot.

## Importing from QA (once per regression cycle)

When QA is known to be correct, `core/qa_import.py` adds whatever the catalog lacks, as drafts
with `origin = qa_import`. It never edits an existing row. It reads one QA config pull
(confdefn → viewdefn → modeldefn → pivotdefn + include FTLs, plus `metric_map_qa.csv` and
`ch_schema.json`) and maps each layer of a pivot column:

| QA pivot | Catalog |
|---|---|
| a read: one scan of a fact table, with its WHERE | source; TY/LY/LLY from `TY_/LY_PRODUCT_SESSION` and `ty/ly_week_id`; window `selected`/`receipt`; locations |
| an aggregate inside the read: `sum`, `sumIf`, `countIf(distinct …)`, `…, time = max week` | measure: `agg`, `expr`, `filter` (`store_hier_attr` subqueries become `loc.<attr> = …`) |
| a column formula: `CASE WHEN d > 0 THEN round(n / d, 4) ELSE 0 END` | metric: `ratio` when the guard is the denominator, else `derived` with a "check with the owner" note |
| a view column and its client formula | binding: metric, period, and the rollup in catalog names |

How rows are matched:

- **Measures:** matched by meaning (source, expr, agg, filter, window and locations), not by name.
- **Metrics:** matched by value on random inputs, so `(shp_r - ret_r) - (shp_c - ret_c)` is
  the same metric as `net_sls_r - net_sls_c`.
- **TY/LY columns** (`ty_x`, `ly_x`, `x_ly`) collapse onto metric `x`; the binding carries the period.

The import reports, and never guesses:

- read filters it doesn't know;
- Assortment-only shapes the engine can't model yet: latest plan version, OP/RP snapshots,
  plan-horizon weeks, rank bands;
- screens whose item population differs from any catalog screen;
- QA config bugs, e.g. a rollup naming a column the pivot doesn't return, or LY and TY formulas
  that differ.

Tests: `tooling/validation/tests/test_qa_import.py`.

## Later

- CSV with per-row versions and `changelog.csv` is the prototype store. The Studio API
  (`ui/spec_api.py` + `core/spec_store.py`) is the only writer, so the same contract can
  move to a DB table or YAML-per-metric with PR review without UI changes.
- Planned additions:
  - **Location sets:** stores + DC.
  - **Populations:** for the assortment and TY/LY families.
  - **Metric types:** LY (52-week offset) and cumulative.
  - **Spec diff between versions:** compare any two versions of a row.
