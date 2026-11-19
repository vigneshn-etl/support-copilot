#!/usr/bin/env python3
"""Turn an ag_capture.js result into tests/cases/<name>.json.
python3 tests/capture/make_case.py NAME CAPTURE.json --defn P --agg level:X --view V --route R
       [--scope DP-48:CH-2:2025_W25:2025_W25] [--drop col,col] [--note text]"""
import argparse, datetime, json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ap = argparse.ArgumentParser()
for a in ("name", "capture"):
    ap.add_argument(a)
for a in ("--defn", "--agg", "--view", "--route"):
    ap.add_argument(a, required=True)
ap.add_argument("--scope", default="DP-48:CH-2:2025_W25:2025_W25")
ap.add_argument("--merchcat", default="FP,MD")
ap.add_argument("--drop", default="")
ap.add_argument("--note", default="")
ap.add_argument("--section", default="grid")
a = ap.parse_args()
cap = json.loads(Path(a.capture).read_text())
drop = {c for c in a.drop.split(",") if c} | {c for c in cap["cols"] if c.endswith("_band")}  # QA band ties are arbitrary
cap["cols"] = {c: v for c, v in cap["cols"].items() if c not in drop}
cap.pop("pinned", None)
pm, lm, hs, he = a.scope.split(":")
case = {"client": "TRD", "env": "qa", "route": a.route, "defnId": a.defn, "aggBy": a.agg, "viewdefn": a.view,
        "section": a.section,
        "scope": {"productLevel": "department" if pm.startswith("DP") else "class", "productMember": pm,
                  "locationLevel": "channel", "locationMember": lm, "historyStart": hs, "historyEnd": he},
        "filters": {"merchcat": a.merchcat.split(",")} if a.merchcat else {},
        "_note": "; ".join(x for x in [a.note, f"dropped: {sorted(drop)}" if drop else ""] if x),
        "expected": {"_source": f"QA UI {datetime.date.today()} ({a.view}, tests/capture/ag_capture.js)",
                     "checksums": dict(cap, rel_tol=1e-6)}}
out = HERE.parent / "cases" / f"{a.name}.json"
out.write_text(json.dumps(case, indent=1))
print(out, len(cap["cols"]), "cols", cap["n_rows"], "rows")
