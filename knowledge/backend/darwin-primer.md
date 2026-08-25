# Darwin — the backend service (the 4th layer)

Repo: `s5-stratos/darwin` (branch `dev`). Java, Maven multi-module,
Javalin (web) + jdbi (SQL) + jgrapht. **1,384 Java files.** This is the
service the React UI calls (`/asst/api/...`) and that executes pivots →
ClickHouse, serves config, and assembles filter options. Confirmed: every
class from the runtime logs (`com.darwin.service.pivot.PivotExecutor`,
`PivotFilterHandler`, `ConfigDefnLoaderTransportImpl`, …) lives here.

Package abbreviations in logs: `c.d.s.p` = `com.darwin.service.pivot`,
`c.d.w` = `com.darwin.web`, `c.d.c` = `com.darwin.config`,
`c.d.s.f` = `com.darwin.service.filters`.

## Modules

| Module | Role |
|---|---|
| `platform` | shared platform code |
| `assortment` | core domain: config loading, pivot engine, filters, members, access, **agents** |
| `assortment-api` | web layer (`com.darwin.web`): controllers, routers, Javalin app |
| `assortment-planner` | planning services (`com.darwin.service`) |
| `assortment-db-liquibase` | DB migrations (Liquibase) |
| `mfp-core / mfp-api / mfp-assortment / mfp-db` | the MFP product's backend |

Docker targets confirm the deployables: `asst-api`, `asst-planner`,
`asst-migrate`, `mfp-api`, `mfp-migrate`.

## The pivot engine (`com.darwin.service.pivot`)

A full lexer/parser/scheduler/executor for the pivotdefn DSL:

- `PivotLexer` / `PivotParser` / `PivotStatementParser` — tokenize and
  parse pivotdefn SQL into a statement AST (`CreateStatement`,
  `SelectStatement`, `InsertStatement`, `DropStatement`,
  `TruncateStatement`, `AlterStatement`).
- `PivotTemplatizer` — FreeMarker expansion (`${TENANT_ID}` etc.).
- `PivotParamGenerator` — builds runtime params + names the session temp
  tables: `PivotParamGenerator.java:174` →
  `String.format("%s_%s_%s_%s", tenantId, pivotId, dimension, sessionId)`
  = e.g. `trd_AssortmentFit_VLP_PRODUCT_<session>` (matches the logs).
- `PivotScheduler` — **builds a `DirectedAcyclicGraph` (jgrapht) of the
  temp-table dependencies** and orders execution. This is the code the
  pivot-lineage idea wanted (see IDEAS.md). Each `PivotElement` exposes
  `getProvidedTables()` / `getModifiedTables()` / `getDependencyTables()`
  (`PivotElement.java:27/34/41`); the scheduler links `provides <- depends`
  and treats DROPs as "cut points" bounding the dependency search.
- `PivotExecutor` / `PivotService` / `PivotTableManager` — execute the
  ordered statements against ClickHouse and clean up temp tables.

**Implication:** the pivot temp-table DAG is not hidden runtime magic —
its rules are documented in `PivotScheduler.java:20-60` and computed from
provided/modified/dependency tables per statement. We can port that logic
to build pivot lineage statically (IDEAS.md, pivot-file lineage).

### `aggregationSQLs` vs `reverseAggSQLs`

Both are top-level `List<String>` fields on the pivotdefn (`PivotDefn.java:20,21,79-88`),
not per-column config — each element is one raw SQL statement for one
drill/aggregation level of the pivot (coarsest/root down to full grain).
They are **not** a roll-up-vs-push-down-to-detail pair despite the naming —
`PivotTemplatizerImpl.java:85-131` shows both do the same job, indexed from
opposite ends of the drill hierarchy:

- `aggregationSQLs`: index 0 = coarsest/root level; last index = finest
  (reused for any deeper level not explicitly listed). Author top → bottom.
- `reverseAggSQLs`: index 0 = most granular/leaf level; last index =
  coarsest (reused for any shallower level not listed). Author bottom → top.
- **Mutually exclusive at runtime**: `useReverse = !reverseAggSQLs.isEmpty()`
  — if `reverseAggSQLs` is non-empty it wins outright and `aggregationSQLs`
  is ignored. Across ~1,100 pivotdefns in trd/express/belk/evereve/aeo-configs,
  zero files populate both — every author picks one and leaves the other `[]`.
  If both are empty, `PivotTemplatizerImpl` throws
  `ConfigException("pivot has neither aggSQLs nor reverseAggSQLs")` at
  pivot-run time (not at config-load time).
- The near-universal config comment (`// if more levels are specified than
  aggSQLs, the last aggSQL will be used`) documents the clamping behavior
  for both lists.
- `ignoreAggByParams` (used for reports/exports) changes how many levels
  render and from which param set: normally driven by the request's `aggBy`
  groupings with per-level cumulative params; with this flag, driven by the
  SQL list's own length with one flattened param set reused for every level.
- The `TD_`-prefix ⇒ reverseAggSQLs theory (seen in some ticket notes) does
  **not** hold — most `TD_*.pivotdefn` files actually use `aggregationSQLs`;
  there's no naming-based branch in the Java code.
- `bottomLevels` in a pivotdefn is dead as far as this mechanism (and all of
  pivot execution) is concerned — see the note on that key above.

Examples: `trd-configs/pivot/QuickRecon.pivotdefn:4734` (`aggregationSQLs`,
root-first) and `express-configs/pivot/EXP01_POView.pivotdefn:182`
(`reverseAggSQLs`, leaf-first).

## Filters (`com.darwin.service.filters.PivotFilterHandler`)

Confirms (from source) how the filter panel gets its values:

- Filter option strategies by type: range picker, product attribute,
  location attribute, or **member level** (the WARN we saw lists these).
- Attribute filters actually run a pivot against ClickHouse to get
  options (hence CH errors can surface inside `getAvailableSelections`).
- **Level filters** (e.g. Price Status / prodlife): members are fetched
  as **id only** — `memberAccess.getMembers(level).map(Member::getId)`
  (`PivotFilterHandler.java:292-293`) — and built into a `FilterValue`
  with **id passed as both id and name**: `new FilterValue(v, v, ...)`
  (line 316; `FilterValue(String id, String name, ...)`,
  `FilterValue.java:16`).

**This upgrades the filter display-alias finding from inferred to
confirmed-in-source.** The UI renders `name ?? id`; the backend never
populates `name` for level members, so the id always shows. The
platform fix is exactly here: fetch the member's display name and pass it
as the 2nd `FilterValue` arg (and expose it from `MemberAccess`/`Member`).
See knowledge/config-layer/how-filters-work.md.

## Config loading (`com.darwin.config.ConfigDefnLoaderTransportImpl`)

Resolves and caches confdefn/viewdefn/modeldefn/pivotdefn by
`(type, appName, id)` — the "Selected cached path /uidefn/... " log lines.
Selects per-tenant/app config; caches aggressively (why config changes
need a cache refresh to show). Exact repo-vs-OCI-override merge logic is
in `getConfigDefn` / `getConfigDefnFromPath` — worth a deeper read when a
"config changed but UI didn't update" ticket appears.

## Bonus finding — the platform team is already building agents

`com.darwin.agents` contains `AgenticController`, `AgentService`,
`PromptService`, `Conversation`, `Message`, plus a repo-root `prompts/chat`
dir. The product already has an in-app AI/agent surface under active
development. Relevant to the support-copilot initiative — worth aligning
with that team (possible integration point, or at least shared learnings).

## What this repo unlocks for triage

- Backend/pivot execution questions are now answerable from source, not
  inference — drop the "backend repo not available, inferring" caveat for
  darwin-covered behavior.
- Filter, config-caching, member-resolution, and plugin-execution
  questions have a definitive home.
- The pivot-lineage and config-verify ideas both have their reference
  algorithm here.

## Conventions (for a darwin CLAUDE.md later)

- Java + Maven; build per-module. Logs use `com.darwin.*` package paths —
  map log class → source file directly.
- `assortment/` = domain + engine; `assortment-api/` = web endpoints;
  migrations in `assortment-db-liquibase/`.
- Pivotdefn DSL is parsed by darwin's own lexer/parser (not a generic SQL
  lib) — its grammar rules live in `service/pivot/Pivot*Parser`/`Lexer`.
