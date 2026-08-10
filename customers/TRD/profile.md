---
client: TRD
name: Torrid
status: active
---

# TRD (Torrid) — customer profile

## Repos (see repos.json for exact branches)

| Layer | Repo | Prod branch | Staging/Upgrade | QA |
|---|---|---|---|---|
| ETL | `s5-stratos/etl-trd-batch` | `etl_assortment_planning` | `etl_assortment_planning_Upgrade` | no QA branch → use Upgrade |
| Config | `s5-stratos/trd-configs` | `allocation-configs` | `allocation-configs` | no QA branch → clone + OCI overlay |
| Frontend | `s5-stratos/assortmentui` | (shared) | (shared) | (shared) |
| Backend | `s5-stratos/darwin` | (shared) | (shared) | (shared) |

## Environments

| Env | App URL | Config source |
|---|---|---|
| **QA** | https://qa.torrid.oci.s5stratos.com/ | OCI bucket `internal-qa-config`, folder `trd/asst/` (US Midwest Chicago) |
| **Staging/Upgrade** | https://asst.upgrade.torrid.s5stratos.com/ | OCI bucket `trd-trd-1-staging-config`, folder `trd/asst/` (US East Ashburn) |
| **Prod** | (torrid prod URL) | OCI bucket `trd-trd-1-prod-config`, folder `trd/asst/` (US East Ashburn) |

**Config-source rule (critical):** git branch `allocation-configs` is the
BASE; the running config in each env = that branch **overlaid with the
env's OCI bucket** (drift lives in OCI, not git). For any env-specific
config question, sync the bucket and diff — see
`knowledge/runbooks/fetch-live-config.md`.

## OCI live-config sync (per env)

```bash
# QA:       bucket internal-qa-config       region us-chicago-1  (US Midwest Chicago)
# Staging:  bucket trd-trd-1-staging-config  region us-ashburn-1  (US East Ashburn)
# Prod:     bucket trd-trd-1-prod-config     region us-ashburn-1  (US East Ashburn)
oci os object sync -bn <bucket> --prefix trd/asst/ --dest-dir ./live-config/<env>/
```

## Batch flows

daily.sh, weekly.sh, intraday.sh, nightly.sh, cyclic.sh, allocation_*.sh
(cron calls 12.x_ch_load_phistory* directly). Lineage: run
tooling/lineage/extract.py against the ETL repo; edges carry `flows`.

## Known quirks

- Weekly eohdata path references missing vsql/weekly/510_eoh_data.sql;
  fullload uses 085_eohdata_stylecolor.sql (found 2026-07, verify).
- Client prefix `trd_`; inbound files S5*_ per table_mappings*.json.

## Jira

Project SUP; summary tag `[TRD]`; labels like Torrid_AP.
