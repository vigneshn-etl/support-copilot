-- family: history_ty
-- Qualification CTEs for pivots that include history_product_ty.ftl (+ history_metrics_ty.ftl):
-- HistoryFit and siblings. Each `-- @cte <name>` block stands in for one darwin session
-- temp table (name = the pivot's table name with ${SESSION_ID} -> SESSION), so the
-- pivot's own read clauses run unchanged against these CTEs.
-- Params (${...}) are filled by tooling/validation/core: scope/filters per dimensions.json,
-- *_CRITERIA read live from the pivotdefn. Source FTLs: filtered_members_create_sclr.ftl,
-- history_base_tables.ftl, filtered_time_period.ftl, history_product_ty.ftl.
-- @detect history_product_ty.ftl
-- @time history

-- @cte SCOPE_PRODUCTS
SELECT product FROM trd_stylecolor_hier_attr
WHERE (product, updated_at) IN (SELECT product, max(updated_at) FROM trd_stylecolor_hier_attr
                                WHERE ${SCOPED_PRODUCT_LEVEL} = ${SCOPED_PRODUCT} GROUP BY product)
  ${PRODUCT_FILTER_AND}
ORDER BY updated_at DESC LIMIT 1 BY product

-- @cte SCOPE_LOCATIONS
SELECT location FROM trd_store_hier_attr
WHERE ${SCOPED_LOCATION_LEVEL} = ${SCOPED_LOCATION}
  ${LOCATION_FILTER_AND}
ORDER BY updated_at DESC LIMIT 1 BY location

-- @cte trd_LOCATION_SESSION
SELECT DISTINCT location FROM trd_store_hier_attr WHERE location IN (SELECT location FROM SCOPE_LOCATIONS)

-- @cte trd_INV_LOCATION_SESSION
SELECT x.location AS location, 1 AS store_flag, 0 AS dc_flag, ${LOCATION_LEVEL_COLS_Y}
FROM trd_LOCATION_SESSION x
ANY LEFT JOIN (SELECT * FROM trd_store_hier_attr ORDER BY updated_at DESC LIMIT 1 BY location) y ON x.location = y.location

-- @cte trd_sku_hier_attr_SESSION
SELECT ${PRODUCT_LEVEL_COLS} product, stylecolor, style, cccolor FROM trd_stylecolor_hier_attr
WHERE (product, updated_at) IN (SELECT product, max(updated_at) FROM trd_stylecolor_hier_attr
                                WHERE ${SCOPED_PRODUCT_LEVEL} = ${SCOPED_PRODUCT} GROUP BY product)

-- @cte trd_ty_ly_lly_week_SESSION
SELECT a.cctytime AS ty_week_id, a.week AS ly_week_id, b.week AS lly_week_id
FROM trd_time_attributes a
ANY LEFT JOIN trd_time_attributes b ON b.cctytime = a.week
WHERE a.cctytime IN (${LEAF_TIME})

-- @cte trd_FILTERED_RCPT_START_END_SESSION
SELECT if(${RCPT_START} = '', (SELECT min(week) FROM trd_time_attributes WHERE week IN (${LEAF_TIME})), ${RCPT_START}) AS final_rcpt_start,
       if(${RCPT_END} = '',   (SELECT max(week) FROM trd_time_attributes WHERE week IN (${LEAF_TIME})), ${RCPT_END})   AS final_rcpt_end,
       if(${RCPT_START} != '' OR ${RCPT_END} != '', 1, 0) AS rcpt_filter_enabled

-- @cte trd_STYLECOLOR_FLOW_SESSION
SELECT stylecolor FROM trd_sku_temp_flow_flag CROSS JOIN trd_FILTERED_RCPT_START_END_SESSION
WHERE stylecolor IN (SELECT product FROM SCOPE_PRODUCTS)
  AND time >= final_rcpt_start AND time <= final_rcpt_end
GROUP BY stylecolor
HAVING ${FLOW_TABLE_SELECTION_CRITERIA}

-- @cte trd_STYLECOLOR_PRODLIFE_X_SESSION
SELECT DISTINCT stylecolor FROM (
  SELECT product AS stylecolor FROM trd_p_history_agg
  WHERE product IN (SELECT product FROM SCOPE_PRODUCTS)
    AND time IN (SELECT ty_week_id FROM trd_ty_ly_lly_week_SESSION)
    AND prodlife IN (${LEAF_PRODLIFE})
  GROUP BY product
  HAVING ${HIST_TABLE_SELECTION_CRITERIA}
  ${ONORDER_UNION}
)

-- @cte trd_PRODUCT_SESSION
SELECT m.*, n.style AS style FROM (
  SELECT stylecolor AS product, avg(dmd_u) AS avg_wkly_slsu, sum(shp_u) AS ttl_shp_u,
         CASE WHEN max(flow_flag) > 1000000 THEN cast(0 AS Float32)
              WHEN max(flow_flag) > 0 THEN cast(1 AS Float32) ELSE cast(2 AS Float32) END AS s5flowstatus
  FROM trd_sku_temp_flow_flag CROSS JOIN trd_FILTERED_RCPT_START_END_SESSION
  WHERE stylecolor IN (SELECT stylecolor FROM trd_STYLECOLOR_FLOW_SESSION)
    AND stylecolor IN (SELECT stylecolor FROM trd_STYLECOLOR_PRODLIFE_X_SESSION)
    AND time >= final_rcpt_start AND time <= final_rcpt_end
    AND if(rcpt_filter_enabled = 1, rec_u > 0, rec_u >= 0)
  GROUP BY stylecolor
) m
ANY LEFT JOIN (SELECT DISTINCT style, stylecolor, product FROM trd_sku_hier_attr_SESSION) n USING (product)
WHERE s5flowstatus IN (${LEAF_FLOW_STATUS})

-- @cte trd_flow_sku_hier_attr_SESSION
SELECT a.*, b.s5flowstatus AS s5flowstatus FROM trd_sku_hier_attr_SESSION AS a
JOIN trd_PRODUCT_SESSION AS b USING (product)
