#!/usr/bin/env python3
"""
Golden fixtures for the spec compiler: tiny hand-made tables (inlined as literals, so they
run on the read-only DB), a tiny spec, and answers worked out by hand. If the compiler
mis-places a rule (window, location set, price filter, snapshot, population), a case fails.

    python3 tests/golden/test_spec_golden.py           exit 1 on any failure
"""
import json, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent))
from core import spec as SP, run as R


def table(cols, rows):
    """(cols as 'name Type', rows) -> a subquery usable wherever a table name goes."""
    names = [c.split()[0] for c in cols]
    types = [c.split(None, 1)[1] for c in cols]
    body = ",".join("(" + ",".join(SP.q(v) if isinstance(v, str) else ("NULL" if v is None else repr(v))
                                   for v in r) + ")" for r in rows)
    sel = ", ".join(f"tupleElement(_t, {i + 1}) AS {n}" for i, n in enumerate(names))
    return f"(SELECT {sel} FROM (SELECT arrayJoin(CAST([{body}] AS Array(Tuple({', '.join(types)})))) AS _t))"


# ---------------------------------------------------------------- fixtures
# products: p1 (latest version moved INTO D1), p2, p3 in D1; p9 in D2 (out of scope)
HIER = table(["product String", "updated_at DateTime", "department String", "class String",
              "style String", "stylecolor String", "subclass String", "group_id String",
              "division String", "total_brand String"],
             [["p1", "2025-01-01 00:00:00", "D0", "cOld", "s1", "p1", "x", "g", "v", "b"],   # old version
              ["p1", "2025-06-01 00:00:00", "D1", "cA", "s1", "p1", "x", "g", "v", "b"],
              ["p2", "2025-06-01 00:00:00", "D1", "cA", "s2", "p2", "x", "g", "v", "b"],
              ["p3", "2025-06-01 00:00:00", "D1", "cB", "s3", "p3", "x", "g", "v", "b"],
              ["p9", "2025-06-01 00:00:00", "D2", "cZ", "s9", "p9", "x", "g", "v", "b"]])
STORES = table(["location String", "updated_at DateTime", "channel String", "selling_channel String",
                "area String", "region String", "district String"],
               [["s1", "2025-01-01 00:00:00", "C1", "x", "x", "x", "x"],
                ["s2", "2025-01-01 00:00:00", "C1", "CD-1", "x", "x", "x"],     # walkout channel
                ["s3", "2025-01-01 00:00:00", "C2", "x", "x", "x", "x"]])        # other channel
# history: product, location, time, prodlife, cluster, shp_r, shp_u, ret_r, ret_u, eoh_u, strcntwk
H = [
    # p1: in scope everywhere -> counted
    ["p1", "s1", "W1", "FP", "A", 100.0, 10.0, 10.0, 1.0, 50.0, 1.0],
    ["p1", "s1", "W2", "FP", "A", 200.0, 20.0, 0.0, 0.0, 40.0, 1.0],
    ["p1", "s2", "W2", "MD", "A", 50.0, 5.0, 0.0, 0.0, 30.0, 1.0],
    ["p1", "s3", "W2", "FP", "A", 999.0, 99.0, 0.0, 0.0, 999.0, 1.0],   # s3 not in channel C1
    ["p1", "s1", "W3", "FP", "A", 999.0, 99.0, 0.0, 0.0, 999.0, 1.0],   # W3 outside the window
    ["p1", "s1", "W2", "OOL", "A", 999.0, 99.0, 0.0, 0.0, 999.0, 1.0],  # OOL not selected
    # p2: in scope, sells little -> fails the population threshold sum(shp_u) > 3
    ["p2", "s1", "W1", "FP", "A", 10.0, 1.0, 0.0, 0.0, 0.0, 1.0],
    # p3: no shipments, but stock -> passes via eoh, snapshot = last week only
    ["p3", "s1", "W1", "FP", "A", 0.0, 0.0, 0.0, 0.0, 7.0, 0.0],
    ["p3", "s2", "W2", "FP", "A", 0.0, 0.0, 0.0, 0.0, 9.0, 0.0],
    # p9: other department
    ["p9", "s1", "W1", "FP", "A", 999.0, 99.0, 0.0, 0.0, 999.0, 1.0],
    # LY (L1, L2 map to W1, W2): p1 sells 100; p2 sells 80 (in LY's population, not TY's)
    ["p1", "s1", "L1", "FP", "A", 60.0, 6.0, 0.0, 0.0, 10.0, 1.0],
    ["p1", "s1", "L2", "FP", "A", 40.0, 4.0, 0.0, 0.0, 20.0, 1.0],
    ["p2", "s1", "L1", "FP", "A", 80.0, 8.0, 0.0, 0.0, 0.0, 1.0],
    # LLY (LL2 maps to L2): p1 sells 50
    ["p1", "s1", "LL2", "FP", "A", 50.0, 5.0, 0.0, 0.0, 0.0, 1.0],
]
# strcntwk_funded per row (same order): p1 s1 W2 is an unfunded store-week
FUNDED_COL = [1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
H = [r + [f] for r, f in zip(H, FUNDED_COL)]
HIST = table(["product String", "location String", "time String", "prodlife String", "cluster String",
              "shp_r Float64", "shp_u Float64", "ret_r Float64", "ret_u Float64", "eoh_u Float64",
              "strcntwk Float64", "strcntwk_funded Float64"], H)
FLOW = table(["stylecolor String", "time String", "flow_flag Float64", "rec_u Float64"],
             [["p1", "W1", 5.0, 0.0], ["p2", "W1", 2000000.0, 0.0], ["p3", "W2", 0.0, 0.0],
              ["p1", "L1", 5.0, 0.0], ["p1", "L2", 5.0, 0.0], ["p2", "L1", 5.0, 0.0], ["p1", "LL2", 5.0, 0.0]])
# calendar: week -> the next year's week it compares to (never itself)
CAL = table(["week String", "cctytime String"],
            [["W1", "N1"], ["W2", "N2"], ["L1", "W1"], ["L2", "W2"], ["LL1", "L1"], ["LL2", "L2"]])

DIMS = {"tenant": "fx",
        "product": {"hier_table": HIER, "key": "product", "levels": {
            "department": {"id": "department", "name": "department"},
            "class": {"id": "class", "name": "class"},
            "stylecolor": {"id": "stylecolor", "name": "stylecolor"}}},
        "location": {"hier_table": STORES, "key": "location", "levels": {
            "channel": {"id": "channel", "name": "channel"}, "store": {"id": "location", "name": "location"}}},
        "filters": {"merchcat": {"kind": "leaf", "all": ["FP", "MD", "OOL"]},
                    "grade": {"kind": "leaf", "all": ["A"]}, "location_attributes": []},
        "flow_status": {"default": [0, 1, 2]},
        "time": {"table": CAL, "week": "week", "ty_week": "cctytime"}}


def M(mid, expr, agg="sum", flt="", win="selected", rollup="sum"):
    return mid, {"measure_id": mid, "source_id": "h", "expr": expr, "agg": agg, "filter": flt,
                 "time_window": win, "location_set": "scope", "rollup": rollup, "version": "1", "status": "approved"}


def MT(mid, typ, expr, den=""):
    return mid, {"metric_id": mid, "type": typ, "expr": expr, "denominator": den, "round": "4",
                 "version": "1", "status": "approved"}


SPEC = {
    "sources": {"h": {"source_id": "h", "table": HIST, "item_key": "product", "location_key": "location",
                      "time_key": "time", "level_filters": "prodlife,cluster"},
                "f": {"source_id": "f", "table": FLOW, "item_key": "stylecolor", "location_key": "",
                      "time_key": "time", "level_filters": ""}},
    "measures": dict([M("shp_r", "shp_r"), M("shp_u", "shp_u"), M("ret_r", "ret_r"), M("ret_u", "ret_u"),
                      M("eoh_last", "eoh_u", "snapshot_last"), M("eoh_sum", "eoh_u"),
                      M("cc", "product", "count_distinct", "strcntwk > 0"),
                      M("wk", "time", "count_distinct", "strcntwk > 0", rollup="max"),
                      M("fnd_shp_u", "shp_u", "sum_funded"),
                      M("str_last", "location", "count_lastval", "strcntwk > 0", rollup="max"),
                      M("wo_shp_u", "shp_u", flt="loc.selling_channel = 'CD-1'")]),
    "metrics": dict([MT("net_sls_r", "derived", "shp_r - ret_r"), MT("net_sls_u", "derived", "shp_u - ret_u"),
                     MT("aur", "ratio", "net_sls_r", "net_sls_u"), MT("eop", "simple", "eoh_last"),
                     MT("cccount", "simple", "cc"),
                     MT("net_sls_var", "derived", "net_sls_r - net_sls_r@ly"),
                     MT("fnd_u", "simple", "fnd_shp_u"), MT("strcnt_last", "simple", "str_last"),
                     MT("wo_u", "simple", "wo_shp_u")]),
    "populations": [
        {"population_id": "P", "step": "1", "rule_id": "hist", "kind": "having", "source_id": "h",
         "time_window": "selected", "condition": "sum(shp_u) > 3 OR sum(eoh_u) > 5", "row_filter": "",
         "applies_when": "", "version": "1", "status": "approved", "notes": ""},
        {"population_id": "P", "step": "2", "rule_id": "fs", "kind": "classify", "source_id": "f",
         "time_window": "selected", "condition": "multiIf(max(flow_flag) > 1000000, 0, max(flow_flag) > 0, 1, 2)",
         "row_filter": "", "applies_when": "", "version": "1", "status": "approved", "notes": ""},
        {"population_id": "P", "step": "3", "rule_id": "all", "kind": "combine", "source_id": "",
         "time_window": "", "condition": "hist", "row_filter": "", "applies_when": "", "version": "1",
         "status": "approved", "notes": ""}],
    "screens": {"FX": {"pivot": "FX", "population_id": "P", "time_mode": "history", "split_by_class": "no"}},
    "bindings": [],
}
WEEKS = {"selected": ["W1", "W2"], "receipt": ["W1", "W2"]}


def req(metrics, agg="level:stylecolor", price=("FP", "MD"), fs=None):
    """metrics: (data_index, rollup formula) or (data_index, rollup formula, period)."""
    return {"pivot": "FX", "aggBy": agg, "flowStatus": fs,
            "scope": {"productLevel": "department", "productMember": "D1",
                      "locationLevel": "channel", "locationMember": "C1"},
            "filters": {"merchcat": list(price)}, "general": {},
            "metrics": [{"label": m[0] + (f"@{m[2]}" if len(m) > 2 else ""), "data_index": m[0],
                         "view_formula": m[1], "viewdefn": "", **({"period": m[2]} if len(m) > 2 else {})}
                        for m in metrics]}


# ---------------------------------------------------------------- cases (hand-computed)
# p1 in scope (C1 stores, W1..W2, FP+MD): shp_r 100+200+50=350, ret_r 10, shp_u 35, ret_u 1
#   eoh at last week W2 = s1 40 + s2 30 = 70 (W1's 50 must NOT be added); eoh_sum = 120
#   net_sls_r 340, net_sls_u 34, aur = round(340/34,4) = 10.0
# p2: shp_u 1, eoh 0 -> fails "sum(shp_u) > 3 OR sum(eoh_u) > 5" -> excluded
# p3: shp_u 0, eoh 7+9=16 -> passes; eop = W2 only = 9; cc = 0 (strcntwk 0)
CASES = [
    ("rows at stylecolor: scope, window, price filter, snapshot, population",
     req([("net_sls_r", ""), ("net_sls_u", ""), ("aur", ""), ("eop", ""), ("cccount", "")]),
     {"rows": {"p1": {"net_sls_r": 340, "net_sls_u": 34, "aur": 10.0, "eop": 70, "cccount": 1},
               "p3": {"net_sls_r": 0, "net_sls_u": 0, "aur": 0, "eop": 9, "cccount": 0}}}),
    ("rollup: ratio of sums, count rows, snapshot summed across items",
     req([("net_sls_r", "sum(net_sls_r)"), ("aur", "sum(net_sls_r) / sum(net_sls_u)"),
          ("eop", "sum(eop)"), ("cccount", "sum(1)")]),
     {"totals": {"net_sls_r": 340, "aur": 10.0, "eop": 79, "cccount": 2}}),
    ("OOL selected: the OOL row joins in (+999 $, +99 u, eoh +999 at W2)",
     req([("net_sls_r", "sum(net_sls_r)"), ("eop", "sum(eop)")], price=("FP", "MD", "OOL")),
     {"totals": {"net_sls_r": 1339, "eop": 1078}}),
    ("grain = class (p1, p3 in different classes; latest version decides p1's class)",
     req([("net_sls_r", "")], agg="level:class"),
     {"rows": {"cA": {"net_sls_r": 340}, "cB": {"net_sls_r": 0}}}),
    # LY: weeks via the calendar (L1, L2), population re-run on LY weeks (p2 in, p3 out),
    # snapshot at LY's last week, a TY - LY variance, and x_ly inferred from the column name
    ("LY: calendar weeks, own population, LY snapshot, TY-LY variance",
     req([("net_sls_r", ""), ("net_sls_r_ly", ""), ("eop", "", "ly"), ("net_sls_var", "")]),
     {"rows": {"p1": {"net_sls_r": 340, "net_sls_r__ly": 100, "eop__ly": 20, "net_sls_var": 240},
               "p2": {"net_sls_r": 0, "net_sls_r__ly": 80, "eop__ly": 0, "net_sls_var": -80},
               "p3": {"net_sls_r": 0, "net_sls_r__ly": 0, "eop__ly": 0, "net_sls_var": 0}}}),
    ("LLY via LY's weeks; a TY rollup naming LY (sum(x) - sum(x@ly))",
     req([("net_sls_r", "sum(net_sls_r)", "lly"), ("net_sls_var", "sum(net_sls_r) - sum(net_sls_r@ly)")]),
     {"totals": {"net_sls_r@lly": 50, "net_sls_var": 160}}),
    ("funded sum skips unfunded store-weeks; count at the last week only",
     req([("fnd_u", ""), ("strcnt_last", "")]),
     {"rows": {"p1": {"fnd_u": 15, "strcnt_last": 2}, "p3": {"fnd_u": 0, "strcnt_last": 0}}}),
    # loc.<attr>: only s2 is in selling channel CD-1 (p1 ships 5 there in W2)
    ("measure filter on a store attribute (loc.selling_channel)",
     req([("wo_u", "sum(wo_u)")]),
     {"totals": {"wo_u": 5}}),
]
# explicit LY weeks from the screen override the calendar (L2 only: p1 40, p2 drops out)
CASES_WEEKS = [
    ("LY weeks given on screen override the calendar",
     req([("net_sls_r", "sum(net_sls_r)", "ly")]),
     {"totals": {"net_sls_r@ly": 40}}, {**WEEKS, "selected@ly": ["L2"]}),
]

# receipt filter (QA: if(rcpt_filter_enabled = 1, rec_u > 0, rec_u >= 0)): on only when receipt weeks
# are picked. Stand-in row filter on strcntwk: p3 has strcntwk 0, so it drops out when on.
SPEC_RCPT = {**SPEC, "populations": [dict(r, row_filter="if(rcpt_filter_enabled = 1, strcntwk > 0, strcntwk >= 0)")
                                     if r["rule_id"] == "hist" else r for r in SPEC["populations"]]}
REQ_RCPT = req([("eop", "sum(eop)"), ("cccount", "sum(1)")])
CASES_RCPT = [
    ("receipt filter off (no receipt weeks picked): p1 + p3",
     REQ_RCPT, {"totals": {"eop": 79, "cccount": 2}}, WEEKS, SPEC_RCPT),
    ("receipt filter on (receipt weeks picked): p3 drops out",
     {**REQ_RCPT, "general": {"rcpt_weeks": ["W1", "W2"]}}, {"totals": {"eop": 70, "cccount": 1}}, WEEKS, SPEC_RCPT),
]

# screen rows = TY items + LY-only items (QA's TY/LY grid). TY: p1, p3; LY: p1, p2 (p2 sells 8 u in LY only).
def rows_spec(flt):
    return {**SPEC, "screens": {"FX": {**SPEC["screens"]["FX"], "row_periods": "ty,ly", "row_filter": flt}}}
CASES_ROWS = [
    ("rows TY + LY: p2 (LY only) is a row with TY values 0",
     req([("net_sls_r", ""), ("cccount", "")]),
     {"rows": {"p1": {"net_sls_r": 340}, "p2": {"net_sls_r": 0}, "p3": {"net_sls_r": 0}}},
     WEEKS, rows_spec("net_sls_u > 0 OR eop > 0 OR net_sls_u@ly > 0")),
    ("rows TY + LY with a row filter: count and TY sums",
     req([("net_sls_r", "sum(net_sls_r)"), ("cccount", "sum(1)")]),
     {"totals": {"net_sls_r": 340, "cccount": 3}}, WEEKS, rows_spec("net_sls_u > 0 OR eop > 0 OR net_sls_u@ly > 0")),
    ("row filter drops rows that fail it (TY sales only: p1)",
     req([("net_sls_r", "sum(net_sls_r)"), ("cccount", "sum(1)")]),
     {"totals": {"net_sls_r": 340, "cccount": 1}}, WEEKS, rows_spec("net_sls_u > 0")),
]

# share of total: a row over the sum of all rows (QA: CROSS JOIN (SELECT sum(x) FROM FINAL)). eop p1 70, p3 9
SPEC_SHARE = {**SPEC, "metrics": {**SPEC["metrics"], **dict([MT("ttl_eop", "derived", "total(eop)"),
                                                              MT("eop_share", "ratio", "eop", "ttl_eop")])}}
CASES_SHARE = [
    ("share of total: row / total(x) over all rows",
     req([("eop_share", ""), ("ttl_eop", "")]),
     {"rows": {"p1": {"eop_share": 0.8861, "ttl_eop": 79}, "p3": {"eop_share": 0.1139, "ttl_eop": 79}}},
     WEEKS, SPEC_SHARE),
]

# class decided per group (QA style review: a style is Carryover if any of its colors is, else New if any is,
# else Sell Down), here per department: p1 (Carryover) and p3 (Sell Down) share D1 -> both Carryover
UP = {"population_id": "P", "step": "3", "rule_id": "grp", "kind": "classify_up", "source_id": "",
      "time_window": "", "condition": "multiIf(countIf(class = 1) > 0, 1, countIf(class = 0) > 0, 0, 2)",
      "row_filter": "", "applies_when": "", "group_level": "department", "version": "1", "status": "approved",
      "notes": ""}
SPEC_UP = {**SPEC, "populations": [dict(r, step="4") if r["kind"] == "combine" else r
                                   for r in SPEC["populations"]] + [UP]}
CASES_UP = [
    ("classify per item: Carryover filter keeps p1 only",
     req([("eop", "")], fs=[1]), {"rows": {"p1": {"eop": 70}}}, WEEKS, SPEC),
    ("classify_up per department: p3 takes D1's Carryover",
     req([("eop", "")], fs=[1]), {"rows": {"p1": {"eop": 70}, "p3": {"eop": 9}}}, WEEKS, SPEC_UP),
    ("classify_up: no Sell Down group left",
     req([("eop", "sum(eop)")], fs=[2]), {"totals": {"eop": 0}}, WEEKS, SPEC_UP),
]

# rule decided per group (QA SKU screens: thresholds per stylecolor, items are its SKUs); here per class:
# cA (p1 35 u + p2 1 u) passes, so p2 joins although p2 alone fails sum(shp_u) > 3
SPEC_GRP = {**SPEC, "populations": [dict(r, group_level="class") if r["rule_id"] == "hist" else r
                                    for r in SPEC["populations"]]}
CASES_GRP = [
    ("having decided per class: p2 comes in with its class",
     req([("net_sls_r", "")]), {"rows": {"p1": {"net_sls_r": 340}, "p2": {"net_sls_r": 10}, "p3": {"net_sls_r": 0}}},
     WEEKS, SPEC_GRP),
]


def main():
    bad = 0
    for name, rq, exp, *wk in CASES + CASES_WEEKS + CASES_RCPT + CASES_ROWS + CASES_SHARE + CASES_UP + CASES_GRP:
        try:
            c = SP.compose(rq, wk[1] if len(wk) > 1 else SPEC, DIMS, wk[0] if wk else WEEKS)
            got_rows, got_tot = {}, {}
            if "rows" in exp:
                cols, _, rows, _ = R.fetch("TRD", "qa", c["sql_rows"])
                gk = c["grain"][0]
                got_rows = {r[gk]: r for r in SP.apply_post([dict(zip(cols, x)) for x in rows], c.get("post"))}
            if "totals" in exp:
                cols, _, rows, _ = R.fetch("TRD", "qa", c["sql_totals"])
                vals = dict(zip(cols, rows[0]))
                got_tot = {lbl: vals[a] for a, lbl in c["totals_map"]}
            errs = []
            for k, cols in exp.get("rows", {}).items():
                if k not in got_rows:
                    errs.append(f"row {k} missing (got {sorted(got_rows)})")
                    continue
                for col, v in cols.items():
                    if abs((got_rows[k][col] or 0) - v) > 1e-6:
                        errs.append(f"{k}.{col}: expected {v}, got {got_rows[k][col]}")
            extra = set(got_rows) - set(exp.get("rows", {}))
            if "rows" in exp and extra:
                errs.append(f"unexpected rows {sorted(extra)}")
            for col, v in exp.get("totals", {}).items():
                if abs((got_tot.get(col) or 0) - v) > 1e-6:
                    errs.append(f"total {col}: expected {v}, got {got_tot.get(col)}")
        except Exception as e:
            errs = [f"{type(e).__name__}: {e}"[:400]]
        bad += bool(errs)
        print(("PASS " if not errs else "FAIL ") + name)
        for e in errs:
            print("      " + e)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
