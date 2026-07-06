# Config-layer reference library

Deep documentation of the configuration layer (the trd-configs-style
repos), sourced from the internal Configuration Training Curriculum
(author: gautham.vemuganti, 8 modules + 3-week authoring program).

| File | What |
|---|---|
| `cheatsheets.md` | All 8 module cheat sheets in one greppable file — **search this first** when debugging config issues |
| `source/` (optional) | Full curriculum: chapters, slides, exercises per module. Download the Drive folder here for offline/full-depth reference |

Drive source: https://drive.google.com/drive/folders/1ESnbna4j7MCk4N0je6ZVEAxHAaskxD2o

## Highest-value facts for triage (learned from the curriculum)

- `confdefnschema.json` at trd-configs repo root — JSON Schema (Draft 7)
  for confdefns; `npx ajv validate -s confdefnschema.json -d
  "uidefn/conf/*.confdefn"` is a ready-made CI lint. The mfp/ apps have
  per-file schemas in `mfp/schemas/`.
- Backup-variant suffixes (`_LG`, `_LG2`, `_lastgood`, `_pre_<date>`,
  `_WIP`, `_Trash`, `_OG`) are runtime-ignored dead files.
- The debugging decision tree (Module 1, in cheatsheets.md) maps error
  hallmarks → file type → fix. Use it before ad-hoc grepping.
- Module 6's symptom→file lookup table routes UI symptoms to the exact
  config file class.
- Pivot grain lives in `bottomLevels` — the root of count-metric
  inflation bugs (see note SUP-4202/SUP-4210 pattern).
- Empty `IN()` defense: every FreeMarker-built IN clause needs
  `<#if list?? && list?size gt 0>` — a recurring production failure.
