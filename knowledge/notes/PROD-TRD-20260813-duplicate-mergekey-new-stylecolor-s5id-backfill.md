---
ticket: null   # no SUP ticket filed — ad-hoc prod incident, see filename for ID
title: TRD (Torrid) daily batch fails with duplicate MERGE key — new stylecolors sent without S5_ID, then backfilled a day later
client: TRD
type: data-issue
repos: [etl]
components: [vsql/daily/vertica_weekly_transform.sql, vsql/weekly/010_products.sql, TRD_REF_S5_CLIENT_ID_MAPPING, TRD_REF_PRD_MEMBERMASTER, trd_h_prodstd, trd_h_prodstd_existing, trd_d_product, trd_ma_stylecolorattributes]
symptom: "Daily batch fails in 07.3_transform_existing.sh -> vertica_weekly_transform.sql: vsql ERROR 3147 'Duplicate MERGE key detected in join [(trd_h_prodstd_existing x trd_h_prodstd) ...]; value [<uuid>]'. EXIT=3, batch aborts, oncall paged."
resolved: 2026-08-13
draft: false
---

## Problem

TRD (Torrid) daily batch failed on 2026-08-13 in the transform stage,
after inbound file load and inbound validation both completed clean.
24 stylecolors ended up with two rows apiece in `trd_h_prodstd`, which
made the `MERGE ... trd_h_prodstd_existing` step in
`vertica_weekly_transform.sql` fail outright (Vertica requires a unique
key on the MERGE source side).

## Diagnosis path

- Ruled out inbound validation (`000_validate_inbounds.sql` /
  `001_check_inbound_rejects.sql`) — passed clean, `FAILURE_COUNT=2` was
  under the `>2` threshold. Not a rejects/zero-count issue.
- Isolated the failure to `vsql/daily/vertica_weekly_transform.sql:51`,
  the `merge into trd_h_prodstd_existing using (select * from
  trd_h_prodstd) src on (src.id = dst.id)` statement.
- Queried the duplicate directly:
  `SELECT id, COUNT(1) FROM trd_h_prodstd GROUP BY id HAVING COUNT(1) > 1;`
  → 24 ids, each appearing exactly twice.
- Compared one duplicated id's two rows: identical on every column except
  `ancestor0`. Cross-checked against Postgres `trd_h_prodstd` (which only
  had one row, from 2026-05-08) — the Postgres value matched one of the
  two Vertica rows, not the other.
- **Dead end:** hypothesized the second (bad) `ancestor0` value came from
  a `TRD_REF_S5_CLIENT_ID_MAPPING` fallback (`coalesce(s5_id, member_id)`)
  producing a self-referential row. Queried
  `SELECT * FROM TRD_REF_S5_CLIENT_ID_MAPPING WHERE client_erp_id =
  '<raw code>' AND levelid = 'style'` → 0 rows. Ruled out — the mapping
  table itself had no fallback entry for that code.
- Traced `010_products.sql`'s style-level INSERT and confirmed
  `ANCESTOR0` is copied **raw, untranslated** at the style level — so the
  two differing values had to be coming from two literal rows in
  `TRD_IN_PRD_HIER`/the source feed for the same product, not from a join
  artifact on our side.
- **Root cause, confirmed against the raw inbound files themselves**
  (`grep` across two consecutive days' `S5ProdMaster_*.dat`):
  - `S5ProdMaster_20260812040217.dat` (Aug 12): the affected stylecolors
    (e.g. `45264596_DEEPDEPTHS`) were present with an **empty `S5_ID`
    field** — `45264596_DEEPDEPTHS||45264596 DEEP DEPTHS|...`.
  - `S5ProdMaster_20260813040226.dat` (Aug 13, the failing run): the
    **same stylecolors** now had `S5_ID` populated —
    `45264596_DEEPDEPTHS|7dcb926e-4a8f-431a-98b9-a36b3cb61c44|...`.
  - Our id-mapping build (`coalesce(S5_ID, MEMBER_ID)` in
    `TRD_REF_S5_CLIENT_ID_MAPPING`) falls back to the raw client code as
    the working "id" whenever `S5_ID` is blank. On Aug 12 that raw-code
    identity got merged into `trd_h_prodstd_existing` (and
    `trd_ma_stylecolorattributes`) as the only version of that product.
    On Aug 13, Torrid's system finished assigning the real `S5_ID`
    (UUID) for the same stylecolor — so the same logical product now
    resolves to a *different* id/ancestor value than the one already
    merged in from the day before. Both versions coexist until manually
    cleaned up, and the MERGE trips the instant it sees two rows race for
    the same key.

## Fix

- Deleted the stale, raw-code-keyed rows for the 24 affected stylecolors
  from Postgres, across every table the stylecolor level touches:
  - `trd_d_product`
  - `trd_h_prodstd`
  - `trd_ma_stylecolorattributes` (stylecolor is the affected level, so
    this table carries the dup too)
- Re-ran the daily batch.
- Sent the customer a failure notification (subject: *"S5 Stratos |
  Torrid Daily Batch Failure 13.08.2026"*) flagging the underlying
  pattern — new stylecolors going out without `S5_ID` before being
  backfilled a day (or more) later.

## Verification

- `SELECT id, COUNT(1) FROM trd_h_prodstd GROUP BY id HAVING COUNT(1) >
  1;` — confirm 0 rows before resuming.
- Daily batch completed through `vertica_weekly_transform.sql` without
  the `ERROR 3147` recurring.

## Knowledge gained (techno-functional)

**Technical:** `TRD_REF_S5_CLIENT_ID_MAPPING` is built every run via
`coalesce(S5_ID, MEMBER_ID)` from `TRD_IN_PRD_MASTER` — if Torrid's
`S5ProdMaster` feed sends a product with a blank `S5_ID`, we silently
adopt their raw client code as the working id for that cycle. Because
`trd_h_prodstd_existing` (and the other `_existing` tables) are
persistent MERGE targets, not full overwrites, that raw-code identity
survives into subsequent days. If Torrid later backfills the real
`S5_ID` for the same product, the same logical entity now resolves to
two different ids across two different daily loads, and
`vertica_weekly_transform.sql`'s MERGE has no way to reconcile them —
it just fails.

**Functional:** `S5_ID` is the identifier Torrid's own product systems
assign to a stylecolor. Newly created stylecolors can appear in Torrid's
daily feed *before* that assignment finishes on their side — our
pipeline currently has no graceful handling for "this product's identity
changed because its permanent ID just got assigned," it just treats it
as two different products until someone manually intervenes.

## Gotchas

- **Fingerprint for this pattern:** `ERROR 3147: Duplicate MERGE key` in
  `vertica_weekly_transform.sql`, pointing at `trd_h_prodstd`/
  `trd_h_prodstd_existing` (or any `*_existing` MERGE). First move: `SELECT
  id, COUNT(1) FROM <table> GROUP BY id HAVING COUNT(1) > 1` on the
  non-`_existing` staging table to get the affected ids fast.
- To find *why* an id is duplicated, don't stop at the mapping table —
  `grep` the affected raw client code across the last 2-3 days of
  `S5ProdMaster_*.dat` directly. The staging tables (`TRD_IN_PRD_MASTER`,
  `TRD_REF_S5_CLIENT_ID_MAPPING`) get dropped and rebuilt every run, so
  they only ever show one day's snapshot — the raw `.dat` files (backed
  up per run) are the only place the day-over-day history is visible.
  This dead-ended once (see mapping-fallback hypothesis above) before the
  raw-file diff gave the real answer.
- Affects all tables at the stylecolor level, not just `trd_h_prodstd` —
  `trd_d_product` and `trd_ma_stylecolorattributes` need the same
  cleanup for the same ids.
- Seen once so far (2026-08-13, 24 stylecolors). If this recurs, it's a
  strong candidate for a proper fix rather than manual cleanup each
  time — e.g. detecting a blank→populated `S5_ID` transition and
  reconciling the old raw-code row instead of leaving both to collide at
  merge time.
