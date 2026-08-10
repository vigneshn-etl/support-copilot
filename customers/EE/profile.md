---
client: EE
name: Evereve
status: active
---

# EE (Evereve) — customer profile

**Naming note:** JIRA/client tag is `EE`, but the app/table-prefix/CLIENT env
var is `eve_` / `eve` (e.g. `evereve.s5stratos.com`, `s5-evereve` GCP project,
`eve_an_store_master_tbl`). Don't split this into a separate "EVE" customer —
same client, two different short codes for different systems.

## Repos (see repos.json for exact branches)

| Layer | Repo | Prod branch | Staging/Upgrade | QA |
|---|---|---|---|---|
| ETL | `s5-stratos/etl-evereve-batch` | `etl_assortment_planning` | `etl_assortment_planning_upgrade` | no QA branch → use Upgrade |
| Config | `s5-stratos/evereve-configs` | `assortment-planning` | `assortment-planning` | `assortment-planning` |
| Frontend | `s5-stratos/assortmentui` | (shared) | (shared) | (shared) |
| Backend | `s5-stratos/darwin` | (shared) | (shared) | (shared) |

## Environments

| Env | App URL | Config source |
|---|---|---|
| **QA** | https://qa.evereve.oci.s5stratos.com/ | OCI bucket `internal-qa-config` (shared QA bucket across clients), folder `eve/asst/`, region US Midwest Chicago |
| **Staging/Upgrade** | https://asst.upgrade.evereve.s5stratos.com/ | OCI bucket `eve-eve-1-staging-config`, folder `eve/asst/`, region US Midwest Chicago |
| **Prod** | https://evereve.s5stratos.com | OCI bucket `eve-eve-1-prod-config`, folder `eve/asst/`, region US East (Ashburn — `us-ashburn-1` confirmed via prod env dump) |

**Config-source rule (same as TRD):** git branch `assortment-planning` is the
BASE; running config in each env = that branch **overlaid with the env's OCI
bucket** (drift lives in OCI, not git). See `knowledge/runbooks/fetch-live-config.md`.
(Supersedes an earlier guess of `evereve-qa-config` in this file — actual
bucket is `internal-qa-config`, shared across clients.)

## OCI live-config sync (per env)

```bash
# QA:       bucket internal-qa-config       region us-chicago-1  (US Midwest Chicago) — shared bucket, path eve/asst/
# Staging:  bucket eve-eve-1-staging-config  region us-chicago-1  (US Midwest Chicago)
# Prod:     bucket eve-eve-1-prod-config     region us-ashburn-1  (US East Ashburn)
oci os object sync -bn <bucket> --prefix eve/asst/ --dest-dir ./live-config/<env>/
```

## Prod deployment facts (confirmed from a prod SSH log, 2026-08-09)

- `SELF_PROJECT_ID` / GCP project: `s5-evereve`; `SELF_DEPLOYMENT_NAME`: `eve-1-prod`
- OCI tenancy: `ocid1.tenancy.oc1..aaaaaaaa4lvcdln5l64nacislbs32k5r4vxgieg57xmnciyrj755kovld3dq`
- OCI compartment: `eve` / child compartment `eve-1-prod` / region `us-ashburn-1`
- GCS backup bucket: `s5-eve-st-prod-backup`; image bucket: `s5-eve-st-prod-eve-images`; SFTP transfer bucket: `evereve-s5-transfer` (inbound `production/inbound`, outbound `production/outbound`)
- ClickHouse instance: `clickhouse-0`
- Prod box accessed via `ssh eve-prod-processor`, working dir `/data/external`

## Batch flows

`weekly.sh`, `daily.sh`, `intraday.sh`, `cyclic.sh`, `mfp_to_ap_sync.sh`,
`adhoc_planning.sh`. `weekly.sh -s <stage>` stages: check_files → load_inbound
→ validate_inbound → reject_exports → without_plan → load_mfp →
validate_without_plan → bulk_plan → failed_items_replan → validate_bulk_plan
→ daily_exports → completion_email. `run_weekly_without_plan.sh` internally
runs PG export/load, master load transform, CH table/PHistory loads, CH
rollups, then the Analytics stage (`20_analytics.sh` →
`25_600_Weekly_Analytics_Store_Update.sh`, which runs
`ch/weekly/600_16_CustomEve.sql` and `600_18_AllocAdjEve.sql`).

## Table / naming conventions

- Client prefix `eve_` on ClickHouse/Postgres tables (`eve_p_*`, `eve_ma_*`,
  `eve_h_*`, `eve_an_*`) — confirmed via [sup-4000-solution-note.md](../../knowledge/notes/sup-4000-solution-note.md)
  and this session's ETL work.

## Known quirks

- **New-store onboarding requires TWO manual steps that are easy to
  decouple**: (1) add the store to `constant_tables/s5_analytics_like_store.csv`
  (like-store mapping), (2) one-time backfill of
  `s5_alloc_backtest_blended_eval_gsu_by_store_deploy` by copying the mapped
  like-store's rows. Missing step 2 doesn't fail until the weekly batch's
  Analytics stage, days/weeks later. Precedent: SUP-4074 (stores 144-147).
  See `knowledge/notes/PROD-EE-20260809-new-store-backtest-backfill-missing.md`.
- `600_18_AllocAdjEve.sql`'s destination columns (`adj_idx_pred_combo` etc.)
  are non-nullable `Float64` — any LEFT JOIN gap in the backtest/rank chain
  surfaces as `CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN`.
- Style-level editable grids (Cloning breadcrumb, Assortment by Floorset
  Rec-Only tabs) define "Style Description" (`member:style:description`)
  with either `inputType: "text"` or no `inputType` at all, while "Style ID"
  (`member:style:name`) uses `inputType: "textValidatorAsync"` and "Color ID"
  uses `inputType: "validValues"` — this asymmetry is the root cause pattern
  for SUP-3928 (bulk paste silently no-ops on Style Description but works on
  Color). See `knowledge/notes/` once the SUP-3928 retro lands.
- `IS_REMOVABLE_${SESSION_ID}` runtime-injected INNER JOIN can silently drop
  Receipt Units rollups for zero-on-hand/zero-on-order/unpublished
  stylecolors in Assortment by Floorset — see `sup-4000-solution-note.md`
  Gotchas.

## Jira

Project SUP; summary tag `[EE]` (confirmed via SUP-4074: `[EE] Store 144 EE
needs to allocate to it this week...`); label seen: `EE_AP_2023`.
