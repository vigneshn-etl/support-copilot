---
name: utd-builder
description: >
  Build the minimal Unit Test Document (.docx) for a SUP ticket: scope used,
  screens checked, metric/column validated, expected vs actual, result, and
  screenshots. Use when the user says "unit test doc", "UTD", "unit testing
  document", "test evidence doc", "document the validation", or at the end of
  validate-fix. Works from a folder of screenshots, from ui-pilot bundles, or
  from scratch.
---

# utd-builder — Unit Test Document

Tool: `tooling/utd_builder/utd.sh` (installs its deps on first run). Format and spec: `tooling/utd_builder/README.md`.

## Pick the input
| Have | Do |
|---|---|
| ui-pilot bundle(s) | `node tooling/ui_pilot/to_utd.js --after <verify-bundle> [--before <repro-bundle>] --build` |
| Folder of screenshots | `tooling/utd_builder/utd.sh init <SUP> --client <C> --shots <dir> --title "<JIRA summary>"` |
| Nothing yet | Ask for a screenshots folder, or offer to capture the screens with ui-pilot |

Screenshot names drive the cases. Example: `01 Assortment Build - Style Color Review - Summary View (after).png`.
- The leading number sets the order.
- ` - ` separates module, screen and view.
- `(before)` / `(after)` label the shot. A before-fix shot is optional.

## Fill the spec (`tickets/<SUP>/utd/<SUP>_UTD.json`)
- `title`, `client`: from the JIRA ticket.
- `scope` (product / location / time, plus filters if any): the scope used in the UI. Take it from the ticket's validation notes or ask. Don't guess from memory.
- For each case:
  - `metric`: the column checked, as the UI labels it.
  - `row`: the member checked, e.g. `Style 477351138.001`.
  - `expected` / `actual`: values or a short phrase.
  - `result`: one of PASS / FAIL / ISSUE / BLOCKED / N/A / INFO.
- Values come from evidence: validate-fix results, DB queries, or the user. **Never invent a number.** If a value is unknown, leave its `<…>` placeholder in place; the build then warns about it.
- Keep it minimal: no explanations or calculations in the document.

## Build
1. `tooling/utd_builder/utd.sh <spec.json> --check`. Errors stop the build; warnings list unfilled fields.
2. `tooling/utd_builder/utd.sh <spec.json>` writes `<SUP>_UTD.docx` next to the spec.
3. Send the .docx to the user (SendUserFile).
4. JIRA: attaching the file is the user's step. Draft a short comment if they want one, and post only after an explicit OK.
