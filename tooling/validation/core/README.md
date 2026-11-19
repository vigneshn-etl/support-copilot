# Validation core: compose, run and compare

`validate.py` takes one JSON request and returns one JSON result. It is the single
entry point for the Data Validation Studio and for automation (Playwright).

```bash
python3 tooling/validation/validate.py --request req.json            # JSON result to stdout
python3 tooling/validation/validate.py --request - < req.json         # request from stdin
python3 tooling/validation/validate.py --request req.json --sql-only  # compose only, no DB
python3 tooling/validation/tests/run_cases.py                         # regression scoreboard
```

Exit code `0` means `OK`, `MATCH` or `COMPOSED`. Exit code `1` means `MISMATCH` or `ERROR`.

## How it computes a number

1. **Render the pivot the way darwin does** (`core/darwin.py` + `core/ftl.py`):
   - Parameters are built like `PivotParamGenerator` builds them: scope, `LEAF_*`,
     `CONDITIONS_BY_DIMENSION`, `GENERAL_CONDITIONS`, `AGG_*`, `AGGREGATION_*`, and so on.
   - The pivotdefn's FreeMarker is rendered with darwin's settings (`ch_sql_tools` is
     auto-imported as `ch`), so every `<#if>` branch resolves as it does on the server.
2. **Layer the requested columns** (`core/formulas.py`): each column is broken into
   reads, measures and columns. A read is one base-table scan with the pivot's own
   FROM/WHERE. `formulas_override.csv` can replace any column by name.
3. **Materialise the session tables** (`core/replay.py`). These stand in for darwin's
   temp tables (scope products and locations, weeks, receipt window, FLOW/HIST
   qualification, flow status).
   - They are computed bottom-up, in parallel waves. Each result is inlined as one
     array literal, so it costs one AST node.
   - This works within the read-only account's limits: `readonly=1`, so
     `max_ast_elements` (50,000) can't be raised; SQL is limited to about 125 KB
     (argv) and 200 KB (guard); output to 2,100 lines; runtime to 90 s.
4. **Run the final query.**
   - `U`: one SELECT per read, grouped exactly as the pivot groups it.
   - `G`: columns at the pivot's output grain.
   - `rows`: G itself.
   - `totals`: the viewdefn rollup formulas (mathjs → ClickHouse) over G.
   - Results larger than the gate's line cap come back as one `groupArray` row.

The pivot's union, rank and band layers never run, because G replaces them. Row counts
for every session table are returned, which makes a mismatch quick to locate.

## Request

```json
{
  "client": "TRD", "env": "qa",
  "route": "#/bottom-up/hindsighting/style-color-review/summary-view",
  "defnId": "HistoryFit",
  "aggBy": "level:stylecolor",
  "section": "rollup",
  "scope": {"productLevel": "department", "productMember": "DP-48",
            "locationLevel": "channel", "locationMember": "CH-2",
            "historyStart": "2025_W37", "historyEnd": "2025_W40",
            "start": "2026_W37", "end": "2026_W40"},
  "filters": {"merchcat": ["FP", "MD"], "class_name": ["Blouse"]},
  "flowStatus": [0, 1, 2],
  "metrics": ["R$ Sales", "net_sls_u"],
  "expected": {"totals": {"R$ Sales": "$4.95M", "Count": 766},
               "rows": [{"stylecolor": "…", "net_sls_r": 1234.5}], "rowKey": "stylecolor"}
}
```

- **`route`**: the URL hash from the screen. It fills in the views.
- **`defnId`** and **`aggBy`**: take them from the `pivot3/listData` call. Each `listData`
  call is one request, because one screen can call several pivots.
- **`section`**: optional. It narrows to the viewdefns whose name contains it.
- **`scope`**:
  - Members can be ids or names (`"048. Wovens"`); names are resolved through the hier table.
  - `{"product": "048. Wovens", "location": "Torrid", "weeks": ["2025-W37", "2025-W40"]}`
    also works. A two-element `weeks` is read as an inclusive range.
- **`filters`**:
  - Level filters (`merchcat` → `LEAF_PRODLIFE`, `grade` → `LEAF_CLUSTER`), product and
    location attributes, and range pickers (`rcpt_weeks`, `sales_weeks`, …). Mapping:
    `customers/<CLIENT>/metrics/dimensions.json`.
  - The browser's `/asst/api/filter/selections` payload (`[{filterId, filterSet}]`) is
    accepted as-is.
- **`metrics`**: optional. Labels or dataIndex values. The default is every metric on the
  screen's views, according to `metric_map.csv`.
- **`expected`**: optional.
  - UI strings are parsed with display precision: `$4.95M` → ±$5K; `56.34%` → ±0.005 pp.
  - Override per metric with `expected.tolerance`.
- **`capture`**: instead of the above, pass the raw browser payloads:
  `{"scope": <GET …/scope data.scope>, "filterSelections": [...], "listData": {"defnId", "aggBy"}, "route": "#/…"}`.

## Result

```json
{
  "status": "MATCH | MISMATCH | OK | COMPOSED | ERROR",
  "error": "…only on ERROR…",
  "resolved": {"pivot", "engine": "replay", "views", "grain", "weeks", "metrics": [...],
               "criteria": {"HIST_TABLE_SELECTION_CRITERIA": "…"}, "ctes": [...]},
  "session_tables": {"trd_PRODUCT_S": {"rows": 766, "inlined": true, "ms": 2100}, …},
  "totals": {"R$ Sales": 4947998.9, …},
  "rows": [{"stylecolor": "…", "s5flowstatus": 1, "net_sls_r": …}, …], "row_count": 766,
  "compare": {"totals": [{"metric", "expected", "db", "diff", "tolerance", "match"}],
              "rows": {"compared_values", "mismatches", "sample", "missing_in_db", "extra_in_db"}},
  "sql": {"rows": "…", "totals": "…"},
  "warnings": [...], "timing_ms": {...}, "elapsed_ms": 0
}
```

## Known limits

- **Nested pivots** (`AGG_LEVEL_2/3`, e.g. Nested Attribute and Cat Recap key
  financials) need the multi-level `aggBy` the UI sends. The core validates the
  deepest level.
- **Band, rank and pareto columns** (`*_band`, `ccperf`) aren't layered yet; they are
  reported in `warnings`.
- **Worklist-scoped pivots** need the user's active worklist ids (`worklistItems`).
  Without them, the worklist is treated as empty.
