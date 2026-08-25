# Configuration Layer — Cheat Sheets (Modules 0–7)

Distilled from the internal Configuration Training Curriculum (author:
gautham.vemuganti). Full chapters/slides/exercises live in the Drive
folder (see README.md in this directory). These are the quick references
the triage/debugging skills should grep first.

---

## Module 0 — The Config Tree

**The file types and where they live:**

- `.confdefn` → `uidefn/conf/`
- `.viewdefn` → `uidefn/view/`
- `.modeldefn` → `uidefn/model/`
- `.pivotdefn` → **`pivot/`** (top-level — NOT under `uidefn/`)
- `.filterdefn` → `uidefn/filter/`
- `M_Meta.conf` → top-level `conf/` (NOT `uidefn/conf/`)
- FreeMarker fragments → `pivot/include/*.ftl`

**Backup-variant suffixes to ignore:** `_LG`, `_LG2`, `_lastgood`,
`_pre_<date>`, `_WIP`, `_Trash`, `_OG`. These files are not loaded by the
runtime. Only the unsuffixed file is live.

**The quartet:** confdefn → view + model → pivot. One confdefn = one app.

---

## Module 1 — Fundamentals & Debugging Decision Tree

**JSON strictness rules:** no trailing commas; all keys double-quoted;
strings double-quoted (not single); no `//` or `/* */` comments; no
leading zeros on numbers. `confdefnschema.json` (repo root) catches these
in the IDE when wired.

**Error-source lookup table:**

| Error hallmark in the log | File type | Category | Most common fix |
|---|---|---|---|
| `SyntaxError: Unexpected token` | Any JSON config | JSON parse | Remove trailing comma at line N |
| `Schema validation failed` | Any JSON config | Schema validation | Add missing required field or fix value type |
| `Definition not found: X` | The file mentioning X | Binding resolution | Grep for X across repo; correct the typo |
| `FreeMarker template error` | A pivotdefn or .ftl | Template | Balance `<#if>`/`</#if>` or fix `${var}` typo |
| `DB::Exception` (ClickHouse) | A pivotdefn | SQL | Check empty `IN()`, join keys, type casts |
| `Component X not found` | A confdefn | Component reference | Spelling check vs component catalogue |
| (no error, wrong numbers) | Pivot, model, or view | Logic | Work backward: pivot SQL → model fields → view dataIndex |

**Clone-first principle:** the default authoring posture — clone a working
quartet, modify, never write from scratch without a reference.

---

## Module 2 — Confdefn

**Required top-level fields (5):** `id`, `defaultTab`, `perspectives`,
`tabs`, `fabTypes`. Optional: `version`, `schema`, `showBookmarks`,
`placeholder`, `printSizes`, `flowStatus`, `lookBackPeriods`, `buttons`,
`context`, `perspective`, `workflows`.

**The tab/section/view hierarchy:**

```
tabs[]                         // top nav
  leftNavSections[]            // left sidebar
    views[]                    // individual feature
      component: "..."         // React component
      componentProps: {
        defns: {               // ← QUARTET BINDING
          model: "..."         // → uidefn/model/X.modeldefn
          view: [...]          // → uidefn/view/Y.viewdefn (LIST, not string)
          subheader: { groupBy: "...", sortBy: "...", countLimit: "..." }
        }
        dataApi: { defnId: "..." }   // → pivot/Z.pivotdefn (direct binding)
      }
```

**10 most-common components:** Worklist (top-bar lists), GridView (grids),
NestedAttribute (multi-level nested grids), ConfigurableGrid
(user-configurable), NestedView (composable nested), MfpSummaryGrid,
SummaryView (multi-section), TopTYvsLY, CollectionView (cards),
CanvasView (free-form canvas).

**Schema/IDE setup:**

```json
"json.schemas": [{ "fileMatch": ["*.confdefn"], "url": "./confdefnschema.json" }]
```

CI validation: `npx ajv validate -s confdefnschema.json -d "uidefn/conf/*.confdefn"`

**Common mistakes:** `defns.view` as string instead of list; wrong
`component` for the viewdefn `type`; model name typo (binding resolution
error at load); trailing comma; forgetting `inPerspectives`.

**Reading an 8000-line confdefn cold:** collapse all `tabs[]` → find tab
by `id`/`pathSlot` → expand, collapse `leftNavSections[]` → find section →
find view in `views[]` → read `componentProps.defns`. ~2 minutes.

**Binding errors:** `defns.model = "X"` but no `uidefn/model/X.modeldefn`;
`defns.view = ["X"]` but no `uidefn/view/X.viewdefn`;
`dataApi.defnId = "X"` but no `pivot/X.pivotdefn`. All caught when the
view opens. `grep -r "X" trd-configs/` is the diagnostic.

---

## Module 3 — Viewdefn

**`type` values:** `grid` (workhorse), `groupBy` (chooser sub-view),
`sort`, `rollUp` (summary metric tiles), `companionView` (right panel),
`configure`, `macro`/`metrics` (key-metric tiles), `countLimit` (top-N),
no type = multi-componentType Summary pattern.

**dataIndex namespaces:**

```
measure value          → BARE:                 "net_sls_r"
hierarchy member       → member:<level>:<prop> "member:class:name"
product/loc attribute  → attribute:<attr>:<prop> "attribute:cc_brand:name"
hierarchy level itself → level:<level>         "level:class"  (groupBy only)
```

Property suffixes: `:id` (key), `:name` (display), `:description`.

**Renderers:** `thousand` 1,234 · `usMoney` $1,234.56 · `usMoneyNoCents`
$1,234 · `usMoneyRounded` $1.2K · `percent` 12% · `percentOneDecimal`
12.3% · `twoDecimal` · `oneDecimal` · `arrowPercent` ▲ 5.2% ·
`backgroundFill` (colored cell).

**Grid column properties:** `dataIndex` (required), `text` (required),
`renderer`, `width`, `visible` (default true), `sortable` (false),
`locked` (false), `lockable` (true), `menuDisabled`, `align`,
`draggable`, `resizable`, `hideFromConfigurator`, `xtype`
(`treecolumn`|`description`), `columns` (nested group).

**xtype values:** `treecolumn` (first hierarchy column w/ expand),
`description`, `level` (groupBy), `attribute` (groupBy), `arrowPercent`
(macro tile), `unique` (rollUp distinct count).

**Common mistakes:** dataIndex doesn't match any model field; wrong
namespace prefix; tree column not first; locked + lockable:false;
missing xtype on groupBy entries.

---

## Module 4 — Modeldefn

**Minimum-viable shape:**

```json
{ "id": "X", "historyFlag": false, "pivotDefn": "Y",
  "model": [ { "name": "fieldname", "type": "string|int|float|boolean" } ] }
```

**Three field shapes:** Standard `{"name","type"}`; PlanDefn
`{"name","defnType":"PlanDefn","type","defnId"}` (editable plan-backed);
Derived `{"name","type":"List","behaviorParams":{"deriveDefaultFrom":"Y"}}`.

**Top-level fields:** `model` (required), `pivotDefn` (required 99%),
`historyFlag` (TY/LY/LLY marker), `id`, `contentDimensionId`,
`postPlugins` (handlers in `plugins/post_pivot/X.groovy`),
`additionalDecorations`, `attributeBand`/`colorBands`, `defaultParams`.

**The dataIndex contract:** every viewdefn `dataIndex` must match a model
field `name`; mismatch = empty column. Adding a column requires:
(1) pivot produces the column (check `pivot/<pivotDefn>.pivotdefn`),
(2) matching model field, (3) type matches pivot output.

**Type casing:** `string`/`String` both work; lowercase for new authoring.

**Debugging:** `Pivot definition not found: X` → check `pivotDefn`
spelling vs `pivot/` filenames; note filename ≠ internal `id` in many
files — trust filenames.

---

## Module 5 — Pivotdefn (FreeMarker + ClickHouse)

**Top-level statements:** `id="..."` (matches model.pivotDefn),
`bottomLevels=[...]` (hierarchy bottoms per dimension — documentation only,
**not read by darwin**: `PivotDefn.from()` never parses this key, so it has
zero runtime effect; actual grain comes from the request-time `aggBy` param
via `PivotParamGenerator.computeGroupings()` — see `knowledge/backend/darwin-primer.md`
§ aggregationSQLs/reverseAggSQLs),
`computed={}`, `params.NAME="""..."""`, `prologueSQL`, `prologueSQLs=[]`,
`aggregationSQLs=[]`, `reverseAggSQLs=[]` (one SQL per drill/aggregation
level, root-first vs leaf-first authoring — mutually exclusive, see
darwin-primer.md), `epilogueSQL`.

**FreeMarker directives:** `<#include "x.ftl" />` (from `pivot/include/`),
`<#if X??>...</#if>`, `<#else>`/`<#elseif>`, `<#list X as item>`,
`<#items as k, v>`, `<#sep>`, `<#assign>`, `<#macro>`.

**Interpolation variables:** `${TENANT_ID}` (customer prefix),
`${SESSION_ID}` (per-request), `${SCOPED_PRODUCT}`,
`${SCOPED_PRODUCT_LEVEL}`, `${SCOPED_LOCATION}`, `${SCOPED_LOCATION_LEVEL}`,
`${LEAF_TIME}`, `${PRODUCT_TABLENAME}`, `${LOCATION_TABLENAME}`.

**Session-scoped temp tables:**

```sql
CREATE TABLE IF NOT EXISTS ${TENANT_ID}_<purpose>_${SESSION_ID}
  ENGINE = Memory AS ...
```

Always Memory engine, both IDs for uniqueness, dropped in `epilogueSQL`.

**3 production gotchas:**

1. Companion-click propagation: wrap `RAW.topMembers` in
   `<#if RAW.topMembers??>` to defend against empty IN on `xtype=level`.
2. TotalView AP WAC/cost lookup: skip `CTAS1_/IMU_/RECORD_STATE_PRODUCTS_`
   tables; use raw tables scoped by `AP_PLAN_FINAL` stylecolors.
3. Empty IN() defense (universal): guard every FreeMarker-built IN with
   `<#if myList?? && myList?size gt 0>`.

**ClickHouse patterns:** `ANY LEFT JOIN`, `LIMIT 1 BY <field>` (dedupe),
`CAST(v as Float32)`, `WHERE x IN (subquery)`.

**Debugging:** FreeMarker error → unbalanced `<#if>` (most common) or
`${var}` typo. `DB::Exception` → empty `IN()` (unguarded iteration),
unknown column (typo/wrong table), type mismatch (missing CAST).

---

## Module 6 — Filterdefn, Meta, YAML

**Filterdefn** (`uidefn/filter/`, ~3 per customer, rarely modified):

```json
{ "id": "X", "filterGroups": [ { "id": "Product", "filters": [
  { "id": "merchcat", "type": "level", "name": "Price Status", "highVisibility": true },
  { "id": "class_name", "type": "attribute", "name": "Class" } ] } ] }
```

`type`: `level` | `attribute`; `highVisibility: true` promotes to primary slot.

**Symptom → file lookup:**

| Symptom in the UI | Most likely file |
|---|---|
| Top-bar filter wrong | `uidefn/filter/*.filterdefn` |
| App doesn't load at all | `conf/M_Meta.conf` |
| Timeout / cache behavior wrong | `conf/app_behavior.yml` |
| Scope debug behavior wrong | `conf/scope_stubs.yml` |
| Feature doesn't render | `uidefn/conf/<app>.confdefn` |
| Column missing or wrong | `uidefn/view/*.viewdefn` |
| Data wrong | `uidefn/model/*.modeldefn` + `pivot/*.pivotdefn` |
| Plugin behavior odd | `plugins/post_pivot/*.groovy` |

---

## Module 7 — JSON-Modules Apps (MFP / MFP_TD / Target Setting)

A second config system in the same repo. Key files per app:
`modules.json` (orchestrator, analogous to confdefn), `metrics.json`
(metric registry), `dimensions.json`, `reports.json`, `balance.json`,
`revisions.json`, `default-locks.json`, `mass-workflows.json`,
`localization.json`, `advisories.json`, `subroutines.json` (mfp/mfp_td),
`auth.json` (target_setting only).

**metrics.json essentials:** each metric has `id`, `units`
(`bare|pct|r|u|c`), `type` (`base` = raw aggregation | `derived` =
computed), `seedable`, `formats`, `aggregation` (`agg1`, `agg2`, `axes2`).

**Folder structure:** `mfp/metrics/calc/` = READ-ONLY metrics;
`mfp/metrics/edit/` = EDITABLE. One folder per metric, folder name =
metric `id`.

**Schemas:** `mfp/schemas/*.schema.json` — one per JSON file; wire into
VS Code.

**Common mistakes:** hand-editing `generated/` (overwritten on build);
`sum` aggregation for percentages (use `mean`); missing `formats` block
(raw number rendering); forgetting `seedable: true` on editable metrics.
