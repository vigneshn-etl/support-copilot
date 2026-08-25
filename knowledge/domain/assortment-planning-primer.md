# Assortment-Planning Primer — the functional mental model

What the S5 products do and how a retailer actually plans an assortment. This
is the "so what does this mean to a planner?" context behind every screen and
metric we support. Read this once; grep `glossary.md` for individual terms.
Source: S5 Products Guide.

## Why this exists (the retail problem)

Retail = selling products at a profit. The better a retailer predicts what
customers will buy, the more profitable it is. Five success factors:
**customer insight** (pick what they'll want), **buying acumen** (how much, what
sizes), **profitability** (right cost in, right price out), **marketing
effectiveness** (draw customers, consistent brand, promos that don't erode
margin), **customer experience** (the right product mix in-store/online).

Assortment Planning is the process that acts on all five: *what to carry, where
and when, and how much to buy* — coordinated across product, marketing,
profitability, and channel mix.

## The product suite (and how the outputs chain)

The products form a pipeline; each feeds the next:

1. **Hindsighting** — reviews historical performance (sales, inventory,
   receipts, margin) TY vs LY across product/location/time. *Read-only* — no
   editable output. Establishes the baseline. **In our system:** the History*
   pivots and the `hindsighting` config branch.
2. **MFP (Merchandise Financial Planning)** — pre-season budgeting: set demand,
   margin targets, and inventory budgets (**OTB**), then manage them with
   in-season re-forecasting. Top-down (division/dept) + bottom-up (style/SKU),
   on 2–5 years of history. **OTB is an input into Assortment Planning** — plans
   should tie to OTB. Concepts: Original Plan → Revised Plan → WIP.
3. **Store Clustering** — groups stores by attributes (region, climate, size,
   channel; volume/mix/affinity). Output localizes planning + allocation.
4. **Assortment Strategy** — sets **choice counts** (e.g. 400 style-colors) at a
   high level, from historical performance + market goals, before detail.
5. **Assortment Planning** — takes the choice count + clusters and plans units,
   margin, and metrics at **style-color × store-cluster**. Output drives POs.
6. **Allocation** — final step: distributes DC (warehouse) stock to stores at
   the **size** level per the plan, across physical + online channels.

Pipeline in one line: **Hindsight → MFP (OTB) → Clusters → Choice Counts →
Assortment Plan (units) → POs → Allocation → (in-season) Revision.**

## Two distinctions that govern everything

- **Pre-season vs In-season.** Pre-season = *planning* before cartons arrive
  (strategy, targets, future vision). In-season = *reacting*/revising once
  product is received and selling. Assortment Planning covers both.
- **Planning vs Forecasting.** Planning (pre-season) leverages history at an
  attribute/like-item level plus user strategy to build a forward plan.
  Forecasting (in-season) leverages a product's *own actual* sales to revise.
  Don't forecast a brand-new strategy (no history exists); don't keep planning
  once actuals contradict the plan.

## The L3 process (how a season is planned, step by step)

Planners move through these phases. Tickets almost always map to one of them —
knowing the phase tells you what the user was trying to do.

**1. Foundations** — 1.1 Hindsighting · 1.2 Financial Plans (MFP) · 1.3 Location
Clusters · 1.4 Assortment Targets (choice counts).

**2. Product Development** — 2.1 design/vendor create the line's options.

**3. Product Selection & Ranging**
- **3.1 Product Selection (Line Adopt).** Design (or vendor) presents the line
  — usually more options than the choice count (design-to-adopt ratio). A PLM
  "publish" event can trigger candidates into S5. Merchants **adopt** items to
  fill the choice count, either via **Design/Vendor Replace** onto existing
  *placeholders* (placeholder → "real", copying attributes + image) or a simpler
  select-and-plan flow. Outcome: the Build module holds all the "real" options.
- **3.2 Ranging (Localize).** Decide *where* each selected product is carried and
  when it phases in/out, for new and carryover products.

**4. Buy (Quantification → Reconciliation → Approve)**
- **4.1 Quantification** — generate the sales & receipt plan, then refine:
  4.1.1 Pre-Season Sales Rating (1–5) · 4.1.2 Lifecycle params (Initial Receipt,
  Debut, Markdown, Exit weeks) · 4.1.3 Price & promotions (ticket price, discount
  rate, %-off, price-point; AUR drives the plan) · 4.1.4 Order/presentation mins ·
  4.1.5 Valid sizes · 4.1.6 Generate plan by **StyleColorSize × week × location**
  · 4.1.7 Validate/adjust sales plan & APS (adjust parameters *[preferred]*, or
  override weekly, or enter an APS Adjustment to scale all weeks) · 4.1.8 Validate
  receipt timing/frequency (edit totals or by size; lock weeks; set valid receipt
  weeks).
- **4.2 Reconciliation** — align the roll-up with **Choice Count Plans** (by
  floorset, new vs carryover, volume tier, APS targets), **MFP** (category ×
  week × channel), and **Location Plans**; compare to **LY/LLY**. Generally
  *soft*, not hard, reconciliation. **In our system:** the CC-count / Stylecolor
  Review comparison screens — where count-grain bugs surface (SUP-4486, 4202).
- **4.3 Approve & Publish** — leadership milestone (Final Buy / Investment Review
  Meeting), often iterative; on approval, **publish** buy quantities, which flow
  to the partner PO-management system → **POs issued** to vendors.

**5. Revision (in-season)**
- **5.1 Post-Publish Revisions** — the plan and published buy quantities get
  revised for: promo changes, current trends, production shortages, fast-track
  new products, or MFP/Location-plan changes (e.g. new stores). Same item-editing
  flows as the buy/reconciliation phases.

## How to use this when triaging

When a ticket lands, place it on this map:
- *Which product* (Hindsight/MFP/Clustering/Strategy/Planning/Allocation)?
- *Which phase* (selection, ranging, quantification, reconciliation, approve,
  revision)?
- *What did the planner expect* the metric/screen to mean (glossary term)?

That functional framing is half of every good root cause — the technical layers
(lineage, config, ETL, DB) give the mechanism; this gives the meaning. Both
halves are mandatory in `knowledge_gained` (see the triage engine).
