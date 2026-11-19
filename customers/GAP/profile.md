# GAP Inc. — group profile

Multi-brand customer, onboarded brand by brand. Each brand is its own tenant:
own config repo, own QA config prefix, own DBs. Confirmed by user 2026-11-16.

| Brand | Code | Status | Customer folder | QA config prefix (`internal-qa-config`, us-chicago-1) |
|---|---|---|---|---|
| Gap | GAP | Live | `customers/GAP/` | `gap/asst/` |
| Old Navy | ONV | Live | `customers/ONV/` | `on/asst/` (prefix is `on`, not `onv`) |
| Gap Outlet | GAO | Live | `customers/GAO/` | `gao/asst/` |

More brands to come; add a row + `customers/<CODE>/` per brand.

Per brand (QA):

| Brand | Config repo (prod branch `assortment_planning`) | CH db | QA UI |
|---|---|---|---|
| GAP | `s5-stratos/gap-configs` | `gap` | https://qa.gap.oci.s5stratos.com/ |
| ONV | `s5-stratos/onv-configs` | `onv` | https://qa.oldnavy.oci.s5stratos.com |
| GAO | `s5-stratos/gao-configs` | `gao` | https://qa.gapoutlet.oci.s5stratos.com/ |

gao-configs was copied from gap-configs (2026-10-11), so config bugs found in one brand often exist in the others.

Notes:
- GAP CH `gap` verified via db_query client `GAP` (2026-11-16). ONV CH auth fails (see ONV profile).
- PG + Vertica read-only user `s5_copilot_ro` wired for GAP/GAO/ONV QA, tested 2026-11-18.
  GAP: all 214 Vertica + 191 PG `public` + 19 `target_setting` tables readable (retested 2026-11-18;
  `target_setting_bkup` intentionally not granted).
  PG tables + `target_setting` are owned by `psql` (`public` schema by `oci_superuser`) — grants must be run as `psql`,
  or they silently no-op with a warning.
- Prefixes verified by `oci os object list --delimiter /` on 2026-11-16.
- DB access goes through the read-only gate keyed by folder name; ClickHouse
  database = lowercase folder name (so `customers/GAO/` → CH db `gao`).
- GAP DB triggers: no revert triggers; BEFORE `scch_*` chain instead; pricing
  propagation; zero price breaks cost saves (see `db/README.md`).
