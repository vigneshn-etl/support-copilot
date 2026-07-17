# Runbook: local UI for bug reproduction

The assortmentui monorepo has first-class support for running the UI
locally against ANY client environment via a Vite dev proxy
(source: assortment-ui/README.md + vite.config.ts:96-125).

## Setup (once)

```bash
cd assortmentui
nvm install && nvm use          # repo pins the node version
npm install -g pnpm@10
pnpm install --frozen-lockfile
```

## Point at a client environment

Create/edit `assortment-ui/.env`:

```bash
VITE_ASST_PROXY_TO=https://qa.torrid.oci.s5stratos.com/
VITE_MFP_PROXY_HOST=https://qa.torrid.oci.s5stratos.com/
```

Then `pnpm start` → local UI at the Vite port, all `/asst` + MFP API
calls proxied to the target env (real backend, real data, real configs).
Switching customer/env = one .env line. Production-build check:
`NODE_ENV=production pnpm build && pnpm preview` (then unset NODE_ENV).

## What this enables for tickets

- **Frontend bugs: full local repro + fix + verify loop.** Breakpoints,
  React devtools, hot reload against the exact QA data that shows the
  bug. Patch code locally, watch the bug die, THEN open the PR — the
  validate-fix Playwright spec can be developed here too.
- **Instrumented evidence**: add console/network logging to narrow a
  bug without touching any environment.
- **Component behavior questions**: answer by running, not inferring
  (e.g. the FilterSectionItem name??id behavior could have been watched
  live).

## What it does NOT give

- Backend/pivot/DB bugs still execute on the proxied environment — the
  local UI just displays them. Config changes still deploy via the
  config service on the env (unclear if a local config-serving mode
  exists — the `/cfg` proxy defaults to localhost:3500, suggesting a
  local config service the platform team may run; ASK them. If it
  exists, local UI + local trd-configs = config repro without deploys —
  huge win, worth confirming).
- Auth: the proxy forwards to the env's login; use your QA credentials.

## Notes

- `VITE_APP_USE_LOCAL_JSON` exists in the env typing but has no consumer
  in current src — likely vestigial; don't rely on it.
- Keep .env out of commits (contains env URLs only, but still).
