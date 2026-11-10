"""metric_map resolver: FROM order and alias qualifiers (python3 tests/test_metric_map_resolver.py)."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import metric_map as mm  # noqa: E402

SCHEMA = {"trd_base": {"product", "rec_u", "shp_u"}, "trd_flow": {"product", "ttl_bohu"},
          "trd_attr": {"product", "stylecolor"}}


def resolve(sql, col):
    blocks, creators = mm.parse_blocks(sql)
    return mm.Resolver(blocks, creators, SCHEMA).col(creators["trd_OUT"][0], col)


def leaf_table(n):
    while n["kind"] == "expr":
        n = next(iter(n["kids"].values()))
    return n.get("table")


def check(name, got, want):
    print(("PASS" if got == want else "FAIL") + f" {name}: {got!r}" + ("" if got == want else f" (want {want!r})"))
    return got == want


SQL = """
CREATE TABLE trd_A AS SELECT product, sum(rec_u) as rec_u FROM trd_base GROUP BY product;
CREATE TABLE trd_BW AS SELECT * FROM trd_base;
CREATE TABLE trd_C AS SELECT product, sum(ttl_bohu) as boh_u FROM trd_flow GROUP BY product;
CREATE TABLE trd_OUT AS SELECT a.*, c.boh_u as boh_u, uniq(a.stylecolor) as cc
FROM trd_A a CROSS JOIN (SELECT * FROM trd_BW limit 1) b ANY LEFT JOIN trd_C c ON a.product = c.product
ANY LEFT JOIN trd_attr d ON a.product = d.product;
"""

ok = all([
    check("a.* column comes from a, not the cross-joined b", resolve(SQL, "rec_u")["kind"], "expr"),
    check("c.boh_u follows alias c", leaf_table(resolve(SQL, "boh_u")), "trd_flow"),
    check("a.stylecolor missing on a falls back to d (CH 21.4)",
          leaf_table(resolve(SQL, "cc")), "trd_attr"),
])
print("ALL PASS" if ok else "FAILURES")
sys.exit(0 if ok else 1)
