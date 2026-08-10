---
ticket: null   # no SUP ticket filed — ad-hoc prod incident, see filename for ID
title: EE (Evereve) weekly batch fails inserting NULL adj_idx_pred_combo — new stores missing backtest backfill
client: EE
type: data-issue
repos: [etl]
components: [ch/weekly/600_18_AllocAdjEve.sql, bash/weekly/25_600_Weekly_Analytics_Store_Update.sh, run_weekly_without_plan.sh, s5_alloc_backtest_blended_eval_gsu_by_store_deploy, constant_tables/s5_analytics_like_store.csv, eve_an_time_class_sales_rank_tbl_allocation_modified_with_indexes]
symptom: "ClickHouse insert failure ~4hrs into the weekly batch (weekly_without_plan stage): 'Cannot convert NULL value to non-Nullable type ... adj_idx_pred_combo ... CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN'. Batch aborts, oncall paged."
resolved: 2026-08-09
draft: false
---

## Problem

EE (Evereve) weekly batch failed on 2026-08-09, ~4 hours into the run, in
the ClickHouse analytics step. All upstream stages (file transfer, Vertica
load, inbound validation, Postgres load) completed clean — this was the
first failure point. Reported via a pasted prod SSH log, no SUP ticket
filed (see `PROD-` naming note below).

## Diagnosis path

- Isolated the failing statement to `ch/weekly/600_18_AllocAdjEve.sql`:
  `INSERT INTO eve_an_time_class_sales_rank_tbl_allocation_modified_with_indexes`
  joining `eve_an_time_class_sales_rank_tbl_allocation` `ANY LEFT JOIN XT`
  `USING (subclass, location)`, where `XT` computes `adj_idx_pred_combo` from
  a further `LEFT JOIN` to `s5_alloc_backtest_blended_eval_gsu_by_store_deploy`.
  Destination column is non-nullable `Float64`.
- Two possible NULL sources in that join chain — checked both with `LEFT ANTI JOIN`
  count queries against ClickHouse:
  - Path A: `(subclass, location)` pairs with no `slsrnk=3` row at all → **0 pairs**, ruled out.
  - Path B: pairs with `slsrnk=3` but no match in the backtest table → **246 pairs**, confirmed cause.
- Broke the 246 down by location: exactly 82 pairs each for locations **148, 149, 150**
  (82 = full subclass count) — i.e. those 3 stores have **zero** rows in the backtest
  table, not a partial/random data-quality gap.
- Checked `constant_tables/s5_analytics_like_store.csv` (the like-store mapping used
  for new-store bootstrapping): 148/149/150 were already mapped (→80, →67, →116
  respectively) — the mapping step was done, but the corresponding one-time backtest
  backfill never was.
- **Root cause:** same gap as prior ticket **SUP-4074** (`[EE] Store 144 EE needs to
  allocate to it this week` — stores 144-147, May/Jun 2026) — new-store onboarding
  updates the like-store CSV but the backtest table backfill
  (`database_changes/clickhouse/*_SUP-4074_*.sql` precedent) is a separate manual
  step that gets missed.
- Checked whether SUP-4074's PR also changed `600_16_CustomEve.sql` logic (it did, for
  store 144) and whether that change was needed here too. Pulled the diff (PR #191):
  it added (a) a generic "preserve new like-store rows across the
  `eve_an_store_master_tbl_allocation` truncate+reload" block, driven off
  `s5_analytics_like_store.new_location` — not store-specific, already present in
  current code, applies automatically; and (b) a hardcoded `str_grade='X'` date-window
  suppression for store 144 specifically. Confirmed via the follow-up SUP-4074
  stores-145/146/147 commit that (b) is NOT a required recurring pattern — that PR
  only added the backfill script, never touched `600_16_CustomEve.sql`. So (a) needed
  no changes for this ticket, and (b) wasn't needed either.

## Fix

- Backfilled `s5_alloc_backtest_blended_eval_gsu_by_store_deploy` for stores 148, 149,
  150 by copying rows from their mapped like-stores (80, 67, 116), same 3-INSERT
  pattern as the SUP-4074 precedent scripts. Verified source stores had full 82-row
  coverage before copying, and confirmed 82 rows landed for each destination store
  after.
- Resumed the batch without redoing already-completed work: on the prod box
  (`eve-eve-1-prod:/data/external/etl-evereve-batch`), backed up
  `run_weekly_without_plan.sh`, temporarily commented out the steps that had already
  succeeded before the failure point (PG export/load, master load transform, CH table
  loads, PHistory loads, CH rollups — everything before the "Analytics" stage), left
  the failure point onward active, then ran `./weekly.sh -s without_plan`.
  Reasoning: `set -eux` means a script that got as far as line 37 (`600_18...sql`)
  necessarily completed every prior line successfully — safe to skip on resume.
- Batch completed successfully. Reverted the temporary script edit with
  `git restore run_weekly_without_plan.sh` (branch was clean/up-to-date with origin,
  so this was a full, safe revert) — confirmed via `git status`.

## Verification

- Post-backfill count check: `s5_alloc_backtest_blended_eval_gsu_by_store_deploy`
  showed 82 rows each for locations 148/149/150 before restarting the batch.
- Batch (`weekly.sh -s without_plan`) completed without error after the fix; the
  `600_18_AllocAdjEve.sql` insert succeeded.
- `git status` on the prod box confirmed `run_weekly_without_plan.sh` was clean after
  the revert (no leftover temporary edit that would affect next week's scheduled run).

## Knowledge gained (techno-functional)

**Technical:** `s5_alloc_backtest_blended_eval_gsu_by_store_deploy` is a model-output
table keyed by `(subclass, location)`, joined via `LEFT JOIN ... USING` in
`600_18_AllocAdjEve.sql` into a non-nullable destination column. New-store onboarding
for EE (Evereve) has two required, currently-manual steps — (1) add the store to
`s5_analytics_like_store.csv`, (2) one-time backfill of the backtest table by copying
the mapped like-store's rows — and only step 1 failing to happen with step 2 done
would be caught immediately; step 2 being skipped fails silently until the weekly
batch's analytics stage runs, days/weeks later.

**Functional:** the backtest table holds blended sales/GSU prediction indices used to
adjust allocation targets per subclass/store — a brand-new store has no sales history
to derive these from, so the platform's onboarding convention is to borrow ("like
store") a comparable existing store's indices as a cold-start proxy until real history
accumulates.

## Gotchas

- Failure surfaces ~4 hours into the weekly run, at the ClickHouse analytics step —
  easy to mistake for a code regression when it's actually a missed onboarding step
  from potentially weeks earlier.
- `CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN` + `600_18_AllocAdjEve.sql` is close to a
  fingerprint for this exact pattern — check `s5_alloc_backtest_blended_eval_gsu_by_store_deploy`
  coverage for the affected location(s) first.
- Editing a checked-out prod batch script in place (to skip already-completed steps
  on a resume) works, but must be reverted before the next scheduled run — it's the
  same file the automated weekly job uses. Always back up first, always confirm
  `git status` is clean after reverting.
- **Client naming trap:** this client's JIRA/client tag is `EE`, but its repos, app
  URL, GCP project, and table prefix all use `eve`/`evereve`. Working from a prod log
  alone (which only shows `CLIENT=eve`, `evereve.s5stratos.com`, etc.) very nearly
  led to creating a duplicate `customers/EVE/` folder before cross-checking JIRA and
  finding `customers/EE/profile.md` already existed for this same client. Always
  check for an existing customer folder by searching both short codes before creating
  a new one.
- **`PROD-<CLIENT>-<YYYYMMDD>-<slug>.md` naming**: use this instead of `SUP-####.md`
  for incidents worked without a filed JIRA ticket (common for prod batch failures
  caught via log/monitoring before anyone opens a ticket). Use the client's
  **established** short code (check `customers/` first) — not whatever code happens
  to appear in a prod log. If a ticket gets filed later, rename the file to
  `SUP-####.md` and update this row in INDEX.md.
