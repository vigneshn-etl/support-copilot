# S5 Stratos Platform Primer — for an AI agent

A portable, self-contained briefing so an agent can reason about our
retail-planning SaaS (products: **Assortment, Allocation, MFP**) without
prior context. The **configuration layer** is the focus; the ETL and UI
layers are described enough to place it. Every structural claim here was
verified against real code; where behavior is inferred it is marked.

---

## 0. The 60-second mental model

The product is a **config-driven planning application**. The same compiled
React frontend and backend service serve every retail customer (tenant);
what each customer sees is defined by **configuration files**, not custom
code. Data flows: nightly/weekly **ETL** loads three databases →
**configuration** files describe how to query and present that data →
the **frontend** renders it.

```
 inbound files ──ETL──▶ Vertica ──▶ Postgres ──▶ ClickHouse
                                       │              │
                        (M_Meta + dims/masters)   (metrics/facts)
                                       │              │
                                   CONFIGURATION LAYER (per tenant)
                          confdefn → view + model → pivot(SQL) ──▶ backend
                                       │
                                   React frontend (generic components)
```

Three ideas unlock almost every ticket:

1. **IDs are load-bearing; names are display-only.** Internal codes (a
   member id like `FP`, a table column, a defn filename reference) drive
   queries, saved user selections, and joins. Renaming an id breaks
   things; changing a display *name* is safe. Fix labels via the name;
   never touch ids.
2. **The database is rebuilt on a schedule.** ETL drops & reloads
   Postgres dimension/master tables from source files every batch, so a
   direct DB edit is temporary — the durable fix is upstream (a source
   CSV or the ETL SQL). This also makes a DB `UPDATE` a perfect
   *self-reverting* experiment in a lower environment.
3. **Lower environments drift from git.** QA/staging config lives in an
   OCI bucket and gets manual hotfixes; the git repo may not match. For
   env-specific debugging, fetch the live config and diff it against the
   repo before concluding anything.

---

## 1. The configuration layer (the core)

An MVC-ish layer of JSON/DSL files, one set per tenant, sitting between
the databases and the UI. **Most client-reported metric/display issues
are fixed here**, not in ETL or the frontend.

### 1.1 The quartet (screen ← data)

```
confdefn ──▶ model ──▶ pivot ──▶ ClickHouse tables
    │                              (generated SQL)
    └──▶ view(s)  (presentation: columns, formats, aggregates)
```

| File | Dir | Role |
|---|---|---|
| `*.confdefn` | `uidefn/conf/` | **App shell.** Tabs → sections → views. Each view names a `component` (a React component) and wires it to `defns: { model, view[], subheader{groupBy,sortBy,...} }`. One confdefn = one app. |
| `*.viewdefn` | `uidefn/view/` | **Presentation.** Grid columns, `dataIndex` (which field), `renderer` (format), and client-side aggregate `formula`s (rollUp/groupBy). |
| `*.modeldefn` | `uidefn/model/` | **Binding.** Names the `pivotDefn` + a typed field list. The bridge from a screen to its data query. |
| `*.pivotdefn` (+ `pivot/include/*.ftl`) | `pivot/` (top level!) | **Data.** FreeMarker-templated **ClickHouse SQL**. `bottomLevels` set the query grain per dimension. `params.*` blocks build metric SQL. |
| `M_Meta.conf` | `conf/` (top level) | **Postgres metadata registry:** tenant, dimensions, hierarchies, levels. Resolves `attribute:*`/`member:*` field references to Postgres. |
| `*.filterdefn` | `uidefn/filter/` | Filter panel definitions (which filters a screen shows). |
| `*.groovy` | `plugins/` | modification / post_pivot hooks (behavior not in the JSON). |
| `mfp/ mfp_td/ target_setting/` | — | A **second** config system (JSON-modules) for the MFP-family apps: `modules.json` (orchestrator), `metrics.json` (registry), etc. |

### 1.2 Rules and traps (each one prevents a class of bug)

- **Filename is identity.** A file's internal `id` field is often a stale
  copy-paste (e.g. `AssortmentSummary.modeldefn` may say
  `id: AssortmentFitStyle`). **Resolve references by filename, never by
  the `id` field.**
- **Template variables:** `${TENANT_ID}` = the client prefix (e.g.
  `trd`); `${SESSION_ID}` = a per-request id; `X_${SESSION_ID}` = a
  session-scoped temp table the pivot creates itself.
- **ClickHouse table naming:** pivots read `trd_x` (a distributed/view
  wrapper); ETL loads `trd_x_tbl` (the local table). **Same logical
  table** — a common source of "table doesn't exist" confusion.
- **The pivot `params.BASE_*` blocks mirror ETL session tables.** The
  metric SQL in a pivot must match the columns the ETL produces. Change
  one side → check the other.
- **Dead config variants:** files ending `_working/_loft/_OG/_copy/_LG/
  _lastgood/_WIP` are backups the runtime ignores. Confirm a file is
  actually referenced by a confdefn before editing; unreferenced = dead.
- **Aggregate grain bug class:** a viewdefn `formula: "sum(1)"` counts
  ROWS. It's only correct if the pivot emits exactly one row per entity.
  If the pivot's `bottomLevels` include e.g. `TimeStd:Week`, rows are at
  week grain and the count inflates by the number of weeks in scope.
  Always check pivot grain before trusting any count/aggregate metric.
- **Subsidiaries:** some tenants have sibling environments that carry
  their own copies of the same viewdefns (e.g. AEO → UNS, TSN, AER). A
  config fix must be replicated to every sibling or it "still fails in
  QA."

### 1.3 The frontend components a confdefn can use

The frontend exposes a fixed registry of ~54 components (validated
against its zod schemas). A confdefn view picks one via `component: "X"`
and passes `componentProps`. Common ones: `Worklist` (list + detail
panes), `GridView` (tabular), `SummaryView`/`CollectionView`/`CanvasView`
(cards), `NestedAttribute`/`NestedView` (nested grids), `TopTYvsLY`/
`FlowType` (grouped cards), `ConfigurableGrid` (API-driven editable grid,
different contract — no `defns`), `MfpSummaryGrid` (MFP planning grid,
uses `viewParams` not `defns`). A `component` name not in the registry =
runtime "Component X not found". A `model`/`view` name with no matching
file = binding-resolution error when the screen opens.

### 1.4 How to read a config error (decision tree)

| Error hallmark | File type | Fix |
|---|---|---|
| `SyntaxError: Unexpected token` | any JSON config | trailing comma / stray char |
| `Schema validation failed` | any JSON config | missing required field / wrong type |
| `Definition not found: X` | the file naming X | grep the repo for X; fix the typo |
| `FreeMarker template error` | pivotdefn / .ftl | unbalanced `<#if>` or `${var}` typo |
| `DB::Exception` (ClickHouse) | pivotdefn | empty `IN()`, wrong table, missing CAST |
| `Component X not found` | confdefn | component-name spelling vs registry |
| No error, wrong numbers | pivot/model/view | work backwards: pivot SQL → model fields → view dataIndex/formula |

JSON is strict: no trailing commas, no comments, double-quoted keys and
strings. A schema at the config repo root validates confdefns
(`npx ajv validate -s confdefnschema.json -d "uidefn/conf/*.confdefn"`).

---

## 2. The ETL layer (context)

Shell scripts orchestrating SQL across three databases, per tenant.

- **Flow:** inbound flat files → **Vertica** (staging `*_IN_*` + transform
  to `*_tbl`/`*_h_*`/`*_d_*`) → **Postgres** (the app DB) → **ClickHouse**
  (analytics/serving). Cross-database movement is via intermediate TSV/CSV
  files, never DB links.
- **Batch flows:** `weekly.sh`, `daily.sh`, `intraday.sh`, `nightly.sh`,
  `cyclic.sh` (+ allocation/fullload variants). A table's "flow" = which
  of these produces it.
- **Constant tables:** small reference data (e.g. `trd_d_prodlife` with
  the price-status members) is loaded from CSVs in `constant_tables/`.
  These CSVs are the durable source for such values; deploy changes via
  the standard "Deploy Constant Tables to Production" process.
- **The `_existing` round-trip:** before a rebuild, current Postgres state
  is exported back into Vertica as `*_existing` tables and MERGEd with the
  fresh build — this preserves user edits and rows that dropped out of the
  feed. First suspect for "a record disappeared after batch."
- **Column position matters:** the Vertica→PG `\copy` and PG→CH loads map
  columns **by ordinal position** (headers ignored). Any new column must
  be appended LAST in every object along the chain, or every following
  column silently shifts.
- **Postgres triggers/functions hold hidden logic.** Some columns are
  recomputed server-side on update (lifecycle weeks, effective prices,
  worklist sync) — logic that exists in NO repo, only in the live DB
  schema. Suspect these for "a value changed by itself."

## 3. The UI layer (context)

- A **pnpm monorepo**, React + TypeScript + Vite, Redux-Toolkit +
  redux-observable epics, **AG Grid Enterprise** for grids.
- **Config-driven:** generic components (`ConfigurableGrid`,
  `SummaryView`, …) are instantiated by the `component` field in
  confdefns; the app fetches the tenant's config at runtime.
- The `component` string is the join key between the config layer and the
  frontend, exactly as ClickHouse table names join ETL and config.
- A separate **backend service** (its own repo, often not in hand)
  actually executes pivots (FreeMarker → ClickHouse), runs groovy plugins,
  and serves config + data to the UI. When a question is about *how the
  platform executes* a config (grain orchestration, plugin order, caching,
  filter option assembly), that answer lives in the backend — say so
  rather than guessing.
- **Local repro:** the UI can run locally against any client environment
  via a Vite dev proxy (`.env`: `VITE_ASST_PROXY_TO=<env-url>`), which is
  the way to reproduce and fix frontend-rendering bugs with real data.

---

## 4. How to route a ticket (which layer?)

| Symptom | Likely layer |
|---|---|
| Wrong number on EVERY screen that shows it | **ETL/data** (trace the table's pipeline) |
| Metric/column missing or mislabeled on ONE view | **Config** (viewdefn/model/pivot) |
| Data correct in DB but wrong/stale on screen | **Frontend** or serving-table refresh timing |
| A value changed with no user edit | **DB triggers** |
| Works for other tenants, broken for one | that tenant's **config** or tenant ETL step |
| Wrong in QA only, right in prod (or vice-versa) | **environment drift** — fetch live config/data and diff vs repo |

## 5. Debugging discipline (always)

- **Cite evidence** for every conclusion: file:line, a query result, a log
  excerpt. Separate **observed** from **inferred**.
- **Search prior solutions first** if a knowledge base exists.
- **Confirm, don't assume:** a one-row DB query or a config diff usually
  turns "probably X" into "X". In a lower env, a self-reverting `UPDATE`
  is a safe probe.
- **Validate any fix with before/after evidence** (pre-state captured
  before the change) — an unvalidated fix is a hypothesis.

---

*This primer is a snapshot for cross-agent knowledge sharing. Exact file
names, table names, and tenant lists belong to specific customer repos and
should be confirmed there. Terminology: "CC" = stylecolor; "prodlife /
merchcat" = price status (FP=full price, MD=markdown, OOL=out of line);
"floorset/superset" = time groupings; "TY/LY/LLY" = this/last/last-last
year.*
