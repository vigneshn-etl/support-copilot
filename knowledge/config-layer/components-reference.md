# Configuration-Layer Component Reference

**Every fact in this document is validated against three sources** (2026-07):

1. **The contract** — `assortmentui/configuration-schemas/schemas/confdefnComponents.ts`
   + `confdefnComponentProps.ts` + `confdefnView.ts` (zod schemas the platform
   validates configs against)
2. **The runtime** — `assortmentui/assortment-ui/src/services/configuration/bindings.utils.ts`
   (the registry that maps `component` strings to React containers)
3. **Working usage** — all live TRD confdefns (`trd-configs/uidefn/conf/*.confdefn`,
   backup variants excluded), scanned programmatically for usage counts and samples

Samples below are copied verbatim from live TRD config. Re-verify anytime:
component list from `z.literal(...)` in confdefnComponents.ts; usage via a
JSON walk of confdefns collecting `component` values.

---

## 1. The binding contract (applies to every component)

A confdefn view registration:

```json
{
  "id": "SummaryView",              // unique within the section
  "name": "Summary View",           // nav label
  "pathSlot": "summary-view",       // URL segment
  "inPerspectives": ["bottom-up", "top-down"],
  "component": "SummaryView",       // ← MUST match a registry name (§2)
  "componentProps": { ... }         // ← shape validated per component (zod)
}
```

`component` not in the registry ⇒ runtime "Component X not found".
`componentProps` violating the schema ⇒ schema validation failure.

### The `defns` block (most data components require it)

Schema (`DefnProps`, confdefnComponentProps.ts):

| Field | Required | Meaning |
|---|---|---|
| `model` | **yes** (string) | → `uidefn/model/<X>.modeldefn` (empty `""` is schema-legal; component then relies on view defns — seen in NestedAttribute) |
| `view` | **yes** (string **array** — never a bare string) | → `uidefn/view/<Y>.viewdefn` list |
| `subheader` | **yes** (object; `{}` allowed) | all fields optional: `groupBy`, `sortBy`, `rollup`, `pareDown`, `countLimit`, `breadcrumbs`, `extraPivotParams` — each naming a sub-viewdefn |
| `dataApi` | no | direct pivot binding `{ defnId, params, isListData? }` (discriminated union client/list) |
| `assortmentModel` | no | secondary model |

### The `keys` block (identifier components)

`zIdentifierProps` — components that track a selected entity **require**:

```json
"keys": { "idProp": "<field>" }        // REQUIRED
// optional: "descProp", "styleId", "leafIdProp"
```

Required-keys components (schema): CollectionView, NestedView, TopTYvsLY,
FlowType, others composing `zIdentifierProps`. Components composing
`zOptionalIdentifierProps` (CanvasView, SummaryView…) may omit `keys`.

### Common optional mixin props (single-purpose, all optional)

| Prop | Default | From mixin |
|---|---|---|
| `title` / `hideTitle` | per-component default | zHasTitle |
| `showPopover` (style pane) | — | zHasPopover |
| `fabType` | — | zHasFab |
| `workflow` (ties to `confdefn.workflows[key]`) | — | zHasWorkflow |
| `showFlowStatus` | **true** | zHasFlowStatus |
| `showLookBackPeriod` | **true** | zHasLookBackPeriod |
| `allowWorklistFunctionality` | — | zHasWorklistFunctionality |
| `showRangeSelector` | — | zHasRangeSelector |

---

## 2. Complete supported component catalogue (54)

From `confdefnComponents.ts` z.literals; count = occurrences in live TRD
confdefns (0 = supported by software, unused at TRD today).

**Assortment / Hindsighting data views**

| Component | TRD uses | One-liner |
|---|---|---|
| Worklist | 50 | Top-bar item list + companion detail views |
| GridView | 23 | AG-Grid tabular view with grid/list/sort/rollup sub-defns |
| NestedAttribute | 23 | Multi-level attribute-nested aggregation grid |
| ConfigurableGrid | 17 | API-driven editable grid (configApi/dataApi, no defns) |
| NestedView | 14 | Composable nested grid (requires keys.idProp) |
| SummaryView | 8 | Card/summary multi-section view |
| TopTYvsLY | 6 | TY/LY comparison cards (groupingInfo.staticColumns) |
| CollectionView | 5 | Card collection (requires keys.idProp) |
| CanvasView | 4 | Free-form canvas with images |
| FlowType | 4 | Cards grouped by flow status (groupingInfo) |
| FlowSheetByStyle | 4 | Week-by-week flow sheet grid |
| AssortmentAddView | 4 | Add-to-assortment flow |
| ParameterToggles | 3 | Parameter toggle panel |
| CategorySummary | 2 | Category-level summary |
| ProductMix | 2 | Mix breakdown view |
| Productivity | 2 | Productivity quadrant/scatter |
| ParetoSummary / ParetoDetails | 2+2 | Pareto analysis pair |
| FloorsetComparison | 2 | Floorset side-by-side |
| PricingOverTime | 2 | Price events over time |
| NestedOvertime | 2 | Nested over-time grid |
| Summary | 1 | Macro trends summary |
| GeoTrends | 1 | Geographic trends map |
| MacroMix | 1 | Macro mix view |
| TopPerformers | 1 | Top performers list |
| StyleEdit | 1 | Style attribute editor |
| AssortmentCart | 1 | Cart for style adoption |
| ProductDetails | 1 | Single product detail |
| ListView | 1 | Flat list view |
| ExceptionsSummary | 1 | Exception dashboard |
| Reporting | 1 | Reporting shell (propless) |
| ConfigEditor | 1 | In-app config editor (propless) |
| EnhancedOvertime | 0 | Enhanced over-time grid |
| NestedStyleOvertime | 0 | Style-nested over-time |
| AssortmentAddBySearch | 0 | Add via search |
| AssortmentPublish | 0 | Publish workflow |
| SizeEligibilityListGrid | 0 | Size eligibility grid |
| QuickTrends | 0 | Quick trends widget |
| RouteToLocation | 0 | Allocation routing view |
| TargetList | 0 | Target list |
| StyleCollection | 0 | Style collection view |
| SankeyGroupedView | 0 | Sankey flow diagram |
| CollectionAnalysis | 0 | Collection analysis |
| PlanogramSimple | 0 | Simple planogram |
| BulkImport | 0 | Bulk import flow |

**MFP family** (viewParams/JSON-modules world, not defns):
MfpSummaryGrid (76 — the MFP workhorse), MfpFavorite (7),
MfpReviewPlans (7), MfpReviewPrivatePlans (7), MfpMassCopy (7),
MfpMassActualize (7), MfpSplitView (0), MfpSmartPlan (0),
MfpReporting (0).

---

## 3. Deep dives (verbatim TRD samples)

### Worklist (50× — the most-used assortment component)

Minimum viable (real, AssortmentUiConf / HistoryCatRecapCatSummaryWorklist):

```json
{
  "defaultPathSlot": "hist-category-summary",
  "defns": { "model": "HistoryGrid_Companion", "subheader": {},
             "view": ["HistoryCatRecapCatSummaryWorklist"] }
}
```

Mandatory: `defns` (model/view/subheader). Worklist-specific: the view
list defines companion tabs; `defaultPathSlot` picks the landing tab.

### GridView (23×)

```json
{
  "title": "Grid View",
  "defns": {
    "model": "HistoryFit",
    "subheader": { "groupBy": "HistoryStyleColorReviewGroupBy" },
    "view": ["HistoryStyleColorGridViewGrid", "HistoryCompanionListSort",
             "HistoryStyleColorReviewGroupBy", "HistoryRollUp",
             "HistoryStyleColorGridViewList"]
  },
  "showPopover": true
}
```

Convention in the view list: grid + listSort + groupBy + rollUp + list
viewdefns. The `type` of each viewdefn must suit its slot (grid vs rollUp
vs groupBy — see cheatsheets.md Module 3).

### SummaryView (8×) / CanvasView (4×)

Same shape: `defns` with card-details + rollUp views, `subheader` with
groupBy/sortBy. `keys` optional (zOptionalIdentifierProps).

```json
{ "title": "Summary View",
  "defns": { "model": "HistoryFit",
    "subheader": { "groupBy": "HistoryStyleColorReviewGroupBy",
                   "sortBy": "HistoryReviewSortBy" },
    "view": ["HistoryCardViewDetails", "HistoryRollUp"] } }
```

### CollectionView (5×) — keys REQUIRED

```json
{ "defns": { "model": "AssortmentSummary",
    "subheader": { "groupBy": "AssortmentStyleReviewGroupBy",
                   "sortBy": "AssortmentReviewSortBy" },
    "view": ["AssortmentRollUp"] },
  "keys": { "idProp": "member:style:id" },
  "showPopover": true, "fabType": "buttonModalStyles" }
```

### TopTYvsLY (6×) / FlowType (4×) — grouped-card pair

Both require `keys.idProp` and use `groupingInfo` to define column groups:

```json
"keys": { "idProp": "id", "descProp": "description" },
"groupingInfo": { "dataIndex": "s5flowstatus",
                  "staticColumns": ["NEW", "CARRYOVER", "SELL DOWN"] }
```

(TopTYvsLY: `dataIndex: "key"`, staticColumns `["TY","LY"]`.)
`dataIndex` must be a model field; staticColumns must match its values.

### NestedView (14×) — keys REQUIRED

`defns` (grid/configure/list/rollUp views) + `keys: {"idProp": "name"}`.

### NestedAttribute (23×)

`defns` with grid/macro/configure/list views. Note: live TRD uses
`"model": ""` — schema-legal; binding comes via the view defns.

### ConfigurableGrid (17×) — DIFFERENT contract: no `defns`

API-driven: `dataApi` (listData + `defnId` + `params.aggBy`), `configApi`
(url + appName/defnId params), optional `planningApi`,
`topAttributesApi`, `keys` (idProp/leafIdProp), `hideCompanion`,
`showFlowStatus`, `showLookBackPeriod`. See §samples: ReviewDeptStoreMeta.
The grid's columns/behavior come from the viewdefn named by
`configApi.params.defnId` (grain: `params.aggBy` like
`"level:department,level:store"`).

### MfpSummaryGrid (76× — MFP workhorse) — DIFFERENT contract

No `defns`. `viewParams` declares the pivot layout inline: `rows[]` /
`columns[]` of `{dimension, items}` (dimensions: product/location/
metrics/revisions/time; items like `level:department`, metric ids,
revision ids `wp`/`ly-actuals`), `summaryMetrics`, and
`subheader.extraBtns` (["Submit","Save","Import","Comment","Reseed"]).
Metric/revision ids must exist in the MFP metrics registry
(mfp/metrics.json — see cheatsheets.md Module 7).

---

## 4. Choosing a component (task → component)

| Need | Use |
|---|---|
| Tabular data, sorting/grouping | GridView (read-mostly) / ConfigurableGrid (editable, API-driven) |
| Card browsing of styles/CCs | CollectionView / SummaryView / CanvasView |
| TY-vs-LY or flow-status card comparison | TopTYvsLY / FlowType |
| Item list driving a detail pane | Worklist |
| Attribute-nested aggregation | NestedAttribute / NestedView |
| MFP planning grid | MfpSummaryGrid |
| Add styles to assortment | AssortmentAddView (+ AssortmentCart) |

## 5. Authoring mistakes the schema/runtime will catch (and how)

1. `defns.view` as a string → schema error (must be array).
2. Missing `defns.model`/`subheader` on defns components → schema error.
3. Missing `keys.idProp` on CollectionView/NestedView/TopTYvsLY/FlowType
   → schema error.
4. `component` name typo → runtime "Component X not found" (registry).
5. Model/view name that has no file → binding resolution error at view
   open (grep the repo for the name).
6. `groupingInfo.dataIndex` not a model field → empty/broken grouping
   (no schema catch — verify by hand).
7. MFP metric id not in metrics.json → broken tile (no schema catch).

Validate configs before deploy:
`npx ajv validate -s confdefnschema.json -d "uidefn/conf/*.confdefn"`
(repo root schema; the zod schemas are the same contract in the
frontend build.)

---

*Regenerate the usage counts after config changes: JSON-walk the live
confdefns for `component` values. Schema source of truth moves with the
assortmentui monorepo — re-check `confdefnComponents.ts` after frontend
upgrades; components can be added/removed between releases.*
