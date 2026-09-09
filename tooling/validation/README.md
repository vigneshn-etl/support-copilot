# Data-Validation Tooling (POC — TRD / Hindsighting)

Compose an **independent** SQL query that reproduces a UI metric's value from
the **main tables** (bypassing the pivot's session temp tables), so you can run
it yourself and cross-check the number on screen. Copy the *inputs* (scope from
the UI request); compute the *output* (metric logic) from the pivot contract —
so agreement is a real test, not a replay.

The tool **emits SQL for you to run** (no DB execution / no read-only access
needed yet). See `POC-hindsighting-trd.md` for the grounded module analysis.

## Pieces

| Script | Does |
|---|---|
| `listdata_parse.py` | A `pivot3/listData` URL → scope `{grain[], flowStatus, topMembers, defnId}`. The UI request IS the scope spec. |
| `pivot_contract.py` | A pivotdefn → `{runtime table, grain, metrics, FLOW/HIST criteria}`. Reads params/FreeMarker (not a plain `grep FROM`). Maps the array base (`*_loc_arr`) → the runtime agg VIEW (`*_agg`) the UI actually queries. |
| `compose.py` | scope + contract → an executable validation SQL string, with provenance comments and explicit `-- TODO/CONFIRM` where something isn't fully grounded. |
| `criteria_consistency.py` | **Static invariant checker (no DB).** Groups pivots by base table; flags criteria that deviate from the majority + no-op (always-true) filters. Exit 1 if issues → CI-gate friendly. |
| `agg_types.py` | **CH correctness.** Classifies each metric's aggregation from the pivot: additive→`sum(m)`, snapshot→`argMax(m,time)` (EOH), first→`argMin(m,time)` (BOH). Fixes the `sum(eoh_u)` over-count. |
| `CLICKHOUSE.md` | The curated CH dialect profile the composer respects (per-metric aggregation, string week `IN`, distinct/Distributed, engines/FINAL). |
| `ch_validate.py` | Validate a composed query with CH itself — `version()` + capability probe (21.4-safe), `EXPLAIN SYNTAX` (dialect check, no data) or `--run` (values). Run locally where you have read-only CH. |
| `compare.py` | **Closes the loop.** Substitute the history weeks, run the composed query on CH, summarize (choice count + metric totals, correct per-metric aggregation), and diff vs expected UI values → MATCH / MISMATCH. |
| `build_catalog.py` | **The scale foundation.** Walks all pivots/screens/views ONCE → SQLite `catalog.db` with `pivots` (incl. `metric_aggs`), `view_index` ((screen,view)→pivot→base), `consistency` (per-pivot verdict), `base_summary`. Exact-key lookups — no RAG/vectors. |
| `compose.py --catalog <db>` | Looks up the pivot's verdict in the catalog and **injects the consistency link into the emitted SQL** (✓ / ⚠ outlier / ⚠ no-op), so the query itself carries the warning. |

## Catalog (how this scales to many modules)

`build_catalog.py` is the shared fact store the composer, checker, and UI all
read by exact key — so adding modules = writing parsers + rebuilding the
catalog, not smarter retrieval. Rebuild:

    python3 build_catalog.py --config-dir <trd-configs>   # -> customers/TRD/lineage/catalog.db

The `.db` is gitignored (regenerable, like the lineage graph). Note: SQLite
needs a real disk — rebuild it locally; it can't be written across the Cowork
mount. Linking a picked view to its consistency verdict is then one join:

    (screen,view) --view_index--> pivot --consistency--> verdict + siblings

## Use

    CFG=/path/to/trd-configs
    # 1) inspect a request
    python3 listdata_parse.py "<pivot3/listData URL from the network tab or logs>"
    # 2) inspect a pivot's contract
    python3 pivot_contract.py --config-dir $CFG --pivot HistoryFit
    # 3) compose the validation query to run yourself
    python3 compose.py --config-dir $CFG \
      --url "api/pivot3/listData?aggBy=level%3Astylecolor&appName=Assortment&defnId=HistoryFit"

`defnId` may be a pivot **or** a model — compose resolves a model to its
`pivotDefn` automatically. Set the `:HISTORY_WEEKS` window to match the UI
before running. Higher product grains (class/department) are flagged as needing
a product-hierarchy join (M_Meta) — stylecolor/style resolve directly.

## Findings (surfaced with NO DB access)

`criteria_consistency.py --glob History` on TRD reports:

- **base `trd_p_history_agg` — INCONSISTENT (17 pivots, 2 variants):** 12 filter
  at `(sum(dmd_u) > 10 or … > 5)` (HistoryFit family); 5 (CatRecap
  Snapshot/ALTERED_STATE variants) filter at `> 0`. Same base, different
  qualification thresholds.
- **base `trd_p_history_sku_agg` — INCONSISTENT (6 pivots):** 4 at `>10/>5`,
  2 at `>0`.
- **5 no-op criteria** (filtering effectively disabled):
  `HistoryAggregateViewsNestedAttributeStyleColor` (+Snapshot OP/RP) and
  `..._for_CatRecap` use `> -10`; **`HistoryInfoGraph` uses literally `1>0`** —
  the exact SUP-4486 second-defect signature.

These are the "counts don't reconcile across screens" class (SUP-4486/4202),
caught statically from config alone. Intentional vs. bug is a business call per
pivot — the checker's job is to make every divergence visible.

## Next

- **Product-hierarchy join** (needs M_Meta gap #3) for class/dept grains +
  `topMembers` scoping.
- **View-contract linter** — extend the checker to viewdefn rollUp/formula grain
  mismatches (the `sum(1)` SUP-4202 class).
- **UI**: extend `tooling/lineage-viz` — pick screen/view/scope → show the
  composed SQL + provenance + any consistency warnings for that base.
