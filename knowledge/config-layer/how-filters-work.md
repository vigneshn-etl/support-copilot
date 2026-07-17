# How filters work (end to end)

Mechanism doc for the filter panel (Price Status–class filters), assembled
from code (trd-configs, assortmentui, ETL), runtime API logs (TRD QA), the
PG schema, and a live probe (2026-07). Claims tagged **observed** or
*inferred*. Backend service repo not yet in workspace — its internals are
inferred from behavior and should be confirmed there.

## The six layers

### 1. Definition — which filters exist (config repo)

- Per-app filterdefn in `uidefn/filter/` (`AssortmentFilterConfig`,
  `TopDownFilterConfig`), chosen by `appName` at request time and cached
  by the backend (**observed**: `ConfigDefnLoaderTransportImpl - Selected
  cached path ... appName=TDAnalysis`).
- `filterGroups[]` → the panel's tabs (Product / Location / TimeScope).
  Each entry `{id, type, name, highVisibility}` = one filter section.
- `name` here is the SECTION HEADER only ("Price Status") — never the
  checkbox values.
- `type` selects the backend's value-resolution strategy (**observed**
  WARN lists them): `level` | product attribute | location attribute |
  range picker.

### 2. Value resolution — where checkbox options come from (backend)

`FilterController.getAvailableSelections` → `PivotFilterHandler
.getFilterState`, per section by `type`:

- **level** → PG dimension table members. Two queries observed:
  - id-only union: `SELECT id, levelid, indx, 'leafValue' as type FROM
    trd_d_prodlife WHERE levelid='merchcat'` (same pattern for
    trd_d_cluster grade, trd_d_time)
  - rich: `SELECT id, name, description, levelid, indx FROM
    trd_d_prodlife WHERE levelid = ?`
  - *Inferred from probe:* the options payload is built from the id-only
    path — `FilterValue.name` arrives null even when PG `name` is set.
- **attribute** → the backend RUNS A PIVOT against ClickHouse (session
  temp tables and all; **observed**:
  `BU_Hindsighting_FilteredLocationAttributes~str_store_banner` executing
  inside the filter endpoint). Consequences: filter options can fail with
  CH errors (schema drift, missing session tables), and options can carry
  facet counts.

### 3. Rendering (frontend, common-ui)

`Filters` → `FilterSection` → `FilterSectionItem`. Option label =
**`{name ?? id}`** (`FilterSectionItem.tsx:48`); search and sort use the
same `value.name ?? value.id` (**observed**). So the UI fully supports
display aliases — it shows ids only because the backend sends level
options without `name`.

### 4. Selection persistence

Selecting values POSTs `/asst/api/filter` → `UPDATE scope SET
filter_conditions` (PG `scope` table, per user+app; **observed**).
Stored as IDS: `CONDITIONS_BY_DIMENSION={prodlife={merchcat=[FP, MD]}}`.
The scope-bar chip ("Price Status: FP, MD") renders from these stored ids.

### 5. Effect on data (ids are load-bearing)

Pivot execution turns stored conditions into literal id predicates in
generated CH SQL: `prodlife IN ('FP', ...)` (**observed**) — matching id
values stored in CH history-table columns. CH also has
`trd_prodlife_view(_tbl)` (id→merchcat mapping, NO name column), loaded
from Vertica, joined in weekly prep (510) and read by MFP exports.
**Renaming ids breaks everything; renaming names breaks nothing.**

### 6. Dimension data lifecycle

`constant_tables/trd_d_prodlife.csv` (ETL repo) → Vertica
`vsql/weekly/040_prodlife.sql` → csv export → PG `delete + \copy` every
weekly batch. Any PG-only edit is reverted on the next run — which makes
PG UPDATEs useless as fixes but PERFECT as self-reverting QA probes.

## The display-alias gap (probe-proven, TRD QA 2026-07)

Setting `trd_d_prodlife.name='PresN', description='PresD'` for id=FP
changed NOTHING in the UI — checkboxes still show the id. Root cause:
UI renders `name ?? id` and backend never populates `name` for
level-type options. **There is currently NO data-only or config-only way
to alias level-filter display values.**

Fix = small platform (backend) change: include `name` in the level-option
query and map it into `FilterValue.name`. Then per-client aliases become a
constant-table CSV edit (id stays, name changes), deployed via the
standard "Deploy Constant Tables" process. Check the scope-bar chip for
the same treatment when that ships.

## Triage cheat-sheet

| Symptom | Look at |
|---|---|
| Filter section missing / wrong header | filterdefn for that app (`uidefn/filter/`), `name` field |
| Checkbox values wrong/missing (level) | PG `trd_d_<dim>` rows for that levelid; then constant CSV upstream |
| Checkbox values wrong/missing (attribute) | The attribute pivot in the logs — often a CH error (schema drift, missing column) |
| Filter options error/empty panel | Backend log: PivotFilterHandler errors; CH session-table races are transient, missing-column errors are real |
| Values display as codes, want pretty labels | The alias gap above — platform change required |
| Selections not sticking | PG `scope.filter_conditions` for that user/app |
| Filter selected but data unchanged | Generated CH SQL predicates (`prodlife IN (...)`) — ids must match data values |

Related notes: SUP-4202 (grain), weekly-product-master-lineage (dimension
rebuild pattern). Probe technique: self-reverting PG UPDATE (weekly batch
restores constants).
