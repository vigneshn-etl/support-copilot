#!/usr/bin/env python3
"""
User-knowledge capture — persist a fact the user tells you, deterministically.

The problem this solves: knowledge a user drops in chat ("the QA branch is
_u", "that pivot counts rows not entities") dies when the session ends. This
appends it to the knowledge hub WITH PROVENANCE so any future session (or a
generic agent handed this repo) inherits it. The LLM's only job is to pass
the fact text and pick the enumerated scope/category; code does the writing.

Routing (deterministic):
  --client <CID>   -> customers/<CID>/captured-knowledge.md   (client-specific)
  (no client)      -> knowledge/captured-knowledge.md         (platform-wide)

Categories (enumerated): technical | functional | config | db | env | gotcha | process

Usage:
  python3 learn.py --client TRD --category env \\
      --fact "QA and staging both use ETL branch etl_assortment_planning_u" \\
      --source SUP-4486 --by vignesh.n
  python3 learn.py --category gotcha \\
      --fact "sum(1) in a rollUp counts ROWS; check the pivot bottomLevels grain first" \\
      --source SUP-4202
"""
import argparse, datetime, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
HUB = HERE.parent.parent
CATEGORIES = ["technical", "functional", "config", "db", "env", "gotcha", "process"]

HEADER = """# Captured knowledge{scope}

Facts captured from users during ticket work, newest first. Each entry is
stamped with source + who + when. Promote durable facts into the proper
knowledge file (profile.md, a primer, a runbook) and prune here.
Generated/appended by `tooling/triage/learn.py`.
"""


def target(client):
    if client:
        p = HUB / "customers" / client / "captured-knowledge.md"
        scope = f" — {client}"
    else:
        p = HUB / "knowledge" / "captured-knowledge.md"
        scope = " — platform"
    return p, scope


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fact", required=True, help="the fact, in one or two sentences")
    ap.add_argument("--category", required=True, choices=CATEGORIES)
    ap.add_argument("--client", default=None, help="CID e.g. TRD; omit for platform-wide")
    ap.add_argument("--source", default="", help="where it came from: SUP-####, chat, doc")
    ap.add_argument("--by", default="", help="who said it (e.g. reporter/user handle)")
    a = ap.parse_args()

    p, scope = target(a.client)
    p.parent.mkdir(parents=True, exist_ok=True)
    if not p.exists():
        p.write_text(HEADER.format(scope=scope))

    today = datetime.date.today().isoformat()
    prov = " · ".join(x for x in (
        f"source: {a.source}" if a.source else "",
        f"by: {a.by}" if a.by else "",
        f"captured: {today}") if x)
    entry = f"\n## [{a.category}] {today}\n{a.fact.strip()}\n_({prov})_\n"

    # newest-first: insert right after the header block (first blank line past it)
    text = p.read_text()
    lines = text.splitlines(keepends=True)
    # find end of header (first line starting with '## ' or EOF)
    idx = next((i for i, l in enumerate(lines) if l.startswith("## ")), len(lines))
    new = "".join(lines[:idx]) + entry + "\n" + "".join(lines[idx:])
    p.write_text(new)

    rel = p.relative_to(HUB)
    print(f"captured -> {rel}")
    if a.category in ("gotcha", "technical", "functional"):
        print(f"  tip: if durable, promote into "
              + (f"customers/{a.client}/profile.md" if a.client else "the relevant primer")
              + " and add a row to knowledge/INDEX.md.")


if __name__ == "__main__":
    main()
