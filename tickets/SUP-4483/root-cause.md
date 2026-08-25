# SUP-4483 — [BLK] Make VPN searchable everywhere — root cause (Summary + History Grid Tabs)

## Symptom (from Marikannan C / reporter, 2026-08-23)
Grid View and TY/LY Grid View search on VPN works. Summary View and
History Grid Tabs (Nested View) do not, even though the assignee already
added `searchIndexes` entries to their `.viewdefn` files.

## Workspace
- Edit clone: `~/Desktop/JIRAs/SUP-4483/belk-configs` (branch `SUP-4483`,
  base `assortment-planning`)
- QA live config: `~/Desktop/JIRAs/SUP-4483/live-config/` (synced via
  `oci os object sync -bn internal-qa-config --prefix belk/asst/override_configuration/`)
- No drift found for the files inspected below — live QA matches what's
  in the `belk-configs` override (assignee's work is already live in QA).

## Mechanism (confirmed via SUP-2975 precedent)
Per-view search fields are driven by a `searchIndexes: string[]` array in
the view's `.viewdefn` (e.g. `"attribute:cc_vpn:name"`). Confirmed pattern
from a prior fix: `belk-configs@34327ab` (SUP-2975).

## Root cause — confirmed in `assortmentui` source, not config

`configuration-schemas/schemas/viewdefns/viewdefn.ts`:
- `zGridViewDefn` (line 292), `zFlowTypeViewDefn` (298), `zTopTYvsLYViewDefn`
  (306), `zCollectionViewDefn` (315), `zFlowSheetGridViewDefn` (336) all
  declare `searchIndexes: z.array(z.string()).optional()`.
- **`zSummaryViewDefn` (line 280-284) does not declare `searchIndexes` at
  all.**
- **`zNestedGridViewDefn` (line 137-147, backs History Grid Tabs / Nested
  View) also does not declare it.**

Zod's `z.object({...})` strips any key not in the schema on `.parse()`
(no `.passthrough()` used here). The tenant config client validates every
fetched viewdefn against these schemas
(`SummaryView.container.ts:118` — `validationSchemas: [zSummaryViewDefn, zRollupDefn]`).
So even though `HistoryStyleColorCardViewDetailsSummary_quick.viewdefn`
correctly has `"searchIndexes": ["attribute:cc_vpn:name"]` (verified live
in QA), it never survives validation into Redux state.

`SummaryView.selectors.ts:87,111`:
```ts
const searchFields = searchIndexes ? searchIndexes : externalGridSearchFields;
```
`searchIndexes` is `undefined` (stripped), so it silently falls back to
`externalGridSearchFields` (`utils/Domain/Constants.ts:92-99` — `name`,
`description`, style/stylecolor name/description only). No VPN → search
"doesn't work" with no error, no warning.

For History Grid Tabs it's worse: `pages/Hindsighting/HistoryGrid/NestedView/*`
and `.../ListView/*` (container/epics/selectors/slice, all 8 files) contain
**zero references to `searchIndexes` or any search-filtering logic at all.**
Not a stripped-field bug — this component type never had config-driven
search wired up in the first place.

## Why Grid / TY-LY work
Both `zGridViewDefn` and `zTopTYvsLYViewDefn` declare `searchIndexes`, and
`CanvasView.selectors.ts` (their shared parent) reads and applies it
correctly — same config mechanism, schema doesn't strip it.

## Conclusion
This is not fixable from `belk-configs` alone. It needs a code change in
the shared `assortmentui` repo (affects every client, not just BELK):
1. Add `searchIndexes: z.array(z.string()).optional()` to `zSummaryViewDefn`
   and `zNestedGridViewDefn` in
   `configuration-schemas/schemas/viewdefns/viewdefn.ts`.
2. For History Grid Tabs, additionally wire a `getSearchIndexes` selector
   + filter call into `NestedView.selectors.ts` / `ListView.selectors.ts`,
   mirroring `SummaryView.selectors.ts:43-45,87,111`.

Config-side work (the `searchIndexes` entries the assignee already added
in `belk-configs`) is correct and doesn't need to change.

## Verification 1 — same VPN column everywhere? view/model/M_Meta consistent?

Audited all 90 `belk-configs` viewdefns with a `searchIndexes` key (live QA
config merged over base repo, no drift found). 10 of them are Mari's actual
edits for this ticket's target screens, and **all 10 use the identical
attribute: `attribute:cc_vpn:name`** — no inconsistency:

- HS: `HistoryStyleColorCardViewDetailsSummary(.../_quick)`,
  `HistoryStyleColorGridViewGrid(.../_quick)`,
  `HistoryStyleColorTYLYGrid_quick/_detail`,
  `HistoryHistoryGridNestedViewGrid(.../_quick)`,
  `TD_HistoryStyleColorGridViewGrid`, `TD_HistoryStyleColorTYLYGrid`
- Asst Build: `AssortmentBuildStyleColorGridViewGrid`,
  `AssortmentBuildStyleColorTYLYGrid`
- Asst Analysis: `AssortmentAnalysisGridNestedViewGrid_quick`

Traced each to its model (`HistoryFit_quick/_detail`, `TD_HistoryFit_*`,
`HistoryHistoryGridNestedViewGrid_quick/_detail`,
`HistoryTYLYTranspose_quick/_detail`, `AssortmentFitWithLY`,
`AssortmentTYLYTranspose`, `AssortmentAnalysisGridNestedViewGrid_quick`) —
**every one of the 13 modeldefns declares `attribute:cc_vpn:name`.** ✓
`M_Meta.conf:796` defines `cc_vpn` once, platform-wide — the single
definition covers all of them. ✓

So view + model + M_Meta are all internally consistent for every screen
Mari touched — this rules out a config-content mistake as the cause of
"Summary/History Grid Tabs still not working." Matches the standing root
cause: the gap is in `assortmentui`'s Zod validation
(`zSummaryViewDefn`/`zNestedGridViewDefn` silently stripping
`searchIndexes`), not a config error.

One open item found in passing (not this ticket's failure, but adjacent):
`AssortmentBuildStyleColorSummaryDetails.viewdefn` (Asst Build Summary
View) still has **no** `searchIndexes` at all — confirms Mari's own note
("Summary View — pending adding VPN to this view") is accurate; not yet
started.

## Verification 2 — does another client (TRD) already have a working pattern?

No reusable fix exists for the specific gap (SummaryView / NestedView
component types) — TRD has the same platform limitation, just hasn't hit
it as visibly:

- TRD has 76 viewdefns with `searchIndexes` set. Mapped each to its
  component type: `ConfigurableGrid`, `GridView`, `TopTYvsLY`,
  `CanvasView`, `StyleEdit`, `FlowSheetByStyle` — all types whose Zod
  schema declares `searchIndexes` (confirmed in
  `configuration-schemas/schemas/viewdefns/viewdefn.ts`) — same working
  pattern as BELK's Grid/TY-LY.
- Only **one** TRD `SummaryView`-typed screen has `searchIndexes` set at
  all (`AllocationWorklistSummaryViewDetails.viewdefn` —
  `['po_number', 'ndc_date', 'member:week:name', 'attribute:erlstmkdnwk:id']`).
  Given `zSummaryViewDefn` strips the field platform-wide, this config is
  almost certainly also silently ineffective at TRD — nobody has filed a
  ticket about it, so it's gone unnoticed, not fixed.
- **Zero** of TRD's 44 `NestedView` screens have `searchIndexes` set —
  TRD has never attempted per-field search on that component type either.
- Precedent worth reusing for the mechanism itself (not this specific
  gap): [SUP-4466](https://s5stratosdev.atlassian.net/browse/SUP-4466)
  — TRD "Archived Allocations" search-by-Worklist-ID — fixed purely by
  adding to `searchIndexes` on `AllocResults_StyleColor_WorklistArchive.viewdefn`,
  **componentType `ConfigurableGrid`** (same working family as
  `GridView`), validated in QA in one day. Confirms the config mechanism
  itself is solid and fast to apply — just not on `SummaryView`/`NestedView`.

**Conclusion:** no client has a workaround to borrow. The
`zSummaryViewDefn`/`zNestedGridViewDefn` schema fix (+ wiring a
`getSearchIndexes` selector into `NestedView`) is genuinely new work in
`assortmentui`, benefits every client once merged, and is worth flagging
as a platform gap rather than a BELK-only fix.

## Status
draft — not yet posted to JIRA, not yet confirmed with reporter/assignee.
