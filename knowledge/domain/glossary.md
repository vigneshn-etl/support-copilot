# Retail / Assortment-Planning Glossary (the FUNCTIONAL half)

The business meaning behind the metrics, screens, and config we debug. Pair
this with the technical layers: when a ticket says "the count is wrong on
Stylecolor Review", the *technical* cause is a pivot/config issue, but the
*functional* question is "what is this count supposed to mean to a planner?"
— that's what this file answers. Source: S5 Products Guide.

**How to use:** grep for the term. Where we know the technical anchor (a
table/pivot/config/screen/ticket), it's tagged **↔ tech:** — that link is what
makes an answer techno-functional. Anchors marked *(grounded)* are confirmed
from prior tickets; others are the likely anchor, confirm via lineage before
relying on them.

---

## Acronym quick-lookup

| Acronym | Means | Note |
|---|---|---|
| TY / LY / LLY | This Year / Last Year / Last-to-Last Year | Core performance comparison. **↔ tech:** `history_product_ty_ly_lly.ftl`, HistoryTYLY pivots, "Top TY vs LY" view *(grounded, SUP-4486)* |
| OP / RP | Original Plan / Revised Plan | MFP: OP = initial target; RP = adjusted for new insight |
| WIP | Work-in-Progress (plan) | The live plan, continuously updated with actuals + forecasts |
| OTB | Open To Buy | MFP inventory budget; an **input into** Assortment Planning — plans should tie to OTB |
| MFP | Merchandise Financial Planning | Pre-season budgeting product. **↔ tech:** `mfp/`, `mfp_td/` configs; `mfpapsync` |
| APS | Average Per store Per week (units) | Sales-velocity measure per store per week. **↔ tech:** APS Adjustment, HistoryFit metrics |
| AUR | Average Unit Retail | Avg selling price; changing it moves the sales/inventory plan |
| CC | Choice Count | # of distinct style-colors to offer. **↔ tech:** CC Count / Stylecolor Review screens *(grounded, SUP-4486/4202)* |
| MSRP | Manufacturer's Suggested Retail Price | "Ticket price" |
| MD | Markdown | Permanent price cut → liquidation mode |
| DC | Distribution Center (warehouse) | Stock sits here before Allocation |
| PO | Purchase Order | What you order from a vendor (≠ receipts, what arrives) |
| SSG | Special Store Groups | A store-grouping construct |
| NRF | National Retail Federation | Owns the standard retail calendar (Feb–Jan, 4-5-4 weeks) |
| PLM | Product Lifecycle Management | Design/line system (Bamboo Rose, Centric); feeds items to S5 |
| ERP | Enterprise Resource Planning | Customer's system of record; source of historical/master data |
| BOPIS | Buy Online, Pick up In Store | An omnichannel pattern |

---

## The products (what S5 sells)

See the companion **assortment-planning-primer.md** for the full product +
process model. One-liners:

- **Hindsighting** — TY-vs-LY review of past sales/inventory/receipts/margin;
  read-only, sets the baseline for future plans. **↔ tech:** History* pivots,
  `hindsighting` config branch *(grounded, AEO)*.
- **MFP (Merchandise Financial Planning)** — pre-season budgets (sales,
  inventory, OTB, margin), top-down + bottom-up, 2–5 yrs history.
- **Store Clustering** — group stores by attributes (region, climate, size,
  channel) to localize plans.
- **Assortment Strategy** — set **choice counts** at a high level before detail.
- **Assortment Planning** — plan units/margin at style-color × store-cluster
  from the choice count; output drives POs.
- **Allocation** — distribute DC stock to stores at **size** level.

---

## Planning concepts

- **Assortment Planning** — choosing the right *mix, depth, and breadth* of
  products per store/channel from demand + customer preference + financial
  goals, to maximize sales and margin. Answers: what to carry, where, when, and
  how much to buy.
- **Pre-Season vs In-Season** — Pre-season = "planning" before goods are
  received (before cartons hit the warehouse). In-season = "reacting"/revising
  after product is selling.
- **Planning vs Forecasting** — Planning (pre-season) uses history at an
  attribute/like-item level + user strategy to shape a *future* plan.
  Forecasting (in-season) uses a product's *own actuals* to revise predictions.
  Rule: don't forecast during planning (no history for a new strategy) and
  don't keep planning once actuals contradict the plan.
- **Top-down / Bottom-up** — top-down plans from high levels (division/dept);
  bottom-up from detail (style/SKU). MFP does both and ties them.
- **Line Plan vs Range Plan** — Line plan = "exactly what are we creating"
  (styles/colors/options, detailed). Range plan = "what should we carry / where"
  (high level, categories + where products are offered). *(The guide states both
  framings — treat Line = detailed creation, Range = coverage/where.)*
- **Three dimensions of planning** — **Product** (category→style), **Location**
  (region→store), **Time** (season→month→week). Right product, right place,
  right time.
- **Hierarchy** — broad→specific levels, e.g. Division → Department → Class →
  Subclass → Style → Color → Size. **↔ tech:** `M_Meta.conf` dimensions/levels;
  pivot `bottomLevels` set the query grain.
- **Newsvendor model** — inventory decision under uncertain demand + limited
  selling window (seasonal/fashion): too few = missed sales, too many = dead
  stock after season.

## Metrics & measures

- **Choice Count (CC)** — # of distinct style-color offerings planned (e.g. 400).
  Set in Assortment Strategy, reconciled against in planning. **↔ tech:**
  Stylecolor Review / CC Count screens; count-grain bugs live here *(grounded,
  SUP-4486 count mismatch, SUP-4202/4210 grain)*.
- **APS** — Average units sold Per store Per week; sales velocity. An **APS
  Adjustment** scales all future planned weeks proportionately.
- **Sell-through** — % of inventory sold (FP sell-through = full-price;
  total sell-through). Higher = better inventory productivity.
- **Margin** — profitability of the sale.
- **AUR** — Average Unit Retail (avg selling price after discounts).
- **Markdown (MD)** — price reduction to clear stock; also a lifecycle
  milestone (markdown week).
- **Pre-Season Sales Rating** — 1–5 qualitative strength rating per item (5 =
  strongest); input to the generated sales/inventory plan.

## Product lifecycle & flow

- **Lifecycle parameters / milestones** (per style-color) — **Initial Receipt**
  (first receipt into DC), **Debut Week** (first sellable week in store),
  **Markdown Week** (enters MD), **Exit Week** (fully out of assortment),
  **Carryover** (funded to continue). **↔ tech:** `*_PRODLIFE_*` temp tables in
  history pivots *(grounded, SUP-4486)*.
- **Flow status** — where a product is in its receipt flow: **New** (first
  receipt arrives), **Carryover** (still receiving, still active),
  **Sell-down / living-on-floor** (no future receipts, selling out). **↔ tech:**
  `FLOW_TABLE_SELECTION_CRITERIA`, `*_STYLECOLOR_FLOW_*` temp tables — the exact
  filter whose commented-out HAVING caused the SUP-4486 over-count *(grounded)*.
- **Receipt interval** — the cyclic interval at which receipt generation runs.
- **Receipts vs POs** — receipts = what actually arrives into stock; POs = what
  you order. Not interchangeable.
- **Floorset** — the merchandising set/period products are planned into;
  receipts and choice counts are reconciled *by floorset*.

## Location & clustering

- **Store Clustering** — grouping stores by shared attributes. **Volume-based**
  (by sales volume tier) or **mix-based**; **Affinity clusters** use product
  attributes + customer preference. Seasonality & price elasticity help find
  similar demand patterns. **↔ tech:** location clusters, `SSG`.
- **Ranging (Localize)** — deciding *where* (which locations/regions) each
  selected product is carried, over time.

## Pricing & promotions

- **Ticket Price** — MSRP / list price.
- **Discount Rate** — a general always-on average % off (e.g. employee discount).
- **Percentage-off Promotion** — item at X% off for a specific week.
- **Price-point Promotion** — item at a fixed price for a specific week.
- **Price Bands** — quality/price tiers: **Good / Better / Best**.
- **Halo effect (Haloification)** — promoting one product lifts sales of related
  products (flagship sneaker promo → also sells socks/shoe-care).
- **Cannibalization** — a new product pulls sales *away* from an existing one of
  the same brand (new shampoo variant eats the old one's demand).
- **Price elasticity** — demand's sensitivity to price; used with seasonality
  for clustering + localized pricing.

## Allocation

- **Allocation** — final step: distribute DC stock to stores at **size** level
  per the Assortment Plan.
- **Greedy Allocation** — always satisfy the highest-priority demand first,
  ignoring future impact.
- **MAP (Multi Advertise Priority)** — priority framework when multiple
  products are promoted at once: who gets visibility, more inventory, better
  placement.
- **Omnichannel vs Multichannel** — Omni = all channels fully integrated as one
  system (e.g. BOPIS). Multi = several channels operating *independently*.

## Reconciliation & approval (process terms)

- **Reconciliation** — align the assortment roll-up with **Choice Count Plans**,
  **MFP** (category × week × channel), and **Location Plans**; compare to LY/LLY.
  Usually a *soft* reconciliation, not hard.
- **Final Buy / Investment Review Meeting** — leadership milestone to approve the
  assortment before execution.
- **Publish (buy quantities)** — after approval, publishing pushes Merchant Buy
  Quantities to the partner PO-management system to create POs.
- **Design-to-adopt ratio** — Design presents more options than the choice count
  asks for; merchants adopt a subset (Line Adopt).
- **Placeholder → Real** — a planned slot ("placeholder") is replaced by a real
  Design/Vendor option (Design/Vendor Replace), copying attributes + image and
  flipping status to "real".

## Algorithms & data

- **K-means** — clustering: *K* = number of groups, *means* = each group's
  center; used for store clustering.
- **Historical data** — past sales/inventory/receipts/margin from the customer's
  ERP; the basis for hindsighting, MFP, and like-item planning.
- **NRF retail calendar** — Feb→Jan standard calendar so weeks/holidays/seasons
  align year-over-year for valid TY/LY comparison.

---

## S5 positioning (pillars)

Simple UI · outperforms manual calculation · performance · business narrative.
