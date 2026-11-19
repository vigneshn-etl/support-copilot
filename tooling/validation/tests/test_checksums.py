"""validate.compare_checksums: case checksums vs engine rows (python3 tests/test_checksums.py)."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import validate as V  # noqa: E402

RES = {"resolved": {"grain": ["stylecolor"], "metrics": [{"label": "GMROI", "data_index": "ty_gmroi"},
                                                         {"label": "LY GMROI", "data_index": "ly_gmroi"}]},
       "provenance": {"metrics": {"GMROI": "gmroi v1 (draft)", "LY GMROI": "gmroi@ly v1 (draft)"}},
       "rows": [{"g_stylecolor": "a", "gmroi": 1.5, "gmroi__ly": float("nan")},
                {"g_stylecolor": "b", "gmroi": 0.0, "gmroi__ly": 2.0}]}


def exp(**cols):
    return {"n_rows": 2, "cols": cols}


ok_cols = {"ty_gmroi": [1.5, 1.5 * V.key_weight("a"), 1], "ly_gmroi": [2.0, 2.0 * V.key_weight("b"), 1]}
checks = [
    ("labels map to metric@period columns; NaN counts as 0", V.compare_checksums(RES, exp(**ok_cols))[0], True),
    ("swapped keys fail the weighted sum",
     V.compare_checksums(RES, exp(ty_gmroi=[1.5, 1.5 * V.key_weight("b"), 1]))[0], False),
    ("row count must match", V.compare_checksums(RES, dict(exp(**ok_cols), n_rows=3))[0], False),
]
bad = 0
for name, got, want in checks:
    print(("PASS " if got == want else "FAIL ") + name)
    bad += got != want
print("ALL PASS" if not bad else "FAILURES")
sys.exit(1 if bad else 0)
