#!/usr/bin/env python3
"""
Compose an INDEPENDENT validation query from (listData request) + (pivot
contract). It does NOT execute — it prints SQL for you to run and compare to
the UI. Copy the INPUTS (grain/filters from the request); compute the OUTPUT
(metric logic) independently from the contract — so agreement is a real test,
not a replay of the pivot's temp-table flow.

Targets the agg VIEW the pivot actually reads (e.g. trd_p_history_agg), so the
temp tables (trd_<Pivot>_PRODUCT_<session>) are bypassed by design.

Anything not fully grounded is emitted as an explicit  -- TODO/CONFIRM  line
rather than guessed (unknown stays unknown).

Usage:
  python3 compose.py --url "<listData URL>" --config-dir <trd-configs>
  python3 compose.py --url "<URL>" --config-dir <cfg> --criteria hist|flow
"""
import argparse, sqlite3, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import listdata_parse, pivot_contract


def consistency_banner(pivot, db_path):
    """Look up this pivot's verdict in the catalog and return SQL-comment lines
    that link the consistency finding straight onto the composed query."""
    try:
        con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
        row = con.execute("SELECT verdict, base, hist, majority_hist, n_siblings "
                          "FROM consistency WHERE pivot=?", (pivot,)).fetchone()
        con.close()
    except Exception as e:
        return [f"-- (consistency: catalog unavailable: {e})"]
    if not row:
        return ["-- consistency: no verdict for this pivot (not in catalog)."]
    verdict, base, hist, maj_hist, nsib = row
    if verdict == "noop":
        out = ["-- ⚠ CONSISTENCY: this pivot's criteria is a NO-OP → rows are UNFILTERED.",
               f"--   criteria as written: {hist or '(see HAVING above)'}"]
        if base and maj_hist:
            out.append(f"--   {nsib} sibling pivots on {base} filter at: {maj_hist}")
        else:
            out.append("--   this pivot reads a DERIVED source (a nested pivot's output), not a")
            out.append("--   base history table directly — cross-check against the module's primary")
            out.append("--   filtered view (e.g. HistoryFit) to see if this view over-counts.")
        return out
    if verdict == "outlier":
        return ["-- ⚠ CONSISTENCY: this pivot's criteria DIFFERS from its base-mates.",
                f"--   this pivot: {hist}",
                f"--   majority ({nsib} pivots) on {base}: {maj_hist}",
                "--   counts on this view may not reconcile with sibling views (SUP-4486 class)."]
    return [f"-- ✓ CONSISTENCY: criteria matches the majority ({nsib} pivots) on {base}."]

# grounded from trd_p_history_agg column list (clickhouse_schema.sql)
# product LEVEL token -> agg column that represents that grain
PROD_LEVEL_COL = {
    "stylecolor": "product",     # 'product' IS the stylecolor id in this view
    "style": "x_style",
}
# fixed lower-grain dimensions available directly on the agg view
FIXED_DIMS = {"location", "time", "merchcat", "grade", "prodlife", "cluster"}
DEFAULT_METRICS = ["dmd_u", "shp_u", "eoh_u", "dmd_r", "shp_r"]


def resolve_pivot(defn_id, config_dir):
    """defnId in the request may be a PIVOT id or a MODEL id. Try pivot first;
    else read the model's pivotDefn. Returns (pivotdefn_path, note)."""
    cfg = Path(config_dir)
    p = cfg / "pivot" / f"{defn_id}.pivotdefn"
    if p.exists():
        return p, None
    m = cfg / "uidefn" / "model" / f"{defn_id}.modeldefn"
    if m.exists():
        import json
        pv = json.loads(m.read_text()).get("pivotDefn")
        if pv:
            pp = cfg / "pivot" / f"{pv}.pivotdefn"
            if pp.exists():
                return pp, f"defnId '{defn_id}' is a model -> pivotDefn '{pv}'"
    return None, f"could not resolve defnId '{defn_id}' to a pivotdefn"


def compose(url, config_dir, which="hist", catalog=None):
    scope = listdata_parse.parse(url)
    pivot = scope["defnId"]
    if not pivot:
        return "-- ERROR: no defnId in the request; cannot pick a pivot."
    cpath, resolve_note = resolve_pivot(pivot, config_dir)
    if not cpath:
        return f"-- ERROR: {resolve_note}"
    c = pivot_contract.extract(cpath)

    table = c["runtime_table"] or "trd_p_history_agg"
    maggs = c.get("metric_aggs", {})
    # core display metrics (correct per-metric aggregation), only those this pivot uses
    CORE = ["dmd_u", "shp_u", "ret_u", "dmd_r", "shp_r", "eoh_u", "boh_u"]
    show = [m for m in CORE if m in maggs] or list(maggs)[:8]
    crit = c["hist_criteria"] if which == "hist" else c["flow_criteria"]
    crit_kind = "HIST (sum-based)" if which == "hist" else "FLOW (avg-based)"

    # resolve the requested product grain
    prod_levels = [g for g in scope["grain"] if g["kind"] == "level"
                   and g["name"] not in FIXED_DIMS]
    warnings, group_cols, select_dims = [], [], []
    for g in prod_levels:
        col = PROD_LEVEL_COL.get(g["name"])
        if col:
            group_cols.append(col); select_dims.append(f"{col} AS {g['name']}")
        else:
            warnings.append(f"grain level '{g['name']}' is not a direct column on "
                            f"{table} — needs a product-hierarchy join (M_Meta). "
                            f"Query below groups at stylecolor; roll up in the tool.")
    if not group_cols:                       # default to stylecolor
        group_cols = ["product"]; select_dims = ["product AS stylecolor"]

    L = []
    L.append(f"-- ============================================================")
    L.append(f"-- VALIDATION QUERY (independent oracle) — compose.py")
    L.append(f"-- pivot/defnId : {pivot}" + (f"   ({resolve_note})" if resolve_note else ""))
    L.append(f"-- grain (aggBy): {scope['grain_raw'] or '(none)'}")
    L.append(f"-- source view  : {table}   (temp tables bypassed by design)")
    if c.get("runtime_note"):
        L.append(f"-- table map    : {c['runtime_note']}")
    L.append(f"-- criteria     : {crit_kind}: {crit}")
    if scope["flowStatus"] not in (None, ""):
        L.append(f"-- flowStatus   : {scope['flowStatus']}  (filter — confirm column below)")
    if scope["topMembers"]:
        L.append(f"-- topMembers   : {scope['topMembers']}  (scope — needs hierarchy join)")
    for w in warnings:
        L.append(f"-- TODO/CONFIRM : {w}")
    L.append(f"-- BEFORE RUN    : set the history time window to match the UI "
             f"(HistoryStart..HistoryEnd / HISTORY_WEEKS).")
    L.append(f"-- CH DIALECT    : `time` is a String week id → filter with IN (not a date BETWEEN).")
    L.append(f"--   additive metrics use sum(); POINT-IN-TIME stock metrics use "
             f"argMax(m, time) (EOH=last) / argMin(m, time) (BOH=first) — NOT sum.")
    # flag any metric we couldn't classify
    unclass = [m for m in show if m not in maggs]
    if unclass:
        L.append(f"-- TODO/CONFIRM : unclassified aggregation for {unclass} — verify vs pivot.")
    L.append("")

    # build (sql, comment) items; comma is emitted BEFORE the comment so an
    # inline note never comments out the separator.
    items = [(d, None) for d in select_dims]
    for m in show:
        info = maggs.get(m)
        expr = info["ch_expr"] if info else f"sum({m})"
        fam = info["family"] if info else "TODO confirm aggregation (unclassified)"
        items.append((f"{expr} AS {m}", fam))
    items.append(("count(DISTINCT product) AS stylecolor_count", "choice count (exact in CH)"))
    L.append("SELECT")
    for i, (txt, cmt) in enumerate(items):
        comma = "," if i < len(items) - 1 else ""
        L.append(f"    {txt}{comma}" + (f"   -- {cmt}" if cmt else ""))
    L.append(f"FROM {table}")
    L.append("WHERE time IN (:HISTORY_WEEKS)               -- REQUIRED: string week ids from the UI's window")
    if scope["flowStatus"] not in (None, ""):
        L.append(f"--  AND prodlife = '{scope['flowStatus']}'    -- CONFIRM: is prodlife the flow-status column?")
    if scope["topMembers"]:
        L.append(f"--  AND <product-hierarchy scope for {scope['topMembers']}>   -- TODO: join M_Meta/product dim")
    L.append(f"GROUP BY {', '.join(group_cols)}")
    if crit:
        L.append(f"HAVING {crit.strip()}")
    if catalog:
        L += consistency_banner(cpath.stem, catalog)   # cpath.stem = resolved pivot name
    L.append(f"ORDER BY {', '.join(group_cols)}")
    L.append(";")
    L.append("")
    L.append("-- Compare to the UI for the SAME scope:")
    L.append("--   * stylecolor_count       == the count/# products shown")
    L.append("--   * each metric (per its aggregation) == the rolled-up value on screen")
    L.append("--   * a row present here but missing on the UI (or vice-versa) => a criteria/filter bug (SUP-4486 class)")
    L.append("--   NOTE: if a stock metric (eoh/boh) mismatches, check the point-in-time ordering key (time).")
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", required=True, help="the pivot3 listData URL (or a log line with it)")
    ap.add_argument("--config-dir", required=True, help="path to trd-configs")
    ap.add_argument("--criteria", choices=["hist", "flow"], default="hist")
    ap.add_argument("--catalog", default=None, help="path to catalog.db → annotate with consistency verdict")
    a = ap.parse_args()
    print(compose(a.url, a.config_dir, a.criteria, a.catalog))


if __name__ == "__main__":
    main()
