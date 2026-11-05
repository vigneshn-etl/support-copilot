# TRD metric map

`metric_map.csv` lists every metric shown on a TRD screen, traced down to its
ClickHouse base columns. There is one row per (screen, view, column), so a metric
that appears on several screens gets several rows. That is deliberate: Studio
search groups them by display name.

Built by `tooling/validation/metric_map.py` from the `trd-configs` git clone
(`allocation-configs`). Base columns are checked with `DESCRIBE TABLE` on TRD QA
ClickHouse, and the results are cached in `ch_schema.json`.

```bash
python3 tooling/validation/metric_map.py --config-dir ../trd-configs --client TRD
python3 tooling/validation/metric_map.py ... --refresh-schema        # re-DESCRIBE on QA
python3 tooling/validation/metric_map.py ... --pivot HistoryFit --explain net_sls_r
```

## The trace

```
confdefn   top nav › left nav › screen view ─→ model / dataApi defnId   (or the viewdefn's own model)
viewdefn   display name, dataIndex, client formula (mathjs)
pivotdefn  dataIndex → SQL expr, followed through params.*, <#include> FTLs,
           session temp tables, UNION ALL branches, ARRAY JOIN, every aggregation level
CH (QA)    table.column exists
```

## Columns

| Column | Meaning |
|---|---|
| `metric_key` | `<pivot>.<dataIndex>`: the pivot-level identity of the number |
| `display_name`, `data_index`, `view_formula`, `renderer`, `visible` | from the viewdefn column |
| `top_nav`, `left_nav`, `screen_view`, `modules` | where it shows (modules = bottom-up / top-down) |
| `viewdefn`, `view_section` | the view file and the JSON section the column sits in |
| `top_nav_id`, `screen_id` | catalog keys, so the Studio can jump to the screen |
| `model`, `pivot` | the binding that serves the data |
| `pivot_expr` | the dataIndex's expression in the pivot's output SELECT (one level) |
| `base_formula` | fully expanded down to base columns. Re-sums of sums are collapsed; `sum(count distinct)` is **kept**, because it's a real semantic step |
| `base_tables`, `base_columns` | CH `table.column` leaves |
| `columns_verified` | `Y` = every leaf column exists on QA CH |
| `filters` | WHERE at the base read, plus any HAVING on the way. `__X__` / `…_SESSION` are runtime scope placeholders |
| `derivation` | the full alias chain, step by step |
| `variants` | `k of n`: how many different base formulas share this display name |
| `status` | `resolved` / `partial` (some leaf unresolved) / `unresolved` / `no_pivot` |

## Snapshot (2026-10-13, trd-configs `ea3ebff`)

- 9,822 rows, 623 display names, 88 pivots.
- 8,468 resolved (86%), 187 partial, 813 unresolved, 354 no_pivot.
- **196 display names have more than one base formula.** Some differences are only
  cosmetic (array vs flat table, extra `CAST`). Real ones worth reviewing:
  - **R$ Sales**: `sum(shp_r)` (gross) on some screens, `sum(shp_r) - sum(ret_r)` (net) on most.
  - **U ST %**: one variant divides by `sum(eoh_u)` summed across all weeks, not
    last-week EOH. That denominator looks inflated.
  - **Count**: `count(distinct product)`, `countIf(… strcntwk > 0)` and
    `uniqIf(x_stylecolor …)` are all summed across groups. That's the off-grain
    `sum(1)` inflation pattern.

## Known gaps (v1)

- `*_band`, `ccperf`, and other rank/band metrics use window or pareto logic
  (`cnt`, …) that isn't traced yet.
- `no_pivot` rows come from presentation-only views, or from screens whose pivot is
  picked at runtime (e.g. nested-attribute Macro views).
- Only CH is traced. ETL and Vertica upstream are out of scope for now.
- Only `AssortmentUiConf` produced rows. The MFP confdefns bind data differently and
  still need a walker.

These rows are **pivot-derived**, so they describe what the code does, not what
it should do. Review a row before treating it as the spec for validation.

## UCM-based map (`metric_map_ucm.csv`, `TRD_metric_base_column_map_qa.xlsx`)

The same trace, built from the **UCM database** rather than the git clone, so it reflects
the config that is actually loaded for QA. `tooling/validation/metric_map_ucm.py` reuses
`metric_map.py`'s parser and resolver; only the inputs change:

```
app_ui_config.config_ui_navigation   top nav › left nav › screen → view
app_view.view_def_item               column label, dataIndex, view formula, renderer
app_public.model_templates           view's model → pivot   (else app_pivot.view_model_pivot_mapping)
app_pivot.patterns.raw_json          pivot SQL sections, FTL includes already inlined
customers/TRD/db/clickhouse_schema.sql + ch_schema.json   base-column check
```

```bash
uv run --script tooling/validation/metric_map_ucm.py --client TRD --env qa
uv run --script tooling/validation/metric_map_ucm.py --client TRD --pivot HistoryFit --explain net_sls_r
```

Needs the UCM DB tunnel: `ssh -N -L 15432:172.16.50.218:5432 <you>@internal-dev-ucm-0`.

Snapshot (2026-10-13, UCM `trd/qa`): 10,960 rows, 1,484 metrics, 112 pivots, 65 base tables.
9,576 resolved (87%), 242 partial, 1,142 unresolved. Against the git map, 8,158 rows trace
the same and 10 differ: Count (`cccount`) in `AssortmentFitStyle` / `_VLP`, where QA counts
`distinct stylecolor` across sales plus on-order (a `STYLE_PREFINAL` block that isn't in
trd-configs `ea3ebff`). Every unresolved row is also unresolved or absent in the git map:
display/attribute fields not on the pivot's table (808), runtime ranking bands and scores (176),
`s5_*` staging tables built outside the pivot (73), other (85).
