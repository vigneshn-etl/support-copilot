#!/usr/bin/env python3
"""
QA config -> Metrics Catalog import (core.qa_import).

  1 units      every pattern the translator knows: read filters, aggregates, ratios, periods
  2 fixture    a small pivot with TY + LY reads, a variance, a broken read and a plan read;
               imported into an empty-ish catalog, applied, then re-imported (must be a no-op)
  3 qa         the real TRD QA config (skipped when not pulled): facts checked by hand on
               2026-11-03 against HistoryFit / HistoryFitTYLYTranspose
"""
import csv, os, sys, tempfile
from pathlib import Path

os.environ["DVS_STORE"] = "csv"
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from core import qa_import as QI, spec as SP, spec_store  # noqa: E402

FAILS = []


def check(name, got, want):
    ok = got == want
    print(("PASS " if ok else "FAIL ") + name)
    if not ok:
        print(f"      got  {got!r}\n      want {want!r}")
        FAILS.append(name)


# ---------------------------------------------------------------- 1 units
SRC = {"history": {"source_id": "history", "table": "zz_p_history_agg", "item_key": "product",
                   "location_key": "location", "time_key": "time", "level_filters": "prodlife,cluster",
                   "_cols": {"product", "location", "time", "shp_u", "ret_u", "shp_r", "ret_r", "eoh_u",
                             "strcntwk", "strcntwk_funded", "prodlife", "cluster", "rec_u"}}}
TY_READ = ("zz_p_history_agg a ANY LEFT JOIN zz_INV_LOCATION_SESSION AS c ON a.location = c.location "
           "WHERE a.product IN (SELECT distinct product FROM zz_TY_PRODUCT_SESSION) AND time IN (select "
           "ty_week_id from zz_ty_ly_lly_week_SESSION) AND prodlife IN (__LEAF_PRODLIFE__) AND a.location "
           "IN (SELECT location FROM zz_LOCATION_SESSION) AND cluster IN (__LEAF_CLUSTER__)")
LY_RCPT = ("( select * FROM zz_p_history_agg CROSS JOIN zz_FILTERED_RCPT_START_END_SESSION WHERE product IN "
           "(SELECT distinct product FROM zz_LY_PRODUCT_SESSION) AND time >= ly_final_rcpt_start AND time <= "
           "ly_final_rcpt_end AND prodlife IN (__LEAF_PRODLIFE__) AND location IN (SELECT location FROM "
           "zz_INV_LOCATION_SESSION) AND cluster IN (__LEAF_CLUSTER__) AND strcntwk > 0 AND if(rcpt_filter_enabled"
           " = 1, rec_u > 0, rec_u >= 0) ) a ANY LEFT JOIN zz_flow_sku_hier_attr_SESSION AS b ON a.product = b.product")


def units():
    check("criteria param -> rule condition (outer parens off)", QI._cond("(sum(a) > 1 or\n sum(b) > 2)"),
          "sum(a) > 1 or sum(b) > 2")
    check("population variant id from thresholds", (QI._pop_slug(["avg(x) > -10 or avg(y) > -10"]),
                                                    QI._pop_slug(["sum(x) > 0"])), ("GTM10", "GT0"))
    rr = "if(if(b > 0, round(a / b, 4), 0) > 0, round((c - if(b > 0, round(a / b, 4), 0)) / if(b > 0, round(a / b, 4), 0), 4), 0)"
    check("ratio of ratios equals itself (0 / 0 is nan, not an error)", QI.equivalent(rr, rr), True)
    check("share of total: total(x) is its own atom", (QI.equivalent("a / total(a)", "a / total( a )"),
                                                       QI.equivalent("total(a)", "a")), (True, False))
    check("split_and keeps parens and quotes", QI.split_and("(a = 1) AND (b IN ('x and y')) and c > 0"),
          ["a = 1", "b IN ('x and y')", "c > 0"])
    check("from_parts opens a select * wrapper", QI.from_parts(LY_RCPT)[0], "zz_p_history_agg")
    r = QI.Read("r", "zz_p_history_agg", TY_READ, "zz", SRC, False)
    check("TY read", (r.source_id, r.period, r.window, r.location_set, r.blocked, r.levels),
          ("history", "ty", "selected", "scope", [], {"prodlife", "cluster"}))
    r = QI.Read("r", "zz_p_history_agg", LY_RCPT, "zz", SRC, False)
    check("LY receipt read: period from the product set and ly_final_rcpt_*",
          (r.period, r.window, r.row_filters, r.blocked), ("ly", "receipt", ["strcntwk > 0"], []))
    r = QI.Read("r", "zz_p_history_agg", LY_RCPT, "zz", SRC, True)
    check("INV_LOCATION with a live DC union blocks", any("DCs" in b for b in r.blocked), True)
    r = QI.Read("r", "zz_p_history_agg", TY_READ, "zz", SRC, True)
    check("store_flag=1 is not dropped when DCs are in INV_LOCATION",
          "DCs" in QI.parse_measure("countIf(distinct a.location, store_flag=1)", r, "zz", SRC["history"]["_cols"])
          .get("blocked", ""), True)
    r = QI.Read("r", "zz_p_history_agg", TY_READ.replace("AND cluster", "AND mystery = 1 AND cluster"), "zz", SRC, False)
    check("unknown read filter blocks (never guessed)", r.blocked, ["read r: no rule for 'mystery = 1'"])
    r = QI.Read("r", "zz_p_history_agg", TY_READ.replace("AND cluster", "AND strcntwk_funded > 0.000001 AND cluster"),
                "zz", SRC, False)
    check("read filter on source columns -> row filter", (r.row_filters, r.blocked),
          (["strcntwk_funded > 0.000001"], []))
    r = QI.Read("r", "zz_p_assort", "zz_p_assort a WHERE (a.product, a.updated_at) IN (SELECT product, "
                "max_updated_at FROM zz_ASST_PRODUCT_MAX_SESSION)", "zz", SRC, False)
    check("assortment latest-version read -> needs engine",
          any("latest updated_at" in b for b in r.blocked), True)
    PS = ("zz_s_assort a WHERE a.x_product IN (SELECT distinct product FROM zz_TY_PRODUCT_SESSION) AND "
          "(a.x_product, snapshot_version, a.updated_at) IN (SELECT product, snapshot_version, max_updated_at "
          "FROM zz_PS_ASST_PRODUCT_MAX_SESSION) AND a.time IN (select ty_week_id from zz_ty_ly_lly_week_SESSION)")
    vsrc = {k: {"source_id": k, "table": "zz_s_assort", "item_key": "x_product", "location_key": "location",
                "time_key": "time", "level_filters": "", "row_filter": f"snapshot_version = '{v}'",
                "latest_by": "updated_at", "_cols": {"x_product", "time", "location", "shp_r"}}
            for k, v in (("plan_rp", "RP"), ("plan_op", "OP"))}
    r = QI.Read("r", "zz_s_assort", PS, "zz", vsrc, False, None,
                {"zz_PS_ASST_PRODUCT_MAX_SESSION": "snapshot_version = 'OP'"})
    check("plan snapshot read -> the versioned source of its snapshot", (r.source_id, r.blocked), ("plan_op", []))
    r = QI.Read("r", "zz_s_assort", PS, "zz", vsrc, False, None, {})
    check("plan read without a known snapshot table blocks", any("latest updated_at" in b for b in r.blocked), True)
    r = QI.Read("r", "zz_p_history_agg", TY_READ.replace("ty_week_id", "ly_week_id"), "zz", SRC, False)
    check("TY products with LY weeks -> mixed periods block", any("mixed periods" in b for b in r.blocked), True)

    ty = QI.Read("r", "zz_p_history_agg", TY_READ, "zz", SRC, False)
    cols = SRC["history"]["_cols"]
    def pm(e, rd=ty):
        x = QI.parse_measure(e, rd, "zz", cols)
        return x.get("blocked") or (x["agg"], x["expr"], x["conds"])
    check("sum", pm("sum(a.shp_u)"), ("sum", "shp_u", []))
    check("sumIf -> sum + filter", pm("sumIf(a.shp_u, a.prodlife = 'FP')"), ("sum", "shp_u", ["prodlife = 'FP'"]))
    check("CAST + countIf distinct, store_flag dropped",
          pm("CAST(countIf(distinct a.location, strcntwk > 0.000001 and store_flag=1) as Float32)"),
          ("count_distinct", "location", ["strcntwk > 0.000001"]))
    check("last week snapshot", pm("sumIf(eoh_u, time = (select max(ty_week_id) from zz_ty_ly_lly_week_SESSION))"),
          ("last_at_max_week", "eoh_u", []))
    check("first week snapshot", pm("sumIf(eoh_u, time = (select min(ty_week_id) from zz_ty_ly_lly_week_SESSION))"),
          ("first_at_min_week", "eoh_u", []))
    check("count at last week -> count_lastval",
          pm("countIf(distinct a.location, store_flag=1 and time = (select max(ty_week_id) from zz_ty_ly_lly_week_SESSION))"),
          ("count_lastval", "location", []))
    check("LY snapshot inside a TY read blocks",
          "snapshot week of ly" in pm("sumIf(eoh_u, time = (select max(ly_week_id) from zz_ty_ly_lly_week_SESSION))"), True)
    check("store attribute subquery -> loc.<attr>",
          pm("sumIf(a.shp_u - a.ret_u, a.location IN (SELECT location FROM zz_store_hier_attr WHERE selling_channel = 'CD-1'))"),
          ("sum", "shp_u - ret_u", ["loc.selling_channel = 'CD-1'"]))
    check("column not on the table blocks", "not columns of" in pm("sum(cc_unit_retail)"), True)
    check("unknown aggregate blocks", "not recognised" in pm("anyLast(shp_u)"), True)
    rc = QI.Read("r", "zz_p_history_agg", LY_RCPT, "zz", SRC, False)
    check("read row filters join the measure filter", pm("CAST(sum(rec_u) as Float32)", rc),
          ("sum", "rec_u", ["strcntwk > 0"]))

    check("distinct stores via multiIf(store_flag=1, …)",
          pm("CAST(countIf(distinct multiIf(store_flag=1, location, null), strcntwk > 0.000001) as Float32)"),
          ("count_distinct", "location", ["strcntwk > 0.000001"]))
    x = QI.parse_measure("countIf(distinct b.stylecolor, strcntwk > 0.000001)", ty, "zz", cols, {"stylecolor": "product"})
    check("joined stylecolor = the item key at stylecolor grain", (x["expr"], x["conds"]),
          ("product", ["strcntwk > 0.000001"]))
    flag = ("zz_p_history_agg ANY LEFT JOIN (SELECT location, max(selling_channel = 'CD-1') AS is_store_channel "
            "FROM zz_store_hier_attr GROUP BY location) USING (location) WHERE product IN (SELECT distinct product "
            "FROM zz_LY_PRODUCT_SESSION) AND time IN (select ly_week_id from zz_ty_ly_lly_week_SESSION)")
    rf = QI.Read("r", "zz_store_hier_attr", flag, "zz", SRC, False)
    check("read table is the FROM table, not a joined subquery's", (rf.table, rf.source_id, rf.period),
          ("zz_p_history_agg", "history", "ly"))
    check("joined channel flag -> loc.<attr>", QI.parse_measure("sumIf(strcntwk, is_store_channel = 1)", rf, "zz", cols)["conds"],
          ["loc.selling_channel = 'CD-1'"])
    pre = ("( SELECT s5flowstatus, style, sum(shp_u) as shp_u_x, 0 as rec_u_x, "
           "CAST(countIf(distinct product, strcntwk > 0.000001) as Float32) as cc_x, "
           "CAST(countIf(distinct location, strcntwk > 0.000001) as Float32) as st_x FROM zz_p_history_agg "
           "WHERE product IN (SELECT distinct product FROM zz_PRODUCT_SESSION) AND time IN (select ty_week_id from "
           "zz_ty_ly_lly_week_SESSION) GROUP BY s5flowstatus, style, product ) a")
    rp = QI.Read("r", "zz_p_history_agg", pre, "zz", SRC, False)
    rp.outer_group = {"s5flowstatus", "style"}
    def pp(e):
        x = QI.parse_measure(e, rp, "zz", cols)
        return x.get("blocked") or ("const" if x.get("const") else (x["agg"], x["expr"], x["conds"]))
    check("pre-aggregate: sum of per-product sums = sum", pp("sum(shp_u_x)"), ("sum", "shp_u", []))
    check("pre-aggregate: a constant 0 column", pp("sum(rec_u_x)"), "const")
    check("pre-aggregate: sum of per-product distinct products = distinct products", pp("sum(cc_x)"),
          ("count_distinct", "product", ["strcntwk > 0.000001"]))
    check("pre-aggregate: per-product distinct stores, summed -> needs a base grain",
          "measure base grain" in pp("sum(st_x)"), True)
    check("pre-aggregate: max of per-product distinct stores -> needs a base grain",
          "measure base grain" in pp("max(st_x)"), True)
    rp.outer_group = {"s5flowstatus", "style", "product"}
    check("pre-aggregate at the output grain: outer agg is identity", pp("max(st_x)"),
          ("count_distinct", "location", ["strcntwk > 0.000001"]))
    check("type names are not columns", QI.cols_in("CAST(shp_u AS Float32) + toFloat64(ret_u)"), ["shp_u", "ret_u"])

    sig = QI.measure_sig
    check("sum_funded == sum + funded filter",
          sig({"source_id": "h", "expr": "shp_u", "agg": "sum_funded", "filter": ""}) ==
          sig({"source_id": "h", "expr": "a.shp_u", "agg": "sum", "filter": "strcntwk_funded > 1e-06"}), True)
    check("legacy snapshot_last == last_at_max_week",
          sig({"source_id": "h", "expr": "eoh_u", "agg": "snapshot_last", "filter": ""}) ==
          sig({"source_id": "h", "expr": "eoh_u", "agg": "last_at_max_week", "filter": ""}), True)
    check("filter conjunct order does not matter",
          sig({"source_id": "h", "expr": "x", "agg": "sum", "filter": "a > 0 AND b = 'Q'"}) ==
          sig({"source_id": "h", "expr": "x", "agg": "sum", "filter": "b = 'Q' and a > 0"}), True)
    check("different filter value differs",
          sig({"source_id": "h", "expr": "x", "agg": "sum", "filter": "b = 'Q'"}) ==
          sig({"source_id": "h", "expr": "x", "agg": "sum", "filter": "b = 'q'"}), False)

    check("ratio split", QI.split_ratio("CASE WHEN s > 0 THEN round((a - b) / s,4) ELSE 0 end"),
          ("s", "a - b", "s", "4"))
    check("ratio round(x) = 0 digits", QI.split_ratio("CASE WHEN s > 0 THEN round(a / s) ELSE 0 END"),
          ("s", "a", "s", "0"))
    check("two divisions is not a plain ratio", QI.split_ratio("CASE WHEN s > 0 THEN round(a / s / c) ELSE 0 END"), None)
    check("equivalent: algebra", QI.equivalent("(a - b) - (c - d)", "a - b - c + d"), True)
    check("equivalent: guard differs", QI.equivalent("if((a + b) > 0, a / (a + b), 0)",
                                                      "if((a + b - c) > 0, a / (a + b), 0)"), False)
    check("equivalent: CASE == if", QI.equivalent("CASE WHEN s > 0 THEN round(a / s, 4) ELSE 0 END",
                                                  "if(s > 0, round(a / s, 4), 0)"), True)
    check("equivalent: rounding digits matter", QI.equivalent("round(a / s, 4)", "round(a / s, 2)"), False)
    check("metric id drops the period tag", [QI.metric_id_for(c, p) for c, p in
          (("ly_net_sls_u", "ly"), ("net_sls_u_ly", "ly"), ("ty_aps_u", "ty"), ("ly_x", "ty"), ("a__b12", "ty"))],
          ["net_sls_u", "net_sls_u", "aps_u", "ly_x", "a"])
    check("rollup ternary == if", QI._rollup_equiv("(sum(a) - sum(b)) > 0 ? sum(c) / (sum(a) - sum(b)) : 0",
                                                   "if((sum(a) - sum(b)) > 0, sum(c) / (sum(a) - sum(b)), 0)"), True)
    check("rollup guard vs none differs", QI._rollup_equiv("(sum(a) - sum(b)) > 0 ? sum(c) / (sum(a) - sum(b)) : 0",
                                                           "sum(c) / (sum(a) - sum(b))"), False)


# ---------------------------------------------------------------- 2 fixture
BASE = """CREATE TABLE IF NOT EXISTS ${{TENANT_ID}}_{P}BASE_${{SESSION_ID}} ENGINE = Memory AS
SELECT b.s5flowstatus as s5flowstatus
{cols}
FROM ${{TENANT_ID}}_p_history_agg a
ANY LEFT JOIN ${{TENANT_ID}}_flow_sku_hier_attr_${{SESSION_ID}} AS b ON a.product = b.product
ANY LEFT JOIN ${{TENANT_ID}}_INV_LOCATION_${{SESSION_ID}} AS c ON a.location = c.location
WHERE a.product IN (SELECT distinct product FROM ${{TENANT_ID}}_{PP}PRODUCT_${{SESSION_ID}})
AND time IN (select {p}_week_id from ${{TENANT_ID}}_ty_ly_lly_week_${{SESSION_ID}})
AND prodlife IN (${{LEAF_PRODLIFE}})
AND a.location IN (SELECT location FROM ${{TENANT_ID}}_LOCATION_${{SESSION_ID}})
AND cluster IN (${{LEAF_CLUSTER}}){extra}
GROUP BY s5flowstatus
"""
TY_COLS = """, sum(shp_r) as shp_r_x
, sum(ret_r) as ret_r_x
, sum(shp_u) as shp_u_x
, sum(ret_u) as ret_u_x
, sum(strcntwk) as strcntwk_x
, sumIf(a.shp_u, a.prodlife = 'FP') as fp_shp_u_x
, sumIf(eoh_u, time = (select max(ty_week_id) from ${TENANT_ID}_ty_ly_lly_week_${SESSION_ID})) as last_value_eoh_u_x
, CAST(countIf(distinct a.location, strcntwk > 0.000001 and store_flag=1) as Float32) as ttl_storecount_x
, sumIf(a.shp_r - a.ret_r, a.location IN (SELECT location FROM ${TENANT_ID}_store_hier_attr WHERE selling_channel = 'CD-1')) as wo_sls_r_x"""
LY_COLS = """, sum(shp_r) as ly_shp_r_x
, sum(ret_r) as ly_ret_r_x"""
PIVOT = '''params.unused = """x"""
prologueSQLs = [
"""{ty}""",
"""{ly}""",
"""{odd}""",
"""CREATE TABLE IF NOT EXISTS ${{TENANT_ID}}_PLAN_${{SESSION_ID}} ENGINE = Memory AS
SELECT s5flowstatus, sum(plan_u) as plan_u_x FROM ${{TENANT_ID}}_p_assort a
WHERE (a.product, a.updated_at) IN (SELECT product, max_updated_at FROM ${{TENANT_ID}}_ASST_PRODUCT_MAX_${{SESSION_ID}})
GROUP BY s5flowstatus
"""
]
reverseAggSQLs = [
"""
SELECT t.s5flowstatus as s5flowstatus
, sum(shp_r_x) as ty_shp_r
, sum(ret_r_x) as ty_ret_r
, ty_shp_r - ty_ret_r as ty_net_sls_r
, sum(shp_u_x) as ty_shp_u
, sum(ret_u_x) as ty_ret_u
, sum(strcntwk_x) as ty_strcntwk
, CASE WHEN ty_strcntwk > 0 THEN round((ty_shp_u - ty_ret_u) / ty_strcntwk, 4) ELSE 0 end as ty_aps_u
, CASE WHEN ty_shp_u > 0 THEN round((ty_shp_u - ty_ret_u) / ty_strcntwk, 4) ELSE 0 end as ty_odd_aps_u
, sum(fp_shp_u_x) as ty_fp_shp_u
, sum(last_value_eoh_u_x) as ty_last_value_eoh_u
, MAX(ttl_storecount_x) as ty_ttl_storecount
, sum(wo_sls_r_x) as ty_wo_sls_r
, sum(ly_shp_r_x) as ly_shp_r
, sum(ly_ret_r_x) as ly_ret_r
, ly_shp_r - ly_ret_r as ly_net_sls_r
, ty_net_sls_r - ly_net_sls_r as net_sls_r_var
, sum(odd_u_x) as odd_u
, sum(plan_u_x) as plan_u
, COALESCE(CAST(ty_ttl_storecount AS Float32), 0) as ty_store_cnt
FROM ${{TENANT_ID}}_TY_BASE_${{SESSION_ID}} t
ANY LEFT JOIN ${{TENANT_ID}}_LY_BASE_${{SESSION_ID}} l USING s5flowstatus
ANY LEFT JOIN ${{TENANT_ID}}_ODD_BASE_${{SESSION_ID}} o USING s5flowstatus
ANY LEFT JOIN ${{TENANT_ID}}_PLAN_${{SESSION_ID}} p USING s5flowstatus
GROUP BY s5flowstatus
"""
]
'''
SCHEMA = {"zz_p_history_agg": ["product", "location", "time", "shp_r", "ret_r", "shp_u", "ret_u", "strcntwk",
                               "eoh_u", "prodlife", "cluster", "strcntwk_funded", "rec_u"],
          "zz_p_assort": ["product", "updated_at", "plan_u"]}
CAT = {
    "sources": [{"source_id": "history", "table": "zz_p_history_agg", "item_key": "product",
                 "location_key": "location", "time_key": "time", "level_filters": "prodlife,cluster",
                 "description": ""}],
    "measures": [{"measure_id": m, "label": m, "source_id": "history", "expr": e, "agg": a, "filter": "",
                  "time_window": "selected", "location_set": "scope", "rollup": "sum"}
                 for m, e, a in (("shp_r", "shp_r", "sum"), ("ret_r", "ret_r", "sum"), ("shp_u", "shp_u", "sum"),
                                 ("ret_u", "ret_u", "sum"), ("strcntwk", "strcntwk", "sum"),
                                 ("eoh_u_last", "eoh_u", "snapshot_last"))],
    "metrics": [{"metric_id": "net_sls_r", "label": "Net sales $", "type": "derived", "expr": "shp_r - ret_r",
                 "denominator": "", "round": "", "requirement": ""}],
    "populations": [{"population_id": "P1", "step": "1", "rule_id": "all", "kind": "combine", "source_id": "",
                     "time_window": "", "condition": "x", "row_filter": "", "applies_when": ""}],
    "screens": [{"pivot": "FIX", "population_id": "P1", "time_mode": "history", "split_by_class": "yes"}],
    "bindings": [{"pivot": "FIX", "viewdefn": "V", "data_index": "ty_net_sls_r", "label": "TY Sales",
                  "metric_id": "net_sls_r", "period": "ty", "rollup_formula": "sum(net_sls_r)"}],
}
VIEW = [("ty_net_sls_r", "sum(ty_net_sls_r)"), ("ly_net_sls_r", "sum(ly_net_sls_r)"),
        ("ty_aps_u", "(sum(ty_shp_u) - sum(ty_ret_u)) / sum(ty_strcntwk)"), ("ty_odd_aps_u", ""),
        ("ty_fp_shp_u", "sum(ty_fp_shp_u)"), ("ty_last_value_eoh_u", "sum(ty_last_value_eoh_u)"),
        ("ty_ttl_storecount", "max(ty_ttl_storecount)"), ("ty_wo_sls_r", "sum(ty_wo_sls_r)"),
        ("net_sls_r_var", "sum(ty_net_sls_r) - sum(ly_net_sls_r)"), ("odd_u", ""), ("plan_u", ""),
        ("ty_store_cnt", "max(ty_store_cnt)"), ("name", "")]


def fixture():
    with tempfile.TemporaryDirectory() as d:
        root = Path(d)
        cfg = root / "cfg"
        (cfg / "pivot" / "include").mkdir(parents=True)
        (cfg / "pivot" / "FIX.pivotdefn").write_text(PIVOT.format(
            ty=BASE.format(P="TY_", PP="TY_", p="ty", cols=TY_COLS, extra=""),
            ly=BASE.format(P="LY_", PP="LY_", p="ly", cols=LY_COLS, extra=""),
            odd=BASE.format(P="ODD_", PP="TY_", p="ty", cols=", sum(shp_u) as odd_u_x", extra="\nAND mystery_flag = 1")))
        sd = root / "spec"
        sd.mkdir()
        for f, rows in CAT.items():
            cols = list(rows[0]) + ["status", "version", "approved_by", "approved_at", "notes"]
            with open(sd / f"{f}.csv", "w", newline="") as fh:
                w = csv.DictWriter(fh, fieldnames=cols)
                w.writeheader()
                for r in rows:
                    w.writerow({**r, "status": "draft", "version": "1"})
        rows = [{"pivot": "FIX", "viewdefn": "V", "data_index": di, "view_formula": vf, "display_name": di,
                 "screen_view": "Grid", "status": "unresolved" if di == "name" else "resolved"} for di, vf in VIEW]
        inputs = (cfg, rows, SCHEMA)
        rep = QI.translate("ZZ", ["FIX"], SP.load(sd), inputs=inputs)
        B = {b["data_index"]: b for b in rep["bindings"]}
        K = {m["id"]: m for m in rep["measures"]}
        M = {m["id"]: m for m in rep["metrics"]}
        def bind(di):
            b = B[di]
            return (b["status"], b.get("metric_id"), b.get("period"), b.get("rollup_formula"))
        check("fixture: catalog binding unchanged -> same", bind("ty_net_sls_r"), ("same", "net_sls_r", "ty", "sum(net_sls_r)"))
        check("fixture: LY column -> same metric, period ly", bind("ly_net_sls_r"), ("new", "net_sls_r", "ly", "sum(net_sls_r)"))
        check("fixture: LY measures matched to catalog shp_r/ret_r", sorted(k for k in K if K[k]["status"] == "same"),
              ["eoh_u_last", "ret_r", "ret_u", "shp_r", "shp_u", "strcntwk"])
        check("fixture: ratio (guard = denominator)", (M["aps_u"]["type"], M["aps_u"]["expr"], M["aps_u"]["denominator"],
                                                      M["aps_u"]["round"]), ("ratio", "shp_u - ret_u", "strcntwk", "4"))
        check("fixture: guard != denominator -> derived + note",
              (M["odd_aps_u"]["type"], any("guards on" in n for n in M["odd_aps_u"]["notes"])), ("derived", True))
        check("fixture: variance across years", (M["net_sls_r_var"]["expr"], bind("net_sls_r_var")),
              ("net_sls_r - net_sls_r@ly", ("new", "net_sls_r_var", "ty", "sum(net_sls_r) - sum(net_sls_r@ly)")))
        check("fixture: FP measure", (K["fp_shp_u"]["agg"], K["fp_shp_u"]["filter"]), ("sum", "prodlife = 'FP'"))
        check("fixture: last-week EOH reuses catalog eoh_u_last", M["last_value_eoh_u"]["expr"], "eoh_u_last")
        check("fixture: store count = distinct locations, max rollup",
              (K["ttl_storecount"]["agg"], K["ttl_storecount"]["filter"], K["ttl_storecount"]["rollup"]),
              ("count_distinct", "strcntwk > 0.000001", "max"))
        check("fixture: walkout -> loc.selling_channel", K["wo_sls_r"]["filter"], "loc.selling_channel = 'CD-1'")
        check("fixture: unknown read filter blocks its column",
              (B["odd_u"]["status"], "mystery_flag = 1" in B["odd_u"]["why"]), ("blocked", True))
        check("fixture: plan read blocks with the engine reason",
              (B["plan_u"]["status"], "latest updated_at" in B["plan_u"]["why"]), ("blocked", True))
        check("fixture: attribute column", B["name"]["status"], "attribute")
        check("fixture: COALESCE / CAST wrappers fall away", (B["ty_store_cnt"]["metric_id"],
              B["ty_store_cnt"]["rollup_formula"]), ("ttl_storecount", "max(ttl_storecount)"))
        check("fixture: nothing blocked on the good reads",
              sorted(b["data_index"] for b in rep["bindings"] if b["status"] == "blocked"), ["odd_u", "plan_u"])

        # apply, reload, import again: nothing left to add
        store = spec_store.SpecStore(sd)
        added = QI.apply(store, rep, "test")
        check("fixture: apply adds the new bindings", len(added["bindings"]),
              sum(1 for b in rep["bindings"] if b["status"] == "new"))
        issues = [i for i in SP.lint(SP.load(sd), {t: set(c) for t, c in SCHEMA.items()}) if i["level"] == "error"]
        check("fixture: applied catalog lints clean", issues, [])
        rep2 = QI.translate("ZZ", ["FIX"], SP.load(sd), inputs=inputs)
        check("fixture: second import adds nothing",
              (rep2["counts"]["measures"].get("new", 0), rep2["counts"]["metrics"].get("new", 0),
               rep2["counts"]["bindings"].get("new", 0)), (0, 0, 0))
        check("fixture: second import sees them as same",
              sorted(b["data_index"] for b in rep2["bindings"] if b["status"] == "same"),
              sorted(b["data_index"] for b in rep["bindings"] if b["status"] in ("same", "new")))
        # QA later changes a metric the catalog now has: propose QA's own, never bind to the catalog one
        pv = cfg / "pivot" / "FIX.pivotdefn"
        old = "ty_strcntwk > 0 THEN round((ty_shp_u - ty_ret_u) / ty_strcntwk, 4) ELSE 0 end as ty_aps_u"
        pv.write_text(pv.read_text().replace(old, old.replace("/ ty_strcntwk, 4)", "/ ty_strcntwk, 0)")))
        rep3 = QI.translate("ZZ", ["FIX"], SP.load(sd), inputs=inputs)
        b3 = next(b for b in rep3["bindings"] if b["data_index"] == "ty_aps_u")
        m3 = {m["id"]: m for m in rep3["metrics"]}
        check("fixture: QA formula differs from catalog metric -> <id>_qa, binding changed",
              (b3["status"], b3["metric_id"], m3.get("aps_u_qa", {}).get("status")), ("changed", "aps_u_qa", "new"))
        origin = {r["measure_id"]: r.get("origin") for r in csv.DictReader(open(sd / "measures.csv"))}
        check("fixture: imported rows carry origin qa_import", origin.get("wo_sls_r"), "qa_import")


# ---------------------------------------------------------------- 3 real QA config
def qa():
    import config_sync as CS
    cfg = CS.effective_dir("TRD", "qa")
    if not (cfg / "pivot" / "HistoryFit.pivotdefn").exists():
        print("SKIP qa: TRD QA config not pulled")
        return
    spec = SP.load(QI.HUB / "customers" / "TRD" / "spec")
    rep = QI.translate("TRD", ["HistoryFit", "HistoryFitTYLYTranspose"], spec)
    B = {(b["pivot"], b["viewdefn"], b["data_index"]): b for b in rep["bindings"]}
    K = {m["id"]: m for m in rep["measures"]}
    M = {m["id"]: m for m in rep["metrics"]}
    hf = [b for b in rep["bindings"] if b["pivot"] == "HistoryFit"]
    check("qa: HistoryFit catalog measures all match QA (no _qa ids)",
          [k for k in K if k.endswith("_qa") and any(f.startswith("HistoryFit:") for f in K[k]["from"])], [])
    check("qa: only the known stk_sls_u rollup guard differs on HistoryFit",
          sorted(f"{b['viewdefn']}.{b['data_index']}" for b in hf if b["status"] == "changed"),
          ["HistoryRollUp.stk_sls_u"])
    g = B[("HistoryFit", "HistoryStyleColorGridViewGrid", "gmroi")]
    check("qa: GMROI grid rollup names a column the pivot lacks -> bound, QA rollup not copied",
          (g["metric_id"], g["rollup_formula"], any("net_margin_r" in n for n in g["notes"])), ("gmroi", "", True))
    check("qa: walkout measure", (K["wo_sls_u"]["expr"], K["wo_sls_u"]["filter"]),
          ("shp_u - ret_u - sfs_u - bopis_u", "loc.selling_channel = 'CD-1'"))
    check("qa: FP sell-thru is the catalog metric", M["fp_sell_thru_pct"]["status"], "same")
    check("qa: avail_inv_aut guard quirk flagged",
          any("guards on" in n for n in M["avail_inv_aut"]["notes"]), True)
    ly = B[("HistoryFitTYLYTranspose", "HistoryStyleColorTYLYGrid", "ly_net_sls_u")]
    check("qa: LY transpose column -> net_sls_u @ly", (ly["metric_id"], ly["period"]), ("net_sls_u", "ly"))
    lye = B[("HistoryFitTYLYTranspose", "HistoryStyleColorTYLYGrid", "ly_eoh_u_per_cc_per_store")]
    check("qa: LY EOP per store differs from TY in the pivot (kept apart)", lye["metric_id"].endswith("_qa"), True)
    sp2 = dict(spec, metrics={**spec["metrics"], "gmroi": next(iter(spec["metrics"].values()))})  # csv seed lacks gmroi
    st = QI.translate("TRD", ["HistoryFitStyleTYLY"], sp2)["bindings"]
    sg = next(b for b in st if b["data_index"] == "gmroi")
    check("qa: per-colour weekcount summed (QA bug) -> catalog gmroi with a note",
          (sg["metric_id"], any("not copied" in n for n in sg["notes"])), ("gmroi", True))
    check("qa: TY/LY screen needs its own population",
          next(s["status"] for s in rep["screens"] if s["pivot"] == "HistoryFitTYLYTranspose"), "blocked")


if __name__ == "__main__":
    units()
    fixture()
    qa()
    print(f"\n{'FAILED ' + str(len(FAILS)) if FAILS else 'ALL PASS'}")
    sys.exit(1 if FAILS else 0)
