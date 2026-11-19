---
name: ui-pilot
description: >
  Reproduce or verify a ticket in the client's QA UI with a generated Playwright
  scenario, capturing screenshots, console errors and API/pivot calls as an
  evidence bundle; optionally build the unit test document from it. Use when the
  user says "reproduce", "repro in UI", "check in UI", "verify on screen",
  "capture screenshots", "unit test doc from UI", or at INVESTIGATE (repro) and
  VALIDATION (verify) for UI/config/pivot tickets.
---

# ui-pilot — UI repro / verify / capture

Tool: `tooling/ui_pilot/` (README there). Pairs with `tooling/utd_builder/`.

## Flow
1. **Write the scenario** → `tickets/<SUP>/ui/scenario.yaml` (format: `tooling/ui_pilot/examples/SUP-4628.yaml`).
   - Routes: from the ticket URL/screenshots, or `tooling/validation/route_resolver.py`.
   - Columns: header text exactly as shown (`customers/<CLIENT>/metrics/metric_map*.csv`).
   - Fill `scope` (product/location/time) — it goes into the UTD.
   - Expected values: from the ticket, or from `tooling/validation/validate.py` (DB truth).
2. **Run.** `node tooling/ui_pilot/pilot.js run <scenario> --mode repro` (before the fix) or `--mode verify` (after it).
   - Exit 3 = not logged in or token expired. Ask the **user** to run `OCI_COMPARTMENT_ID=<ocid> node tooling/ui_pilot/pilot.js login --client <C>`. It gets an M2M token from OCI Vault, as in qa-automation. `--manual` is the human sign-in fallback.
   - Never fetch secrets or type credentials yourself.
3. **Read only `summary.json`.** Open `network.json`/`console.json` only for errors, and screenshots only if a check is unclear. This keeps tokens low.
4. **Fix the scenario, not the app.** If a selector or row isn't found, adjust the scenario and rerun. Use Chrome tools to explore only when stuck, then save what you learned back into the scenario.
5. **UTD:** `node tooling/ui_pilot/to_utd.js --after <verify-bundle> [--before <repro-bundle>] --build`.
   - The before-fix bundle is optional.
   - Attaching it to JIRA is a draft; post only after the user approves.

## Rules
- `allowWrites: true` only with the user's explicit OK for that scenario. QA is shared.
- REPRODUCED/VERIFIED is evidence for the gates. Cite the bundle path and the check rows.
- At retro, keep `scenario.yaml` as the ticket's regression asset.
