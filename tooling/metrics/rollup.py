#!/usr/bin/env python3
"""
Metrics rollup — turn the copilot's own artifacts into utilization + quality +
knowledge-growth numbers. ADMIN tool (answers "how is the copilot being used").

The engine already emits structured telemetry: every worked ticket is a
`tickets/<ID>/state.json`. This aggregates those + solution notes + the
learning logs into one rollup — no new instrumentation, exact-key reads.

Usage:
  python3 tooling/metrics/rollup.py            # text summary
  python3 tooling/metrics/rollup.py --json     # machine-readable (dashboard reads this)
"""
import argparse, datetime, json, glob, collections, sys
from pathlib import Path

HUB = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(HUB / "tooling" / "triage"))
try:
    import confidence as conf          # reuse the deterministic scorer
except Exception:
    conf = None


def _inc(counter, key):
    if key:
        counter[str(key)] += 1


def rollup():
    tickets = {"total": 0, "by_stage": collections.Counter(), "by_type": collections.Counter(),
               "by_component": collections.Counter(), "by_client": collections.Counter(),
               "by_mode": collections.Counter(), "by_owner": collections.Counter()}
    quality = {"requirement_confirmed": 0, "root_cause_run_confirmed": 0,
               "prior_art_used": 0, "confidence_bands": collections.Counter(),
               "avg_confidence": None}
    scores = []

    for f in sorted(glob.glob(str(HUB / "tickets" / "*" / "state.json"))):
        try:
            d = json.loads(Path(f).read_text())
        except Exception:
            continue
        tickets["total"] += 1
        cls = d.get("classification", {}) or {}
        _inc(tickets["by_stage"], d.get("stage"))
        _inc(tickets["by_type"], cls.get("type"))
        _inc(tickets["by_client"], d.get("client"))
        _inc(tickets["by_mode"], d.get("mode"))
        _inc(tickets["by_owner"], d.get("owner") or d.get("worked_by"))
        for c in (cls.get("component") or []):
            _inc(tickets["by_component"], c)
        if (d.get("requirement", {}) or {}).get("confirmed"):
            quality["requirement_confirmed"] += 1
        if (d.get("root_cause", {}) or {}).get("confirmed_by_execution"):
            quality["root_cause_run_confirmed"] += 1
        if d.get("prior_art"):
            quality["prior_art_used"] += 1
        if conf:
            try:
                sc, band, _, _ = conf.score(d)
                quality["confidence_bands"][band] += 1
                scores.append(sc)
            except Exception:
                pass
    if scores:
        quality["avg_confidence"] = round(sum(scores) / len(scores), 1)

    knowledge = {
        "solution_notes": len(glob.glob(str(HUB / "knowledge" / "solutions" / "*.md"))),
        "notes": len(glob.glob(str(HUB / "knowledge" / "notes" / "*.md"))),
        "customers": len([p for p in (HUB / "customers").glob("*") if p.is_dir()]),
        "captured_knowledge_entries": 0,
    }
    for ck in glob.glob(str(HUB / "**" / "captured-knowledge.md"), recursive=True):
        knowledge["captured_knowledge_entries"] += sum(
            1 for l in Path(ck).read_text().splitlines() if l.startswith("## ["))

    # learning layer
    learn = {"ledger": collections.Counter(), "calibration_n": 0, "calibration_avg_delta": None}
    led = HUB / "tooling" / "learning" / "skill_ledger.jsonl"
    if led.exists():
        for l in led.read_text().splitlines():
            if l.strip():
                try:
                    learn["ledger"][json.loads(l).get("action")] += 1
                except Exception:
                    pass
    cal = HUB / "tooling" / "learning" / "calibration_log.jsonl"
    if cal.exists():
        deltas = []
        for l in cal.read_text().splitlines():
            if l.strip():
                try:
                    deltas.append(abs(json.loads(l).get("delta", 0)))
                except Exception:
                    pass
        if deltas:
            learn["calibration_n"] = len(deltas)
            learn["calibration_avg_delta"] = round(sum(deltas) / len(deltas), 1)

    gaps = []
    if not any(tickets["by_owner"].values()):
        gaps.append("No `owner` on states — add one per ticket to unlock per-person metrics.")
    if tickets["total"] < 10:
        gaps.append("Few tickets recorded — centralize state.json (commit or Jira comment) as the team adopts.")

    # make Counters JSON-friendly
    def d(c): return dict(c)
    return {
        "generated": datetime.datetime.now().isoformat(timespec="seconds"),
        "tickets": {k: (d(v) if isinstance(v, collections.Counter) else v) for k, v in tickets.items()},
        "quality": {**{k: (d(v) if isinstance(v, collections.Counter) else v)
                       for k, v in quality.items()}},
        "knowledge": knowledge,
        "learning": {"ledger": d(learn["ledger"]),
                     "calibration_n": learn["calibration_n"],
                     "calibration_avg_delta": learn["calibration_avg_delta"]},
        "gaps": gaps,
    }


def print_text(r):
    t, q, k, l = r["tickets"], r["quality"], r["knowledge"], r["learning"]
    print(f"COPILOT UTILIZATION  ({r['generated']})\n" + "=" * 52)
    print(f"tickets worked: {t['total']}")
    print(f"  by component: {t['by_component']}")
    print(f"  by type:      {t['by_type']}")
    print(f"  by client:    {t['by_client']}")
    print(f"  by stage:     {t['by_stage']}")
    print(f"  by mode:      {t['by_mode'] or '(mode not recorded)'}")
    print(f"\nquality:")
    print(f"  requirement confirmed: {q['requirement_confirmed']}/{t['total']}")
    print(f"  root cause run-confirmed: {q['root_cause_run_confirmed']}/{t['total']}")
    print(f"  prior-art reused: {q['prior_art_used']}/{t['total']}")
    print(f"  confidence bands: {q['confidence_bands']}   avg: {q['avg_confidence']}")
    print(f"\nknowledge: {k['solution_notes']} solution notes, {k['notes']} notes, "
          f"{k['captured_knowledge_entries']} captured facts, {k['customers']} customers")
    print(f"learning: ledger {l['ledger'] or '{}'}, calibration n={l['calibration_n']} "
          f"avg|delta|={l['calibration_avg_delta']}")
    if r["gaps"]:
        print("\ngaps:")
        for g in r["gaps"]:
            print("  - " + g)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    r = rollup()
    print(json.dumps(r, indent=1) if a.json else "") or (None if a.json else print_text(r))


if __name__ == "__main__":
    main()
