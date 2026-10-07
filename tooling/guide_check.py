#!/usr/bin/env python3
"""Fail if a skill, tool or MCP server exists but GUIDE.md doesn't mention it.
Run: python3 tooling/guide_check.py   (exit 1 + list of gaps)"""
import json, sys
from pathlib import Path

HUB = Path(__file__).resolve().parent.parent

# feature -> phrases; GUIDE.md must contain at least one (case-insensitive)
FEATURES = {
    "skill:triage-ticket": ["solve a ticket"],
    "skill:validate-fix": ["validate"],
    "skill:ticket-retro": ["retro"],
    "skill:impact-analysis": ["what breaks if"],
    "skill:qa-sync": ["push a config fix to qa"],
    "skill:copilot-help": ["type `help`"],
    "mcp:lineage": ["lineage"],
    "mcp:db-readonly": ["query live qa databases"],
    "mcp:clickhouse-docs": ["clickhouse"],
    "mcp:knowledge": ["full-text search"],
    "tool:triage": ["confidence score"],
    "tool:lineage-viz": ["lineage-viz"],
    "tool:validation": ["data validation studio"],
    "tool:metrics": ["utilization dashboard"],
    "tool:learning": ["flashcards"],
    "tool:knowledge": ["full-text search"],
    "tool:lineage": ["what feeds"],
    "tool:db": ["query live qa databases"],
}
# internal/experimental — deliberately not advertised to users
INTERNAL = {"tool:pyspark"}


def discovered():
    found = {f"skill:{p.name}" for p in (HUB / ".claude/skills").iterdir() if (p / "SKILL.md").exists()}
    found |= {f"tool:{p.name}" for p in (HUB / "tooling").iterdir() if p.is_dir() and not p.name.startswith(("_", "."))}
    mcp = HUB / ".mcp.json"
    if mcp.exists():
        found |= {f"mcp:{n}" for n in json.loads(mcp.read_text()).get("mcpServers", {})}
    return found


def main():
    guide = (HUB / "GUIDE.md").read_text().lower()
    gaps = []
    for feat in sorted(discovered() - INTERNAL):
        phrases = FEATURES.get(feat)
        if phrases is None:
            gaps.append(f"{feat}: not registered in guide_check.FEATURES — document it in GUIDE.md, then add it here")
        elif not any(p in guide for p in phrases):
            gaps.append(f"{feat}: GUIDE.md doesn't mention any of {phrases}")
    if gaps:
        print("GUIDE.md is missing features:\n  " + "\n  ".join(gaps))
        sys.exit(1)
    print(f"GUIDE.md covers all {len(discovered())} skills/tools/MCPs")


if __name__ == "__main__":
    main()
