# `add_to_assortment()` — the ann/KWG "materialize a cart into the plan" procedure

**Where:** `etl-ann-batch` Postgres, `add_to_assortment(input_jsessionid, scope_product,
scope_location, scope_start, scope_floorset) RETURNS refcursor`.
Deployed body is in `deployments/postgres/postgres_ap_ddls.sql`; **QA has drifted
ahead of git** — always diff the live body (`\sf add_to_assortment`) before editing.
Written as `sN := '<dynamic SQL>'` string assignments, then a long block of
`EXECUTE sN`. **You must read the EXECUTE order, not the definition order** — they
differ, and some `sN` are defined but commented out at execute time (`s4_2`, `s51_1`,
`s41_1`, `s112`).

Related triggers that fire *because* this procedure writes `ann_d_product`:
`trigger_upd_name_description` (style rename → cascade to child stylecolors +
size-concept siblings) and `trg_upd_specstyleid` (`update_specstyle_id`, on
`ann_ma_styleattributes.sty_specstyleid`). See [[sup-3879-add-to-assortment-name-fix]].

---

## 1. What it is trying to achieve (one sentence)

Take the (style, colour) items a planner dropped into their **cart** and fully
materialize them into the planning system for one scope (department / channel /
start week / floorset), so the planning engine can pick them up.

"Fully materialize" = create/refresh **7 kinds of rows**:

| Layer | Table | "what it means" |
|---|---|---|
| identity | `ann_d_product` | the member + its **display name** (what the UI shows) |
| hierarchy | `ann_h_prodstd` | stylecolor → style → subclass → class → dept → total |
| style attrs | `ann_ma_styleattributes` | fit, fabric, merch group, size range, spec style… |
| colour attrs | `ann_ma_stylecolorattributes` | colour name/family/type, print, composite name |
| images | `ann_ma_imgattributes` | one image per colour |
| sizes | `ann_ma_sizeattributes` | the valid sizes for the colour |
| plan data | `ann_ma_stylecolorchannelattributes` | the per-store planning row (receipt wks, MD wks, ranging code, ticket price, cost…) |
| membership | `ann_a_assortment` | "this colour is in the assortment for this scope" + store ranging + store count |
| analytics | `ann_an_price_storecount_info` | price × store-count for reporting |

Then it **queues** the finished colours into `plan_queue` and **returns** their ids.

**Inputs it reads** (all keyed by `jsessionid`):
`cart_master` (one row per style×colour the user added — carries **client-supplied
names**, `style_type`/`stylecolor_type` = `existing` | `similar`, `cccolor`, `img`),
`cart_params` (size type + scope), `cart_ranging` (store climate/grade/ssg choice).

**Output:** a `refcursor` over the `final_stylecolor_id`s that were added, so the
API can answer the browser.

---

## 2. The shape of the logic (chunks)

Everything is done at **3 grains** — style, stylecolor, stylecolorsize — and for
**2 shapes** — the *master* size type (e.g. MISSY) and each *size-concept sibling*
(PETITE / TALL / CURVY). So most steps appear ~4× (grain × shape). Read one path
first (a single colour, master only), then come back for the fan-out.

```
A. SETUP                 build session-scoped temp table names + the scope row
B. RESOLVE IDENTITY      for every cart row: final id + display name, per grain
   (this is where the SUP-3879 fix lives — step "9C" / s4_0_3)
C. WRITE DIMENSION       ann_d_product + ann_h_prodstd  (delete stale, insert)
D. COPY ATTRIBUTES       style attrs, colour attrs, dependency-lookup fields
E. IMAGES                pick image (cart upload > original > spec) -> imgattributes
F. SIZES                 sizeattributes
G. CHANNEL / PLAN ROW    stylecolorchannelattributes (the row that gets planned)
H. ASSORTMENT MEMBERSHIP ann_a_assortment + store ranging + store count
I. PRICE × STORECOUNT    markdown math -> ann_an_price_storecount_info
J. FINISH                queue ready colours, mark cart processed, archive, delete,
                         RETURN the id list
```

**Invariant after each chunk** (say it out loud — this is the trick):
- after A: "I have a private scratch namespace and the scope as a table"
- after B: "every cart row now has `final_style_id`, `final_stylecolor_id`,
  `final_stylecolorsize_id` and the correct display names"
- after C: "those ids exist as real members with a place in the hierarchy"
- after D–G: "each new colour has every attribute a plan needs, copied from its source"
- after H: "each colour is a member of the assortment for this scope"
- after J: "the ready ones are in `plan_queue`; the cart is emptied and archived"

---

## 3. Step-by-step (why · output · what it unblocks)

Grouped by chunk. Step numbers are the procedure's own comments (verify against the
SQL — comments drift).

### A. Setup — STEP 1-3 (`s1`)
- **1-2** `uuid_generate_v4()` → suffix for every temp-table name.
  *Why:* two planners can run this concurrently; temp tables must not collide.
- **3** `input_t1` = `(jsid, scope_product, scope_location, scope_start,
  scope_floorset)` as a 1-row table.
  *Why:* every later step joins to it instead of re-passing 5 args; it's the
  session filter. *Output feeds:* literally everything downstream.

### B. Resolve identity — STEP 4-22
The engine room. Turn "user wants colour X on style Y" into concrete ids + names.

- **4-5** `cart_master_temp` ← `cart_master` **fanned out per size type**
  (`s2` master rows, `s2_1` one extra row per related size concept from
  `ann_l_size_concept_lookups`). Adds empty columns to be filled later
  (`final_style_id`, `class_id`, …).
  *Output:* the master working list every subsequent step joins to.

- **6-8** `cart_style` (`s3` master, `s3_1` size-concept, `s3_2` derive sibling id).
  `final_style_id = (style_type = 'similar') ? uuid_generate_v4() : incoming id`.
  `displayed_style_name` starts as the **client** style name.
  *Why split:* a brand-new placeholder style needs a fresh id; an existing style
  reuses its real id.

- **9A** `s4_0_1` — for **existing** size-concept rows, look up the *real related
  style* (`ann_ma_styleattributes.sty_missy_related_style` + `sty_size_type` →
  `ann_d_product`) and take **its** name. (This is why a PETITE colour is named
  after style `857603`, not the MISSY master.)
- **9B** `s4_0_2` — size-concept rows with no real related style → mint a uuid,
  name = `master id ' ' size_type`.
- **9C** `s4_0_3` — **SUP-3879 fix.** For **existing master** rows, overwrite
  `displayed_style_name/description` from `ann_d_product` (the authoritative name,
  already updated by `update_specstyle_id` if a spec style is attached). Without
  this, a stale client placeholder name flows into new colour names.
- **10** `s4_1` — push `final_style_id` + resolved name back into
  `cart_master_temp`. *This is the hand-off:* the stylecolor step (B/12) builds
  `style_name || ':' || cccolor` from these values.

- **11** `s4_2_*` `s4_3` `s4_4` `s4_5` — fill `sty_size_type`, `class_id`,
  `subclass_id`, `class_name`, `subclass_name` on every row (from `cart_params` /
  `ann_h_prodstd` / size-concept lookups), drop rows that don't resolve.
  *Why now:* the attribute-copy steps (D) join on class/subclass; the size step
  needs `sty_size_type`.

- **12-14** `cart_stylecolor` (`s5` master, `s5_1` size-concept, `s5_1_1` sibling id).
  `final_stylecolor_id = (stylecolor_type = 'similar') ? uuid : incoming id`.
  `displayed_stylecolor_name = (similar) ? style_name || ':' || cccolor :
  stylecolor_name`. **← the name the UI shows for a new colour is built here, from
  the `style_name` that 9C/s4_1 just corrected.**
- **15** `s5_2` — existing size-concept colours → real related stylecolor's
  product + description.
- **16** `s5_3` — unmatched existing alternates → uuid + composed name.
- **17** `s6` — push `final_stylecolor_id` + name back into `cart_master_temp`.
  *`final_stylecolor_id` is THE key every step after C joins on.*

- **18-22** `cart_stylecolorsize` — same pattern at the size grain
  (`s7`, `s7_01`, `s7_1`, `s7_1_1`, `s7_1_2` from `ann_ma_sizeattributes`,
  `s7_2` uuid fallback).

### C. Write dimension + hierarchy — STEP 23-34
Ids + names are known; now create the rows the rest of the system (and the UI) reads.

- **23-25** `ann_d_product` styles: `s8` delete stale `similar` rows for this
  session, `s9` insert `similar`, `s9_1` insert `existing` **if missing**.
- **26-28** `ann_d_product` stylecolors: `s10` delete stale `similar`, `s11` insert
  `similar` (name = `displayed_stylecolor_name`), `s11_1` insert `existing` if
  missing. **← the row the bug produced with a wrong name.**
- **29-30** `ann_d_product` stylecolorsizes (`s13`, `s13_1`).
- **31-34** `ann_h_prodstd` — delete stale, insert the parent chain for
  style / stylecolor / stylecolorsize (`s14`, `s15`, `s15_1`, `s15_2`, `s16`-`s19_1`).
  *Why here:* attribute + assortment steps join `ann_h_prodstd` to find ancestors.

**Idempotency motif (recurring everywhere):** `similar` → *delete-then-insert*
(a replan fully rebuilds it); `existing` → *insert-if-missing* (never clobber a real
member). Learn this once; it repeats at every grain.

### D. Copy business attributes — STEP 35-53
Every planning attribute the new style/colour needs, copied from its **source** (the
style/colour it's based on).

- **35** `s20` delete stale style-attr rows for `similar`.
- **36-41** dependency-lookup fields: colour family (`s21`), colour type (`s21_1`),
  `patternedtostyle` / `patternedtostylecolor` mapping delete+insert
  (`s22`-`s25`).
- **42-44** `ann_ma_styleattributes` insert — master (`s26`), similar size-concepts
  (`s26_1`), existing size-concepts (`s26_2`). Big column lists (fit, fabric,
  neckline, size range, merch dept, `sty_specstyleid`, …).
- **45-48** `s26_3` aggregate size-concept members into arrays on the master
  (`sty_size_concepts`), `s26_4` merch group, `s26_5` retail ticket type, `s26_6`
  `sty_stylenumber_name` composite, `s26_7` main-label default.
- **49-53** `ann_ma_stylecolorattributes`: `s27` delete stale, `s28`/`s28_1`/`s28_2`
  insert (master similar / alt similar / alt existing), `s28_3` set
  `cc_stylecolornumber_name = ann_d_product.name || ', ' || description`
  (reads the name Chunk C just wrote).

### E. Images — STEP 54-58 (`s29`-`s32`)
`s29_1` match a spec-style image (`ann_specimages` by `left(product,6) =
sty_specstyleid`); `s30` build a per-colour table of `{orig, cart, spec}` images;
`s31` delete; `s32` insert with **priority cart upload > original > spec**.

### F. Sizes — STEP 59-61 (`s33`, `s34`, `s34_1`)
`ann_ma_sizeattributes` — delete stale, insert valid sizes for `similar`, add
`existing` if missing.

### G. Channel / plan row — STEP 62-66 + `s37`/`s38`/`s51`
- **62** `s35` `default_cart_params` — the scope + size type for this session,
  used as the source key.
- **63-66** `temp_sclr_chnl_attr` — build the per-colour channel row by copying the
  **source colour's** `ann_ma_stylecolorchannelattributes` (receipt weeks, markdown
  weeks, sell-down week, `ccrangecode`, `ccticketpricechannel`, cost, discount,
  valid sizes, sales rank…), master similar (`s36`), alt similar (`s36_1`), master
  existing (`s36_2`), alt existing (`s36_3`).
- `s37` delete existing channel rows for these (product, location); `s38` insert
  from the temp table. `record_state = 0` for the master colour, `1` for a
  size-concept sibling (so siblings don't double-count).
- `s51` set `plan_current` from `ann_serviceparams`.
*Why this matters:* **this is the row the planning engine actually plans.** No
channel row ⇒ the colour is not really in the plan.

### H. Assortment membership + ranging — `s39`-`s41`
- `s39` / `s39_1` `temp_assort` — join `cart_ranging` (planner's store
  climate/grade/ssg choice, or size-concept defaults) + `get_store_count(...)`.
- `s40` delete existing `ann_a_assortment` plan rows for these (product, location);
  `s41` insert. Now the colour "is in the assortment" for this scope.

### I. Price × store-count — `s100`-`s115`
Markdown/price math: build ticket-price + markdown timeline per colour
(`s100`-`s110_5`), compute `selling_price = least(A,B) * (1 - discount)`, join store
count, `s114` delete + `s115` insert `ann_an_price_storecount_info` (feeds analytics
/ reporting).

### J. Finish — `s42`-`s50`, then `OPEN … RETURN`
- **`s42`** `final_list` = colours that have **both** a channel row (G) **and** an
  assortment row (H). *Gate:* a half-built colour is excluded.
- **`s43`** insert those into **`plan_queue`** `(product, location, initiator,
  initiated_at)` → the planning engine picks them up asynchronously.
- **`s44`** `update cart_master set isProcessed = 1`.
- **`s45`-`s47`** archive `cart_master` / `cart_params` / `cart_ranging`.
- **`s48`-`s50`** delete them from the live cart tables.
- **`s43_1`** + `OPEN added_prods FOR EXECUTE s43_1; RETURN added_prods;` — return
  the queued `final_stylecolor_id`s so the API can respond.

---

## 4. The forward-feeding chain (how outputs reach the finish line)

```
input_t1 (scope)
   └─> cart_master_temp   (cart rows × size types) ......... the working set
          ├─ cart_style ........ final_style_id + name  ──(s4_1)─┐
          │                                                       ▼
          ├─ cart_stylecolor ... final_stylecolor_id + name  ← style_name : cccolor
          │        └──(s6)──> cart_master_temp.final_stylecolor_id  ← THE join key
          └─ cart_stylecolorsize
                 │
   ann_d_product + ann_h_prodstd   (must exist before attributes can attach)
                 │
   styleattributes / stylecolorattributes / images / sizes   (per-colour data)
                 │
   stylecolorchannelattributes (G)   +   ann_a_assortment (H)
                 │         both required
                 ▼
   final_list (s42 gate) ─> plan_queue (s43) ─> planning engine
                 │
   isProcessed=1, archive, delete, RETURN id list
```

**Where SUP-3879 sat:** one line, in `cart_style` name resolution (9C / `s4_0_3`).
Fix the name there → it flows `s4_1 → cart_master_temp.style_name → s5
(displayed_stylecolor_name) → s11 (ann_d_product insert)`. One correction, right
name at every downstream point. That is the payoff of a pipeline with clean
hand-offs: you fix the earliest wrong value, not every symptom.

---

## 5. How to read a procedure like this (reusable method)

1. **Signature + return first.** Inputs, output type. Here: cart session + scope →
   refcursor of added ids.
2. **List the output tables.** `grep -nE 'INSERT INTO|CREATE (TEMP|TEMPORARY)|UPDATE |DELETE FROM'`.
   The real (non-temp) tables it writes **are the chapters**. Temp tables are its
   local variables.
3. **Find the execute order.** A build/execute split (`sN := …` then `EXECUTE sN`)
   is common in dynamic-SQL PL/pgSQL — the run order is the `EXECUTE` block, and
   some are commented out there. Never trust definition order.
4. **Name every temp table in plain words** ("working list", "style identity
   resolver", "channel row builder"). Half the confusion is opaque names.
5. **Write the invariant per chunk** — one sentence: "after this, X is true."
   Chain of invariants = the algorithm.
6. **Trace ONE row end to end.** A single colour, master size only. Ignore the
   size-concept fan-out and the `similar`/`existing` split on pass 1.
7. **Then read the two axes:** `similar` vs `existing`, and master vs size-concept.
   Everything is one of the 4 combinations.
8. **Spot the recurring motif.** Here: `similar` = delete-then-insert, `existing` =
   insert-if-missing, repeated at every grain. Learn it once.
9. **Verify comments against code.** Step-number comments are a gift here but they
   drift; the SQL is truth.
10. **Anchor with a real bug.** "The name bug lived in the identity chunk because it
    trusted the cart, not `ann_d_product`" sticks far better than re-reading 3000
    lines.

## 6. For long-term memory (mnemonics)

- **The pipeline shape** (reusable across this codebase's "add X" procs):
  **Resolve identity → write dimension → write attributes → write plan data →
  queue → return.** Most "materialize into the system" procedures follow it.
- **3 grains** (style / stylecolor / stylecolorsize) **× 2 shapes**
  (master / size-concept) = why steps repeat ~4×.
- **2 types:** `similar` = brand new (mint uuid, delete+insert),
  `existing` = real member (reuse id, insert-if-missing).
- **The gate:** `plan_queue` only gets colours with **both** a channel row **and**
  an assortment row (`s42`).
- **The name of a new colour** = `<style's current ann_d_product.name> : <cccolor>`
  — always from the dimension, never the cart (post SUP-3879).
- **Two triggers do work you won't see in this proc:** `update_specstyle_id`
  (spec attach renames the style row) and `trigger_upd_name_description` (style
  rename cascades to child colours + size-concept siblings).
