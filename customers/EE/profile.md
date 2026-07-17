---
client: EE
name: Evereve
status: active
---

# EE (Evereve) — customer profile

## Repos (clone into repos/ or point at local copies)

| Layer | Repo | Notes |
|---|---|---|
| Config layer | evereve-configs | branch `assortment-planning`; github.com/s5-stratos/evereve-configs |
| Frontend | assortmentui | shared product repo, not per-client; github.com/s5-stratos/assortmentui |
| ETL | (not yet identified) | fill in when an ETL-routed EE ticket comes up |

## Environments

- QA: `qa.evereve.oci.s5stratos.com`
- Dev: `dev.evereve.oci.s5stratos.com`
- Lower-env config source of truth: **OCI bucket, not git** — bucket referenced in
  prior notes as `evereve-qa-config` — knowledge/runbooks/fetch-live-config.md
  (not yet exercised for EE as of SUP-3928; runbook's OCI commands are still
  template-only, fill in once run for this client)

## Table / naming conventions

- Client prefix `eve_` on ClickHouse/Postgres tables (`eve_p_*`, `eve_ma_*`, `eve_h_*`)
  — confirmed via [sup-4000-solution-note.md](../../knowledge/notes/sup-4000-solution-note.md)

## Known quirks

- Style-level editable grids (Cloning breadcrumb, Assortment by Floorset Rec-Only
  tabs) define "Style Description" (`member:style:description`) with either
  `inputType: "text"` or no `inputType` at all, while "Style ID"
  (`member:style:name`) uses `inputType: "textValidatorAsync"` and "Color ID"
  uses `inputType: "validValues"` — this asymmetry is the root cause pattern for
  SUP-3928 (bulk paste silently no-ops on Style Description but works on Color).
  See [knowledge/notes/](../../knowledge/notes/) once the SUP-3928 retro lands.
- `IS_REMOVABLE_${SESSION_ID}` runtime-injected INNER JOIN can silently drop
  Receipt Units rollups for zero-on-hand/zero-on-order/unpublished stylecolors
  in Assortment by Floorset — see sup-4000-solution-note.md Gotchas.

## Jira

Project SUP; summary tag `[EE]`.
