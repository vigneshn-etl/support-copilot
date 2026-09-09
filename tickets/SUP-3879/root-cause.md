# SUP-3879 — root cause (evidence-cited)

**Symptom:** [KWG/ann] Attach a Spec Style to a placeholder style, then WITHOUT
replan/refresh add a new Style Color. The new color's name/description keeps the
old placeholder name (`S5_VN_SIM_STY01:000003 …`) while sibling colors show the
new spec name (`841918:001987 …`).

## Chain (observed)

1. **assortmentui** composes child names client-side and does NOT refresh the
   style name after spec-attach (intentional per ticket). On "add color" it POSTs
   `/asst/api/assortment/cart/<id>/addToAssortment` with the stale name.
   - log `ann_similar_style_sce1.txt:31547-31548`:
     `adding to assortment cartId=…, id=2e7170f6…, name=S5_VN_SIM_STY01, … type=existing`
     `adding to assortment choice … name=S5_VN_SIM_STY01: 000003 GOLDEN CROISSANT, description=S5_VN_SIM_STY 000003 GOLDEN CROISSANT`
   - spec style was already attached at 17:09:06 (`…:191` sets
     `ann_ma_styleattributes.sty_specstyleid=841918`).

2. **darwin** persists the client name/description verbatim into `cart_master`.
   - `darwin/assortment/src/main/java/com/darwin/service/AssortmentHelper.java:1155-1164`
     `new TransientMember(… stylecolorItem.get("name"), stylecolorItem.get("description") …)`
   - `darwin/assortment/src/main/java/com/darwin/dbv2/CartQueueManager.java:283-284`
     `batch.bind("stylecolorName", stylecolor.getName())` → `cart_master.stylecolor_name`
   - matches user's `cart_master` dump: `style_name=S5_VN_SIM_STY01`,
     `stylecolor_name=S5_VN_SIM_STY01-001987 BLUE HYDRANGEA`, `isprocessed=0`.

3. **PG function `add_to_assortment`** (processor of `cart_master`) builds the
   new similar color's display name from `style_name`, which is never
   re-resolved from `ann_d_product` for a plain existing master style.
   - `etl-ann-batch/database_changes/postgres/sql_changes/20251223_speedup_add_to_assortment.sql:653`
     (statement `s5`):
     `case when stylecolor_type = 'similar' then style_name||':'||cccolor else stylecolor_name end as displayed_stylecolor_name`
   - `style_name` here = stale `cart_master.style_name`. The only steps that
     refresh it from live `ann_d_product.name` are `s4_0_1` (missy/petite
     related-style only, gated on `sty_missy_related_style`) and `s4_0_2`
     (alt size-type siblings, `sc_type != 'master'`). No general refresh for
     `style_type='existing' AND sc_type='master'`.
   - same code in `deployments/postgres/postgres_ap_ddls.sql` (~line 3435) and
     every prior `*_add_to_assortment.sql`.

**Why the first color is correct:** the spec-attach routine renames the style
and its *existing* stylecolors in `ann_d_product` server-side from the spec
style's attributes (DB dump: `2e7170f6` name→`841918`, `ce88709c` →
`841918:001987 BLUE HYDRANGEA`). Only colors added afterwards via a fresh
`add_to_assortment` job carrying the stale `style_name` are wrong.

## Root cause (one line)

`add_to_assortment` derives a newly-added color's name as
`cart_master.style_name || ':' || cccolor`, and `cart_master.style_name` is a
client-captured snapshot of the *placeholder* style name (assortmentui doesn't
refresh it post spec-attach, darwin stores it as-is) — the function never
re-reads the style's current name from `ann_d_product` for a plain existing
style.

## Fix options (not yet applied)

- **Preferred (server-authoritative, ETL):** in `add_to_assortment`, before
  `s5`, add a general refresh:
  `UPDATE cart_style a SET displayed_style_name = p.name,
   displayed_style_description = p.description
   FROM ann_d_product p
   WHERE p.id = a.incoming_style_id AND a.style_type='existing' AND a.sc_type='master';`
  (Then `s4_1` propagates to `cart_master_temp.style_name` and `s5` builds the
  correct color name.) Scope: `etl-ann-batch` branch `etl_assortment_planning`,
  `postgres_ap_ddls.sql` + a new `database_changes/.../SUP_3879_add_to_assortment.sql`.
- Alt (darwin): in `AssortmentHelper.addMembers`, for `type='existing'` look up
  name/description from `ann_d_product` instead of trusting the client payload.
- assortmentui refresh of the style name is explicitly rejected by the ticket.

## Open checks before fixing

- Confirm which `*_add_to_assortment.sql` is actually deployed in KWG/ann QA
  (repo drift) — diff live function body vs repo.
- Confirm the `similar` vs `existing` `stylecolor_type` for the "add color"
  path (DB dump wrong row uses `:` separator ⇒ `similar` branch).
- Check the `description` build too (`s5` line 654) — same stale `style_description`.

---

# FIX (drafted 2026-09-03) — edit clone `/Users/vigneshn/Desktop/JIRAs/SUP-3879/etl-ann-batch` (branch SUP-3879)

QA `add_to_assortment` has drifted ahead of git (`add_to_assortment_qa_ann.sql`
= 3450 lines vs repo `20251223_speedup` ~1050). Fix authored against the QA body.

## Fix 1 — `add_to_assortment` (done)

New migration `database_changes/postgres/sql_changes/20260903_SUP_3879_add_to_assortment.sql`
(full CREATE OR REPLACE = QA body + 3 edits), registered in `changelog_current.xml`.

- declare `s4_0_3 text;`
- new statement **s4_0_3** (STEP 9C), placed after `s4_0_2`, executed before `s4_1`:
  ```sql
  update <cart_style> a
  set displayed_style_name       = coalesce(p.name, a.displayed_style_name)
     ,displayed_style_description = coalesce(p.description, a.displayed_style_description)
  from ann_d_product p
  where p.id = a.final_style_id
    and p.levelid = 'style'
    and a.style_type = 'existing'
    and a.sc_type = 'master';
  ```
- `EXECUTE s4_0_3;` after `EXECUTE s4_0_2;`

Effect: for an existing style, the cart's working `style_name` is realigned to the
authoritative `ann_d_product.name` (which `trg_upd_specstyleid` already updates to
the spec style number on attach) *before* `s5`/`s5_1` build
`displayed_stylecolor_name = style_name || ':' || cccolor` for new (`similar`)
colors and before `s4_1` pushes it to `cart_master_temp`.

### Scenario coverage (Fix 1 only)

| Scenario | style_type / stylecolor_type | Behaviour after fix |
|---|---|---|
| Add from Existing Style, then add new colour | existing / similar | new colour = `<current style name>:<cccolor>` — spec name if attached ✓ |
| Add Similar Style Color (new colour on existing style) — **ticket bug** | existing / similar | fixed — spec name ✓ |
| Add from Similar Style (brand-new placeholder) | similar / similar | untouched by s4_0_3 (not `existing`); colour = `<placeholder>:<cccolor>` ✓ |
| Normal new placeholder, no spec style | similar / similar | unchanged — `<placeholder>:<cccolor>` ✓ |
| Existing colours already present, spec attached, add colour + replan | — | **new** colour follows spec; **pre-existing** colours keep old name until full replan — see Fix 2 |

## Fix 2 — cascade rename to pre-existing child stylecolors (OPEN — needs decision + QA source)

`update_specstyle_id()` (trigger `trg_upd_specstyleid`) renames only the STYLE row
in `ann_d_product` (`where id = NEW.product`). Colours added *before* the spec
attach keep `<placeholder>:<cccolor>` until a full replan re-sends them.
To make pre-existing colours flip on attach, add to the `NEW.sty_specstyleid is
not null` branch, right after the `update ann_d_product set name = NEW.sty_specstyleid`:

```sql
-- SUP-3879: cascade to child stylecolors that currently follow the style name
update ann_d_product d
set name        = NEW.sty_specstyleid || ':' || sca.cccolor
   ,description  = coalesce((select target_value from ann_l_dependencylookup
                              where lookup_id='bbr_style_id' and target_id='bbr_style_desc'
                                and lookup_value = NEW.sty_specstyleid), d.description)
                    || ':' || sca.cccolor
from ann_h_prodstd h, ann_ma_stylecolorattributes sca
where h.ancestor0 = NEW.product and h.id = d.id and sca.product = d.id
  and d.levelid = 'stylecolor'
  and d.name LIKE v_old_style_name || ':%';   -- capture v_old_style_name BEFORE the style rename
```

Needs: (a) confirm the team wants pre-existing colours retro-renamed;
(b) the **QA** body of `update_specstyle_id()` (repo copy is likely stale too);
(c) confirm the child stylecolor name format is exactly `<style>:<full cccolor>`
(DB dump `ce88709c` = `841918:001987 BLUE HYDRANGEA` supports this).

## Validation plan (stage 7)

PRE (QA, one fresh placeholder):
- `select id,name,description from ann_d_product where id in (<style>, <colors>)`
- `select product, style_name, stylecolor_name from cart_master where jsessionid=<js> and isprocessed=0`

Repro the ticket steps 1-7 on QA after deploying the migration:
- assert new colour `ann_d_product.name` = `<sty_specstyleid>:<cccolor>` and matches its sibling.
- Style Color Review grid: both colours identical style prefix.
Regression:
- add-from-similar (no spec): name still `<placeholder>:<cccolor>`.
- existing style, existing colours only: names unchanged (real stylecolor numbers).
- missy/petite alt-size add: names unchanged (s4_0_1/s4_0_2 path).

---

# Scenario 3 analysis — "similar style + spec + color, planning not completed" (`after_codeChange.txt`)

Timeline (QA, internal-qa ann-asst-0):
- 17:46:29 sess `d0213b4f`: add-from-similar style 857539 `S5_VN_SIM_STY_AF`, colour `019930 WHITE/NAVY`, `type=similar`. Planned → real style id `ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c`.
- 17:47:42 `property/update/granular` `sty_specstyleid=844809` on `ad9cd4d5` → `trg_upd_specstyleid` → `update_specstyle_id()` renames **only** `ann_d_product` id `ad9cd4d5` → name `844809`.
- 17:47:56 sess `ba323087`: add colour `000004 HOLIDAY CRANBERRY` (id `15a79ff6…`), **`type=existing`**, client still sends `name=S5_VN_SIM_STY_AF`.

Key point: the second "add colour" reaches darwin as **`type=existing`** (log 129220) — once the
style is persisted it is never `similar` again. So **Fix 1's `s4_0_3` gate
(`style_type='existing' AND sc_type='master'`) DOES fire here** → `displayed_style_name`
is realigned to `ann_d_product.name` = `844809` → new colour becomes
`844809:000004 HOLIDAY CRANBERRY`. ✓

BUT the colour added **before** the spec attach (`019930 WHITE/NAVY`) is already in
`ann_d_product` as `S5_VN_SIM_STY_AF:019930 WHITE/NAVY`, and `update_specstyle_id()`
renames only the style row → that colour keeps the placeholder prefix →
**the two colours still show different names** (= the ticket symptom).

⟹ **Fix 2 (cascade rename to child stylecolors in `update_specstyle_id`) is REQUIRED**
for this scenario, not optional. Fix 1 covers colours added after the attach; Fix 2
covers colours that already existed at attach time.

Note: `after_codeChange.txt` is an application log — it does NOT contain the
PL/pgSQL internal SQL of `add_to_assortment` nor the trigger `RAISE NOTICE`s, so it
cannot by itself confirm the persisted names. Needs DB queries below.

## Verification queries (run on QA ann after the repro)

```sql
-- style + both colours
select d.id, d.levelid, d.name, d.description, d.updated_at
from ann_d_product d
where d.id = 'ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c'
   or d.id in (select id from ann_h_prodstd where ancestor0 = 'ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c')
order by d.levelid, d.name;

-- what the style's authoritative name is
select product, sty_specstyleid, sty_vendor_style_description, style_description
from ann_ma_styleattributes where product = 'ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c';

-- pending cart rows (client-supplied names)
select jsessionid, style_type, style_name, stylecolor_type, cccolor, stylecolor_name, isprocessed
from cart_master
where jsessionid in ('d0213b4f-0b43-4c62-bcc2-55b7d4d0eefc','ba323087-ea1b-41ab-9a3b-29b9839b3331');
```

Expected WITH Fix 1 only: colour `000004` = `844809:000004 HOLIDAY CRANBERRY`,
colour `019930` = `S5_VN_SIM_STY_AF:019930 WHITE/NAVY` (mismatch).
Expected WITH Fix 1 + Fix 2: both colours prefixed `844809:`.

## Need from reporter
- QA source of `update_specstyle_id()` (repo copy `20260414_SUP_3892…` is likely stale).
- Confirm Fix 1 migration `20260903_SUP_3879_add_to_assortment.sql` is actually deployed on QA for this log (or was the log pre-deploy?).

---

# Scenario 3 — RESULT (post-fix DB query, 2026-09-03) → PASS

```
ad9cd4d5… | style      | 844809                          | LONG LINE JACKET WITH WOVEN RUFFLE TRIM
a2dcc8be… | stylecolor | 844809:000004 HOLIDAY CRANBERRY  | LONG LINE JACKET WITH WOVEN RUFFLE TRIM:000004 HOLIDAY CRANBERRY
15a79ff6… | stylecolor | 844809:019930 WHITE/NAVY         | LONG LINE JACKET WITH WOVEN RUFFLE TRIM:019930 WHITE/NAVY
```

Both colours prefixed `844809:` (name) and spec-style description. cart_master empty
(rows consumed). Ticket symptom gone for this scenario.

## Mechanism confirmed (revises earlier analysis)

- Replan payload (17:47:56): `styleType=existing`, `stylecolorType=similar`,
  `styleName=S5_VN_SIM_STY_AF` (stale), `cccolor=000004`, one choice only.
- New colour `a2dcc8be` (fresh uuid, `similar`): named by `add_to_assortment` s5 =
  `style_name || ':' || cccolor`. **Fix 1 `s4_0_3`** realigned `style_name` →
  `ann_d_product.name` = `844809` ⇒ `844809:000004 HOLIDAY CRANBERRY`. ✓ (Fix 1 working.)
- Pre-existing colour `15a79ff6` (`019930 WHITE/NAVY`) was **NOT in this session's
  cart** — `add_to_assortment` never touched it. It is correct (`844809:019930…`)
  because the **QA `update_specstyle_id()` trigger already cascades the rename to
  child stylecolors** at spec-attach time (17:47:42). The repo copy
  (`20260414_SUP_3892…`) does NOT cascade → QA trigger has drifted ahead of git,
  same as `add_to_assortment`.

## ⇒ Fix 2 is NOT needed

QA's `update_specstyle_id()` already handles pre-existing child colours. Only
`add_to_assortment` (colours added *after* attach, composed from the stale cart
`style_name`) was broken — that is Fix 1, and it is verified working here.

Open: (a) get QA `update_specstyle_id()` source to record the cascade (currently
inferred from the `15a79ff6` result, not read); (b) confirm the deployed change is
exactly `s4_0_3` from `20260903_SUP_3879_add_to_assortment.sql`; (c) also drift-
reconcile git — commit the QA `add_to_assortment` + `update_specstyle_id` bodies.

## Still to test before close
- Style that is `type=existing` from the start (real style, not similar-origin) →
  attach spec → add colour, no replan. (Ticket's literal steps.)
- Add-from-Existing-Style + add colour.
- Regression: add-from-similar with NO spec (name stays `<placeholder>:<cccolor>`).

---

# CORRECTION (QA `update_specstyle_id()` received 2026-09-03)

QA `update_specstyle_id()` == repo `2025_12_09_SUP-3543.sql` verbatim. It renames
**only the style row**:
`update ann_d_product set name = NEW.sty_specstyleid, description = <bbr_style_desc>
 where id = NEW.product;`
**No cascade to child stylecolors.** My earlier "the QA trigger cascades" inference
was WRONG.

So in Scenario 3, `15a79ff6` (`019930 WHITE/NAVY`) ending up as `844809:019930…`
is NOT explained by the trigger, and NOT by `add_to_assortment` (QA body has no
`update ann_d_product` for stylecolors, no sibling reprocess) nor
`after_add_to_assortment` (empty). At spec-attach (17:47:43) darwin's
`SyncHandlerImpl` re-syncs `ann_stylecolor_hier_attr` and enqueues `15a79ff6` into
`plan_queue` (priority 10) — a re-plan of the existing colour. Leading theory:
`15a79ff6`'s `ann_d_product` row was (re)created / renamed by that post-attach
processing, OR the first colour's initial planning had not completed before the
spec attach so `15a79ff6` was *born* as `844809:019930…`.

## Decisive query (run on QA)

```sql
select id, levelid, name, created_at, updated_at
from ann_d_product
where id in ('ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c',
             '15a79ff6-7d57-4a03-978a-85563f35e35b',
             'a2dcc8be-6b88-42c2-8dc5-5fa5186d65a1');

-- any stale placeholder-named rows left anywhere?
select id, levelid, name from ann_d_product where name like 'S5_VN_SIM_STY_AF%';
```

- `15a79ff6.created_at` **>** 17:47:42  ⇒ born after attach ⇒ Fix 1 alone is enough
  for this flow; Fix 2 only matters for "colour fully planned BEFORE attach, never
  re-planned after".
- `15a79ff6.updated_at` **>** `created_at` (and created_at < 17:47:42) ⇒ something
  renamed it post-attach — identify it, Fix 1 likely complete.

## Fix 2 (trigger cascade) — DRAFTED, apply only if the query shows a stale gap

Add to `update_specstyle_id()`, inside `if NEW.sty_specstyleid is not null`, capture
old name first then cascade:

```sql
-- (near top of the ELSE branch) capture the style's current display name
v_old_style_name text;
...
select name into v_old_style_name from ann_d_product where id = NEW.product;
...
-- immediately AFTER: update ann_d_product set name = NEW.sty_specstyleid ... where id = NEW.product;
update ann_d_product d
set name        = NEW.sty_specstyleid || ':' || sca.cccolor
   ,description  = coalesce((select target_value from ann_l_dependencylookup
                              where lookup_id='bbr_style_id' and target_id='bbr_style_desc'
                                and lookup_value = NEW.sty_specstyleid), d.description)
                    || ':' || sca.cccolor
from ann_h_prodstd h
    ,ann_ma_stylecolorattributes sca
where h.ancestor0 = NEW.product
  and h.id  = d.id
  and sca.product = d.id
  and d.levelid = 'stylecolor'
  and d.name LIKE v_old_style_name || ':%';   -- only colours currently following the style name
```

Guard `d.name LIKE v_old_style_name || ':%'` = only rename colours whose name is
currently `<placeholder>:<...>` (i.e. never had a real stylecolor number), so
genuine existing-numbered colours are untouched. Also mirror into the
`COALESCE(NEW.sty_specstyleid,'')=''` (spec removed) branch to revert them.

---

# Scenario 4 — existing real style, NO spec style (`existing_style_scenario.txt`) — regression check

Style `592495` (ANN CARDIGAN) — a real style, not similar-origin. **No spec attach
anywhere in this log** (no `property/update/granular`, no `ChangedRow{sty_specstyleid}`).

- 18:15:20 sess `6dbb74ff`: add style `592495` + colour `001987 BLUE HYDRANGEA`
  (`stylecolorType=existing`, id `18f9f1ff-e5f2-408f-8b7c-27f29d41421c`).
- 18:18:42 sess `66ce70b0`: add NEW colour `000004 HOLIDAY CRANBERRY`
  (`stylecolorType=similar`, client id `592495-009192`), `styleName=592495`.

Fix 1 behaviour: `s4_0_3` sets `displayed_style_name = ann_d_product.name('592495')`
= `592495` (no spec, unchanged) ⇒ new colour = `592495:000004 HOLIDAY CRANBERRY`
(`similar` branch, colon). Existing colour `18f9f1ff` untouched (`existing` branch,
keeps real number `592495-001987`, dash). **No behaviour change vs pre-fix ⇒ no
regression.** This log does NOT exercise the fix's spec-attach path — still need an
existing-style + spec-attach run to validate the main path on a real style.

## DB cross-check queries (QA ann)

```sql
-- 1. style + every stylecolor under it
select d.id, d.levelid, d.name, d.description, d.created_at, d.updated_at
from ann_d_product d
where d.id = '592495'
   or d.id in (select id from ann_h_prodstd where ancestor0 = '592495')
order by d.levelid, d.name;

-- 2. the two test colours, resolved by cccolor
select d.id, d.name, d.description, sca.cccolor, sca.cc_stylecolornumber_name,
       sca.cc_specstyle_cccolor, sca.cc_specstylecolorid, d.created_at, d.updated_at
from ann_ma_stylecolorattributes sca
join ann_d_product d on d.id = sca.product
where sca.product in (select id from ann_h_prodstd where ancestor0 = '592495')
  and sca.cccolor in ('001987 BLUE HYDRANGEA','000004 HOLIDAY CRANBERRY');

-- 3. spec-style attribute on the style (expect sty_specstyleid NULL here)
select product, sty_specstyleid, sty_vendor_style_description, style_description
from ann_ma_styleattributes where product = '592495';

-- 4. any stylecolor under 592495 NOT prefixed with the style number (stale check)
select id, levelid, name from ann_d_product
where id in (select id from ann_h_prodstd where ancestor0 = '592495')
  and name not like '592495%';

-- 5. cart_master residue (expect 0 rows post-processing)
select jsessionid, style_type, style_name, stylecolor_type, cccolor, stylecolor_name, isprocessed
from cart_master
where jsessionid in ('6dbb74ff-8275-45bc-97a4-63ab120dd207','66ce70b0-4ef0-40b9-b32e-65f0bcedb741');

-- 6. what the UI grid shows (hier attr)
select product, style_name, stylecolor_name, style_desc, stylecolor_desc
from ann_stylecolor_hier_attr
where product in (select id from ann_h_prodstd where ancestor0 = '592495')
order by stylecolor_name;
```

### Expected
| Row | name | why |
|---|---|---|
| style `592495` | `592495` / `ANN CARDIGAN` | real style, no spec |
| `001987 BLUE HYDRANGEA` | `592495-001987` (dash) | `existing` stylecolor — real number kept |
| `000004 HOLIDAY CRANBERRY` (new) | `592495:000004 HOLIDAY CRANBERRY` (colon) | `similar` — composed `style_name‖':'‖cccolor` |
| query 4 | 0 rows | no stale names |
| query 5 | 0 rows | processed |

## Scenario 4 — RESULT (DB, 2026-09-03) → PASS (no regression)

| check | result |
|---|---|
| new colour `000004 HOLIDAY CRANBERRY` (`a7bb5f4d`, 18:18:42) | name `592495:000004 HOLIDAY CRANBERRY`, desc `ANN CARDIGAN:000004 HOLIDAY CRANBERRY` ✓ |
| existing colour `001987 BLUE HYDRANGEA` (`18f9f1ff`) | name `592495-001987` unchanged (real number, dash) ✓ |
| stale-name rows under 592495 | 0 ✓ |
| cart_master residue | 0 ✓ |
| hier-attr grid | consistent, `style_name=592495` ✓ |

Note: `592495` has `sty_specstyleid = 592495` (self — MISSY style is its own spec
style), so `s4_0_3` DID run: `displayed_style_name = ann_d_product.name('592495') =
'592495'` — same value, correct. Pre-existing March-2026 new colours on this style
already use the colon form (`592495:019847 RICH CLARET` etc.), confirming the
`similar`-stylecolor naming convention.

# STATUS

| Scenario | Fix 1 result | Notes |
|---|---|---|
| S3 add-from-similar + spec + colour | PASS (both colours `844809:`) | how the pre-existing `15a79ff6` got corrected still unexplained — decisive query pending |
| S4 existing real style, no spec, add colour | PASS, no regression | doesn't exercise spec-attach path |

## Remaining before close
1. **Decisive query (S3)** — `select id, name, created_at, updated_at from ann_d_product
   where id in ('ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c',
   '15a79ff6-7d57-4a03-978a-85563f35e35b','a2dcc8be-6b88-42c2-8dc5-5fa5186d65a1');`
   → decides whether Fix 2 (trigger cascade) is needed.
2. **Existing REAL style + attach spec + add colour** (ticket's literal steps) — the
   one path not yet covered by a run. Expect new colour = `<sty_specstyleid>:<cccolor>`
   and (if Fix 2 in) pre-existing planned colours flip too.

---

# Scenario 5 — existing MISSY style `853092` + size concepts, NO spec attach (`after_code_change_existing.txt`)

User "could not add a spec id" → this run has **no spec attach** (no
`ChangedRow{sty_specstyleid}`). Just existing style `853092` (MOCK NECK EXTENDED
SHOULDER SHELL) + 2 new colours (`000012 RED SCARLET` @18:33, `000026 STAR VIOLET`
@18:38). `853092` = MISSY with size-concept siblings PETITE + TALL.

Per-colour result (`000012`):
| level | id | name | verdict |
|---|---|---|---|
| MISSY (master) | `3c259bbc` | `853092:000012 RED SCARLET` | ✓ |
| PETITE | `3c259bbc…PETITE` | `857603:000012 RED SCARLET` | ✓ (real related style 857603) |
| TALL | `3c259bbc…TALL` | `S5-853092_TALL:000012 RED SCARLET` | ✗ `S5-` synthetic prefix |

## NOT caused by Fix 1

`s4_0_3` is gated `sc_type = 'master'` — it only touched the MISSY master row
(`displayed_style_name = ann_d_product.name('853092') = '853092'` ⇒ correct). The
PETITE row is resolved by `s4_0_1` (real related style `857603`). The TALL row is
resolved by `s4_0_1` too, but to a **synthetic sibling style row named
`S5-853092_TALL`** — the colour just inherits it via s5 `style_name‖':'‖cccolor`.

The `853092…TALL` style row is **not in the recently-updated styles list** (top-5 by
updated_at are all 17:4x–17:5x) ⇒ it pre-existed this run. So the bad name is on the
TALL *style* row, created earlier by size-concept expansion when no real related
style exists for that size type. Pre-existing, separate mechanism.

## ⇒ Separate defect, not SUP-3879

SUP-3879 = "colour follows spec style / not stale placeholder". Master + properly-
linked PETITE both correct here ⇒ Fix 1 good. The TALL `S5-<master>_<sctype>` synthetic
style name is a different bug (size-concept sibling with no real related style).
Recommend its own ticket.

## Queries to confirm (QA)

```sql
-- the size-concept sibling styles + how they're linked
select product, name_from_dp.name, sty_specstyleid, sty_missy_related_style,
       sty_size_type, sty_missy_related_style_bbr
from ann_ma_styleattributes sa
left join lateral (select name from ann_d_product where id = sa.product) name_from_dp on true
where product in ('853092','857603')
   or sty_missy_related_style = '853092';

-- every style row that looks synthetic
select id, name, description, created_at from ann_d_product
where levelid='style' and name like 'S5-%' order by created_at desc limit 20;

-- the 3 TALL/PETITE/MISSY style rows behind the new colours
select id, levelid, name, description, created_at, updated_at from ann_d_product
where id in ('3c259bbc-92ac-4b13-b3fd-bf42ddc6e5ea',
             '3c259bbc-92ac-4b13-b3fd-bf42ddc6e5eaPETITE',
             '3c259bbc-92ac-4b13-b3fd-bf42ddc6e5eaTALL')
   or id in (select ancestor0 from ann_h_prodstd where id in
             ('3c259bbc-92ac-4b13-b3fd-bf42ddc6e5eaPETITE','3c259bbc-92ac-4b13-b3fd-bf42ddc6e5eaTALL'));
```

## Spec-attach on existing style — still blocked
User could not attach a spec id to `853092`. Need: what the UI showed, and
`select product, sty_specstyleid, sty_size_type, sty_missy_related_style from
ann_ma_styleattributes where product = '853092';`

## Scenario 5 — RESULT: TALL prefix is pre-existing DATA, out of scope

`ann_ma_styleattributes` for the `853092` size family:
- `857603` (name `857603`) — PETITE sibling, **real style number**
- `b9a49431-…` (name `S5-853092_TALL`) — TALL sibling, **synthetic name**
- `853092` — MISSY master

`ann_d_product` has **hundreds** of `S5-<number>_TALL` / `S5-<n>_PETITE` /
`S5-<n>_CURVY_PETITE` style rows all `created_at` 2025-07-24 20:09:13 and
2025-08-29 20:59:57 — a **batch/cutover job** minted synthetic size-concept sibling
styles for size types with no real related style number. `S5-853092_TALL` is one of
them, from 2025-08-29.

⇒ New colours under `853092` name correctly relative to their parent style:
MISSY→`853092:`, PETITE→`857603:` (real), TALL→`S5-853092_TALL:` (parent's actual
synthetic name). **Not a regression, not SUP-3879, not reachable by `add_to_assortment`
colour naming.** Separate ticket if the business wants those `S5-*_TALL` styles
renamed / given real numbers.

# VALIDATION STATUS (Fix 1 = s4_0_3)

| Scenario | Verdict |
|---|---|
| S3 add-from-similar → spec attach → add colour | PASS — colour = `844809:<cccolor>` |
| S4 existing real style, no spec, add colour | PASS — no regression, colour = `<style#>:<cccolor>` |
| S5 existing MISSY + size concepts, no spec | PASS for master + real PETITE sibling; TALL follows its pre-existing synthetic parent name (out of scope) |

Core fix behaviour verified: new stylecolor names follow the parent style's
**authoritative `ann_d_product.name`** (spec number when a spec style is attached),
not the stale client `cart_master.style_name`.

## Two open items before close

1. **Fix 2 decision** — still need:
   `select id, name, created_at, updated_at from ann_d_product
    where id in ('ad9cd4d5-007f-4ae2-a4d3-7d0ab25f0f7c',
    '15a79ff6-7d57-4a03-978a-85563f35e35b','a2dcc8be-6b88-42c2-8dc5-5fa5186d65a1');`
   If `15a79ff6.created_at` < 17:47:42 (spec attach) AND its name is already
   `844809:019930…` → something DID cascade the pre-existing colour ⇒ Fix 2 not
   needed. If it was born after → the "colour planned before spec attach, never
   re-planned" gap is real ⇒ Fix 2 needed.

2. **Existing real style + successful spec attach** not yet run — `853092` family all
   have `sty_specstyleid` NULL and the UI wouldn't let the user attach one. Need:
   what the UI did (error / greyed / no-op).

---

# RESOLVED — the full mechanism (2026-09-04)

## The missing piece: `trigger_upd_name_description`

```sql
create trigger trigger_upd_name_description
AFTER UPDATE OF name, description ON ann_d_product
FOR EACH ROW WHEN (new.levelid = 'style')
EXECUTE PROCEDURE update_name_description();
```
`update_name_description()` (postgres_ap_ddls.sql:6292): when a **style** row's name
changes it cascades:
1. **child stylecolors** → `name = NEW.name || ':' || cccolor`
2. **size-concept sibling styles** without their own spec →
   `name = NEW.name || '_' || sty_size_type`
No `updated_at = now()` in the cascade → that column stays at the row's original value.

## End-to-end, corrected

Spec attach → `update_specstyle_id` runs `UPDATE ann_d_product SET name='844809'
WHERE id=<style>` → `trigger_upd_name_description` fires →
- every existing child stylecolor renamed to `844809:<cccolor>`  (⇒ `15a79ff6`
  `019930 WHITE/NAVY` created 17:46:29 shows `844809:019930 WHITE/NAVY`,
  `updated_at` still 17:46:29)
- sibling styles `844809_PETITE`, `844809_TALL`

`add_to_assortment` for a colour added **after** the attach builds the name from the
**client cart `style_name`** (stale placeholder) BEFORE any d_product row exists for
that colour — the trigger can't help there. That is the only gap, and **Fix 1
`s4_0_3`** closes it by realigning the cart `style_name` to `ann_d_product.name`.

## Fix 2 — NOT NEEDED (withdrawn)

`trigger_upd_name_description` already cascades a style rename to all child
stylecolors. Pre-existing colours follow the spec automatically. The trigger-cascade
draft in the earlier section is not required — do not implement.

## Q: why does a PETITE stylecolor get `857603:` not `853092:`?

Size concepts (PETITE/TALL/CURVY) are **separate styles**, each with its own style
number. `853092` (MISSY) is linked to real PETITE style `857603`
(`sty_missy_related_style=853092, sty_size_type=PETITE`). `add_to_assortment` s4_0_1
resolves each size-concept row to **its own** related style in `ann_d_product` and
names the colour after that — PETITE → `857603:<cccolor>`. This IS "read d_product
and use the style name"; it just uses the PETITE style's name because the colour
belongs to style `857603`. TALL → `S5-853092_TALL:<cccolor>` — same logic, but TALL's
related style is the synthetic `S5-853092_TALL` (no real number ⇒ separate data issue).
`s4_0_3` governs only the master row (`sc_type='master'` → `853092`); siblings are
`s4_0_1`'s job. Both consult d_product, resolving to different correct styles.

# FINAL VERDICT

**Fix 1 (`s4_0_3` in `add_to_assortment`) is the complete fix.** Validated:
- S3 similar-origin + spec + colour → `844809:` on both new and pre-existing colours ✓
- S4 existing real style, no spec → `<style#>:<cccolor>`, no regression ✓
- S5 existing MISSY + size concepts → master `853092:`, PETITE `857603:` (correct
  per size-concept model); TALL synthetic-name = separate pre-existing data issue ✓
- Pre-existing colours handled by `trigger_upd_name_description`, not our change ✓

Migration: `database_changes/postgres/sql_changes/20260903_SUP_3879_add_to_assortment.sql`
+ `changelog_current.xml` entry. Edit clone: `/Users/vigneshn/Desktop/JIRAs/SUP-3879/etl-ann-batch` (branch SUP-3879).
