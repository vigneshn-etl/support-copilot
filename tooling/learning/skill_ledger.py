#!/usr/bin/env python3
"""
Skill ledger — make skill erosion VISIBLE before it's deep.

The risk with AI: you drift from author to prompter, accept everything, and
your own SQL/config/debugging muscle quietly detrains. This logs, per skill,
whether YOU authored a thing, merely accepted the AI's version, reviewed it
critically, or did a deliberate no-AI cold rep. The report surfaces the
balance and flags skills you've stopped exercising — not to nag, just so the
invisible becomes a number you can act on.

Actions (what YOU did):
  authored  - you wrote it first (with or without AI checking after)
  reviewed  - AI wrote it; you interrogated it line-by-line and can explain it
  accepted  - AI wrote it; you took it without deep review   (the risky one)
  cold      - you did it deliberately WITHOUT AI (a training rep)

Commands:
  skill_ledger.py log --skill sql --action authored --ticket SUP-4486 [--note "..."]
  skill_ledger.py report [--days 30] [--skill sql]
  skill_ledger.py streak                 # your recent cold-rep / authored streak

Ledger: tooling/learning/skill_ledger.jsonl
"""
import argparse, datetime, json
from pathlib import Path

LED = Path(__file__).resolve().parent / "skill_ledger.jsonl"
ACTIONS = ["authored", "reviewed", "accepted", "cold"]
# how much each action counts toward "keeping the muscle" (authored/cold = full)
ENGAGEMENT = {"authored": 1.0, "cold": 1.0, "reviewed": 0.5, "accepted": 0.0}


def log(a):
    rec = {"ts": datetime.datetime.now().isoformat(timespec="seconds"),
           "skill": a.skill, "action": a.action, "ticket": a.ticket, "note": a.note}
    LED.parent.mkdir(parents=True, exist_ok=True)
    with LED.open("a") as f:
        f.write(json.dumps(rec) + "\n")
    print(f"logged: {a.skill} / {a.action}"
          + (f" ({a.ticket})" if a.ticket else "")
          + ("  — a training rep, nice" if a.action in ("authored", "cold") else ""))


def _read(days=None, skill=None):
    if not LED.exists():
        return []
    rows = [json.loads(l) for l in LED.read_text().splitlines() if l.strip()]
    if skill:
        rows = [r for r in rows if r["skill"] == skill]
    if days:
        cut = (datetime.datetime.now() - datetime.timedelta(days=days)).isoformat()
        rows = [r for r in rows if r["ts"] >= cut]
    return rows


def report(a):
    rows = _read(a.days, a.skill)
    if not rows:
        print("no entries yet — start logging with `log --skill … --action …`.")
        return
    skills = {}
    for r in rows:
        s = skills.setdefault(r["skill"], {k: 0 for k in ACTIONS})
        s[r["action"]] = s.get(r["action"], 0) + 1
    win = f"last {a.days}d" if a.days else "all time"
    print(f"SKILL LEDGER ({win})\n")
    print(f"  {'skill':<14}{'authored':>9}{'reviewed':>9}{'accepted':>9}{'cold':>6}   engagement")
    for s, c in sorted(skills.items()):
        total = sum(c.values())
        eng = sum(ENGAGEMENT[k] * c.get(k, 0) for k in ACTIONS) / total if total else 0
        bar = "█" * round(eng * 10) + "·" * (10 - round(eng * 10))
        flag = ""
        if total >= 4 and eng < 0.3:
            flag = "  ⚠ mostly accepting — take the wheel back"
        elif eng >= 0.7:
            flag = "  ✓ staying sharp"
        print(f"  {s:<14}{c['authored']:>9}{c['reviewed']:>9}{c['accepted']:>9}{c['cold']:>6}   {bar} {eng:.0%}{flag}")
    print("\nengagement = authored/cold count full, reviewed half, accepted zero.")
    print("aim: keep the skills you care about above ~60%.")


def streak(a):
    rows = _read(days=a.days or 30)
    reps = [r for r in rows if r["action"] in ("authored", "cold")]
    accepts = [r for r in rows if r["action"] == "accepted"]
    print(f"last {a.days or 30}d: {len(reps)} training reps (authored/cold), "
          f"{len(accepts)} passive accepts.")
    if len(accepts) > 2 * max(1, len(reps)):
        print("  ⚠ accepts outpacing reps — schedule a cold rep (one ticket, no AI).")
    elif reps:
        print("  ✓ good ratio — the muscle is getting worked.")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    lg = sub.add_parser("log")
    lg.add_argument("--skill", required=True, help="sql | config | pivot | etl | debugging | …")
    lg.add_argument("--action", required=True, choices=ACTIONS)
    lg.add_argument("--ticket", default="")
    lg.add_argument("--note", default="")
    rp = sub.add_parser("report"); rp.add_argument("--days", type=int, default=None)
    rp.add_argument("--skill", default=None)
    st = sub.add_parser("streak"); st.add_argument("--days", type=int, default=None)
    a = ap.parse_args()
    {"log": log, "report": report, "streak": streak}[a.cmd](a)


if __name__ == "__main__":
    main()
