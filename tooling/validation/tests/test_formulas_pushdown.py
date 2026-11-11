"""formulas.Layering: sumIf over a pre-aggregated read -> read-level conditional measure
(python3 tests/test_formulas_pushdown.py)."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import metric_map as mm  # noqa: E402
from core import formulas as F  # noqa: E402

SCHEMA = {"trd_p_history_agg": {"product", "prodlife", "shp_u", "ret_u"}}
SQL = """
CREATE TABLE trd_SALES_SESSION AS SELECT product, prodlife, sum(shp_u) as shp_u_x
FROM trd_p_history_agg a GROUP BY product, prodlife;
CREATE TABLE trd_OUT AS SELECT product, sumIf(x.shp_u_x, x.prodlife = 'FP') as fp_shp_u, sum(x.shp_u_x) as shp_u
FROM (SELECT * FROM trd_SALES_SESSION) x GROUP BY product;
"""


def check(name, got, want):
    print(("PASS" if got == want else "FAIL") + f" {name}: {got!r}" + ("" if got == want else f" (want {want!r})"))
    return got == want


blocks, creators = mm.parse_blocks(SQL)
res = mm.Resolver(blocks, creators, SCHEMA)
out = creators["trd_OUT"][0]
L = F.Layering("T", res, blocks, creators, "trd_", ("fp_shp_u", "shp_u"))
tok, _ = L.define(res.col(out, "fp_shp_u"))
exprs = {k.rsplit(":", 1)[1]: v["expr"] for k, v in L.measures.items()}
ok = all([
    check("sumIf over x.shp_u_x becomes one measure token", tok.startswith("{m:") and tok.endswith(":fp_shp_u}"), True),
    check("its expr carries the condition on the read", exprs.get("fp_shp_u"), "sumIf(shp_u, prodlife = 'FP')"),
    check("no problems logged", [p for p in L.problems if "fp_shp_u" in p or "prodlife" in p], []),
])
print("ALL PASS" if ok else "FAILURES")
sys.exit(0 if ok else 1)
