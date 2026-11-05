# utd-builder

Unit Test Document (.docx) from a JSON spec. Minimal by design: scope, a
results table, then one page per test case (screen path, metric, row,
screenshots). No prose.

```bash
# 1. Skeleton from a folder of screenshots (one case per screen; copies shots into the ticket)
tooling/utd_builder/utd.sh init SUP-1234 --client BELK --shots ~/Desktop/SUP-1234-shots --title "<JIRA summary>"
# 2. Fill the <…> fields in tickets/SUP-1234/utd/SUP-1234_UTD.json, then check + build
tooling/utd_builder/utd.sh tickets/SUP-1234/utd/SUP-1234_UTD.json --check
tooling/utd_builder/utd.sh tickets/SUP-1234/utd/SUP-1234_UTD.json      # -> SUP-1234_UTD.docx next to it
node tooling/utd_builder/test/test_build.js                            # self-test
```

`utd.sh` installs `docx` on first run. If `~/.npm` is root-owned, it falls back to a private cache.
From ui-pilot runs: `node tooling/ui_pilot/to_utd.js --after <bundle> [--before <bundle>] --build`.

**Screenshot names → cases** (for `init`): `01 Assortment Build - Style Color Review - Summary View (after).png`
- The leading number sets the order.
- ` - ` (or ` > `, `›`, `__`) separates module, screen and view.
- `(before)` / `(after)` mark Before/After-fix shots of the same screen. Before is optional.

Spec (`examples/template.json`):

| Field | Meaning |
|---|---|
| `ticket`, `title`, `client`, `tested_by`, `date` | Header |
| `environment` | QA URL |
| `scope.product/location/time/filters` | UI scope used (filters optional) |
| `cases[].module/screen/view` | Screen path, rendered `Module › Screen › View` |
| `cases[].metric`, `row` | Metric/column validated, row/member checked |
| `cases[].scope` | Optional per-case scope override |
| `cases[].expected/actual/result` | `PASS` / `FAIL` / `ISSUE` / `BLOCKED` / `N/A` / `INFO` |
| `evidence_only_with_shots` | Optional `true`: evidence pages only for cases that have shots (large sweeps); all cases stay in the results table |
| `cases[].shots[]` | `{label?, path}` — paths relative to the spec file; missing file → placeholder box. After-fix shot is the norm; add a `"Before fix"` shot only when one exists |

Input source is independent: hand-written spec + manual screenshots, or a
ui-pilot evidence bundle (planned) converted to this spec.
Example: `tickets/SUP-4628/utd/SUP-4628_UTD.json`.

**Validation** runs on every build:
- **Errors** stop the build: no ticket, no cases, a case without a screen, a non-image screenshot.
- **Warnings** list unfilled `<…>` fields, missing scope parts, unknown results and missing screenshot files.

`evidence_only_with_shots: true` gives a page only to cases that have screenshots. Use it for large sweeps.
