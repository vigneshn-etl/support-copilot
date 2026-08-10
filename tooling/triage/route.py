#!/usr/bin/env python3
"""
Deterministic router — classify a ticket from its text, NOT from LLM judgment.

Extracts features (client tag, symptom signals, scope signals) and maps them
through a decision table to: type, component(s), environment — each with a
`source` so nothing is "guessed". The LLM's only job is to pass the ticket
text; the mapping is code. Output seeds state.json's classification.

Usage:
  python3 route.py --title "..." --body "..." [--issuetype Bug] [--json]
  echo '<ticket text>' | python3 route.py --stdin
"""
import argparse, json, re, sys

# --- feature signals (extend as patterns emerge) ----------------------------
CLIENT_TAG = re.compile(r"\[([A-Z]{2,5})\]")

TYPE_SIGNALS = {
    "data-issue": [r"\b(wrong|incorrect|missing|inflated|mismatch|not match|stale|duplicat)\w*\b.*\b(value|count|number|data|units?|qty|quantity|total)\b",
                   r"\b(on[- ]?order|eoh|boh|sales|inventory|receipt)\b.*\b(wrong|missing|off)\b"],
    "bug":         [r"\b(bug|defect|error|broken|fails?|crash|does\s?n.?t work|not working|unexpected)\b",
                    r"\b(should (be|show)|expected)\b.*\bbut\b"],
    "enhancement": [r"\b(add|create|new|support|enable|introduce|implement)\b.*\b(column|metric|field|view|filter|feature|report)\b",
                    r"\brequirement\b"],
    "config-change":[r"\b(rename|relabel|display name|label|reorder|hide|show)\b",
                     r"\b(view|grid|column|metric)\b.*\b(config|configure)\b"],
    "deploy":      [r"\b(deploy|constant table|promote to (prod|production)|release)\b"],
    "question":    [r"^\s*(how|what|why|where|can we|is it|does)\b", r"\?\s*$"],
}

# component signals -> which layer. Multiple can fire (hybrid).
COMPONENT_SIGNALS = {
    "etl":     [r"\b(batch|etl|vsql|psql|clickhouse-client|inbound|s5\w+\.(csv|dat)|table_mappings|load|weekly|daily|intraday|vertica|staging)\b",
                r"\b(wrong|missing)\b.*\b(everywhere|all (screens|views)|every screen)\b"],
    "config":  [r"\b(view|viewdefn|pivot|pivotdefn|model|modeldefn|confdefn|metric|formula|group ?by|roll ?up|filter|column)\b",
                r"\b(one (view|screen)|only (in|on)|single view)\b"],
    "frontend":[r"\b(refresh|render|click|drag|scroll|button|modal|grid (not|does)|UI|screen freezes|display)\b"],
    "backend": [r"\b(pivot (fail|error)|SystemBrokenException|DB::Exception|getAvailableSelections|darwin|filter (option|values)|cache)\b"],
    "db":      [r"\b(trigger|changed by itself|updated_at|recompute|constraint)\b"],
}

ENV_SIGNALS = {
    "qa":      [r"\bqa\b", r"qa\.[a-z]+\.oci", r"internal-qa"],
    "staging": [r"\b(staging|upgrade)\b", r"asst\.upgrade"],
    "prod":    [r"\b(prod|production)\b", r"\.s5stratos\.com(?!.*qa)"],
}


def _hits(text, patterns):
    return sum(1 for p in patterns if re.search(p, text, re.I))


def route(title, body, issuetype=None):
    text = f"{title}\n{body}"
    out = {"signals": {}}

    # client
    m = CLIENT_TAG.search(title) or CLIENT_TAG.search(body)
    out["client"] = m.group(1) if m else None

    # type — Jira issuetype is the strongest signal; else score the text
    type_scores = {t: _hits(text, pats) for t, pats in TYPE_SIGNALS.items()}
    out["signals"]["type"] = {k: v for k, v in type_scores.items() if v}
    if issuetype:
        jt = issuetype.lower()
        mapped = ("bug" if "bug" in jt else
                  "enhancement" if jt in ("task", "story", "new feature") else
                  "deploy" if "deploy" in jt else None)
        if mapped:
            out["type"] = mapped; out["type_source"] = "jira-issuetype"
    if "type" not in out:
        best = max(type_scores, key=type_scores.get)
        out["type"] = best if type_scores[best] else "question"
        out["type_source"] = "router" if type_scores[best] else "router-default"

    # component — all layers that fire; hybrid if >1 strong
    comp_scores = {c: _hits(text, pats) for c, pats in COMPONENT_SIGNALS.items()}
    out["signals"]["component"] = {k: v for k, v in comp_scores.items() if v}
    fired = [c for c, v in comp_scores.items() if v > 0]
    fired.sort(key=lambda c: comp_scores[c], reverse=True)
    if not fired:
        out["component"] = ["config"]           # most tickets are config; flag low-confidence
        out["component_source"] = "router-default"
    elif len(fired) == 1:
        out["component"] = fired; out["component_source"] = "router"
    else:
        out["component"] = fired[:2] + (["hybrid"] if len(fired) > 1 else [])
        out["component"] = ["hybrid"] + fired[:2]
        out["component_source"] = "router"

    # environment
    env = None
    for e, pats in ENV_SIGNALS.items():
        if _hits(text, pats):
            env = e; break
    out["environment"] = env or "unknown"

    # a routing-confidence flag (not the full confidence score — that's later)
    out["routing_note"] = []
    if type_scores.get(out["type"], 0) <= 1 and out.get("type_source") != "jira-issuetype":
        out["routing_note"].append("weak type signal — confirm with reporter")
    if out["component_source"] == "router-default":
        out["routing_note"].append("no component signal — defaulted to config; confirm")
    if out["environment"] == "unknown":
        out["routing_note"].append("environment not stated — ask")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--title", default="")
    ap.add_argument("--body", default="")
    ap.add_argument("--issuetype", default=None)
    ap.add_argument("--stdin", action="store_true")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    if a.stdin:
        a.body = sys.stdin.read()
    r = route(a.title, a.body, a.issuetype)
    if a.json:
        print(json.dumps(r, indent=1))
    else:
        print(f"client={r['client']}  type={r['type']} ({r['type_source']})")
        print(f"component={r['component']} ({r['component_source']})")
        print(f"environment={r['environment']}")
        if r["routing_note"]:
            print("notes: " + "; ".join(r["routing_note"]))


if __name__ == "__main__":
    main()
