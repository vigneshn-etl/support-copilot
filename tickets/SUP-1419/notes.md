---
ticket: SUP-1419
title: "[TRD] Pareto Summary Quintiles are not calculating correctly"
client: TRD
type: bug
repos: [config]           # confirmed: trd-configs, pivot/HistoryInfoGraph.pivotdefn + include
components: [pareto-summary, HistoryInfoGraph pivot, CTAS2/3/4 SlsU_Rank bucketing, composite_band (secondary)]
status: INVESTIGATE (stage 4) — root cause identified in live TRD code + runtime log, not yet confirmed against a captured UI payload for the literal ticket repro. See "Root cause (confirmed)" below.
---

This is the scratch working file for SUP-1419. Not committed as a knowledge
note yet — graduate the relevant parts into `knowledge/notes/SUP-1419.md`
(TEMPLATE.md format) once we clear the ROOT-CAUSE and VALIDATION gates.

## Ticket summary

At "all" flow status, Quintiles with no sales — contribution from top 50%
of CCs = 100% in *every* bucket (Top 20% / Above Average / Average / Below
Average / Bottom 20%), instead of a graduated Pareto contribution curve.

Repro (from ticket): torrid.s5stratos.com → Top-Down > Hindsighting >
Performance > Pareto Summary. Product = `08. CURVE`, Location = Torrid,
Time = `2024-W01-Feb-W1` to `2024-W06-Mar-W2`.

Old ticket (created 2024-05-28), resurrected via comment 2026-05-28
("issue in all clients, valid"). Currently in sprint S043 (2026-07-12 to
2026-07-19), Low priority, assigned to Vignesh.

## Prior art

- **SUP-4256** `[AEO] Pareto Summary > inventory by band inconsistent`
  (linked "relates to", still In Development). Same screen/mechanism —
  CC Count mismatch between Pareto Summary (67cc) and History Grid (68cc).
  Comment from Nicole Rockwell: *"This is an issue in all clients so I'm
  sure it's valid."* A prior engineer (Ryan Z) reportedly couldn't trace
  where the numbers came from. **Working assumption: SUP-1419 and SUP-4256
  are two symptoms of the same underlying pivot defect** — treat together,
  cross-link the eventual fix/note.
- No existing `knowledge/notes/` or `knowledge/playbooks/` coverage of
  pareto/quintile/composite_band — this will be new ground.

## UPDATE 2026-07-15 — trd-configs cloned, runtime log analyzed, root cause identified

`trd-configs` cloned (branch `allocation-configs`) into
`tickets/SUP-1419/repos/trd-configs`. TRD's `HistoryInfoGraph.pivotdefn`
has diverged substantially from EE's on metric formulas (different naming,
`_x` suffix convention, extra funded metrics) — **do not reuse the EE file
as evidence going forward**, everything below is sourced from TRD's own
repo + a real runtime log (`app_logsv1.txt`, QA host `trd-asst-0`,
`assortment-api.txt`, 2026-07-15).

The log captured a live `HistoryParetoSummary` pivot execution (session
`P4A70F9AEBE6C4EDB907EF53BA0C4E914`/`P973100D1FE00404B9C84D9C18F77AD86`,
product `DP-147`, location `CH-2`, `FLOW_STATUS=0, 1, 2` — i.e. **"all"
flow status**, matching the ticket's repro condition even though the
specific product/location differ from the ticket's literal example). This
confirms the mechanism is live/real, not just theoretical.

### Root cause (confirmed) — Finding B: primary

`HistoryParetoDetailsRollUp.viewdefn` (dataIndex: `cc_count`, `slsr`,
`slsu`, `ttl_margin_pct`, `sls_r_per_cccount`) is the viewdefn that renders
the 5 quintile detail rows (Top 20% / Above Average / Average / Below
Average / Bottom 20%) — confirmed by matching its dataIndex fields
1:1 against the pivot's final `aggregationSQLs` output columns
(`pivot/HistoryInfoGraph.pivotdefn:394-413`).

Those rows are built by a 3-stage CTAS pipeline in
`pivot/HistoryInfoGraph.pivotdefn`:

- **`CTAS2_INFOGRAPH_TY`** (lines 229-249): ranks every stylecolor by
  `SlsU` (shipped units) descending, using `groupArray()` +
  `arrayEnumerateUniq()` as a rank-number trick (`SlsU_Rank`). Critically,
  **line 243 has a commented-out filter: `-- where SlsU > 0`.** As written,
  zero-sales stylecolors (exactly "quintiles with no sales" from the
  ticket) are included in the ranked population instead of being excluded.
- **`CTAS3_INFOGRAPH`** (lines 273-320): buckets `CTAS2`'s ranked rows into
  `Top 50` / `Top 20%` / `Above Average` / `Average` / `Below Average` /
  `Bottom 20%` via `SlsU_Rank <= MAX(SlsU_Rank) * <cutoff>` — the exact
  section names shown in `ParetoSummary.tsx`'s `sectionNames` array.
- **`CTAS4_INFOGRAPH`** (lines 324-385): computes each bucket's `SlsR_Pct`
  / `SlsU_Pct` / `Margin_Pct` etc. as `bucket_sum / grand_total` — this is
  where a "contribution %" figure would come from for the "Contributions
  from Top 50% CCs" panel (topRight, indx=2 "Top 50" row in the
  `ParetoSummary.tsx` render).

**Not yet nailed down:** exactly *why* this produces literally **100%** in
every bucket (vs. some other wrong number) — that requires the raw pivot
JSON response for the exact ticket repro (product `08. CURVE`, Torrid,
`2024-W01-Feb-W1` to `2024-W06-Mar-W2`, all flow status), which isn't in
this log. Leading theory: with the `SlsU > 0` guard disabled, if the
department/time scope in the repro has very few or zero actually-selling
stylecolors, `SlsU_Rank`'s count-based percentile cutoffs (`MAX(SlsU_Rank)
* 0.5` etc.) stop tracking a meaningful sales threshold — every bucket
could end up spanning ~the same (or all of) the population, making each
bucket's `SlsR_Pct` collapse toward the same value. Need the actual
payload to confirm the exact arithmetic. **Do not close the root-cause gate
on this theory alone — it explains the mechanism class, not the literal
number, yet.**

### Finding A (confirmed real, likely NOT this screen) — composite_band

Independently confirmed as a real, currently-live defect, but **ruled out
as the cause of this specific ticket** — it's a different code path that
doesn't feed `HistoryParetoDetailsRollUp.viewdefn` (no `composite_band`/
`ccperf` dataIndex found in that or `HistoryParetoItemStrip`/
`HistoryParetoGraphSortBy` viewdefns). Keeping this documented since it's
a real bug in shared code and may be the SUP-4256 (AEO CC-count mismatch)
root cause instead — worth a separate ticket/note.

Evidence (from `pivot/include/history_bands_ty_ly_lly.ftl`, included by
`HistoryInfoGraph.pivotdefn:225`, and confirmed executing verbatim against
real TRD data in the runtime log at lines 7337-7349, session
`P973100D1FE00404B9C84D9C18F77AD86`):

```sql
CREATE TABLE trd_COMPOSITE_BAND_<session> ENGINE = Memory as
select stylecolor
    , temp_comp_band
    , rowNumberInBlock()+1 as k
    , cast( multiIf(k <= 0.2*cnt, 1, k <= 0.4*cnt, 2, k <= 0.6*cnt,3, k <= 0.8*cnt,4, 5) as Float32) as composite_band
from
        (select stylecolor, temp_comp_band from trd_PRE_COMPOSITE_BAND_<session> where temp_comp_band > 0 order by temp_comp_band asc)
        CROSS JOIN
        (select count(*) cnt from trd_PRE_COMPOSITE_BAND_<session> where temp_comp_band > 0)
UNION ALL
select stylecolor, temp_comp_band, 0, cast(1 as Float32) as composite_band from trd_PRE_COMPOSITE_BAND_<session> where temp_comp_band = 0
```

Every stylecolor with `temp_comp_band = 0` (TRD's weighted score:
`0.35*net_sls_margin_r_band + 0.2*net_sls_margin_pct_band +
0.45*net_sls_r_band` — all zero when there's no sales/margin) is excluded
from the ranked distribution and hard-coded to `composite_band = 1`,
regardless of true rank. This `.ftl` include is shared across pivotdefns
(`history_bands_ty_ly_lly.ftl`, `history_bands_ty_ly.ftl`,
`history_bands_ty.ftl`, and `assortment_bands_*.ftl` variants exist too —
worth checking how many pivots/clients include these), which supports
Nicole Rockwell's SUP-4256 comment that "this is an issue in all clients."

### Diagnosis dead end

Originally hypothesized `composite_band`/`ccperf` as the root cause (see
"Investigation so far" below, proxy evidence from EE) — confirmed real in
TRD too, but tracing the actual viewdefn wiring showed it doesn't drive
this screen's visible quintile rows. Don't re-walk this path for SUP-1419;
it's the right lead for a *different* ticket (SUP-4256 or a new one).

## UPDATE 2026-07-15 (cont'd) — UI repro attempts, 2025 data, flow status confirmed "All"

Ticket's 2024 time scope isn't selectable in current system (window has
moved forward); user repro'd with current/future weeks instead
(2025-W10-Apr-W1 to 2025-W13-Apr-W4). Confirmed: the "All / New /
Carryover / Sell Down" checkboxes at the top of the Pareto Summary screen
**are** the flow status filter — "All" checked = the ticket's "all flow
status" condition. So every screenshot below was already testing the
right variable.

Five scopes tested, flow status = All throughout:

| Scope | # CCs | Top20/AboveAvg/Avg/BelowAvg/Bottom20 (Sales U) | Top 50% CCs panel (R$/FGM/Unit) |
|---|---|---|---|
| Apparel Reserve | 0 | 0/0/0/0/0 | 0% / 0% / 0% |
| Belle Isle | 75 | 47/29/17/6/0 | 93% / 93% / 86% |
| Shapewear | 25 | 63/35/1/0/0 | 100% / 99% / 99% |
| Total Brand | 20,564 | 95/4/0/0/1 | 100% / 100% / 100% |

**Finding: none of these reproduce the original ticket's literal symptom**
("100% in every quintile bucket"). In all five, the 5 quintile buckets are
properly graduated. A consistency check (top-50%-by-count cutoff should
roughly equal the cumulative sum of buckets up to the 50% headcount mark,
and lower buckets should be ~0 when top-50 is high) **passes in every
case** — the "100%" readings (Shapewear, Total Brand) are explainable as
rounding of a genuinely front-loaded distribution (a handful of styles
driving nearly all volume — common in retail), not a stuck/defaulted
calculation.

**Where this leaves the root-cause gate:** the code defect found earlier
(commented-out `WHERE SlsU > 0` at `pivot/HistoryInfoGraph.pivotdefn:243`)
is still real and confirmed live-executing, but we have NOT yet produced a
UI repro that visibly breaks because of it. Current 2025 data at every
scope tried is skewed toward "few real sellers + long zero-sales tail,"
which happens to still produce coherent numbers. Need a scope where
zero-sales CCs are the large majority AND the real sellers are more evenly
spread (not 1-2 mega-sellers dominating) to actually stress the missing
filter — haven't found/tried that shape yet.

**Do not close the root-cause gate on the code finding alone** — per
workflow.md, root cause needs a UI/query result that demonstrates the
actual broken behavior, and so far every repro is arguably *correct*
behavior for skewed data.

## Next steps

1. **Find a scope that breaks the consistency check** — try a
   pre-season-heavy or brand-new department where zero-sales CCs are the
   large majority and remaining sellers are evenly spread (not 1-2
   mega-sellers). If quintile buckets ever come back non-graduated
   (e.g. two buckets both showing high % simultaneously, or a lower
   bucket showing more than an upper one) — that's the break.
2. If no scope breaks it: capture the raw network response for
   `pivot3/listData?defnId=HistoryParetoSummary` on whichever scope looks
   closest to a break, to see the literal numbers before UI rounding —
   drop in `tickets/SUP-1419/logs/`.
3. If still nothing breaks after a real attempt at (1): consider that the
   `WHERE SlsU > 0` omission, while a genuine code defect, may not be
   currently reproducible with today's TRD data shape — note this
   explicitly in the eventual JIRA comment rather than closing the ticket
   silently. Still worth fixing defensively (re-enable the filter) since
   it's clearly not intentional (commented out, not deleted).
4. Separately: file/flag the `composite_band` no-sales collapse
   (`pivot/include/history_bands_ty_ly_lly.ftl:829-848`) against SUP-4256
   — check if `HistoryFit`/other AEO-side viewdefns *do* bind
   `composite_band`/`ccperf` to a visible column (unlike TRD's
   `HistoryParetoDetailsRollUp`).
5. Root-cause JIRA comment on SUP-1419 once (1)-(3) settle whether this is
   visibly reproducible or a latent defect — per workflow.md this needs an
   evidence citation + proposed fix + validation plan sketch before FIX
   stage starts.

## Investigation so far (proxy evidence — EE client, not TRD)

`trd-configs` wasn't cloned yet when this was first triaged, so the pivot
mechanism was traced in `repos/evereve-configs` (EE client) as a proxy —
same product template, same `pivotDefn: HistoryInfoGraph` binding
(`evereve-configs/uidefn/model/HistoryParetoSummary.modeldefn:4`). The
Nicole Rockwell "issue in all clients" comment is weak supporting evidence
that this pivot logic is shared/templated rather than TRD-specific, but
**not confirmed** — first thing to check once trd-configs is cloned (§ Next
steps).

Frontend ruled out: `repos/assortmentui/.../ParetoSummary.tsx` and
`ParetoSummary.utils.ts` are pure render — `columnItems`/`quintiles`/`top*`
arrive as props, no client-side calculation. Confirms Config-layer routing
per `knowledge/system-map.md` ("wrong on one view/screen → config layer").

Two candidate mechanisms in `evereve-configs/pivot/HistoryInfoGraph.pivotdefn`
that could produce "100% in every bucket" for no-sales quintiles:

1. **`composite_band`** (lines 1878–1889): ranks CCs by a weighted score
   `temp_comp_band` (50% net sales units + 30% margin% + 20% sell-thru%),
   splits into 5 equal-count bands via `k <= 0.2*cnt` etc. Rows where
   `temp_comp_band = 0` (no sales/margin/sell-thru — exactly "quintiles
   with no sales") are excluded from the ranked ordering and **hard-coded
   to `composite_band = 1`** (line 1888):
   ```
   UNION ALL
   select ${AGGREGATION_PRODUCTS}, temp_comp_band, 0, cast(1 as Float32) as composite_band
   from ${TENANT_ID}_PRE_COMPOSITE_BAND_${SESSION_ID} where temp_comp_band = 0
   ```
   Every no-sales CC collapses into band 1 regardless of true rank.

2. **`ccperf`** (lines 1969–2007): Pareto rank from cumulative net-sales-$
   (`R_SlsR`) vs total (`ttl`) via
   `multiIf(R_SlsR <= 0.2*ttl, 1, ..., 5)`, built from `PARETO_BAND`
   (lines 1413–1447: sorts CCs `SlsR DESC`, `runningAccumulate`). At "all"
   flow status, zero-`SlsR` CCs sort to the tail; once cumulative reaches
   the true total, trailing zero-sales CCs still get `R_SlsR/ttl` ≈ 1.0 →
   `ccperf = 5`. Possible saturation but doesn't obviously explain "100% in
   *every* bucket" as cleanly as (1) does.

**Leading hypothesis: (1)** — the no-sales collapse into a single fixed
band is the more direct match for "100% in all buckets," but this is
**inferred, not confirmed**. Haven't seen a real query output or TRD's
actual pivotdefn yet — do not treat as root cause until evidenced.

## Next steps (this session)

1. Clone `trd-configs` into `tickets/SUP-1419/repos/trd-configs` (see
   command below — verify URL/branch with user, guessed from the
   `s5-stratos` GitHub org pattern used by `evereve-configs`).
2. Diff TRD's `HistoryInfoGraph.pivotdefn` (or whatever it's named there)
   against the EE version above — confirm same `composite_band`/`ccperf`
   logic, or find TRD-specific divergence.
3. User reproduces in the app (torrid.s5stratos.com, same filters as
   ticket) and captures:
   - Browser devtools Network tab response for the Pareto Summary pivot
     call (raw `quintiles`/`columnItems` payload) — most direct evidence.
   - Any relevant backend/batch logs.
4. Once we have TRD's pivotdefn + a real payload: confirm which mechanism
   (composite_band vs ccperf vs something else entirely) actually feeds
   the UI's quintile rows, and pin the exact root-cause line.
5. Cross-check against SUP-4256 (AEO) — same root cause?

## Suggested clone command (verify before running)

```bash
git clone https://github.com/s5-stratos/trd-configs.git tickets/SUP-1419/repos/trd-configs
```

`tickets/SUP-1419/repos/` and `tickets/SUP-1419/logs/` are gitignored — safe
to drop the clone and pasted logs here without polluting the hub repo.
