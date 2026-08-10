# Idea Bucket

Enhancements to consider later. Add freely; promote to a build when ready.
Status: 💡 idea · 🔬 investigated (feasibility known) · 🏗️ building · ✅ done

---

## 💡 Config-verify harness (static config validation, no data needed)
Run schema + binding + FreeMarker + grain checks on any confdefn/viewdefn/
pivotdefn change. Runs in sandbox / laptop / CI on every config PR — the
"shift-left" of what a QA deploy catches, in seconds, no data/backend/
browser. Proven feasible: validated a real TRD confdefn against the repo's
`confdefnschema.json` with ajv in the sandbox. Note: the committed
confdefnschema.json is stale vs live config (flags "additional properties")
— regenerate it via `configuration-schemas` exporter (`tsx exporter/export.ts`).
Wire as a skill the VALIDATION gate calls for config fixes.
Source: session 2026-07.

## 🔬 Pivot-file lineage (temp-table dependency graph)
Pivotdefns build many session temp tables in dependency order, consumed by
views. Goal: a fine-grained lineage graph of temp-table dependencies within
and across pivots.
**Investigated 2026-07 — verdict: build it STATICALLY, don't reuse UI code.**
- UI's pivotService.ts / pivotWorker.ts are thin HTTP clients (call
  /asst/api/pivot3/listData); they do NOT parse pivotdefns or run SQL.
  Real execution is in the BACKEND service (c.d.s.p.PivotExecutor /
  PivotTableManager) — repo not available. So not reusable.
- BUT ordering is declared in the pivotdefn itself: stages run in order
  prologueSQL → prologueSQLs[] → aggregationSQLs[] → reverseAggSQLs[] →
  epilogueSQL; each `CREATE TABLE ${TENANT_ID}_X_${SESSION_ID}` + `FROM`/
  `JOIN` gives the temp-table DAG. Topological read of CREATE-vs-FROM
  across stages (after resolving <#include> .ftl, which our config
  extractor already does) yields the graph — no backend, no data.
- Approach: extend tooling/lineage (config extractor) to parse per-pivot
  stage SQL at temp-table grain → intra-pivot DAG + link outputs to the
  real CH tables (already have the coarse pivot→CH edges).
- **UPDATE (darwin repo now available):** the exact algorithm exists in
  `darwin/assortment/.../service/pivot/PivotScheduler.java` — it builds a
  jgrapht `DirectedAcyclicGraph` from each statement's provided/modified/
  dependency tables (`PivotElement.getProvidedTables/getModifiedTables/
  getDependencyTables`), with DROPs as cut points. Its rules are
  documented in `PivotScheduler.java:20-60`. Two build options now:
  (a) PORT that logic to our Python extractor (rules are all there), or
  (b) call darwin's own parser/scheduler headless to emit the graph.
  Also confirmed: session table naming is
  `tenantId_pivotId_dimension_sessionId` (PivotParamGenerator.java:174).
Value: "why is this metric wrong" inside an 8000-line pivot becomes a
navigable temp-table graph instead of manual SQL reading.
Source: session 2026-07; darwin reviewed 2026-07.

---
## 🔬 Pivot SQL query builder (standalone runnable debug SQL)
Turn a pivotdefn (chain of CREATE TABLE X ... then use X, temp tables
dropped at runtime) into SQL an engineer can run manually to verify
transformation logic / validate data — because the runtime temp tables
are Memory-engine and dropped, so you can't inspect them post-hoc.
**Verdict (investigated 2026-07, grounded in real trd-configs pivots):
feasible — but as "persist-and-inspect", NOT a pure CTE rewrite.**

Why not pure WITH/CTE: measured across pivot/:
- 5,994 `CREATE TABLE ${TENANT_ID}_X_${SESSION_ID}` temps (the dominant
  pattern — CTE-friendly in isolation), BUT
- 20 `INSERT INTO ${TENANT_ID}_...` = multi-write temp tables (CREATE then
  add rows) — CTEs are immutable, can't model these.
- 57 files create tables inside `<#list>` loops = a DYNAMIC number of
  tables (unknown until params bound) — static CTE rewrite can't size it.
- 15k `ENGINE=Memory`; 17 joinGet/dictGet (need dictionaries loaded).

The killer dependency — SCOPE BINDING: pivots reference session scope
tables everywhere (${SCOPED_PRODUCT} ×629, ${PRODUCT_TABLENAME} ×421,
${LOCATION_TABLENAME} ×121, time windows…). These are built by the
runtime from the user's scope selection. **No concrete scope (product ids
+ location ids + time range) = no runnable SQL.** So the builder MUST take
a scope and materialize those scope tables first.

Recommended design (persist-and-inspect):
1. Bind a concrete scope (from the ticket's repro steps or a chosen one).
2. Expand FreeMarker with real params — **reuse darwin's own
   PivotTemplatizer + PivotParamGenerator** for exact-runtime fidelity
   (don't reimplement FreeMarker+param-gen in Python — it would drift).
3. Materialize the scope tables; keep the CREATE-table chain but redirect
   temps into a per-user **scratch schema** (survives, isolated); STRIP
   the epilogue DROPs/TRUNCATEs.
4. Engineer runs it, then `SELECT * FROM scratch.<tenant>_X_<id>` to
   inspect any intermediate; a teardown drops the scratch schema.
This handles multi-write temps, loops, and Memory-engine uniformly
(it's just the real execution minus teardown). Optional CTE rewrite is a
nice-to-have for the many single-consumer pure-SELECT chains.

Edge cases to handle: scope binding (chief); FreeMarker `<#if>` branches
(SQL varies by params → must bind); loop-generated tables; multi-write
temps; Memory-engine + drops; joinGet/dictGet dictionary availability;
session-id collisions (namespace per user); cleanup of scratch schema;
scope resolution may need PG (M_Meta) not just CH; **read-only DB account
can't CREATE — needs a write grant limited to the scratch schema** (keep
it separate from the read-only MCP user).

Best use cases: "why is this number wrong" (run for reporter's exact
scope, SELECT the temp table that computes the metric, compare to base —
the SUP-4202/4210 class); stage-by-stage transform verification; pre/post
config-change diff (row-count/checksum a temp table before & after — feeds
the VALIDATION gate). Pairs with pivot-file lineage: that graph says WHICH
temp table to inspect; this builder lets you actually query it.

Improvements: "stop after table X" mode (build only up to the temp of
interest); auto-namespaced scratch schema + auto-cleanup; **strongly
consider proposing a darwin "debug-SQL" endpoint/CLI** (pivotId + scope →
expanded, teardown-stripped SQL) since darwin already owns the parser +
templatizer + scheduler — a small platform feature beats a drift-prone
reimplementation. Wire into validate-fix for pivot config changes.
Source: session 2026-07.

<!-- add new ideas above this line -->
