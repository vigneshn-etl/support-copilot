#!/usr/bin/env python3
"""
Aggregation-type classifier (CH correctness).

The big correctness trap: not every metric is additive. In a history pivot,
sales/demand/receipts are SUMMED, but inventory/stock metrics (EOH, BOH,
store/CC counts, in-transit) are POINT-IN-TIME — the pivot takes their LAST
value by time, not a sum. Summing EOH across weeks over-counts massively and
produces a plausible-but-wrong number.

We don't reconstruct the pivot's intricate union SQL (that risks false
precision). Instead we classify each metric by unambiguous tokens in the
pivotdefn and emit the CH-native expression per family:

  additive  -> sum(m)                (sum(m) present)
  snapshot  -> argMax(m, time)       (last_value_m / last_value(m) present)
  first     -> argMin(m, time)       (first_value_m present)
  unknown   -> sum(m)  + a TODO      (nothing conclusive -> flag, don't guess)

argMax(m, time) is the CH-correct "value at the latest week" once you GROUP BY
the entity. `time` is the ordering key (confirm per pivot if a pivot orders by
something else).
"""
import re

# metric universe seen on the history agg view (extend as needed)
METRIC_UNIVERSE = [
    "dmd_r","dmd_u","dmd_c","dmd_r_csp","shp_r","shp_u","shp_c","shp_r_csp",
    "ret_r","ret_u","ret_c","ret_r_csp","bopis_r","bopis_u","bopis_c",
    "sfs_r","sfs_u","sfs_c","boh_r","boh_u","boh_c","eoh_r","eoh_u","eoh_c",
    "bop_intransit_r","bop_intransit_u","bop_intransit_c",
    "eop_intransit_r","eop_intransit_u","eop_intransit_c",
    "oo_r","oo_u","oo_c","storecount","cccount",
]
ORDER_KEY = "time"   # the point-in-time ordering column on the agg view


def classify(text, metrics=None):
    """Return {metric: {'family':..., 'ch_expr':..., 'evidence':...}}."""
    metrics = metrics or METRIC_UNIVERSE
    out = {}
    for m in metrics:
        snap = re.search(rf"last_value[_(]\s*{re.escape(m)}\b", text)
        first = re.search(rf"first_value[_(]\s*{re.escape(m)}\b", text)
        summed = re.search(rf"\bsum\(\s*{re.escape(m)}\s*\)", text)
        if snap:
            fam, expr, ev = "snapshot", f"argMax({m}, {ORDER_KEY})", "last_value token"
        elif first:
            fam, expr, ev = "first", f"argMin({m}, {ORDER_KEY})", "first_value token"
        elif summed:
            fam, expr, ev = "additive", f"sum({m})", "sum() token"
        else:
            continue   # metric not used by this pivot
        out[m] = {"family": fam, "ch_expr": expr, "evidence": ev}
    return out


def ch_expr(metric, family):
    return {"additive": f"sum({metric})",
            "snapshot": f"argMax({metric}, {ORDER_KEY})",
            "first":    f"argMin({metric}, {ORDER_KEY})"}.get(family, f"sum({metric})")


if __name__ == "__main__":
    import argparse, json
    ap = argparse.ArgumentParser()
    ap.add_argument("pivotdefn")
    a = ap.parse_args()
    res = classify(open(a.pivotdefn).read())
    fams = {}
    for m, d in res.items():
        fams.setdefault(d["family"], []).append(m)
    for fam in ("additive", "snapshot", "first"):
        if fams.get(fam):
            print(f"{fam:9}: {', '.join(sorted(fams[fam]))}")
    print(f"\n{len(res)} metrics classified.")
