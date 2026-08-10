#!/usr/bin/env python3
"""
Deterministic confidence scoring for a ticket triage state.

NOT the LLM saying "90%". A 0-100 score COMPUTED from countable facts in
state.json, with a line-item breakdown so it's inspectable and tunable.
The bands drive behavior (see WORKFLOW in the triage skill):

  <40  insufficient   -> DO NOT propose a fix; gather the missing evidence
  40-69 plausible      -> confirm by running the listed checks
  70-89 evidence-backed-> cite-complete; safe to propose, human approves
  90+  confirmed       -> a check was RUN that proves the root cause

Usage:
  python3 confidence.py <state.json>        # prints score + breakdown
  python3 confidence.py <state.json> --json # machine-readable
Weights live in WEIGHTS below — tune them from real outcomes (that is the
learning loop). Change weights, re-score past tickets, compare.
"""
import argparse, json, sys
from pathlib import Path

# --- tunable weights (the fine-tuning surface) ------------------------------
WEIGHTS = {
    "requirement_confirmed":      15,   # reporter agreed we understand the ask
    "type_not_guessed":           5,    # classification.type_source != guess
    "component_not_guessed":      5,
    "environment_known":          5,
    "prior_art_found":            8,    # a matching solution note/ticket
    "each_resolved_evidence":     4,    # per resolved citation (cap below)
    "root_cause_has_citations":   15,   # root cause backed by >=1 resolved evidence
    "root_cause_confirmed_run":   25,   # a check was EXECUTED (query/lineage/config-verify)
    "required_evidence_received": 8,    # all matrix-required evidence is back
    "validation_all_pass":        10,   # validation checks executed and passed
    # penalties (negative)
    "penalty_unresolved_entity": -6,    # per evidence marked resolved=false but used
    "penalty_inferred_claim":    -2,    # per 'inferred' (not observed) claim, capped
    "penalty_missing_requirement": -30, # requirement not confirmed = cannot be confident
    "penalty_missing_required_evidence": -10,
}
CAP_RESOLVED_EVIDENCE = 24   # max points from raw evidence count (avoid gaming)
CAP_INFERRED_PENALTY  = -10


def score(state: dict):
    b = []                     # breakdown lines
    pts = 0
    def add(key, times=1, note=""):
        nonlocal pts
        v = WEIGHTS[key] * times
        pts += v
        b.append(f"{'+' if v>=0 else ''}{v:>4}  {key}{('  '+note) if note else ''}")
        return v

    cls = state.get("classification", {}) or {}
    req = state.get("requirement", {}) or {}
    ev  = state.get("evidence", []) or []
    rc  = state.get("root_cause", {}) or {}
    val = state.get("validation", {}) or {}
    reqd = state.get("requested_evidence", []) or []

    # requirement understanding — the MAIN thing
    if req.get("confirmed"):
        add("requirement_confirmed")
    else:
        add("penalty_missing_requirement", note="requirement NOT confirmed by reporter")

    # classification grounded, not guessed
    if cls.get("type_source") in ("jira-issuetype", "router", "reporter-confirmed"):
        add("type_not_guessed")
    if cls.get("component_source") in ("router", "system-map", "reporter-confirmed"):
        add("component_not_guessed")
    if cls.get("environment") and cls["environment"] != "unknown":
        add("environment_known")

    # prior art
    if state.get("prior_art"):
        add("prior_art_found", note=f"{len(state['prior_art'])} match(es)")

    # evidence quality
    resolved = [e for e in ev if e.get("resolved")]
    n_res = min(len(resolved), CAP_RESOLVED_EVIDENCE // WEIGHTS["each_resolved_evidence"])
    if n_res:
        add("each_resolved_evidence", n_res, note=f"{len(resolved)} resolved citations")
    unresolved_used = [e for e in ev if e.get("resolved") is False]
    if unresolved_used:
        add("penalty_unresolved_entity", len(unresolved_used),
            note=f"{len(unresolved_used)} claims cite unretrieved things")
    inferred = [e for e in ev if e.get("observed_or_inferred") == "inferred"]
    if inferred:
        p = max(CAP_INFERRED_PENALTY, WEIGHTS["penalty_inferred_claim"] * len(inferred))
        pts += p; b.append(f"{p:>5}  penalty_inferred_claim  ({len(inferred)} inferred)")

    # root cause grounding
    rc_refs = rc.get("evidence_refs") or []
    rc_cited = any(0 <= i < len(ev) and ev[i].get("resolved") for i in rc_refs)
    if rc.get("statement") and rc_cited:
        add("root_cause_has_citations")
    if rc.get("confirmed_by_execution"):
        add("root_cause_confirmed_run", note="a check was executed")

    # required evidence (from the matrix) received
    if reqd:
        missing = [r for r in reqd if r.get("status") == "requested"]
        if not missing:
            add("required_evidence_received")
        else:
            add("penalty_missing_required_evidence",
                note=f"{len(missing)} required item(s) still outstanding")

    # validation
    results = val.get("results") or []
    if results and all(r.get("verdict") == "pass" for r in results):
        add("validation_all_pass")

    raw = pts
    clamped = max(0, min(100, raw))
    band = ("confirmed" if clamped >= 90 else
            "evidence-backed" if clamped >= 70 else
            "plausible" if clamped >= 40 else "insufficient")
    return clamped, band, b, raw


BAND_ACTION = {
    "insufficient": "DO NOT propose a fix. Gather the missing evidence first.",
    "plausible": "Plausible — confirm by RUNNING the listed checks before proposing.",
    "evidence-backed": "Evidence-backed. Safe to propose; human approves the gate.",
    "confirmed": "Confirmed by execution. Proceed.",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("state")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    state = json.loads(Path(a.state).read_text())
    sc, band, breakdown, raw = score(state)
    if a.json:
        print(json.dumps({"score": sc, "band": band, "raw": raw,
                          "action": BAND_ACTION[band], "breakdown": breakdown}, indent=1))
    else:
        print(f"CONFIDENCE: {sc}/100  [{band}]  (raw {raw})")
        print(f"ACTION: {BAND_ACTION[band]}\n")
        print("breakdown:")
        for line in breakdown:
            print("  " + line)

if __name__ == "__main__":
    main()
