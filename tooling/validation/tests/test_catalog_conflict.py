"""catalog save refuses an edit made on an older version (no DB: fake connection)."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from core import catalog_db as C

CUR = {"metric_id": "m1", "label": "M1", "metric_type": "ratio", "expr": "a/b", "denominator": "",
       "round_digits": "2", "requirement": "", "status": "approved", "version": 3, "updated_by": "asha",
       "notes": None, "qa_ref": None}


class Fake:
    def __enter__(self): return self
    def __exit__(self, *a): pass
    def execute(self, sql, args=None):
        self.sql = sql
        return self
    def fetchone(self):
        return dict(CUR, expr="a/c") if self.sql.startswith("UPDATE") else dict(CUR)


C.connect = lambda: Fake()
st = C.CatalogDB("trd", "qa")
row = {"metric_id": "m1", "label": "M1", "type": "ratio", "expr": "a/c", "round": "2"}
ok = 0
try:
    st.upsert("metrics", row, "me", base_version="2")
    print("FAIL stale edit was saved")
except C.Conflict as e:
    ok += 1
    print("PASS stale edit refused:", e)
st.upsert("metrics", row, "me", base_version="3")
ok += 1
print("PASS current edit saved")
print("ALL PASS" if ok == 2 else "FAILED")
