# Evidence Matrix — deterministic "what to gather", by (type × component)

A lookup, not a judgment. Given the ticket's `type` and `component` (from
the router), this table says exactly what evidence is REQUIRED before the
root-cause gate can pass, and the exact command/query to obtain it. The
triage skill reads this, records each as `requested_evidence[]` in
state.json, and the confidence score penalizes anything still outstanding.

Rule: **request only what's needed for this cell, in one batched ask.**
Never ask for what Jira already answers.

## By component (the primary axis)

### component = ETL  (symptom: data wrong/stale/missing EVERYWHERE)
Required evidence:
1. **Lineage of the affected table(s)** — `query.py upstream <table>` /
   `impact <table>`. (self-serve, no user needed)
2. **Which batch flow + last run** — the `flows` on the edges; ask reporter
   for the batch date/log if a run failed.
3. **Actual row sample** from the suspect table (if data values disputed):
   ```
   CLIENT=trd vsql -c "select ... from <table> where <keys> limit 20"
   CLIENT=trd psql  -c "select ... from <table> where <keys> limit 20"
   ```
4. If "record disappeared after batch" → check the `_existing` round-trip +
   inbound rejects (see note SUP-4254 pattern).
Cross-check query to prove/disprove: compare the value across the pipeline
(Vertica staging → PG → CH) with the same key.

### component = Config  (symptom: wrong on ONE view/screen, right elsewhere)
Required evidence:
1. **The exact screen + view** (confdefn path) and the viewdefn/pivot behind
   it — resolve via combined lineage or `components-catalog.md`.
2. **App/runtime logs** for the failing action — ask reporter for the
   `getAvailableSelections` / pivot error from assortment-api logs, or a
   HAR/network capture.
3. **Lower-env check**: is this QA/staging? → **fetch OCI live config and
   diff vs git** (fetch-live-config.md) — config drift is the #1 cause.
4. **DB cross-check query** to confirm the data is correct underneath (so we
   isolate config vs data):
   ```
   CLIENT=trd clickhouse-client --query "select <metric> from <ch_table> where <scope> limit 20"
   ```
5. For a metric/count grain bug → check pivot `bottomLevels` vs viewdefn
   `formula` (the SUP-4202/4210 class).

### component = Frontend  (symptom: doesn't refresh / interaction / render)
Required evidence:
1. **Exact repro steps + screenshot/Loom** from the ticket.
2. **Browser console + network** capture of the failing action.
3. Confirm data is correct via API/DB (isolate render vs data).
4. If reproducible → a local UI run against the env (local-ui-setup.md).

### component = Backend (darwin)  (symptom: pivot exec, filter values, cache)
Required evidence:
1. **assortment-api log** with the `com.darwin.*` stack / failing SQL.
2. The pivotdefn + the generated SQL from the log.
3. Confirm the behavior in darwin source (darwin-primer.md) — observed, not
   inferred.

### component = DB / triggers  (symptom: "value changed by itself")
Required evidence:
1. The trigger/function on the table (customers/<CID>/db/README.md + schema).
2. Before/after of the row; check `pg_trigger_depth` + bulk-load path.

## By type (modifiers)

- **data-issue** → always needs a DB row sample or query result proving the
  wrong value (no fix on a disputed value without the actual numbers).
- **bug** → needs repro (steps/log/screenshot) + the code location.
- **enhancement / config-change** → needs the acceptance criteria confirmed
  + a blast-radius (lineage impact) of the change + a validation plan.
- **deploy** → needs the target env + the deploy artifact/checklist; usually
  a runbook, not a diagnosis.
- **question** → answer from knowledge + cite; no fix.

## Environment modifier

- **qa / staging** → git may NOT match; fetch OCI live config / query live DB
  and diff before concluding (drift).
- **prod** → repo is more trustworthy; still confirm with a read-only query
  where possible; never run writes.

## The gate

The root-cause gate passes only when every REQUIRED item for the cell is
`received` (or `na`) AND the root cause cites ≥1 resolved evidence.
Outstanding required items → confidence penalty → gate blocked.
