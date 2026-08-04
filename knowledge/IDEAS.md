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
<!-- add new ideas above this line -->
