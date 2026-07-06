---
client: TRD
name: Torrid
status: active
---

# TRD (Torrid) — customer profile

## Repos (clone into repos/ or point at local copies)

| Layer | Repo | Prototype local path |
|---|---|---|
| ETL | etl-trd-batch | ../etl-trd-batch |
| Config layer | trd-configs | (local clone; also live in OCI bucket — see runbook) |
| Frontend | assortmentui | ../assortmentui (shared product repo, not per-client) |

## Environments

- QA: (fill URL) · Staging: (fill) · Prod: (fill)
- Lower-env config source of truth: **OCI bucket, not git** —
  knowledge/runbooks/fetch-live-config.md

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
