# ui-pilot

Reproduce or verify a ticket in the QA UI from a short YAML scenario, with
Playwright on system Chrome. The output is an evidence bundle that the agent
reads cheaply (`summary.json`) and that `to_utd.js` turns into a unit test
document. **Read-only by default.**

```bash
cd tooling/ui_pilot && PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install   # once
OCI_COMPARTMENT_ID=<ocid> node pilot.js login --client BELK   # M2M token (OCI Vault -> FusionAuth); session -> ~/.ui_pilot/auth (600)
node pilot.js login --client BELK --manual              # fallback: you sign in in a headed window
node pilot.js run scenario.yaml --mode repro            # before fix: expect the bug
node pilot.js run scenario.yaml --mode verify           # after fix: expect correct values
node pilot.js run scenario.yaml --mode capture          # screenshots only
node to_utd.js --after <bundle> [--before <bundle>] --build   # -> tickets/<SUP>/utd/<SUP>_UTD.docx
node test/smoke.js                                      # offline self-test (local fake grid)
```

Flags: `--headed` (watch it), `--trace` (Playwright trace.zip), `--out <dir>`.
Exit: `0` expected verdict · `1` otherwise · `2` bad input · `3` login needed.

## Scenario

See `examples/SUP-4628.yaml`. Top level: `ticket, title, client, env | url,
scope, setScope?, allowWrites, cases[]`. Each case:

| Key | Meaning |
|---|---|
| `module/screen/view`, `metric`, `row` | Labels for the UTD |
| `route` | Hash route (`#/bottom-up/...`) |
| `steps[]` | `search: txt` · `click: txt \| {text\|qa\|role+name\|selector}` · `fill: {…, value}` · `press: Enter` · `waitFor: …` · `wait: ms` · `setScope: {product, location}` · `goto: route` |
| `expect[]` | `cell: {row, col, equals\|notEquals\|contains\|approx(+tol)\|notEmpty}` · `text: {visible\|hidden}` · `noConsoleErrors` · `noFailedRequests` |
| `shot` | `grid` (default) · `main` · `page` · CSS selector |

`cell` finds the AG Grid row by exact cell text (substring as fallback) and the column by header text.
It scrolls the grid to get past row and column virtualization.

## Verdicts

| Mode | All checks pass | Any check fails |
|---|---|---|
| repro | `NOT_REPRODUCED` | `REPRODUCED` |
| verify | `VERIFIED` | `FAILED` |
| capture | `CAPTURED` | — |

A case that errors (no grid, blocked write, timeout) makes the verdict `INCOMPLETE`.

## Bundle (`tickets/<SUP>/ui/<mode>-<stamp>/`)

`summary.json` (verdict, per-case checks, scope from the breadcrumb, error counts)
· `shots/` · `console.json` · `network.json` (every `/api/` call with status and
timing, pivot request bodies, error bodies) · `scenario.yaml` · `trace.zip` (with `--trace`).

## Guards

- Clicks or fills that look like writes (save, submit, publish, delete, plan queue, clone, …)
  and grid-cell edits are refused unless `allowWrites: true`.
- Login follows s5-stratos/qa-automation `docs/auth-setup.md`. The `<vault>-fusionauth` OCI Vault
  secret is exchanged for a FusionAuth M2M token (about 4h), which is injected once via the
  app's `?injectAccessToken=` and saved as a browser session. The token is never printed, and
  it is only stored inside the session file (600). `ACCESS_TOKEN`/`ACCESS_TOKEN_EXPIRE` env
  vars skip OCI. `run` exits 3 when the token has under 5 minutes left. `--manual` is the
  human sign-in fallback.
- Selectors are reused from `assortmentui/e2e-test/src/utils/selectors.ts` and
  `features/scope/scope.ts`.
