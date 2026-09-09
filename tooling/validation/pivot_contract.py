#!/usr/bin/env python3
"""
Extract a pivotdefn's CONTRACT — the facts the composer needs to build a
faithful, independent validation query:

  { pivot, base_table, bottom_levels, metrics[], flow_criteria, hist_criteria }

pivotdefns are a FreeMarker-templated superset of JSON (they start with id=...,
bottomLevels=[...], and params.X= triple-quoted blocks), so we parse with
targeted regex, not json.load. Base tables + criteria live inside params.*
blocks — a plain grep FROM misses them, which is the whole point of having
this extractor.

Usage:
  python3 pivot_contract.py <path-to.pivotdefn>            # human view
  python3 pivot_contract.py <path-to.pivotdefn> --json     # machine
  python3 pivot_contract.py --config-dir <trd-configs> --pivot HistoryFit
"""
import argparse, json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import agg_types

# base (array-packed) table -> the runtime agg VIEW the pivot actually reads.
# Grounded from clickhouse_schema.sql (the _agg views ARRAY JOIN the _arr base,
# exposing flat columns dmd_u/shp_u/... at store x week x merchcat x grade grain).
ARR_TO_AGG = {
    "trd_p_history_loc_arr": "trd_p_history_agg",
    "trd_p_history_sku_loc_arr": "trd_p_history_sku_agg",
}

# metric columns we recognize in the history agg (extend as needed)
KNOWN_METRICS = ["dmd_r","dmd_u","dmd_c","shp_r","shp_u","shp_c",
                 "ret_r","ret_u","boh_u","eoh_r","eoh_u","eoh_c",
                 "bopis_u","sfs_u","dmd_r_csp","shp_r_csp"]


def _triple(text, key):
    """grab the body of  params.KEY=\"\"\" ... \"\"\"  """
    m = re.search(rf'{re.escape(key)}\s*=\s*"""(.*?)"""', text, re.S)
    return m.group(1).strip() if m else None


def extract(path: Path):
    t = path.read_text()
    c = {"pivot": path.stem, "path": str(path)}

    # bottomLevels (grain)
    bl = re.search(r"bottomLevels\s*=\s*\[(.*?)\]", t, re.S)
    c["bottom_levels"] = re.findall(r'"([^"]+)"', bl.group(1)) if bl else []

    # base clickhouse table(s): trd_p_history* referenced anywhere in the defn
    c["base_tables"] = sorted(set(re.findall(r"trd_p_history[a-z0-9_]*", t)))
    # runtime agg view the pivot actually reads: map the array-packed base to
    # its _agg view (what the UI query hits), per ARR_TO_AGG.
    agg = [x for x in c["base_tables"] if x.endswith("_agg")]
    if agg:
        c["runtime_table"] = agg[0]
    elif c["base_tables"]:
        c["runtime_table"] = ARR_TO_AGG.get(c["base_tables"][0], c["base_tables"][0])
        c["runtime_note"] = (f"mapped base {c['base_tables'][0]} -> runtime view "
                             f"{c['runtime_table']} (ARRAY JOIN internal)")
    else:
        c["runtime_table"] = None

    # mandatory conditions
    c["flow_criteria"] = _triple(t, "params.FLOW_TABLE_SELECTION_CRITERIA")
    c["hist_criteria"] = _triple(t, "params.HIST_TABLE_SELECTION_CRITERIA")

    # metrics: which known metric columns are summed in the params
    summed = set(re.findall(r"sum\((\w+)\)", t))
    c["metrics"] = [m for m in KNOWN_METRICS if m in summed] or \
                   sorted(m for m in summed if m in KNOWN_METRICS)

    # per-metric aggregation family + CH expression (additive/snapshot/first)
    c["metric_aggs"] = agg_types.classify(t)

    # runtime grain var used?
    c["uses_aggregation_products"] = "${AGGREGATION_PRODUCTS}" in t
    return c


def _resolve(a):
    if a.pivot and a.config_dir:
        return Path(a.config_dir) / "pivot" / f"{a.pivot}.pivotdefn"
    return Path(a.pivotdefn)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pivotdefn", nargs="?")
    ap.add_argument("--config-dir")
    ap.add_argument("--pivot")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    p = _resolve(a)
    if not p.exists():
        ap.error(f"not found: {p}")
    c = extract(p)
    if a.json:
        print(json.dumps(c, indent=1)); return
    print(f"PIVOT CONTRACT: {c['pivot']}")
    print(f"  runtime table : {c['runtime_table']}  (all: {c['base_tables']})")
    print(f"  grain         : {c['bottom_levels']}"
          + ("   [+ runtime ${AGGREGATION_PRODUCTS}]" if c['uses_aggregation_products'] else ""))
    print(f"  metrics       : {c['metrics']}")
    print(f"  FLOW criteria : {c['flow_criteria']}")
    print(f"  HIST criteria : {c['hist_criteria']}")


if __name__ == "__main__":
    main()
