#!/usr/bin/env python3
"""
Criteria-consistency checker (static — no DB, no live logs).

Invariant: pivots that read the SAME base table should apply the SAME
FLOW/HIST selection criteria. When they diverge, two screens qualify products
by different thresholds on the same data → "counts don't reconcile across
screens" (the SUP-4486 / SUP-4202 class). This finds those outliers, and also
flags NO-OP criteria (always-true for non-negative metrics, e.g. `> -10`,
`>= 0`, `1>0`) which silently disable filtering.

It reuses pivot_contract.extract, so it inherits the base->agg-view mapping and
the params/FreeMarker parsing.

Usage:
  python3 criteria_consistency.py --config-dir <trd-configs>            # History* pivots
  python3 criteria_consistency.py --config-dir <cfg> --glob 'History*'  # custom scope
  python3 criteria_consistency.py --config-dir <cfg> --all              # every pivotdefn
  python3 criteria_consistency.py --config-dir <cfg> --json
Exit code 1 if any inconsistency/no-op is found (CI-gate friendly).
"""
import argparse, json, re, sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import pivot_contract

# metrics known to be non-negative (units/retail/cost/counts) — from the agg view
NONNEG = set(pivot_contract.KNOWN_METRICS)


def norm(crit):
    """collapse whitespace/newlines so equal criteria compare equal."""
    if not crit:
        return None
    return re.sub(r"\s+", " ", crit).strip()


def is_noop(crit):
    """True if the criteria is always-true for non-negative metrics.
    An OR of comparisons is always-true if ANY branch is always-true:
      metric > n   with n < 0      -> always true (metric >= 0)
      metric >= n  with n <= 0     -> always true
      literal like 1>0 / 1=1       -> always true
    """
    if not crit:
        return False
    c = crit.lower()
    if re.search(r"\b1\s*>\s*0\b|\b1\s*=\s*1\b", c):
        return True
    for m in re.finditer(r"(avg|sum|min|max)?\(?\s*(\w+)\s*\)?\s*(>=|>)\s*(-?\d+(?:\.\d+)?)", c):
        _, metric, op, num = m.groups()
        if metric not in NONNEG:
            continue
        n = float(num)
        if op == ">" and n < 0:
            return True
        if op == ">=" and n <= 0:
            return True
    return False


def scan(config_dir, glob):
    pdir = Path(config_dir) / "pivot"
    rows = []
    for f in sorted(pdir.glob(f"{glob}.pivotdefn")):
        c = pivot_contract.extract(f)
        rows.append({
            "pivot": c["pivot"],
            "base": c.get("runtime_table"),
            "flow": norm(c.get("flow_criteria")),
            "hist": norm(c.get("hist_criteria")),
            "flow_noop": is_noop(c.get("flow_criteria")),
            "hist_noop": is_noop(c.get("hist_criteria")),
        })
    return rows


def analyze(rows):
    """group by base table; find the majority criteria + outliers + no-ops."""
    by_base = defaultdict(list)
    for r in rows:
        if r["base"]:
            by_base[r["base"]].append(r)
    report = {"groups": [], "noops": [], "inconsistent_bases": 0}
    for base, members in sorted(by_base.items()):
        # only consider pivots that actually declare criteria
        with_crit = [m for m in members if m["hist"] or m["flow"]]
        if not with_crit:
            continue
        # majority by the (flow,hist) pair
        tally = defaultdict(list)
        for m in with_crit:
            tally[(m["flow"], m["hist"])].append(m["pivot"])
        variants = sorted(tally.items(), key=lambda kv: len(kv[1]), reverse=True)
        majority = variants[0][0]
        outliers = []
        for (flow, hist), pivots in variants[1:]:
            outliers.append({"flow": flow, "hist": hist, "pivots": pivots})
        grp = {
            "base": base,
            "n_pivots": len(with_crit),
            "n_variants": len(variants),
            "majority": {"flow": majority[0], "hist": majority[1],
                         "pivots": tally[majority]},
            "outliers": outliers,
        }
        report["groups"].append(grp)
        if len(variants) > 1:
            report["inconsistent_bases"] += 1
    for r in rows:
        if r["flow_noop"] or r["hist_noop"]:
            report["noops"].append({"pivot": r["pivot"], "base": r["base"],
                                    "flow": r["flow"] if r["flow_noop"] else None,
                                    "hist": r["hist"] if r["hist_noop"] else None})
    return report


def print_report(rep):
    print("CRITERIA-CONSISTENCY REPORT\n" + "=" * 60)
    for g in rep["groups"]:
        flag = "  ⚠ INCONSISTENT" if g["n_variants"] > 1 else "  ✓ consistent"
        print(f"\nbase {g['base']}  ({g['n_pivots']} pivots, {g['n_variants']} variant(s)){flag}")
        mj = g["majority"]
        print(f"  majority ({len(mj['pivots'])}): HIST {mj['hist']}")
        print(f"                    FLOW {mj['flow']}")
        print(f"     used by: {', '.join(mj['pivots'][:8])}"
              + (" …" if len(mj['pivots']) > 8 else ""))
        for o in g["outliers"]:
            print(f"  ⚠ OUTLIER: HIST {o['hist']}")
            print(f"             FLOW {o['flow']}")
            print(f"     pivots: {', '.join(o['pivots'])}")
    if rep["noops"]:
        print("\n" + "-" * 60)
        print("NO-OP criteria (always true → filtering effectively disabled):")
        for n in rep["noops"]:
            which = "HIST" if n["hist"] else "FLOW"
            print(f"  ⚠ {n['pivot']}  [{which}]  {n['hist'] or n['flow']}   (base {n['base']})")
    print("\n" + "=" * 60)
    print(f"SUMMARY: {rep['inconsistent_bases']} base table(s) with inconsistent "
          f"criteria; {len(rep['noops'])} no-op criteria.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config-dir", required=True)
    ap.add_argument("--glob", default="History")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    glob = "*" if a.all else (a.glob.rstrip("*") + "*")
    rows = scan(a.config_dir, glob)
    rep = analyze(rows)
    if a.json:
        print(json.dumps(rep, indent=1))
    else:
        print_report(rep)
    sys.exit(1 if (rep["inconsistent_bases"] or rep["noops"]) else 0)


if __name__ == "__main__":
    main()
