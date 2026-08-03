---
ticket: SUP-TBD   # fill in once this is logged as a SUP ticket
title: MFP-to-AP Plans Sync fails with NULL channel insert when it overlaps weekly batch
client: BD
type: bug
repos: [etl]
components: [mfp_to_ap_sync.sh, weekly.sh, bd_p_mfp.sql, bd_store_hier_attr, bd_store_hier_attr_tbl_2, 12.2_load_ch.sh]
symptom: "clickhouse-client insert into bd_p_mfp_tbl fails: Code 349 CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN, converting source column channel to destination column channel."
resolved: null   # root cause confirmed; fix not yet applied
draft: true   # confirm mechanism against a second occurrence before flipping to false
---

## Problem

Boden (BD) `mfp_to_ap_sync.sh` (run_mfpapsync.sh → `ch/mfpapsync/bd_p_mfp.sql`)
failed on 2026-07-26 ~06:30 America/New_York (10:30 UTC) inserting into
`bd_p_mfp_tbl`: ClickHouse rejected the insert because `channel` resolved to
NULL for at least one row, and `bd_p_mfp_tbl.channel` is non-nullable.

## Diagnosis path

- `bd_p_mfp.sql`'s `channel` column comes from
  `left outer join (select distinct territory, channel from bd_store_hier_attr) c
  on a.territory = c.territory` — a LEFT join, so an unmatched territory
  produces `channel = NULL` and aborts the insert.
- First suspicion: missing/stale row in `bd_store_hier_attr` for a specific
  territory (dimension coverage gap) or a location-parsing regex bug. Ruled
  out once timing was checked — see below.
- Checked whether the client's weekly batch could be running concurrently and
  colliding. `mfp_to_ap_sync.sh` has a lock check for this:
  `if [[ -f "$SCRIPT_DIR"/"batch_$(date +%F).txt" ]]` (line 47, pre-fix).
- **Bug found:** `weekly.sh` (and `daily.sh`) write/remove that lock file in
  `$CONFIG_DIR` (`weekly.sh:56`, `weekly.sh:198`), but `mfp_to_ap_sync.sh`
  checked `$SCRIPT_DIR` instead. Different directories — the check could
  never see the lock, so mfpapsync always proceeds regardless of whether
  weekly is running.
- Checked timing in that day's `weekly.sh` log: incoming files didn't land
  until ~08:56–09:01 UTC (file-wait loop `00_wait_incoming_files.sh` polling
  `2026-07-26T07:00:04Z`→ found ~`Jul 26 09:01`), so
  `execute_run_weekly_without_plan` (the lock-holding function, which runs
  steps 01→16 including `12.2_load_ch.sh` and `13_process_clickhouse.sh`)
  started ~09:01 UTC. mfpapsync ran at 10:30 UTC — well inside that window
  for a batch moving 1.6GB+ of files through Vertica/PG/CH.
- `bash/weekly/12.2_load_ch.sh` does
  `TRUNCATE TABLE bd_store_hier_attr_tbl_2` then reloads it row-by-row from
  `BD_store_hier_attr.tsv`.
- `SHOW CREATE TABLE bd_store_hier_attr` confirms it is
  `ENGINE = Distributed('DarwinCluster', 'bd', 'bd_store_hier_attr_tbl_2')` —
  i.e. it has no independent state; it reflects `bd_store_hier_attr_tbl_2`
  live, including mid-truncate.
- **Root cause:** mfpapsync's `bd_p_mfp.sql` query hit `bd_store_hier_attr`
  while weekly's `12.2_load_ch.sh` had it truncated (between the `TRUNCATE`
  and the completed reload). Every `territory` lookup returned no match →
  `channel = NULL` across the board → insert rejected. The safety mechanism
  meant to prevent exactly this (the batch lock) was broken by the path bug,
  so it never blocked the overlap.

## Fix (proposed, not applied)

- `repos/etl-bod-batch/mfp_to_ap_sync.sh:47` — change the lock check from
  `"$SCRIPT_DIR"/"batch_$(date +%F).txt"` to
  `"$CONFIG_DIR"/"batch_$(date +%F).txt"` to match where weekly.sh/daily.sh
  actually write/remove it. One-line change; not yet made in the repo.

## Verification

- Not started — no fix applied yet. Once the one-line change above is made,
  plan is: confirm mfpapsync skips (logs "batch is running") when it starts
  while weekly is genuinely mid-`12.2_load_ch.sh`, and confirm it still runs
  and inserts cleanly on a normal run with no overlap.
- Pre-fix state captured in `bod_failed.txt` (mfpapsync run) and
  `bd_weekly.txt` (same-day weekly run) for reference.

## Gotchas

- `mfp_to_ap_sync.sh`'s "batch is running" branch does
  `echo "batch is running" | tee -a "$LOG_FILE"; EXIT=$?` — `EXIT` captures
  the exit status of `echo`/`tee` (always 0), not a meaningful skip signal.
  Even with the lock path fixed, a caller relying on mfpapsync's exit code to
  detect "did the sync actually run" will see success (0) on a skip too. Not
  fixed here — flagging in case it matters for downstream monitoring.
- This codebase's naming convention: `<name>_tbl` / `<name>_tbl_2` are the
  physical/local tables that get truncated+reloaded; the unsuffixed name
  (`bd_store_hier_attr`, `bd_h_timestd`, `plan_data_wide`) is typically a
  Distributed table or view over it, not a separate copy — any truncate+reload
  window on the `_tbl` side is immediately visible (as empty) on the
  unsuffixed side, on `DarwinCluster`. Same risk applies to every other batch
  step that reads an unsuffixed name while another job is reloading its `_tbl`
  counterpart — not unique to mfpapsync/channel.
- No `customers/BD` profile existed in the hub before this ticket — added one.
