"""
Load a client's spec CSVs (customers/<CLIENT>/spec) into the UCM dvs schema as dvs_app.

Dry run by default: reports what would be inserted, what already exists and what differs.
--apply inserts missing rows only (origin 'seed', status and version kept); existing rows are
never overwritten. Legacy agg names are mapped to the UCM vocabulary on the way in.

  python3 migrations/dvs/load_csv.py --client TRD            # dry run
  python3 migrations/dvs/load_csv.py --client TRD --apply
"""
import argparse, csv, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from core import catalog_db as CDB          # noqa: E402
from core.spec import LEGACY_AGGS            # noqa: E402

HUB = ROOT.parents[1]
ORDER = ["sources", "measures", "metrics", "populations", "screens", "bindings"]   # FK order


def rows_of(spec_dir, file):
    p = spec_dir / f"{file}.csv"
    return list(csv.DictReader(open(p, newline=""))) if p.exists() else []


def prepare(file, row):
    vals = CDB.to_db(file, row)
    if file == "measures":
        vals["agg_kind"] = LEGACY_AGGS.get(vals["agg_kind"], vals["agg_kind"])
    status = (row.get("status") or "draft").strip()
    vals["status"] = status if status in ("draft", "approved", "retired") else "draft"
    vals["version"] = int(row.get("version") or 1)
    if vals["status"] == "approved":
        vals["approved_by"] = row.get("approved_by") or None
        vals["approved_at"] = row.get("approved_at") or None
    vals["origin"] = "seed"
    return vals


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--client", required=True)
    ap.add_argument("--env", default="qa")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--user", default="load_csv")
    a = ap.parse_args()
    spec_dir = HUB / "customers" / a.client.upper() / "spec"
    tenant = a.client.lower()
    print(f"{'APPLY' if a.apply else 'DRY RUN'}: {spec_dir} -> dvs (tenant={tenant}, env={a.env})")
    with CDB.connect() as c:
        c.execute("SELECT set_config('dvs.user', %s, true)", (a.user,))
        for file in ORDER:
            table, keys = CDB.TABLES[file]
            kcols = [CDB.RENAMES.get(file, {}).get(k, k) for k in keys]
            have = {tuple(str(r[k]) for k in kcols): r for r in c.execute(
                f"SELECT * FROM {table} WHERE tenant = %s AND environment = %s", (tenant, a.env)).fetchall()}
            new = same = diff = 0
            seen = {}
            for row in rows_of(spec_dir, file):
                vals = prepare(file, row)
                k = tuple(str(vals[kc]) for kc in kcols)
                if k in seen:                   # same key twice in the CSV (e.g. one column under two headers)
                    print(f"  ! {file} {'|'.join(k)} duplicate in CSV, kept first; label '{row.get('label', '')}'")
                    first = seen[k]
                    first["notes"] = "; ".join(x for x in (first.get("notes"), f"also shown as '{row.get('label', '')}'") if x)
                    continue
                seen[k] = vals
            for vals in seen.values():
                k = tuple(str(vals[kc]) for kc in kcols)
                if k in have:
                    cur = have[k]
                    d = [col for col, v in vals.items() if col not in ("origin", "status", "version",
                         "approved_by", "approved_at", "notes") and cur.get(col) != v]
                    if d:
                        diff += 1
                        print(f"  ~ {file} {'|'.join(k)} differs in {', '.join(d)} (kept DB)")
                    else:
                        same += 1
                    continue
                new += 1
                if a.apply:
                    cols = ["tenant", "environment"] + list(vals)
                    c.execute(f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({', '.join(['%s'] * len(cols))})",
                              [tenant, a.env] + list(vals.values()))
            print(f"  {file:12s} -> {table:15s} new {new:4d}  same {same:4d}  differs {diff:4d}")
        if not a.apply:
            c.rollback()
            print("dry run: nothing written (use --apply)")


if __name__ == "__main__":
    main()
