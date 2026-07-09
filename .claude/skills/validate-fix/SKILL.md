---
name: validate-fix
description: >
  Generate and execute a validation plan for a fix before closing a
  ticket. Use when a fix is ready/implemented, when the user says
  "validate", "test this fix", "is it safe to close", "write validation
  steps", or at stage 6-7 of the ticket workflow. Validation evidence is
  mandatory before any ticket closes.
---

# Validate a fix (workflow stages 6–7)

Rule zero: **capture the PRE state before the fix is applied.** If the
fix already landed, say so and validate against expected values instead.

## 1. Generate the plan (at root-cause time, not after the fix)

Pick the recipe by layer (combine for hybrid):

**ETL / data fix**
- Pre/post snapshot: same aggregate query (counts + a business sum) at
  the affected grain, before and after re-run. (The SUP-4230 pattern:
  dept-level totals pre/post.)
- Spot-check 2-3 specific entities the reporter named, end to end
  (Vertica → PG → CH with the lineage path).
- Regenerate lineage; `diff.py` confirms only intended edges changed.
- Confirm which batch flow(s) must re-run (`flows` on the edges) and that
  downstream steps completed.

**Config fix**
- `npx ajv validate -s confdefnschema.json -d "uidefn/conf/*.confdefn"`
  (and mfp schemas if touched).
- Grain check for any count/aggregate metric: pivot bottomLevels vs
  formula (the SUP-4202 class).
- Grid export comparison: expected vs actual at the aggregate level the
  reporter used.
- Replication check: does this client have subsidiaries/env copies that
  need the same change? (AEO: UNS/TSN/AER — see note SUP-4210.)

**Frontend fix**
- Playwright spec named SUP-XXXX.spec.ts in the assortmentui e2e harness
  asserting the CORRECT behavior (fails pre-fix, passes post-fix).
- Manual repro of the ticket's exact steps on QA (Chrome), screenshot.

**DB fix (trigger/function)**
- Before/after behavior on a test row; check trigger_depth interactions
  and bulk-load paths (triggers disabled during loads?).

## 2. Execute and collect proof

Run what you can (queries via db MCP, ajv, lineage diff, tests). Ask the
engineer to run what you can't (batch re-runs, env deploys). Proof =
numbers, outputs, screenshots — not assertions.

## 3. Post to JIRA

Draft a validation-results comment: plan, results, artifacts, verdict
(PASS/FAIL per check). Get user approval, post it. FAIL on any check =
ticket does not close; loop back.

## 4. Feed the flywheel

The validation recipe that worked goes into the solution note
(ticket-retro) — next similar ticket gets it for free.
