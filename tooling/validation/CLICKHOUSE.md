# ClickHouse dialect profile (for the composer)

The composed validation queries run on ClickHouse. We don't "translate" SQL —
we reuse the pivot's own CH expressions against the same agg view the UI hits,
so correctness comes from *reuse + let-CH-validate*, not from teaching an LLM
CH. This is the small, curated set of CH rules the composer must respect.
Grounded in the TRD `trd_p_history_agg` schema + HistoryFit pivot.

## 1. Aggregation is per-metric, NOT blanket sum  (the big one)

- **Additive** (flows) → `sum(m)`: demand, shipped/sales, returns, BOPIS, SFS,
  receipts/on-order, end-of-period in-transit.
- **Snapshot / point-in-time** (stock) → `argMax(m, time)`: EOH (end-on-hand),
  store count, CC count. `argMax(m, time)` = the value at the latest week per
  group — summing these over weeks over-counts badly.
- **First-value** → `argMin(m, time)`: BOH (beginning-on-hand).
- Family is detected by `agg_types.py` from the pivot (`sum(m)` vs
  `last_value_m` vs `first_value_m` tokens). Unclassified ⇒ emitted with a
  `-- TODO confirm` (never silently summed).

`time` is the ordering key; confirm per pivot if one orders by something else.

## 2. `time` is a String week id, not a date

`time` is `LowCardinality(String)` (a week label like `202545`), so:
- Filter with `time IN (<week ids>)` — **never** a date `BETWEEN` or date funcs.
- The UI window (`HistoryStart..HistoryEnd` / `HISTORY_WEEKS`) is a set of week
  ids; the composer emits `:HISTORY_WEEKS` as an IN-list placeholder.

## 3. Distinct / counts

- `count(DISTINCT product)` is exact in CH (backed by `uniqExact`).
- On a **Distributed** table, distinct/joins can under/over-count without
  `GLOBAL` or querying the local shard. Our objects (`trd_p_history_agg`) are
  Distributed wrappers → for distinct-heavy checks, confirm against the local
  or use `uniqExact`. Simple `sum`/`GROUP BY` over Distributed is fine.

## 4. Engines / FINAL

- Queryable objects are `Distributed` over `ReplicatedMergeTree`/`MergeTree`
  locals — **not** `ReplacingMergeTree`, so **no `FINAL`/dedup needed** here.
- If a future base table IS `ReplacingMergeTree`/`Collapsing`, add `FINAL` (or
  an argMax dedup) or you'll double-count un-merged parts. Check the engine in
  `customers/<CID>/db/clickhouse_schema.sql` before composing on a new table.

## 5. ARRAY JOIN is inside the view

The array-packed base (`trd_p_history_loc_arr`) is unnested by the `_agg` VIEW
via `ARRAY JOIN`, exposing flat columns. The composer targets the `_agg` view,
so it needs **no** ARRAY JOIN itself. (Only relevant if you ever compose over
the raw `_arr` base.)

## 6. Nullable

`Nullable` columns (e.g. `client_erp_id`) are ignored by aggregates; harmless
for `sum`/`argMax`. Don't `GROUP BY` a Nullable without intent.

## 7. ClickHouse 21.4 compatibility (most of the fleet)

Most TRD/customer CH servers are **21.4** (April 2021). The composer stays
inside a pre-21.4-safe whitelist — keep it there as modules are added.

**Safe (used since long before 21.4):**
- `sum`, `count`, `count(DISTINCT x)`, `uniqExact`, `avg`, `min`, `max`
- `argMax(m, ord)`, `argMin(m, ord)`  ← how we do point-in-time (EOH/BOH)
- `GROUP BY`, `HAVING`, `WHERE`, `IN`, `ORDER BY`, `LIMIT`
- `LowCardinality`, `Array`, `ARRAY JOIN` (inside the view), `CAST`, `toString`

**Avoid on 21.4 (version-sensitive / newer):**
- **Window functions** (`last_value() OVER (…)`, `row_number() OVER`) — were
  EXPERIMENTAL in 21.4 (`allow_experimental_window_functions`), inconsistent.
  → Always use `argMax/argMin` instead (we do). THIS is the main rule.
- Named CTEs used as tables (`WITH x AS (SELECT …) SELECT … FROM x`) — flaky on
  old versions; prefer subqueries.
- `EXCEPT` / `INTERSECT`, `LIMIT … BY` edge cases, and functions added after
  21.4 — don't introduce them in composed queries.

**Version-sensitive rules:**
- `argMax(m, time)` orders by `time`; on 21.4 a `LowCardinality(String)` ordering
  key is fine as long as week ids are fixed-width (e.g. `202545`, lexical =
  chronological). If a pivot orders differently, wrap `toString(time)`.
- `count(DISTINCT)` over a **Distributed** table needs `GLOBAL` or a local-shard
  query for an exact number (true on 21.4 too).
- `EXPLAIN SYNTAX` exists in 21.4, but if a box rejects it, fall back to
  `SELECT … LIMIT 0` / `FORMAT Null` (valid on every version).

**Enforcement:** the composer only emits whitelist constructs; `ch_validate.py`
runs `SELECT version()` + a capability probe (argMax/uniqExact) against the
actual server, so every validation self-confirms the target version.

## Looking up CH behavior (clickhouse-docs MCP)

The `clickhouse-docs` MCP (in `.mcp.json`) exposes ClickHouse's official docs —
use it to confirm function signatures, engine/`FINAL` behavior, `argMax`
semantics, settings, etc. while composing or debugging. It's **docs-only** (no
DB). The docs describe *current* ClickHouse, which is well ahead of the 21.4
fleet, so treat it as "how the concept works" and confirm version-specific
availability with `ch_validate.py` against the actual server (§7).

## Validate with ClickHouse itself

CH's own parser is the authoritative dialect check. Before executing, run
`EXPLAIN SYNTAX <query>` (or `... LIMIT 0` / `FORMAT Null`) — it certifies the
SQL is valid CH + schema-correct without returning data. `ch_validate.py`
wraps this for when read-only access lands. Until then, the CH schema dump
gives static type/engine checks.
