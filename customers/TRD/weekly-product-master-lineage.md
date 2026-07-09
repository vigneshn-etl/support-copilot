# TRD Weekly Batch — Product Master Data Lineage

End-to-end lineage for the five product-master tables, traced from the
lineage graph (`customers/TRD/lineage/`) and verified against the actual
scripts. Covers: `trd_d_product`, `trd_h_prodstd`, `trd_ma_styleattributes`,
`trd_ma_stylecolorattributes`, `trd_ma_sizeattributes`.

## The shared pipeline (all five tables follow it)

```
S5 inbound files (SFTP)
   └─ 01/02/03: copy + generated COPY stmts (table_mappings.json) → Vertica TRD_IN_* staging
        └─ 04/05: validations + reject exports
             └─ 06 master load → vsql/weekly/010_products.sql   ← ALL transform logic
                  ├─ 07.1–07.3: "existing" round-trip (preserve prior PG state)
                  ├─ 09: vsql/weekly/exports.sql  → pg_exports/*.csv  (\o redirects)
                  │    └─ 10: pgsql/weekly/load_pgsql.sql  delete + \copy → Postgres (app DB)
                  └─ 11: bash/weekly/11_ch_export_load_truncates.sh
                       ├─ Vertica → tsv → ClickHouse   (d_product, h_prodstd)
                       └─ PG → export_to_ch.sql → tsv → ClickHouse (sizeattributes, hier_attr)
```

Key orchestrators: `weekly.sh` → `run_weekly_load_inbound.sh` /
`run_weekly_without_plan.sh` → numbered steps in `bash/weekly/`.
The same PG/CH load scripts also run in the **daily** flow
(`pgsql/daily/load_pgsql.sql` is line-for-line the same pattern).

### The "existing" round-trip (important for debugging)

Before rebuild, current PG state is exported
(`07.1_export_existing_pgsql.sh` → `pgsql/weekly/export_existing.sql` →
`pg_exports_existing/*.csv`, with a `sed` cleanup of quote artifacts),
loaded back into Vertica as `trd_*_existing` tables, then
`vsql/daily/vertica_weekly_transform.sql` **MERGEs** the freshly built
tables into the `*_existing` versions (e.g. `merge into
trd_h_prodstd_existing using trd_h_prodstd on id`). This preserves rows
that exist in the app but vanished from the inbound feed, and fixes SKU
hierarchy mismatches (`trd_h_prodstd_mismatch` logic). If a product
"disappears," this cycle is the first suspect — see note SUP-4254 for the
carriage-return variant of that failure.

### Shared reference tables built first (010_products.sql)

- `TRD_REF_PRD_MEMBERMASTER` — distinct `member_id` + `product_level`
  from `TRD_IN_PRD_MASTER`, restricted to members present in
  `TRD_IN_PRD_HIER` (i.e. only products that exist in the hierarchy).
- `TRD_REF_S5_CLIENT_ID_MAPPING` — maps `s5_id` ↔ client ERP id per level
  (`coalesce(S5_ID, MEMBER_ID)`); backfilled from `trd_d_product_existing`
  for ids no longer in the feed. **This is the id-translation table for
  everything below** (and the dedup-sensitive table from note SUP-4230).

---

## 1. trd_d_product — product dimension (all levels)

| Stage | Detail |
|---|---|
| Source file | `S5ProdMaster_*.csv` → `TRD_IN_PRD_MASTER` (MEMBER_ID, S5_ID, MEMBER_NAME, MEMBER_DESC, PRODUCT_LEVEL) |
| Build | `vsql/weekly/010_products.sql` — empty CTAS defines shape, then one INSERT per hierarchy level: synthetic `ProductRoot`, then total_brand, division, group, department, class, subclass, style, stylecolor, stylecolorsize |
| Logic | `PRODUCT_LEVEL='sku'` normalized to `'stylecolorsize'` first; each level insert filters `TRD_IN_PRD_MASTER` via membermaster; id = MEMBER_ID (client id), style/stylecolor/size levels translate to s5_id via the mapping table; audit columns (eventdate, version_id, created/updated_at, record_state=0) |
| → Postgres | `exports.sql` `\o ./pg_exports/trd_d_product.csv` (from `trd_d_product_existing`) → `load_pgsql.sql`: `delete from trd_d_product; \copy ... DELIMITER '|' CSV HEADER encoding 'windows-1251'` (transactional full reload) |
| → ClickHouse | `11_ch_export_load_truncates.sh`: `vsql -c "select * from trd_d_product" -o trd_d_product.tsv` → sed CSV-quoting → `truncate` + `INSERT INTO trd_d_product FORMAT CSVWithNames` |
| Data | One row per product node at every hierarchy level: id, client_id, name, description, levelid, index, audit columns. The UI's product-name lookup everywhere. |
| Key consumers | PG: app product dimension; CH: pivots `VsnStatus`/`TD_VsnStatus`, allocation prep, MFP exports (`dimensions_extract.csv`, `hierarchy_extract.csv`) |

## 2. trd_h_prodstd — standard product hierarchy

| Stage | Detail |
|---|---|
| Source file | `S5ProdHier_*.csv` → `TRD_IN_PRD_HIER` (MEMBER_ID, ANCESTOR0..ANCESTOR7) |
| Build | `010_products.sql` CTAS: join HIER × membermaster for non-style levels, then INSERTs for style/stylecolor/stylecolorsize that translate id AND ancestor ids to s5_ids via `TRD_REF_S5_CLIENT_ID_MAPPING` |
| Logic | Ancestor columns are level-positional: ANCESTOR0=stylecolor, ANCESTOR1=style, ANCESTOR2=subclass, ANCESTOR3=class, ANCESTOR4=department(group_id at 4 for names), ANCESTOR5=division, ANCESTOR6=total_brand, ANCESTOR7=root (see `TRD_REF_CC_SKU_MAPPING` for the canonical decoding). Weekly-transform MERGE reconciles `_existing` + a mismatch-repair pass for SKUs whose parents changed |
| → Postgres | `pg_exports/trd_h_prodstd.csv` → delete + `\copy` (same pattern). PG-side: `load_pgsql.sql` later UPDATEs h_prodstd names from `trd_d_product` |
| → ClickHouse | Same Vertica→tsv→CH path as d_product (`truncate` + insert) |
| Data | One row per product with its full ancestor chain — THE join table for any "roll up to level X" logic in all three databases |
| Key consumers | Massive fan-out (107+ downstream): eohdata, onorder stylecolor mapping, valid values, dependency lookup, clustering exports, CH `trd_sku_hier_attr`, MFP hierarchy extract. **Changing this table = full impact analysis mandatory** (`lineage_impact trd_h_prodstd`) |

## 3. trd_ma_styleattributes — style-level attributes

| Stage | Detail |
|---|---|
| Source file | `S5ProdAttrStyle_*.csv` → `TRD_IN_PRD_ATTRSTYLE` (~40 attribute columns) |
| Build | `010_products.sql` CTAS: ATTRSTYLE × membermaster (level='style') × s5 mapping; columns renamed to `sty_*` (KNIT_OR_WOVEN→sty_knit_or_woven, …); `RMS_STYLECOLOR_CREATE_DATE`→`ccstylecreatedate`; placeholders `sty_is_locked`/`sty_s5_adopted` added as NULL |
| Logic | Pure rename/typing + id translation; user-editable fields preserved via the `_existing` MERGE cycle. PG-side intraday UPDATEs sync from `trd_h_prodstd` and `trd_ma_specstyleattributes` (spec/PLM data) |
| → Postgres | `pg_exports/trd_ma_styleattributes.csv` (from `_existing`, `select distinct`) → delete + `\copy` |
| → ClickHouse | No direct CH copy. Style attributes reach CH denormalized inside `trd_stylecolor_hier_attr` (PG view/table maintained by DDL migrations, exported via `pgsql/weekly/export_to_ch.sql`) — the pivots' attribute source |
| Data | One row per style: merchandising attributes (brand, silhouette, fabrication, franchise, key item…) powering `attribute:sty_*` fields in config-layer views |

## 4. trd_ma_stylecolorattributes — stylecolor (CC) attributes

| Stage | Detail |
|---|---|
| Source file | `S5ProdAttrStyleClr_*.csv` → `TRD_IN_PRD_ATTRSTYLECLR` (~80 columns) |
| Build | `010_products.sql` CTAS with `cc_*` renames (UNIT_RETAIL→cc_unit_retail::numeric(16,4), SEASON_CODE→cc_season_code, …) |
| Logic | Richest post-processing of the five: 9 UPDATE blocks denormalize display names (stylecolor_name, style_name, total_brand_name, division_name, group_name, dept/class/subclass names) by joining `trd_h_prodstd` ancestor positions to `trd_d_product` per level; color family enriched from `TRD_IN_VV_COLORMAPPING`. PG-side updates from spec attributes, channel attributes, style attributes and serviceparams (intraday/weekly) |
| → Postgres | `pg_exports/trd_ma_stylecolorattributes.csv` → delete + `\copy` (NULL '' handling — the free-text minefield of note SUP-4254) |
| → ClickHouse | Via denormalized `trd_stylecolor_hier_attr` export (and the separate `trd_ma_stylecolorchannelattributes` tsv — a different table, PG-born, not part of this build) |
| Data | One row per stylecolor/CC: pricing, season, color, sourcing + denormalized hierarchy names. Powers `attribute:cc_*` everywhere in Assortment views |

## 5. trd_ma_sizeattributes — SKU/size attributes

| Stage | Detail |
|---|---|
| Source file | `S5ProdAttrSize_*.csv` → `TRD_IN_PRD_ATTRSKU` (ITEM, ITEM_DIFF_2/3, STYLECOLORSIZE_CREATE_DATE, SIZE_ATTR_ID) |
| Build | `010_products.sql` CTAS: ATTRSKU × membermaster (level='stylecolorsize') × s5 mapping; `size_attr_id`→`sizeattribute`, `isvalid=1`, `parent_id` initially NULL |
| Logic | `TRD_REF_CC_SKU_MAPPING` built from h_prodstd (ID→STYLECOLOR..TOTAL_BRAND decode), then `UPDATE trd_ma_sizeattributes SET parent_id = STYLECOLOR` — the SKU→CC linkage the UI size views depend on (the mixed-id table from note SUP-4230's diagnosis) |
| → Postgres | `pg_exports/trd_ma_sizeattributes.csv` → delete + `\copy` |
| → ClickHouse | **PG → CH** (not Vertica→CH): `pgsql/weekly/export_to_ch.sql` `\copy (select product, parent_id, item_diff_2/3, sizeattribute, …) to trd_ma_sizeattributes.tsv` → `11_ch_export_load_truncates.sh` truncate + insert |
| Data | One row per SKU: size diffs, size attribute id, parent stylecolor. 60+ CH consumers: flow flag, sku_hier_attr, ASN/allocation worklists, size-level pivots |

---

## Debugging quick reference

- Product missing in UI → check the existing-merge cycle + inbound
  rejects first (notes SUP-4254); confirm row in PG `trd_d_product`, then
  CH copy freshness (`11_ch` truncate/insert is all-or-nothing).
- Wrong hierarchy rollup → `trd_h_prodstd` ancestors vs
  `TRD_REF_CC_SKU_MAPPING` decode; remember s5_id translation at
  style/stylecolor/size levels.
- Attribute wrong on one screen only → config layer (viewdefn/pivot), not
  this pipeline; wrong everywhere → this pipeline.
- Full blast radius: `lineage_impact <table>` (MCP) or
  `python3 tooling/lineage/query.py impact <table>`.

*Generated from code + lineage graph (2026-07); regenerate graphs after
any change to these scripts.*
