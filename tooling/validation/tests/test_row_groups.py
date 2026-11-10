"""row groups (Pareto Summary) and bands: pure python, no DB."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from core import row_groups as RG, spec as SP

bad = 0
def check(name, got, want):
    global bad
    ok = got == want
    bad += not ok
    print(("PASS " if ok else "FAIL ") + name + ("" if ok else f"\n      got {got}\n      want {want}"))

# 10 items ranked by units desc (ties by id): Top 20% = ranks 1-2, Above Average 3-4, ... Bottom 20% 9-10
rows = [{"g_stylecolor": f"i{k}", "u": float(u), "r": float(10 * u), "__items": 1.0}
        for k, u in enumerate([5, 9, 0, 7, 1, 3, 0, 8, 2, 4])]
g = RG.group(rows, RG.PARETO, "u", "g_stylecolor", ["u", "r", "__items"])
check("pareto: counts per group", [g[k]["__items"] for k, _ in RG.PARETO], [10, 5, 2, 2, 2, 2, 2])
check("pareto: top 20% = the 2 best sellers", g["Top 20%"]["u"], 17.0)
check("pareto: below average = ranks 7-8 (2 + 1 units)", (g["Below Average"]["u"], g["Bottom 20%"]["u"]), (3.0, 0.0))
t = RG.group([{"k": k, "u": 1.0, "x": float(i)} for i, k in enumerate("edcba")], RG.PARETO, "u", "k", ["x"])
check("pareto: equal ranks ordered by item id (a first)", t["Top 20%"]["x"], 4.0)
RG.evaluate(g, [("pct", "if((total(u)) > 0, round((u) / (total(u)), 4), 0)", "ratio")])
check("pareto: share of total = share of the Total group", g["Top 20%"]["pct"], round(17 / 39, 4))
check("band: 4 positive scores -> ranks 1..4 of n=4 cut at 0.8/1.6/2.4/3.2; 0 -> 0",
      SP.band_of({"a": 3, "b": 1, "c": 0, "d": 2, "e": 5}), {"a": 4, "b": 2, "c": 0, "d": 3, "e": 5})
check("band: equal scores ordered by key", SP.band_of({"y": 1, "x": 1, "z": 1, "w": 1, "v": 1}),
      {"v": 1, "w": 2, "x": 3, "y": 4, "z": 5})
print("ALL PASS" if not bad else f"FAILED {bad}")
sys.exit(1 if bad else 0)
