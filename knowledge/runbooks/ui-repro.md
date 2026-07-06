# Runbook: reproduce a UI issue

## Interactive (triage-time) — Claude in Chrome
1. User logs into the QA env in Chrome (URLs in knowledge/clients/<CLIENT>.md).
2. Claude follows the ticket's Steps-to-Reproduce, captures what the
   grid/screen actually shows, compares against expected values.
3. Read ticket attachments/Looms first — often faster than live repro.

## Repeatable (evidence + regression) — Playwright
- Harness lives in assortmentui monorepo: `e2e-test/` (+ `e2e-cred-helper`).
- Write the repro as a spec named after the ticket: `e2e-test/.../SUP-XXXX.spec.ts`.
- The spec asserts the CORRECT behavior (it fails while the bug lives,
  passes after the fix) — it becomes the permanent regression test.
- Runs on engineer machine or CI, not inside the agent sandbox
  (network/auth constraints).
