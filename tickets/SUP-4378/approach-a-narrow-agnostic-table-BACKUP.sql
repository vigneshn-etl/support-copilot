-- SUP-4378: BACKUP / not-taken approach.
--
-- We evaluated two ways to get price-status-agnostic (tot_) and FP-only (fp_) sums
-- for FP ST% / updated ST% / WOH / FP WOH, on top of belk-configs pivot/include/history_metrics_ty.ftl:
--
--   Approach A (this file): a SEPARATE, narrow, additive Memory table — only the ~6 source
--     columns actually needed (wo_shp_u, omni_shp_u, wo_ret_u, omni_ret_u, eoh_u, eoh_intransit_u),
--     leaving _BASE_SUM_SALES_METRICS_/_BASE_SUM_RCPT_METRICS_/_BASE_SUM_OO_METRICS_ completely
--     untouched. Zero risk to existing metrics/screens; pays the ARRAY JOIN unnest cost twice.
--
--   Approach B (what we actually implemented, in history_metrics_ty.ftl on this branch): single
--     pass — removed `AND prodlife IN (${LEAF_PRODLIFE})` from _BASE_SUM_SALES_METRICS_'s WHERE
--     clause and re-injected it into every existing sumIf/countIf column, adding the new tot_/fp_
--     columns alongside. ~2.6x faster (measured on real BELK QA data, see ticket conversation),
--     but touches ~30 existing columns across a file shared by 10 pivots.
--
-- Empirical A/B test on belk QA (x_product 463198181.668, FY26_W25-W52):
--   Approach A: pass 1 (filtered) 1.483s + pass 2 (agnostic) 2.389s = 3.872s total
--   Approach B: single pass = 1.493s
--
-- Decision: went with Approach B (see history_metrics_ty.ftl on branch SUP-4378), accepting the
-- larger diff surface deliberately, with care taken to re-inject the prodlife condition into every
-- existing column rather than just the ones this ticket needed.
--
-- Keeping Approach A here in case:
--   (a) the single-pass reinjection turns up a regression during validation and we need to fall
--       back to the zero-risk version for a hotfix, or
--   (b) a future pivot that shares history_metrics_ty.ftl turns out to have a subtlety the
--       reinjection didn't account for, and isolating the new metrics into their own table becomes
--       the safer path for that specific pivot.

CREATE TABLE ${TENANT_ID}_BASE_SUM_SALES_METRICS_AGNOSTIC_${SESSION_ID} ENGINE = Memory AS
SELECT
s5flowstatus, ${AGGREGATION_GROUPS_COMMA}

, CAST(sumIf(wo_shp_u, store_flag=1) as Float32) as tot_wo_shp_u_x
, CAST(sumIf(omni_shp_u, store_flag=1) as Float32) as tot_omni_shp_u_x
, CAST(sumIf(wo_ret_u, store_flag=1) as Float32) as tot_wo_ret_u_x
, CAST(sumIf(omni_ret_u, store_flag=1) as Float32) as tot_omni_ret_u_x
, CAST(sumIf(wo_shp_u, store_flag=1 AND prodlife='FP') as Float32) as fp_wo_shp_u_x
, CAST(sumIf(omni_shp_u, store_flag=1 AND prodlife='FP') as Float32) as fp_omni_shp_u_x
, CAST(sumIf(wo_ret_u, store_flag=1 AND prodlife='FP') as Float32) as fp_wo_ret_u_x
, CAST(sumIf(omni_ret_u, store_flag=1 AND prodlife='FP') as Float32) as fp_omni_ret_u_x
, CAST(sumIf(eoh_u, time = (select max(ty_week_id) from ${TENANT_ID}_ty_ly_lly_week_${SESSION_ID})) as Float32) as tot_last_value_eoh_u_x
, CAST(sumIf(eoh_intransit_u, time = (select max(ty_week_id) from ${TENANT_ID}_ty_ly_lly_week_${SESSION_ID})) as Float32) as tot_last_value_eoh_intransit_u_x

FROM
    (
      SELECT *, prodlife as merchcat, cluster as grade from ${TENANT_ID}_p_history_agg_no_dept a
      WHERE
          a.x_product IN (SELECT distinct product FROM ${TENANT_ID}_PRODUCT_${SESSION_ID})
          AND a.month IN (select ty_month_id from ${TENANT_ID}_ty_ly_lly_week_${SESSION_ID})
          AND a.time in (select distinct ty_week_id from ${TENANT_ID}_ty_ly_lly_week_${SESSION_ID})
          -- NOTE: no prodlife filter here at all — this is the agnostic pull
          AND a.location IN (SELECT location FROM ${TENANT_ID}_INV_LOCATION_${SESSION_ID})
          AND cluster IN (${LEAF_CLUSTER})
    ) as a
    ANY LEFT JOIN ${TENANT_ID}_flow_sku_hier_attr_${SESSION_ID} AS b ON a.x_product = b.product
    ANY LEFT JOIN ${TENANT_ID}_INV_LOCATION_${SESSION_ID} AS c ON a.location = c.location
${MAYBE_GROUP_BY}
 s5flowstatus, ${AGGREGATION_GROUPS}
;

-- To wire this in instead of Approach B: JOIN this table into _BASE_ATTR_AGG_FILTER_'s source
-- UNION (alongside _BASE_SUM_SALES_METRICS_/_RCPT_/_OO_) with the new columns zero-filled in the
-- other two, same shape-matching pattern used for every other column today.
