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
