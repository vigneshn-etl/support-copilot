# SUP-3061 — [TB] "Performance" group-by shows no data in Collection View

**Component:** ETL (`etl-tb-batch`) — Jira currently says Config, should change.
**Environments affected:** staging/upgrade **and** prod (both confirmed).
**Confidence:** confirmed — runtime logs + direct DB queries on both envs.
Zendesk #4237.

---

## The issue in one line
The Postgres table that supplies the labels for the "Performance" sales-quintile band
(`tb01_v_memberbasedvalidvalues`) is **empty on every batch**, because the Vertica view it is
exported from (`V_MemberBasedValidValues_View`) **does not exist** in TB's Vertica — so darwin
can't band, and the group-by renders blank.

---

## End-to-end chain

### 1. UI (assortmentui)
- Hindsighting → Style / Stylecolor Review → **Collection View** → Group By → **Performance**.
- Collection View calls `pivot3/listData?defnId=HistoryFit&aggBy=level:stylecolor`
  (flat style-color rows, no server-side grouping for a `product`-dimension group-by —
  `StyleColorReview.slice.ts getAggBys`).
- It then groups those rows **client-side** on the field `ccperf`
  (`CollectionView.selectors.ts buildGroupsFromFlatData`, `dataIndex: "ccperf"` from
  `tb-configs-v2/uidefn/view/TB01_HistoryStyleColorGroupBy.viewdefn`).
- `ccperf` is null on every row → one empty group → FitView shows nothing.
- (Grid View survives because AG Grid just shows all rows under one "(Blank)" group — that is why
  the reporter only saw it break in Collection View.)

### 2. Backend (darwin) — where it gives up
`ccperf` ("Performance") is **not a stored attribute**. It is a 1–5 sales-retail quintile band
that darwin's `BandingProcessor` computes **at query time**. To label the bands it first reads the
valid values:
```
SELECT attributekey, attributevalue FROM tb01_v_memberbasedvalidvalues
WHERE membertie = '' AND attributeid = 'ccperf';
```
Runtime log (`TB_Perform_logs.txt`, staging — repeats every request):
```
BandingProcessor - attribute banding slsr with ccperf with vals []
BandingProcessor - no values available during attribute banding, bailing early
```
Empty result → banding aborts → no `ccperf` column in the response → UI groups on nothing.

### 3. The data — table is empty in BOTH environments
Direct queries:
| Env | `SELECT * ... WHERE attributeid='ccperf'` | whole table |
|---|---|---|
| Staging | 0 rows | 0 rows (`SELECT DISTINCT membertie` → nothing) |
| Prod | 0 rows | prod weekly `pg/load.sql` shows `DELETE 0 / COPY 0 / UPDATE 0 ×5` for this table |

So it isn't just `ccperf` — **the entire `tb01_v_memberbasedvalidvalues` table is empty every batch.**

### 4. The ETL pipeline for `tb01_v_memberbasedvalidvalues`
```
06_t.sh  → vertica/05_Location_Mod.sql   builds  TB_Store_ValidValues   (staging 1,056 / prod 1,062)  ✓
         → vertica/06_Product.sql        builds  TB_SC_ValidValues      (staging 17,189 / prod 17,291) ✓
                          |
                          |   (a Vertica view is supposed to UNION these two,
                          |    lowercase attributeid, rename attributename→attributevalue,
                          |    add indx/eventdate)
                          v
07_export.sh → vertica/export_mod.sql:83
     select attributeid, membertie, attributekey, attributevalue, indx, eventdate
     from V_MemberBasedValidValues_View;
     →  ERROR 4566: Relation "V_MemberBasedValidValues_View" does not exist
        (vsql has no ON_ERROR_STOP → error ignored, batch continues, CSV empty/stale)
                          v
10_load_pg.sh → pg/load.sql
     DELETE FROM tb01_v_memberbasedvalidvalues;                       → DELETE 0
     \COPY tb01_v_memberbasedvalidvalues FROM 'V_MemberBasedValidValues.csv' ... → COPY 0
     UPDATE ... WHERE attributeid='ccperf' AND attributekey='1'..'5'  → UPDATE 0  (relabels rows that never arrived)
```
Findings:
- **`V_MemberBasedValidValues_View` is not defined anywhere in `etl-tb-batch`** and does not exist
  in staging or prod Vertica (`v_catalog.views` has no match for `%valid%`).
- The 4 `UPDATE`s in `pg/load.sql` only *relabel* `ccperf` rows — they assume the rows already
  exist. They don't, and `ccperf` is **not** produced by `TB_Store_ValidValues` / `TB_SC_ValidValues`
  anyway (those only carry real `Str*` / `CC*` attributes).
- The batch never fails on any of this — it is silent.

---

## Full lineage of `tb01_v_memberbasedvalidvalues`

### Vertica (transform — `06_t.sh`)
| Script | Line | Action |
|---|---|---|
| `vertica/05_Location_Mod.sql` | 228 | `CREATE TABLE TB_Store_ValidValues AS` — UNION of all `Str*` location attrs (`attributeid,'' membertie,attributekey,attributename`) |
| `vertica/06_Product.sql` | 426 | `CREATE TABLE TB_SC_ValidValues AS` — UNION of all `CC*` style-color attrs, same shape |
| — | — | **`V_MemberBasedValidValues_View` — expected to UNION the two above; NEVER CREATED (see below)** |

### Vertica → CSV (export — `07_export.sh`)
| Script | Line | Action |
|---|---|---|
| `vertica/export_mod.sql` | 82-83 | `\o ./V_MemberBasedValidValues.csv` then `select attributeid, membertie, attributekey, attributevalue, indx, eventdate from V_MemberBasedValidValues_View;` → **ERROR 4566, relation does not exist** (no `ON_ERROR_STOP`, batch continues, CSV empty) |
| `07_export.sh` | 36 | `sed -i 's,","""",g' ./V_MemberBasedValidValues.csv` (quote-doubling on the empty file) |

### CSV → Postgres (load — `10_load_pg.sh`)
| Script | Line | Action |
|---|---|---|
| `pg/load.sql` | 38 | `DELETE FROM tb01_v_memberbasedvalidvalues;` → `DELETE 0` |
| `pg/load.sql` | 39 | `\COPY tb01_v_memberbasedvalidvalues FROM 'V_MemberBasedValidValues.csv' CSV HEADER DELIMITER E'\t';` → `COPY 0` |
| `pg/load.sql` | 40-43 | 4× `UPDATE ... SET attributevalue=... WHERE attributeid='ccperf' AND attributekey='1'/'2'/'4'/'5'` → `UPDATE 0` each (relabels rows that were never inserted; key `3` "Average" not even covered) |
| `pg/load.sql` | 44 | `UPDATE ... SET membertie='' WHERE membertie IS NULL` → `UPDATE 0` |

`pg/insert.sql` (lines 7,14-19) and `pg/truncate.sql` (line 7) reference the same table but are **not called by any batch script** — legacy/manual helpers.

### Postgres → darwin (consumers of `<tenant>_v_memberbasedvalidvalues`)
| File (darwin) | Line | Query / use |
|---|---|---|
| `facade/MemberBasedValidValuesFacade.java` | 36 | table name = `tenantId.toLowerCase() + "_v_memberbasedvalidvalues"` |
| `facade/MemberBasedValidValuesFacade.java` | 251-255 | `SELECT attributekey, attributevalue FROM ${tableName} WHERE membertie = :memberTieStr AND attributeid = :attributeId ORDER BY ${ascSortColumn}` — **this is the exact query in the runtime log** |
| `pivot/processor/BandingProcessor.java` | 267 → 361 | gets valid values for the band; empty list → logs `no values available during attribute banding, bailing early` (the SUP-3061 failure) |
| `pivot/BandingService.java` | 57 | `getNamedValidValues(...)` for the server-side `getGroupByAggSum` path (Grid View / `Pivot2Controller`) |
| `pivot/processor/AttributePostProcessor.java` | 260-262 | `SELECT attributeid, attributekey, attributevalue FROM ${tenantId}_v_memberbasedvalidvalues WHERE attributeid = ? AND attributekey = ANY(?)` — attribute-value decoration |
| `dbv2/JdbcValidValuesRepo.java` | 31-34 | `SELECT attributeid, membertie, array_agg(attributevalue) ... GROUP BY attributeid, membertie` — bulk prefetch |

## Is the view definition anywhere in the repo (old DDL / deploy scripts)?

**No.** `git log --all -p -S "V_MemberBasedValidValues_View"` across `etl-tb-batch` (every branch:
`main`, `etl_assortment_planning`, `etl_assortment_planning_upgrade`, `etl-modern`,
`etl-modern-with-old-vsql-constant_table`, and the legacy `etl-tb-transformation-staging-actual`
monorepo layout) returns **only `SELECT ... FROM V_MemberBasedValidValues_View`** lines — never a
`CREATE VIEW` / `CREATE TABLE`. There is no `Deployments/`, no PG DDL file, no liquibase changeset
for it (`database_changes/postgres/` only has the two `SUP-1583` attribute changelogs).

`etl-modern` branches additionally have a ClickHouse side
(`V_MemberBasedValidValues_TBL` / `_1_TBL`, ingested from the same CSV in
`etl-tb-coordinator-.../execution/batchCoordinator/IngestData.sh`) — also never created from DDL
in the repo, fed from the same broken CSV.

**Reference implementations (other tenants build it as a real table, not a phantom view):**
- `etl-trd-batch/vsql/weekly/070_valid_values.sql:602` `create table trd_v_memberbasedvalidvalues (...)` then row inserts; exported `vsql/weekly/exports.sql:76` `select * from trd_v_memberbasedvalidvalues`; PG side `pgsql/weekly/load_pgsql.sql:499-540` loads it + merges `constant_tables/default_v_memberbasedvalidvalues.csv` (which carries `ccperf` keys 1-5); PG DDL `Deployments/postgres/postgres_ap_ddls.sql:737` + trigger `set_mvv_indx` at `:5171`.
- `etl-aeo-batch/*/vsql/weekly/070_valid_values.sql:269` `CREATE TABLE aeo_v_memberbasedvalidvalues`; `*/pgsql/weekly/load_pgsql.sql:290` `CREATE TABLE static_v_memberbasedvalidvalues` (constant merge).
- `etl-ann-batch`, `etl-belk-batch` — same pattern.

TB is on the old style and the view was assumed to be a pre-provisioned Vertica object that was
never actually created for this tenant.

## The fix (ETL — `etl-tb-batch`, branch `SUP-3061`, both staging + prod)

### A. Create the missing Vertica view  *(restores ALL member-based valid values)*
Add a `CREATE OR REPLACE VIEW V_MemberBasedValidValues_View` (in `06_t.sh`'s vsql, e.g. end of
`vertica/06_Product.sql`, or a new `vertica/06a_valid_values_view.sql`) that unions the two
existing tables into the shape the export/PG table expect:
```sql
CREATE OR REPLACE VIEW V_MemberBasedValidValues_View AS
SELECT LOWER(attributeid) AS attributeid, membertie, attributekey,
       attributename       AS attributevalue,
       ROW_NUMBER() OVER () AS indx,
       CURRENT_DATE         AS eventdate
FROM (
  SELECT attributeid, membertie, attributekey, attributename FROM TB_Store_ValidValues
  UNION ALL
  SELECT attributeid, membertie, attributekey, attributename FROM TB_SC_ValidValues
) u;
```
*(exact column list / casing to be verified against another tenant + the PG table + the darwin
attribute keys used in `TB01_*GroupBy.viewdefn`.)*

### B. Seed the `ccperf` band labels  *(unblocks "Performance" specifically)*
`ccperf` is a computed band, so its 5 labels are static — they must be seeded, not sourced.
TRD keeps them in `constant_tables/default_v_memberbasedvalidvalues.csv`. TB has no constant-table
mechanism, so add them in `pg/load.sql`, replacing the 4 no-op `UPDATE`s inside the same
`BEGIN … COMMIT` block:
```sql
DELETE FROM tb01_v_memberbasedvalidvalues WHERE attributeid = 'ccperf';
INSERT INTO tb01_v_memberbasedvalidvalues (attributeid, membertie, attributekey, attributevalue) VALUES
  ('ccperf','','1','Top 20%'),
  ('ccperf','','2','Above Average'),
  ('ccperf','','3','Average'),
  ('ccperf','','4','Below Average'),
  ('ccperf','','5','Bottom 20%');
```
(`indx` auto from sequence, `eventdate` defaults to `CURRENT_DATE`.)
If (A) also emits `ccperf`, keep only one source to avoid duplicates.

### C. Make the failure loud  *(prevent silent recurrence)*
Add `-v ON_ERROR_STOP=1` to the `vsql` call in `07_export.sh` (and ideally the transform
steps) so a missing relation aborts the batch instead of shipping an empty file.

---

## Validation
1. **Pre-state (done):** both envs — `SELECT * FROM tb01_v_memberbasedvalidvalues WHERE attributeid='ccperf';` → 0 rows.
2. Apply on staging; rerun `06_t.sh` + `07_export.sh` + `10_load_pg.sh` (or manual INSERT for a fast check).
3. **Vertica:** `SELECT count(*) FROM V_MemberBasedValidValues_View;` → > 18,000.
4. **Postgres:** `... WHERE attributeid='ccperf'` → 5 rows.
5. **darwin log:** `attribute banding slsr with ccperf with vals [Top 20%, Above Average, ...]` — no "bailing early".
6. **UI:** Collection View → Group By Performance → 5 quintile groups (Top 20% … Bottom 20%);
   spot-check a style-color's band vs its SlsR rank. Repeat in Style Review and on prod.

---

## Out of scope (flag separately)
- Prod weekly batch has many other failures: `03_upto_100.sql` `MSRP_USD` missing;
  `MFP_ETL_ALL_v3.sql` INSERT column mismatch + missing `TB01_MFP_BY_PRICESTATUS_*_TEMP`;
  `adjust_phistory.sql:51`; `09_AM.sql` duplicate column / `StyleColor` missing;
  `09_AM_MOD_JUL202020.sql` `TB01_AP_PREP_METRICS_ALMOST` missing; `15_Report_Mod.sql` `Month` missing;
  `16_Temp_Flow_Preagg.sql` `tb_TYLY_MONTH_MAPPING` missing; `final_exceptions_part2.sql` `plant` missing;
  `export_rejects.sql` `REC_Wtimestamp` missing; ClickHouse `Cannot parse infinity` / `No data to insert`;
  `load.sql:63` reindex error.
- Empty valid-values table also affects any other member-based attribute darwin bands/validates
  (not just Performance).

---

## Knowledge gained
- **Technical:** `ccperf` "Performance" is a query-time `slsr` quintile band computed by darwin's
  `BandingProcessor`, which needs `<tenant>_v_memberbasedvalidvalues` rows for
  `attributeid='ccperf'` (membertie `''`); with none it logs "no values available … bailing early"
  and the group-by is silently blank. TB's Vertica view `V_MemberBasedValidValues_View` was never
  created, so that whole table loads empty every batch (`COPY 0`), silently. Band labels are static
  → seed them (constant-table pattern, like TRD).
- **Functional:** "Performance" buckets style-colors into sales quintiles (Top 20% → Bottom 20%)
  so planners can hindsight winners vs losers at the collection level.
