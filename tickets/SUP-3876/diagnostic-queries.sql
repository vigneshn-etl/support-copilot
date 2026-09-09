-- SUP-3876 [KWG] MD AUR Calc incorrect — root-cause confirmation queries
-- Target: LOFT QA / staging ClickHouse (tenant = loft)
--
-- Hypothesis to confirm: the Flow Sheet plan-engine eff_aur / eff_aur_ecom is
-- computed off the FP (pre-MD) ticket for weeks where the corp markdown calendar
-- (loft_l_corpdisc_tbl, which the Pricing view uses) already has an MD ticket in
-- effect and there is no planner channel override. Formula lives in
-- loft-configs/pivot/include/p1_08_price_cost_computation.ftl:273-282 (adjust_for_md).
--
-- REPLACE {SC}   = failing style-color id from the ticket screenshots (e.g. '764147-001264')
--         {DEPT} = its department id (Q0 returns it)
--
-- If you only have the style number:
--   SELECT DISTINCT product, style, department, class, subclass
--   FROM loft_stylecolor_hier_attr WHERE style = '{STYLE}';
--
-- Column discovery if any SELECT below errors on a name:
--   SELECT name, type FROM system.columns WHERE table = 'loft_p_flowsheet';
--   (repeat for loft_l_corpdisc_tbl, loft_l_mdstrategy_tbl, loft_d_time,
--    loft_p_itemprice, loft_p_channeloverride, loft_stylecolorchannelattributes)


-- Q0. Markdown drivers the plan engine reads for this style-color -------------
SELECT *
FROM loft_stylecolorchannelattributes
WHERE product = '{SC}'
ORDER BY updated_at DESC
LIMIT 3;
-- note: department, ccticketpricechannel (FP ticket), ccticketpricechannel_override,
--       cc_discount_pct / cc_discount_pct_ecom, ccmdstrategy, erlstmkdnwk, dbt_wk, exitdate


-- Q1. Flow Sheet plan output (exactly what the grid renders) ------------------
--     latest plan version only; prodlife = engine FP/MD tag;
--     ccticketpricechannel = engine "current" ticket (should be the MD ticket in MD weeks);
--     a_dmd_r_fp / a_dmd_u  ~= the FP ticket the engine actually used;
--     eff_aur / eff_aur_ecom = the disputed metric.
SELECT f.time,
       d.indx                                   AS week_indx,
       f.channel,
       f.prodlife,
       round(f.ccticketpricechannel, 2)         AS cur_ticket_stores,
       round(f.ccticketpricechannel_ecom, 2)    AS cur_ticket_ecom,
       round(f.a_dmd_r_fp     / nullIf(f.a_dmd_u, 0), 2)      AS fp_ticket_used_stores,
       round(f.a_dmd_r_fp_ecom/ nullIf(f.a_dmd_u_ecom, 0), 2) AS fp_ticket_used_ecom,
       round(f.eff_aur, 2)                       AS eff_aur_stores,
       round(f.eff_aur_ecom, 2)                  AS eff_aur_ecom,
       f.updated_at
FROM loft_p_flowsheet f
INNER JOIN loft_d_time d ON d.id = f.time
WHERE f.product = '{SC}'
  AND (f.product, f.channel, f.updated_at) IN (
        SELECT product, channel, max(updated_at)
        FROM loft_p_flowsheet WHERE product = '{SC}' GROUP BY product, channel)
ORDER BY d.indx, f.channel;


-- Q2. Corp markdown calendar for the department — what the Pricing view uses --
--     A week with an 'MD' prodlife row here, but prodlife='FP' / FP-ticket eff_aur
--     in Q1, is the bug.
SELECT c.*, d.indx AS week_indx
FROM loft_l_corpdisc_tbl c
INNER JOIN loft_d_time d ON d.id = c.time
WHERE c.department = '{DEPT}'
  AND (c.corpaddoff > 0 OR c.corpexcl > 0)
ORDER BY d.indx, c.prodlife;


-- Q3. MD-strategy discount curve for the department — the engine's md_disc -----
--     If ccmdstrategy (from Q0) has no matching rows here, or md_disc = 0, the
--     engine applies ZERO markdown in MD weeks -> eff_aur stays on the FP ticket.
SELECT * FROM loft_l_mdstrategy_tbl
WHERE department = '{DEPT}'
ORDER BY 1, 2;


-- Q4. Planner overrides for this style-color — these MASK the bug per channel/week
--     (feed expressed_aur / addoff in the engine). Weeks with NO row here are the
--     weeks the reporter sees as wrong.
SELECT i.*, d.indx AS week_indx
FROM loft_p_itemprice i
INNER JOIN loft_d_time d ON d.id = i.time
WHERE i.product = '{SC}'
ORDER BY d.indx;

SELECT o.*, d.indx AS week_indx
FROM loft_p_channeloverride o
INNER JOIN loft_d_time d ON d.id = o.time
WHERE o.product = '{SC}'
ORDER BY d.indx;
