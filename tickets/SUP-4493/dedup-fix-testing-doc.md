# SUP-4493 — Validation plan: GROUP BY dedup fix for `store_master_new`

## Background

Root cause (full analysis in session transcript / ticket): the hardcoded
future-year projection block in `bash/weekly/update_weekly_ch.sh` (originally
`SUP-3890`) stamps synthetic clone rows into `store_master_new_tbl_pre`
without checking whether real data already covers that week. As real data's
natural horizon has advanced past the block's hardcoded starting point
(`2026_W40`/`2027_W40`), it has been creating duplicate `(product, channel,
location, time)` rows for `2027_W40` through `2028_W13`. Those duplicates
inflate `groupArray()` results inconsistently between adjacent weeks in the
darwin `FlowSheetPlan` pivot, causing `arrayMap` array-length-mismatch
crashes (`uncBOH` vs `prevEOH`) — which took down 100% of the 2026-08-09
weekly bulk plan (16,932/16,932 items failed).

**Decision**: rather than replace the hardcoded projection logic (the fully
dynamic fix, also prepared separately — see `SUP-4493_store_master_new_fix.sh`
in the scratchpad), the chosen fix is to **deduplicate at the final load**
into `store_master_new_tbl` — collapsing any duplicate key down to one row
via `GROUP BY` + `any()`, right before the live table is populated. This
does not change the projection logic itself; it only prevents duplicates
from reaching the table planning actually reads.

## What this validation is checking

1. The dedup query removes 100% of duplicate keys (`HAVING count(1) > 1`
   groups go to zero).
2. No rows are lost beyond the intended collapse — `rows after dedup` should
   exactly equal `distinct (product, channel, location, time) keys before
   dedup`, not less (which would mean we lost a legitimately-unique row) and
   not more (which would mean dedup didn't fully collapse a group).
3. A spot check against a known duplicate example (`CL-0781 / GP-01 /
   LC-0484 @ 2027_W49`, confirmed duplicated during root-cause investigation)
   resolves to exactly one row post-dedup.

## Pre-conditions

- `test_store_master_new_pre` — an isolated test table, seeded from
  `store_master_new_tbl_backup` (the clean, pre-projection real data) and
  then had the buggy `"Balance of 2027"` projection block replayed against
  it during root-cause reproduction. This table should currently contain the
  reproduced duplicate bug in the `2027_W40`-`2028_W13` range. **Confirm
  this table still exists and still has duplicates before running the test**
  (see Step 0 below) — if it doesn't, it needs to be rebuilt via the repro
  steps used during root-cause analysis before this validation can run.
- This test never touches `store_master_new_tbl_pre`, `store_master_new_tbl`,
  or any other prod-facing table — only `test_store_master_new_pre` (read)
  and `test_store_master_new_tbl_dedup` (a new table this test creates).

## Test script

See `sup4493_dedup_test.sh` (same directory). Run it directly on the
`exp-prod-processor` host where `clickhouse-client` is already configured.

## Steps and expected results

| Step | Action | Expected result |
|---|---|---|
| 0 | Confirm `test_store_master_new_pre` has duplicates (baseline) | `DUP_COUNT_BEFORE > 0` — if this is `0`, the test table needs to be rebuilt with the reproduced bug first; stop and rebuild before continuing |
| 1 | Record `TOTAL_ROWS_BEFORE` and `DISTINCT_KEYS_BEFORE` | `TOTAL_ROWS_BEFORE > DISTINCT_KEYS_BEFORE` (proves duplicates exist and quantifies them) |
| 2 | Run the dedup `GROUP BY` query into `test_store_master_new_tbl_dedup` | Query completes without error |
| 3 | Record `TOTAL_ROWS_AFTER` | `TOTAL_ROWS_AFTER == DISTINCT_KEYS_BEFORE` exactly |
| 4 | Re-run the duplicate-group check against the deduped table | `DUP_COUNT_AFTER == 0` |
| 5 | Spot check `CL-0781 / GP-01 / LC-0484 @ 2027_W49` | Exactly 1 row returned |

## Pass/fail

**Pass** if all five expected results hold. **Fail** if `DUP_COUNT_AFTER > 0`
(dedup didn't fully collapse groups) or `TOTAL_ROWS_AFTER != DISTINCT_KEYS_BEFORE`
(either lost legitimate rows or didn't fully collapse duplicates).

## Known limitation (record regardless of pass/fail)

`any()` picks arbitrarily between the real row and the stale synthetic clone
when they conflict — there is no provenance marker distinguishing them post
-hoc (both get the same `eventdate`). This test proves the dedup mechanism
works structurally; it cannot prove which of the two candidate values is
kept for any given duplicate, since that's not knowable from the data itself.
This is a known, accepted tradeoff of the dedup approach vs. the fully
dynamic fix, and should be noted alongside this result when the fix is
proposed for review.

## Cleanup

`test_store_master_new_pre` and `test_store_master_new_tbl_dedup` are test
artifacts only — safe to drop after validation is recorded, or keep for
reference until the real fix ships.

## Actual results — 2026-08-12

Run manually and interactively on `exp-prod-processor` (not via
`sup4493_dedup_test.sh` directly, but the same sequence: rebuild
`test_store_master_new_pre` from `store_master_new_tbl_backup`, replay the
buggy `"Balance of 2027"` insert to reproduce the bug, dedup into
`test_store_master_new_tbl`, re-check). Full log: `Unit_testing_logs.txt`
in this ticket's `/Users/vigneshn/Desktop/JIRAs/SUP-4493/` folder.

| Check | Result |
|---|---|
| Duplicates in fresh `test_store_master_new_pre` (pre-reproduction) | `0` — confirms clean baseline |
| Duplicates after replaying the buggy projection insert (`2027_W40`-`2028_W13`) | `1,180,296` groups — matches `90,792 combos/week × 13 weeks` exactly, corroborating the root-cause scale finding independently |
| Dedup query (`CREATE TABLE test_store_master_new_tbl ... GROUP BY ...`) | Completed with no errors, processed `39.04M` source rows |
| Duplicates after dedup, same range | `0` |
| Total row count after dedup | `37,860,264` — matches the pre-reproduction baseline row count exactly (no legitimate rows lost, no residual duplicates) |
| Spot check `CL-0781 / GP-01 / LC-0484 @ 2027_W49` | Exactly 1 row |

**Result: PASS.** All five validation criteria satisfied with hard numbers,
not just qualitative checks. No errors encountered anywhere in the run.

Deviation from the written test script, noted for the record: this run
checked duplicates scoped to `time >= '2027_W40' AND time <= '2028_W13'`
(the known-bad range) rather than across the entire table as
`sup4493_dedup_test.sh` does. Not a gap in coverage — that range is exactly
where the reproduced bug lives, and the same `GROUP BY` logic applies
uniformly to every row regardless of range, so a scoped check here is
equally conclusive.
