# LP Hindsighting Build — Why Each Step

A learning-oriented build journal for adding **Hindsighting** to Lilly
Pulitzer (LP). Every step records **what** we did and **why**, with how
other clients (TRD = reference impl, AEO, LP-MFP, EE) do the same thing.
Grows as the work proceeds. Read top-to-bottom the first time.

- **Target repos:** `etl-lp-batch` (ETL), `lp-configs` (config)
- **Reference feed:** one-time batch `20260806124953` in
  `gs://lillypulitzer-s5-transfer/onetime/inbound/`, staged on the QA OCI
  VM at `/data/external/lp/20260806124953/`
- **TDD:** `S5-Integrations_LillyPulitzer_AP_Apr2026_v1.2.xlsx` (v1.2 =
  Apr 2026; the feed is Aug 2026, so **the delivered files win any
  conflict with the TDD**)

---

## The end goal in one paragraph

Hindsighting is a read-only TY-vs-LY review of sales / inventory /
receipts / margin at style, stylecolor and SKU grain. In our platform it
is three stacked things: **(1)** an ETL pipeline that turns a weekly
SKU×store×week actuals feed + product/location/time master data into a
ClickHouse fact called `p_history_agg`; **(2)** ~30 `History*` pivotdefns
that compute every hindsight metric on the fly from that fact; **(3)** the
UI config (models, views, `M_Meta.conf` silo) that renders it. LP has
none of this today — LP runs MFP only, at month / category / channel
grain, which is too coarse to reuse. So this is a new fine-grain data
domain, not an extension of MFP.

---

## The layer model (memorize this)

```
S5 inbound files (pipe-delimited, gzipped .dat, on GCS)
  │
  ▼  COPY
LP_IN_*        Vertica "landing" — mirrors the file, 1 col per file col, ALL VARCHAR
  │
  ▼  master-load (010_products.sql-style): in-place UPDATE/DELETE on LP_IN_*
  │              for level aliases + UTF-8 cleanup, then CREATE TABLE ... AS
  │              SELECT with inline sentinel->NULL / LOWER(level) / casts.
  │              NO physical staging table — AEO/TRD don't have one either.
LP_D_* / LP_H_* / LP_MA_*    Vertica — the dimension / hierarchy / attribute model
  │
  ├──▶  Postgres   (app database — serves the UI's dimension lookups + hier_attr views)
  │
  └──▶  ClickHouse (_tbl tables — where pivots actually run)
                    + the p_history_* fact chain (fed direct from the actuals file)
```

Each arrow is a deliberate design choice. The rest of this doc is the
"why" behind each arrow.

---

# PHASE 1 — one-time data into the Vertica landing layer

## Step 1.1 — Obtain the feed and decompress it

**What:** `gsutil rsync` the batch folder to the VM; the `.dat` files are
gzip streams despite the extension; `mv f.dat f.dat.gz && gunzip` to get
plain text; keep the originals untouched.

**Why:**
- **Why the files are gzipped-with-a-`.dat`-name:** S5's transfer
  contract. LP's *own MFP* feed works the same way — see
  `etl-lp-batch/bash/weekly/01_copyIncomingFiles.sh` (the `for f in *.dat;
  do mv "$f" "$f.gz"; gunzip; done` loop). AEO's feed, by contrast, is
  *not* compressed — so you can't copy AEO's `onetime_load_vertica.sh`
  verbatim.
- **Why keep the originals:** they are your re-load fallback. GCS is the
  system of record but re-pulling 627 MB every time you re-test is slow.
  Work on a `workspace/` copy.
- **Why decompress at all** (vs. `COPY ... GZIP`): the shared
  `SQLGenerator.py` and the loader we use here handle gzip inline, so for
  the *load* you don't strictly need to. But you decompress anyway for
  **inspection** — you must read the headers before writing DDL (Step
  1.2), and `head`/`wc`/`awk` need plain text.

**Watch:** `S5WeeklySalesInv` is 627 MB gz → **24 GB** / 114M rows
uncompressed. Check `df -h` before decompressing.

---

## Step 1.2 — Read every file header before writing any DDL

**What:** `head -2` + pipe-field-count on each decompressed file; `cat`
the `S5RDYFile` manifest; enumerate `PRODUCT_LEVEL` / `LOC_LEVEL` values;
check for ragged rows.

**Why:**
- **The TDD is a design intent, not a data contract.** LP's TDD v1.2
  (Apr 2026) disagrees with the Aug 2026 feed in ~10 places: the
  "Columns" sections are roughly right, the "Sample" sections are stale.
  Examples we hit: TDD sample shows a 10-level product hierarchy, feed
  has 7; `S5ProdAttrStyle` TDD sample ~20 cols, feed has 6;
  `S5ProdAttrStyleClr` feed has **104** cols; `S5LocAttr` feed 14 not 30.
  **Always diff against the real header.** (AEO's ETL is *generated* from
  its TDD by a `generators/` toolkit — that only works because AEO's feed
  and TDD are kept in lock-step; LP's aren't, yet.)
- **The RDY manifest gives you the row-count oracle.** `S5RDYFile` is
  `FILENAME | RECORD_COUNT` per file. Every downstream count check
  ("did the COPY load everything?") compares against this. Load it into
  `LP_IN_RDYFILE`.
- **`wc -l` lies on files with embedded newlines.** `S5ProdAttrStyleClr`
  (+18), `S5LocMaster` (+6), `S5AccountAttr` (+6) carry literal newlines
  inside quoted free-text fields (print names like `UH OH`). A quoted-CSV
  parser (Vertica `ENCLOSED BY '"'`) handles them; `wc`/`awk -F'|'` don't.
  So for those three, validate by **loaded row count vs RDY**, never line
  count.
- **The level vocabulary drives the whole downstream model.** LP product
  levels: `total_products → division → department → class → style →
  stylecolor → stylecolorsize` (note `total_products` *plural* — differs
  from AEO's `total_product`). LP location: `total_location →
  channel_group → channel → selling_channel → customer_group →
  location`. You can't write `010_products.sql` (Step 4) without this.

---

## Step 1.3 — Decide what loads to Vertica vs straight to ClickHouse

**What:** the 12 dimension / master / attribute files → Vertica landing.
The 114M-row `S5WeeklySalesInv` fact → **skip Vertica**, load straight to
a ClickHouse landing table, validate there.

**Why:**
- **The hindsight fact pipeline runs entirely in ClickHouse.** Vertica
  never touches the actuals fact after inbound. AEO's own
  `onetime_process_history.sh` loads every actuals file *directly* into
  CH (`aeo_p_history_in_sales_inv_delta_tbl`) and never lands them in
  Vertica. AEO's weekly `03_insert_data.sh` does the same. Loading 114M
  rows / 24 GB into Vertica just to run a handful of reject `SELECT`s and
  then discard it is wasted I/O and disk.
- **Where Vertica earns its keep is the *dimensions*.** The referential
  integrity cascade (every hierarchy row's ancestors must be the right
  level in master), member uniqueness across dimensions, "attributes
  without a hierarchy row" — those checks are mature Vertica SQL (see
  AEO's `001_check_inbound_rejects.sql`), and the dimension files are
  tiny (biggest is 12 MB) so it's fast.
- **You cannot fully bypass Vertica** either: Postgres needs the
  dimension data for its `hier_attr` views, and that comes from the
  Vertica master-load. So the split is: Vertica for dims, CH-direct for
  the fact.
- **Feasibility for a one-time load:** CH ingests 24 GB / 114M rows in
  minutes with a `DIRECT`-style insert. Validation in CH is ~6 SQL checks
  (row count vs RDY, week range, null keys, keys-not-in-dim, yearly sum
  vs client control totals). The only thing you give up vs Vertica is
  ergonomic reject-row *extraction* — mitigated by loading to an
  all-`String` CH `_raw` table first, then `SELECT`ing the bad rows.

---

## Step 1.4 — Create the `LP_IN_*` landing tables

**What:** 12 `public.LP_IN_<INTERFACE>` tables, every column `varchar`,
plus `IN_BATCH_ID / IN_FILE_NAME / IN_LOAD_TS` audit columns. Register
each interface in `LP_INTERFACE_MASTER`.

**Why a landing layer at all** (vs. COPY straight into the model):
- **Separation of concerns.** COPY's only job is "get the bytes off the
  file into a table without losing rows." Transformation (typing, joins,
  id-mapping, denormalization) is a separate, reviewable step. If a load
  fails you know it's the file; if a transform fails you know it's your
  logic. Every client does this — `TRD_IN_*`, `AEO_IN_*`,
  `LP_MFP_ACTUALS_INBOUND`, `EVE_IN_*`.
- **The landing table is disposable.** Truncate-and-replace per batch. No
  history, no audit trail obligations — that lives downstream.

**Why ALL VARCHAR** (this is the important one):
- **A typed column turns a data-quality problem into a load failure.**
  This AP feed has: `"NULL"` (quoted string) *and* bare `NULL` *and* `""`
  *and* the literal `"unknown"` all meaning "no value"; booleans quoted
  inconsistently within one row; `""` doubled-quotes used as inch marks
  (`27""`); at least one UTF-8→Latin-1 round-trip corruption. If
  `std_cost` were `numeric`, every `"NULL"` in that column rejects the
  whole row at COPY time — and you're paged at 3am for a data issue you
  can't fix (it's the client's data).
- **Land as text → COPY only fails on *structural* damage** (wrong field
  count). Sentinel normalization + typing happen once, downstream, inline
  in the master-load transform (Phase 4) — not in a separate table.
- **This is exactly what TRD does.** `TRD_IN_PRD_MASTER`,
  `TRD_IN_PRD_HIER`, `TRD_IN_PRD_ATTRSTYLE`, `TRD_IN_LOC_*` — every
  column `varchar(200)`–`varchar(500)`. TRD only types the *measure*
  columns on its *fact* tables (`numeric(16,4)`), and even then the key
  columns stay varchar.
- **Deliberate divergence from LP-MFP.** `LP_MFP_ACTUALS_INBOUND` *is*
  typed (`boh_u int`, `net_sls_r real`). That's fine for MFP because MFP
  data arrives pre-validated (Snowflake → Mulesoft, which does basic
  validation). This AP feed is raw D365 / Centric. Different source
  cleanliness → different landing strategy.
- **AEO goes one step further** with a two-layer landing
  (`AEO_RAW_IN_*` = all-text structural clone, then `AEO_IN_*` = typed,
  with a RAW→IN transform between). We collapsed that to one all-varchar
  layer — simpler, and the trimming AEO does in that RAW→IN step we do
  inline in the master-load `AS SELECT` instead.

**Why the `IN_BATCH_ID / IN_FILE_NAME / IN_LOAD_TS` audit columns:**
- MFP's inbound tables have no batch lineage — that's a gap, not a
  feature. When a downstream number looks wrong, "which file / which
  batch did this row come from?" is the first question. Cheap to add.
- The loader supplies them as COPY *expression* columns (constants), so
  they're not read from the file. The `copy_columns()` helper filters
  `column_name NOT LIKE 'in\_%'` so they never appear in the COPY column
  list.

**Why `public` schema, `LP_` uppercase, `CREATE TABLE` with no projection
clause:**
- **Match the environment you're deploying into.** Staging already has
  `LP_MFP_*`, `LP_INTERFACE_*`, `LP_IN_RDYFILE` — all `public`, all
  `LP_` uppercase, all plain `CREATE TABLE` (Vertica auto-creates the
  superprojection). Diverging (a custom `lp` schema, lowercase,
  `SEGMENTED BY HASH`) creates two conventions in one database for no
  benefit. Landing tables are transient — projection tuning is pointless.
- **Vertica gotcha:** the catalog (`v_catalog.columns.table_name`) stores
  the identifier in the case it was typed, and the loader's column-list
  query uses a **case-sensitive** `=`. Create tables uppercase → the
  loader's MANIFEST must reference them uppercase.

**Why register in `LP_INTERFACE_MASTER`:**
- It's LP's existing validation framework (same shape as AEO's
  `AEO_INTERFACE_MASTER`). `000_validate_inbounds.sql` walks this table:
  for every row with `TYPE='IN'` it counts the `INBOUND_TABLE`, writes
  `LP_INTERFACE_COUNTS`, and if `CHECK_ZERO_COUNT='Y'` and the count is 0
  → a `LP_INTERFACE_VALIDATION_FAILURES` row. `CHECK_PERCENTAGE_DIFF` +
  `COUNT_DIFF_PERCENTAGE_THRESHOLD` do the "count dropped >20% vs last
  run" check — set to `'N'` for the one-time load (no prior run), flip to
  `'Y'` when these go weekly.
- **Vertica has no multi-row `INSERT ... VALUES (),(),()`** — one INSERT
  statement per row (that's why the MFP seed file has one line per
  interface).

**Column-width choices:** generous but not absurd. IDs `varchar(128)`,
names `varchar(512)`, free-text descriptions `varchar(4000)`, size lists
`varchar(1024)`. If a COPY rejects on length, widen and reload — cheaper
than guessing perfectly.

**One rename:** `S5DailyBookings` column 1 is `TIME`, which is a Vertica
**reserved keyword**. The loader builds its COPY column list from the
catalog and can't quote it, so the landing column is `week_id` (matches
`LP_IN_DAILY_PO`). The master-load transform must know file-col-1 =
`week_id`.

---

## Step 1.5 — Load the files with `COPY` (`load_lp_inbound.sh`)

**What:** per file — presence / zero-byte / gzip-integrity / header
column-count check, then `COPY ... FROM LOCAL ... GZIP DELIMITER '|'
ENCLOSED BY '"' NO ESCAPE RECORD TERMINATOR E'\n' SKIP 1 REJECTMAX 0
REJECTED DATA '<f>.rej' EXCEPTIONS '<f>.rjc' DIRECT`, truncate-and-replace,
one `LP_IN_LOAD_AUDIT` row per file.

**Why each COPY option:**
- **`FROM LOCAL`** — the file is on the client host running `vsql`, not
  on a Vertica node. `FROM LOCAL` streams it over the session.
- **`GZIP`** — Vertica decompresses inline. Means you run the loader
  against the *original gzipped* directory, not the decompressed
  `workspace/`. (If you point it at decompressed files, `GZIP` errors —
  "not in gzip format".)
- **`DELIMITER '|'`** — the S5 transfer format for LP (and every other
  client).
- **`ENCLOSED BY '"'`** — LP quotes most fields. Critical: it also makes
  Vertica treat a newline *inside* a quoted field as data, not a row
  break. This is what lets the 3 embedded-newline files load correctly.
- **Escape / doubled-quote — the debugging path (2026-09-03).** LP escapes
  an embedded quote by doubling it (`""`), RFC-4180 style — and the
  apparel catalog `S5ProdAttrStyleClr` is full of inch marks (`26.5""`,
  `27"""`, `6""H`). Three attempts:
  1. `NO ESCAPE` — reasoned "don't let Vertica eat backslashes." 7781 /
     10239 rejected, "too many columns" — Vertica reads `"27"""` as
     field `27` + a phantom empty field.
  2. Dropped `NO ESCAPE` (back to default `ESCAPE '\'`). **Identical**
     7781 rejects. → **Vertica COPY has NO RFC-4180 `""` handling at
     all.** It only recognises `\"` (or whatever the escape char is).
  3. `ENCLOSED BY '"' ESCAPE AS '"'` → Vertica **error 3169: ENCLOSED BY
     and ESCAPE AS can not be the same value.**
  **Fix:** preprocess the file first — `sed 's/\\/\\\\/g; s/|""|/||/g;
  s/""/\\"/g'` — turning `""` into `\"`, then load with `ENCLOSED BY '"'`
  and the default `ESCAPE '\'`. This is exactly what AEO's
  `01_copyIncomingFiles.sh` does. Result: 10239 loaded, 0 inch-mark
  rejects.
  **Residual:** `sed` is line-oriented — a newline *inside* a quoted
  field is two lines to sed, and the `""`→`\"` rewrite on the fragments
  breaks Vertica's ability to rejoin them → ~18 `S5ProdAttrStyleClr`
  rows ("artwork sent 9/5" merch comments with a literal newline) reject
  as "too few columns". A field-aware Python `csv` preprocessor would
  fix those too, but they're not hindsight dimensions — accepted and
  sent to the client. `S5LocMaster` / `S5AccountAttr` also have embedded
  newlines but no `""`, so the sed is a near-no-op and they load exact.
  **Lesson:** `REJECTMAX` + a small per-interface tolerance + loading the
  messy files first with `--only` is how you find a COPY-format problem
  before it silently truncates a full run. And: **never assume a DB's
  COPY speaks RFC-4180** — Vertica, Postgres `\copy`, and ClickHouse all
  differ on `""`, escape, and enclosure rules.
- **`SKIP 1`** — every S5 file has a header row.
- **`REJECTED DATA` / `EXCEPTIONS`** — the two reject outputs. `.rej` =
  the raw rejected line; `.rjc` (EXCEPTIONS) = Vertica's reason per line.
  This is **COPY-level rejection** — only catches *structural* damage
  (wrong field count, unparseable). Business-rule rejects (null keys,
  orphan members) are a *separate* later step against the loaded table.
- **`REJECTMAX 0`** — fail the file if *any* row rejects. Strict on
  purpose for a controlled one-time load. The risk: if Vertica's quoted
  parser doesn't fully handle the embedded newlines, the file fails hard
  — so load the 3 dirty files *first* with `--only` and confirm 0
  rejects before the full run.
- **`DIRECT`** — write straight to ROS (disk), bypass WOS. Right for bulk
  one-shot loads; avoids a WOS-overflow spill on the bigger files.
- **`RECORD TERMINATOR E'\n'`** — explicit Unix line ending (the files
  come from Unix per `file` output).

**Why truncate-and-replace** (not append / merge): a half-loaded table
after a failure is worse than an empty one. The landing layer is
disposable — full reload per batch. (The *model* tables downstream use a
merge/`_existing` round-trip instead — see Phase 4 — because those hold
user edits.)

**Why read the COPY column list from the catalog** (not hardcode it): the
DDL stays the single source of truth. Add a column to the table, the
loader picks it up. `SELECT column_name FROM v_catalog.columns WHERE
table_schema=... AND table_name=... AND column_name NOT LIKE 'in\_%'
ORDER BY ordinal_position`.

**Validation checkpoint after this step:** each `LP_IN_*` row count ==
its `RECORD_COUNT` in `LP_IN_RDYFILE`. For the 3 embedded-newline files
this is the *only* reliable check.

---

# PHASE 2 — inbound validation + reject export  *(next)*

**Why (preview):** COPY only caught structural damage. Now we check the
*content*: (a) counts — zero-count and %-drop, via `LP_INTERFACE_MASTER`
(`000_validate_inbounds.sql`); (b) business rules per interface into
`LP_REJ_*` tables + a `reject_reason` (`001_check_inbound_rejects.sql`).
The rule set comes from the TDD "Requirements & Validations" sections:
member ID unique & not-null, **unique across product+location+time**, no
spaces in IDs, level id lowercase, `\n`/`\t` in a record → reject it,
master ⊇ hierarchy, hierarchy ancestors must be the right level in master
(the RI cascade — see AEO's `001` for the pattern). LP-MFP has *no*
dimension reject tables today — we're adding them AEO-style. Rejects are
exported to GCS outbound and the client fixes and resends; a
`FAILURE_COUNT > threshold` halts the batch.

**Why it matters that rejects are *reported*, not *blocking*:** the bad
rows stay in `LP_IN_*`. The master-load (Phase 4) does its own hard
filtering — it only builds `LP_D_*` from rows that actually join. The
reject report tells the client *why their data thinned out*.

---

# PHASE 3 — typing + normalization  *(folded into Phase 4, no separate layer)*

**Corrected 2026-09-04:** there is **no `LP_STG_*` layer**. No client has
one — AEO's `aeo_staging.*` schema (`v_staging_products.sql`) is a dev
simulation harness, not the prod flow; `AEO_RAW_IN_*`→`AEO_IN_*` is a load
artifact, not staging. Normalization is **inline in the master-load
transform** (Phase 4): in-place `UPDATE LP_IN_... SET product_level=...`
for level aliases, `DELETE ... WHERE ISUTF8(member_id)='f'`, then
`"NULL"`/`""`/`"unknown"` → SQL NULL and numeric casts wrapped inline in
the `CREATE TABLE lp_d_* AS SELECT ...`. LP being all-varchar (vs AEO's
typed `AEO_IN_*`) just means heavier `NULLIF`/cast wrapping in that
SELECT — not an extra table.

---

# PHASE 4 — master-load: dimensions + hierarchies  *(next)*

**Why (preview):** `LP_IN_*` → `LP_D_PRODUCT`, `LP_H_PRODSTD`,
`LP_MA_STYLEATTRIBUTES`, etc. The pattern (from TRD/AEO `010_products.sql`):
build two shared reference tables first —
`LP_REF_PRD_MEMBERMASTER` (members that exist in *both* master and
hierarchy) and `LP_REF_S5_CLIENT_ID_MAPPING` (the id-translation table
*everything* below depends on) — then one `INSERT` per hierarchy level
into `LP_D_PRODUCT` (synthetic root, then total_products, division, …,
stylecolorsize). Ancestor columns in `LP_H_PRODSTD` are level-positional
after this step (unlike the *relative* ancestors in the raw file). The
`_existing` round-trip (export current PG state, merge it back) preserves
user edits and rows that vanished from the feed — this is the #1 suspect
when "a product disappears from the UI" (see hub notes SUP-4254,
SUP-4230, PROD-TRD-20260813).

---

# PHASE 5 — Vertica → Postgres  *(next)*

**Why (preview):** Postgres is the *app* database — it serves the UI's
dimension-name lookups and, critically, the `stylecolor_hier_attr` /
`store_hier_attr` **views** that flatten hierarchy + attributes for
export to ClickHouse. Pattern: `\o` redirect `SELECT * FROM lp_d_*` to
CSV, then `delete from lp_d_*; \copy ... CSV` — a transactional full
reload.

---

# PHASE 6 — Postgres / Vertica → ClickHouse  *(next)*

**Why (preview):** ClickHouse is where pivots actually execute. The
dimension `_tbl` tables get loaded Vertica/PG → TSV → CH
(`11_ch_export_load_truncates.sh`); `sku_hier_attr` is derived *in* CH
from size attrs × `stylecolor_hier_attr`. CH pattern: `<name>_tbl` =
`ReplicatedMergeTree` (the load target), `<name>` (bare) = `Distributed`
proxy over it, `<name>_agg` / `_view` = views. **You load the `_tbl`.**

---

# PHASE 7 — the `p_history_*` fact chain (ClickHouse)  *(next)*

**Why (preview):** `S5WeeklySalesInv` (CH landing) → `p_history_in_sales_inv_tbl`
(typed, zeroed) → `p_history_sales_inv_tbl` (joined to id-maps / store
hier / tyly / store-tier; derives `strcntwk`, first-funded week) →
`p_history_sku_tbl` → `p_history_loc_arr_tbl` (array-packed by location)
→ **VIEW `p_history_agg`** (ARRAY JOIN explode) ← *what the pivots read*.
Then `090_flow_flag` / `510_am_prep` / `520_preagg` build flow status and
the YTD / monthly / annual roll-ups the Summary and Yearly-Trend pivots
need.

---

# PHASE 8 — config: pivots / views / M_Meta  *(next)*

**Why (preview):** `lp-configs` gets a `pivot/` dir (~30 `History*`
pivotdefns + ~40 shared FreeMarker includes), `uidefn/model` + `view`
(~130), and `M_Meta.conf` gets the Hindsighting silo + the ProdStd /
LocStd / TimeStd / ProdLifeStd / ClusterStd hierarchy definitions. Metrics
are computed on the fly in CH from `p_history_agg` — they are NOT stored
(`M_Meta.conf:119` on AEO).

---

## Cross-client reference — how everyone does the landing layer

| | landing table types | fact measures | reject tables | id mapping |
|---|---|---|---|---|
| **TRD** (reference) | `TRD_IN_*` all `varchar(200-500)` | typed `numeric(16,4)` on fact only | per-interface, RI cascade | `S5_ID` column in the file |
| **AEO** | `AEO_RAW_IN_*` (text) → `AEO_IN_*` (typed) | typed | rich `AEO_REJ_*`, generated from TDD | `CLIENT_MEMBER_ID` + `REF_S5_CLIENT_ID_MAPPING` |
| **LP-MFP** | `LP_MFP_*_INBOUND` **typed** (`real`/`int`) | typed | facts only, no dim rejects | none (MFP ids are hierarchy ids) |
| **LP-AP (us)** | `LP_IN_*` **all varchar** | fact skips Vertica | *to build* — AEO-style | `CLIENT_MEMBER_ID` present; mapping TBD |
| **EE** | `EVE_IN_*`, `intraday` cadence | typed | per-interface | `EVE_IN_PRD_ERP_PIM_MAP` |

**Takeaway:** dimensions land as text everywhere. The only real variation
is (a) one landing layer vs. two (RAW + IN), and (b) whether fact
*measures* are typed at COPY or deferred. LP-AP: one layer, all text,
fact deferred to CH.

---

## Open questions / where confidence is low

Flagged so we can get answers rather than guess:

1. **LP ClickHouse cluster** — not yet confirmed it exists for the LP
   deployment (MFP-only tenants may not have one). Everything from Phase 6
   on depends on it: cluster present, DB name, `DarwinCluster` config,
   disk sizing for 114M rows × 182 weeks. *Need: infra confirmation.*
2. **Master-load transform rules** — the exact sentinel list (`"NULL"` /
   `""` / `"unknown"` / bare `NULL`) per column, and which columns are
   genuinely numeric, for the inline coercion in the `AS SELECT`.
   *Need: a pass over the actual loaded data + the TDD "Requirements &
   Validations" per sheet.*
3. **id-mapping** — `CLIENT_MEMBER_ID` is present in `S5ProdMaster` /
   `ProdAttrStyleClr` / `ImageURL`. Is it the join key S5 expects, and
   does LP send it consistently at every level? AEO's model needs a
   `REF_S5_CLIENT_ID_MAPPING`; TRD gets `S5_ID` in the file. *Need:
   confirm LP's intent with the integration team / TDD §1.2.*
4. **Wholesale scope** — `S5DailyBookings` + `S5AccountAttr` + the `LW-`
   locations + `net_whsl_transfer_*` columns. Is wholesale in scope for
   Hindsighting v1, or retail-only? No AEO pattern to copy for wholesale.
   *Need: solutioning decision.*
5. **Store clustering** — TDD interface `6.4 S5LocVolTier_` (loc × month ×
   class × tier A/B/C) is "move to biz owned" and **not in the feed**. So
   `cluster_view` / `int_store_tier_dept_week` get stubbed (`cluster =
   'NA'`) for now. Confirm that's acceptable for v1.
6. **Calendar** — TDD says `S5TimeHier` / `S5TimeMaster` / `S5MFPTYLY` are
   "S5 will provide" (not sent by LP). Need to confirm S5 generates the
   NRF calendar + TY/LY/LLY week offsets and where.
7. **Currency** — no currency column, no currency interface → USD only.
   Confirm (removes the `currency_conv` joins in Phase 7).

---

## Running log (append per session)

- **2026-09-03** — Phase 1: `lp_in_ddl_vertica_qa.sql` run against QA
  (empty env, so self-contained: framework + 12 `LP_IN_*` + audit +
  interface seeds). RDY manifest loaded. Loader config'd for
  `LP_SCHEMA=public`, uppercase MANIFEST, sales line removed.
  - **Connection:** QA Vertica listens on node IP `172.16.230.50:5433`,
    not `127.0.0.1`. `/usr/local/bin/vsql` is a wrapper that injects it;
    the raw `/opt/vertica/bin/vsql` the loader calls needs
    `export VSQL_HOST=172.16.230.50` (DB `darwin`, user `dbadmin`).
  - **`NO ESCAPE` bug** (see Step 1.5) — dropped it. Then learned Vertica
    has **no RFC-4180 `""` handling at all** and forbids `ESCAPE ==
    ENCLOSED BY` (error 3169). Fix = sed-preprocess `""` -> `\"` (+ `\` ->
    `\\`, `|""|` -> `||`) then load with default `ESCAPE '\'`. Same as
    AEO's `01_copyIncomingFiles.sh`.
  - **Residual:** the sed is line-oriented, so `S5ProdAttrStyleClr`'s ~18
    rows with a newline INSIDE a quoted "artwork sent" comment field get
    split and rejected ("too few columns"). Decision: **accept them** —
    those fields aren't hindsight dimensions; the 18 go back to the
    client in the reject bundle. Per-interface reject max in the manifest
    (`|25` for StyleColr, `|0` for the rest).
  - **Full batch loaded 2026-09-03 07:29** — all 12 files at exact RDY
    count. Only reject in the whole batch: `LP_IN_PROD_ATTR_STYLECOLOR`
    18 rows.
  - **Loader productionised** -> `JIRAs/SUP-4648/OT_loadinbound_S3.sh`:
    (1) `reset_batch_state()` clears prior audit/prepared/reject artifacts
    per run; (2) per-interface reject max (4th MANIFEST field);
    (3) `collect_rejects()` -> `reject_summary.csv` + `lp_rejects_<batch>.tar.gz`;
    (4) dropped the no-op `COMMIT;` (autocommit noise).
  - **Vertica vsql autocommit is OFF** — `COPY` and `TRUNCATE` self-commit
    (loads always worked), but `DELETE`/`INSERT` silently roll back on
    session end without an explicit `COMMIT`. Bit us on the audit table:
    `reset_batch_state()`'s DELETE and `audit_row()`'s INSERT both need
    `; COMMIT;`. Fixed in `OT_loadinbound_S3.sh`. (The earlier
    "Cannot commit; no transaction in progress" noise was *only* the
    `COPY` line — removing COMMIT there was right, removing it from the
    audit DML was not.)
  - **Phase 1 CLOSED.** Reject bundle to hand to LP:
    `/data/logs/lp/rejects/20260806124953/lp_rejects_20260806124953.tar.gz`.
  - **SUP-4648 folder** now holds the as-built artifacts:
    `OT_gunzip_S1`, `OT_verticaddl_S2.sql`, `OT_loadinbound_S3.sh`,
    `OT_salesinv_ch_S4.sql`, `OT_salesinv_load_S4.sh`.

### 2026-09-03 — S5WeeklySalesInv -> ClickHouse (step 4)

- **LP CH confirmed:** OCI, database `lp` (empty/greenfield), server
  **v21.4.1** (old — hub notes "21.4 gotchas"), client v22.12,
  `DarwinCluster` = **1 node**. LP's MFP ETL never loads CH via the repo
  (Vertica + Postgres only) — so no LP CH table pattern to copy, and no
  AEO template for "validate the fact in CH" (AEO validates actuals in
  Vertica). New design.
- **CH 21.4 constraints:** `FORMAT CSVWithNames` auto-skips the header and
  loads **positionally** (raw table column order must equal the file
  header); no `ESCAPE` in `LIKE`; no `input_format_csv_skip_first_lines`
  (22.x). `--input_format_with_names_use_header=0` makes the positional
  load explicit.
- **CH CSV is RFC-4180-compliant** — handles `""` and multiline quoted
  fields natively. So the sales fact needs **no sed pre-pass** (unlike
  the Vertica AP load). It's also numeric-heavy with few free-text traps.
- **Two-layer, mirrors AEO:** `lp_p_history_in_sales_inv_raw` (47 String
  cols, plain `MergeTree`) <- file; then ~10 validation queries; then
  `lp_p_history_in_sales_inv_delta_tbl` (typed `Nullable(Float32)`,
  `PARTITION BY time`) <- promote with `toFloat32OrNull(nullIf(x,'NULL'))`.
- **Engine = plain `MergeTree` for now** (validation phase). The
  production chain — `ReplicatedMergeTree(...)` + `Distributed('DarwinCluster',
  'lp', ...)` + the `p_history_agg` views — is Phase 7.
- **Deferred:** keys-not-in-dims (3.10) is cross-DB — dims are in Vertica
  until Phase 6.
- Next: run `OT_salesinv_load_S4.sh`, then Section 3 validation; the
  by-year aggregate table (3.9) goes to LP for control-total
  reconciliation.
- **Load + validate done (2026-09-03):** 114,394,630 rows, exact RDY,
  ~2 min, zero errors. CH CSV handled it with no preprocessing.
  Validation: grain / keys / numerics all clean; SKU grain confirmed.
  **Client flags:** (1) history starts `2023_W53`, only 153 weeks —
  TDD wanted `2022_W01` / 182 wks; (2) no DC (999) rows; (3) max week
  `2026_W49` (future); (4) 1 negative `ret_r`; (5) by-year aggregates
  (`net_sls_r` 2025 = $345M — matches LP's real revenue) -> LP to
  reconcile. Decision: promote with the 153 weeks, chase history in
  parallel (2 yrs covers TY-vs-LY).

### 2026-09-03 — Phase 2: AP business validation (step 5)

- **No cross-client precedent for a cross-dimension member_id
  uniqueness check** — not AEO, TRD or EE. It's a TDD *assertion*
  enforced by LP's id-prefix scheme (products numeric/`TP-`/`DV-`…,
  locations `LC-`/`LS-`/`LW-`/`CH-`…). We added it anyway (one
  `INTERSECT`) — catches a broken prefix scheme on a resend.
- AEO's `001` is generated from its TDD by a `generators/` toolkit we
  don't have -> hand-written from LP's TDD "Requirements & Validations"
  + AEO rule shapes.
- **Tables:** 12 × `LP_REJ_<interface>` = `LP_IN_<interface>` (via
  `CREATE TABLE … LIKE`) + `reject_reason`. Everything else
  (`LP_INTERFACE_*`, `LP_IN_RDYFILE`) already exists.
- **Scripts** (`SUP-4648/`): `OT_rejtables_S5.sql`,
  `OT_validate_counts_S5.sql` (AEO 000 equiv),
  `OT_check_rejects_S5.sql` (AEO 001 equiv), `OT_run_validation_S5.sh`
  (runs all + exports `lp_ap_rejects_<batch>.tar.gz` for the client).
  **Report only — exits 0**, no halt (one-time load).
- **LP adaptations:** `total_products` plural; no `convert_levels`;
  `LOC_HIER.ancestor0` literal `"RETAIL"` skipped in the RI check; RI =
  immediate-parent + orphan-ancestor (full positional cascade noted as
  extensible); wholesale feeds (`DAILY_PO`/`ACCOUNT_ATTR`/`DAILY_BOOKINGS`)
  get lighter checks.
- Vertica gotchas re-confirmed: no multi-row `VALUES`; vsql autocommit
  OFF; `LIKE` backslash-escape is unreliable -> use `_` wildcard, and
  `ESCAPE '\'` explicitly for the one literal-underscore match (RDY
  filename prefix, to keep `S5ProdAttrStyle` from matching
  `S5ProdAttrStyleClr`).
- **Ran 2026-09-04** (`OT_run_validation_S5.sh 20260806124953`):
  - **All 12 interfaces at exact RDY count — 0 count-validation failures.**
  - **Product + location master / hierarchy / attributes: 0 rejects.**
    RI cascade, orphan-ancestor, cross-dimension uniqueness all clean.
  - `LP_IN_DAILY_PO` **222** (on-order, not a hindsight dim): 198
    "dups", 17 SKUs not in Product Master, 7 malformed `week_id`.
    **The 198 were a rule bug (fixed 2026-09-08):** PO-line grain includes
    `ndc_date` + `flow_id` — same po_id/week with a different delivery
    date is a separate scheduled delivery, not a dup. Dedup key widened;
    re-run for the real count (expect ~0).
  - `LP_IN_LOC_ATTR` **13** — `LS-` stores in the hierarchy with no
    store-attribute row (96 have attrs). Blank store attrs in hindsight
    store views; affects clustering later, not TY-vs-LY.
  - `LP_IN_LOC_HIER` **1** — FALSE POSITIVE (fixed 2026-09-08). The row
    was `TL-01` = `total_location`, the hierarchy ROOT — it has no parent
    by definition. `OT_check_rejects_S5.sql` null-ancestor0 check now
    joins LOC_MASTER and excludes `loc_level = 'total_location'`.
    LOC_HIER -> 0 after re-run.
  - Bundle: `/data/logs/lp/rejects_ap/20260806124953/lp_ap_rejects_20260806124953.tar.gz` -> LP.
- **Verdict:** the hindsight-core dimensions are clean enough to build
  `LP_D_*` / `LP_H_*` on. The `DAILY_PO` issues are on-order scope — flag,
  don't gate. Phase 2 CLOSED.

### 2026-09-04 — step 6: dimension keys -> CH, fact membership check

- **Why:** OT_salesinv_ch_S4.sql check 3.10 (every fact product/location
  key resolves to a real dimension member) was deferred as cross-DB —
  dims in Vertica, fact in CH. Rather than export-and-diff, mirror the
  **key columns only** into small CH `lp_ref_*` tables and anti-join.
- **Keys only, deliberately:** `member_id` / `ancestor*` / level codes.
  `member_name` / `member_desc` / `customer_type` have embedded newlines
  (LocMaster +6, AccountAttr +6) which break unquoted TSV. The AP
  business validation already proved 0 rows with a space in `member_id`,
  so the token columns are safe for a `vsql -F E'\t' -At | clickhouse-client
  FORMAT TSV` pipe.
- **NOT Phase 6.** These are validation scratch tables, not the
  production `stylecolor_hier_attr` / `store_hier_attr` / `sku_hier_attr`
  `_tbl`s — those need the master-load transform + the S5<->client
  id-mapping, which is gated on the open client concerns.
- **Scripts** (`SUP-4648/`): `OT_hier_ch_S6.sql` (4 `lp_ref_*` DDL +
  8 validation queries), `OT_hier_ch_load_S6.sh` (Vertica -> CH loader,
  4-row manifest, count-verifies each).
- Checks: SKU-in-master (`product_level='stylecolorsize'`),
  SKU-in-hier, store-in-master (`loc_level='location'`, `999` excluded),
  store-in-hier; offender lists ranked by `net_sls_u` for LP; reverse
  coverage (SKUs that never sold — informational).
- **Time keys not checked** — LP sends no calendar (S5 provides
  S5TimeHier/Master). Week format + range done in step 4.
- **Ran 2026-09-04 — fact is essentially fully joinable:**
  - `lp_ref_*` loaded: prod 79692, loc 4283 (my 4895 loc note was wrong —
    loc master == loc hier == 4283, breakdown adds up).
  - Level vocab present and sane: product `stylecolorsize` 64325 /
    `stylecolor` 10239 (matches the S5ProdAttrStyleClr load count) /
    `style` 5038 / class 64 / dept 20 / div 5 / total 1. Location
    `location` 4266 + 6 customer_group + 5 selling_channel + 3 channel +
    2 channel_group + 1 total.
  - **3.3 SKU membership: 0 orphans.** 62241 distinct SKUs sold — every
    one is a `stylecolorsize` in master with a full ancestor chain
    (3.8: 0 blank ancestor0/1 for sold SKUs).
  - **3.4 store membership: 1 orphan** — `LW-289951` (wholesale), 34
    rows, all `2026_W24`, $0 / 0 units. Noise; add to the LP list or it
    drops out.
  - **3.7 coverage:** 2084 / 64325 master SKUs (3.2%) never sold in 153
    weeks — normal, LP's catalog is tightly scoped to what sells.
  - **Verdict: the CH fact + Vertica product/location dims are
    internally consistent.** Green light to promote the fact (step 4
    section 4) and start Phase 3/4. `LW-289951` -> LP list.
