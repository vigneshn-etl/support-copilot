# SUP-4493 — Backup alternative: `NOT IN` guard on each year-block insert

**Status**: not the chosen fix (GROUP BY dedup is preferred — see
`bash/weekly/update_weekly_ch.sh` on the local `SUP-4493` branch at
`/Users/vigneshn/Desktop/JIRAs/SUP-4493/etl-exp-batch/`). Kept here purely
as a documented alternative in case the preferred fix is opposed or needs
to be swapped.

## What it does

Instead of deduplicating once at the final load, add a guard to **every**
hardcoded per-year block in the `SUP-3890` projection section, so each
`INSERT` skips any row whose key already exists in
`store_master_new_tbl_pre` before inserting.

## Example — applied to one block (`# 2029`)

Original:
```sql
insert into store_master_new_tbl_pre
select product,channel,location, cast(cast('2029' as Float32) as String) || right(time,4) as insert_time, aps_index,grade,bi,strclimate,strmenscapacity,strwomenscapacity, b.indx as insert_indx, eventdate
from store_master_new_tbl_pre a
join exp01_time b on insert_time = b.id
where time between '2026_W01' and '2026_W52'
```

With the guard added:
```sql
insert into store_master_new_tbl_pre
select product,channel,location, cast(cast('2029' as Float32) as String) || right(time,4) as insert_time, aps_index,grade,bi,strclimate,strmenscapacity,strwomenscapacity, b.indx as insert_indx, eventdate
from store_master_new_tbl_pre a
join exp01_time b on insert_time = b.id
where time between '2026_W01' and '2026_W52'
and (product, channel, location, insert_time) not in (
    select product, channel, location, time from store_master_new_tbl_pre
)
```

The same `and (product, channel, location, insert_time) not in (select product, channel, location, time from store_master_new_tbl_pre)`
clause needs to be added identically to **every** year-block: the `# Balance
of 2027` block, `# 2028 / has a 53rd week` (both branches of its `UNION
ALL`), `# 2029` through `# 2033`, `# 2034 / has a 53rd week` (both
branches), `# 2035`, and `# 2036` — roughly 12 insertion points across the
~120-line `SUP-3890` block in `bash/weekly/update_weekly_ch.sh`.

## Why this is the backup option, not the preferred one

- **More surface area for error**: the same clause has to be copy-pasted
  correctly into ~12 separate statements rather than written once. A
  mistake or omission in any one of them silently reintroduces the bug for
  that specific block only — harder to spot than a single missing clause.
- **More expensive**: `NOT IN` against a large, growing uncorrelated
  subquery (`store_master_new_tbl_pre` reached 80+ million rows during
  testing) runs once per year-block — roughly 12 full subquery evaluations
  per run, versus one `GROUP BY` pass in the dedup approach.
- **Same core limitation as the dedup fix**: neither approach touches the
  hardcoded literals themselves (`2026_W40`, `2026_W01`-`W52`, the per-year
  `'2028'`...`'2036'` strings, the manual `2028_W53`/`2034_W53`
  special-casing). The underlying drift — real data's horizon advancing
  past the block's fixed starting point — continues indefinitely; this
  guard (like the dedup fix) just prevents it from producing visible
  duplicates.
- Also carries the same `any()`-equivalent ambiguity risk conceptually:
  whichever row (real or synthetic) happens to already exist first "wins"
  by virtue of the `NOT IN` check, with no way to guarantee it's the real
  one.

If this is preferred over the dedup approach for some other reason (e.g. a
review preference for filtering at the point of generation rather than at
final load), it is functionally viable — just costs more to implement
correctly (12 edit points vs. 1) and more to run.
