#!/usr/bin/env python3
"""Regression: run every tests/cases/*.json through validate.py, print a scoreboard.
   python3 tests/run_cases.py [name-filter]      exit 1 if any case is not MATCH."""
import json, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import validate as V

flt = sys.argv[1] if len(sys.argv) > 1 else ""
cases = sorted(p for p in (HERE / "cases").glob("*.json") if flt in p.stem)
bad = 0
for p in cases:
    raw = json.loads(p.read_text())
    ctx = V.context(raw.get("client", "TRD"))
    t = time.time()
    r = V.validate(raw, ctx, with_rows=not raw.get("_totals_only"))
    out = HERE / "results" / f"{p.stem}.json"
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(r, indent=1, default=str))
    ok = r["status"] == "MATCH"
    bad += not ok
    print(f"{'PASS' if ok else 'FAIL'}  {p.stem:42} {r['status']:9} {time.time() - t:6.1f}s  {r.get('error') or ''}")
    for c in (r.get("compare") or {}).get("totals", []):
        if not c["match"]:
            print(f"        {c['metric']:22} UI={c['expected']!s:12} DB={c['db']}")
    ck = (r.get("compare") or {}).get("checksums")
    if ck and (ck["mismatches"] or ck["missing_in_db"] or ck["expected_rows"] not in (None, ck["n_rows"])):
        print(f"        rows UI={ck['expected_rows']} DB={ck['n_rows']}  missing={ck['missing_in_db'][:5]}")
        for m in ck["mismatches"][:10]:
            print(f"        {m['col']:30} UI={m['expected']} DB={m['db']}")
sys.exit(1 if bad else 0)
