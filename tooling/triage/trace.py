#!/usr/bin/env python3
"""
Reasoning-trace + solution-note writer.

state.json IS the debug trace; this renders it two ways:

  (default)  a human-readable REASONING TRACE — the debug/fine-tune view:
             every stage, hypothesis (incl. ruled-out), each evidence line
             with a resolved/inferred marker, the root cause, and the
             confidence breakdown. This is what you read to see WHY the
             engine concluded what it did.

  --note     a SOLUTION NOTE draft (knowledge/solutions/<ID>.md, per
             TEMPLATE.md) built ONLY from resolved evidence + the mandatory
             techno-functional knowledge_gained. Closes the loop: a worked
             ticket becomes reusable prior_art for the next one.

Usage:
  python3 trace.py tickets/<ID>/state.json            # print trace
  python3 trace.py tickets/<ID>/state.json --note     # write solution note
  python3 trace.py tickets/<ID>/state.json --note --stdout   # print, don't write
"""
import argparse, json, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
HUB = HERE.parent.parent


def _load_confidence():
    """Reuse the deterministic scorer so the trace shows the same number."""
    sys.path.insert(0, str(HERE))
    import confidence
    return confidence


def marker(e):
    if not e.get("resolved"):
        return "UNRESOLVED"
    return "observed" if e.get("observed_or_inferred") == "observed" else "inferred"


def render_trace(st):
    conf = _load_confidence()
    sc, band, breakdown, raw = conf.score(st)
    L = []
    L.append(f"REASONING TRACE  {st.get('ticket')}  ({st.get('client','?')})   stage={st.get('stage')}")
    L.append("=" * 72)

    cls = st.get("classification", {})
    L.append(f"CLASSIFICATION  type={cls.get('type')} ({cls.get('type_source')})  "
             f"component={cls.get('component')} ({cls.get('component_source')})  "
             f"env={cls.get('environment')}")

    req = st.get("requirement", {})
    gate = "CONFIRMED" if req.get("confirmed") else "NOT CONFIRMED (gate blocks analysis)"
    L.append(f"\nREQUIREMENT [{gate}]")
    L.append(f"  {req.get('statement','(none)')}")
    if req.get("acceptance"):
        L.append(f"  acceptance: {req['acceptance']}")

    pa = st.get("prior_art", [])
    if pa:
        L.append("\nPRIOR ART")
        for p in pa:
            L.append(f"  - {p.get('ref')}: {p.get('why_relevant','')}")

    ev = st.get("evidence", [])
    if ev:
        L.append("\nEVIDENCE  (index: [marker] kind — claim @ locator)")
        for i, e in enumerate(ev):
            L.append(f"  [{i}] [{marker(e)}] {e.get('kind')} — {e.get('claim','')}")
            if e.get("locator"):
                L.append(f"        @ {e['locator']}")

    rq = st.get("requested_evidence", [])
    if rq:
        L.append("\nREQUESTED EVIDENCE (matrix)")
        for r in rq:
            L.append(f"  - [{r.get('status')}] {r.get('item')}"
                     + (f"   `{r['command']}`" if r.get("command") else ""))

    hy = st.get("hypotheses", [])
    if hy:
        L.append("\nHYPOTHESES  (the diagnosis path — ruled-out included)")
        for h in hy:
            tag = h.get("status", "?").upper()
            L.append(f"  - [{tag}] {h.get('cause','')}  refs={h.get('evidence_refs',[])}")
            if h.get("status") == "ruled_out" and h.get("ruled_out_because"):
                L.append(f"        ruled out: {h['ruled_out_because']}")

    rc = st.get("root_cause", {})
    if rc.get("statement"):
        run = "RUN-CONFIRMED" if rc.get("confirmed_by_execution") else "reasoned only"
        L.append(f"\nROOT CAUSE  [{run}]  refs={rc.get('evidence_refs',[])}")
        L.append(f"  {rc['statement']}")

    kg = st.get("knowledge_gained", {})
    if kg.get("technical") or kg.get("functional"):
        L.append("\nKNOWLEDGE GAINED (techno-functional)")
        if kg.get("technical"):  L.append(f"  technical:  {kg['technical']}")
        if kg.get("functional"): L.append(f"  functional: {kg['functional']}")

    L.append("\n" + "-" * 72)
    L.append(f"CONFIDENCE {sc}/100  [{band}]  (raw {raw})")
    L.append(f"ACTION: {conf.BAND_ACTION[band]}")
    for line in breakdown:
        L.append("  " + line)
    return "\n".join(L)


def render_note(st):
    """Solution note per knowledge/TEMPLATE.md — resolved evidence only."""
    conf = _load_confidence()
    sc, band, _, _ = conf.score(st)
    cls = st.get("classification", {})
    req = st.get("requirement", {})
    ev = st.get("evidence", [])
    rc = st.get("root_cause", {})
    kg = st.get("knowledge_gained", {})
    fix = st.get("fix", {})
    val = st.get("validation", {})
    resolved = [e for e in ev if e.get("resolved")]

    fm = [
        "---",
        f"ticket: {st.get('ticket')}",
        f"title: {req.get('statement','')[:80]}",
        f"client: {st.get('client','')}",
        f"type: {cls.get('type','')}",
        f"repos: {json.dumps(cls.get('component', []))}",
        f"environment: {cls.get('environment','')}",
        f"confidence: {sc}/100 ({band})",
        "draft: true            # generated from state.json — human review before trusting",
        "---", "",
    ]
    body = ["## Problem", "", req.get("statement", "(none)"), ""]
    if req.get("acceptance"):
        body += [f"**Acceptance:** {req['acceptance']}", ""]

    body += ["## Diagnosis path", ""]
    for h in st.get("hypotheses", []):
        if h.get("status") == "ruled_out":
            body.append(f"- Suspected: {h.get('cause','')} — ruled out: {h.get('ruled_out_because','')}")
        elif h.get("status") == "confirmed":
            body.append(f"- **Confirmed:** {h.get('cause','')}")
        else:
            body.append(f"- Considered: {h.get('cause','')}")
    body.append("")
    if rc.get("statement"):
        run = " (confirmed by execution)" if rc.get("confirmed_by_execution") else ""
        body += [f"**Root cause{run}:** {rc['statement']}", ""]

    body += ["## Evidence (resolved)", ""]
    for e in resolved:
        body.append(f"- {e.get('claim','')}")
        if e.get("locator"):
            body.append(f"  - `{e['locator']}`")
    body.append("")

    body += ["## Fix", ""]
    for c in fix.get("changes", []) or ["(not recorded)"]:
        body.append(f"- {c}")
    if fix.get("branch"): body.append(f"- branch: `{fix['branch']}`")
    if fix.get("pr"):     body.append(f"- PR: {fix['pr']}")
    body.append("")

    body += ["## Verification", ""]
    for p in val.get("plan", []) or []:
        body.append(f"- {p}")
    for r in val.get("results", []) or []:
        body.append(f"- [{r.get('verdict')}] {r.get('check')} — {r.get('proof','')}")
    if not (val.get("plan") or val.get("results")):
        body.append("(none recorded)")
    body.append("")

    body += ["## Knowledge gained (techno-functional — required)", ""]
    body += [f"**Technical:** {kg.get('technical','(MISSING — fill before publishing)')}", ""]
    body += [f"**Functional:** {kg.get('functional','(MISSING — fill before publishing)')}", ""]
    return "\n".join(fm + body)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("state")
    ap.add_argument("--note", action="store_true", help="render a solution-note draft")
    ap.add_argument("--stdout", action="store_true", help="with --note: print instead of write")
    a = ap.parse_args()
    st = json.loads(Path(a.state).read_text())

    if not a.note:
        print(render_trace(st)); return

    md = render_note(st)
    if a.stdout:
        print(md); return
    out = HUB / "knowledge" / "solutions" / f"{st.get('ticket')}.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(md)
    print(f"wrote {out}  (draft — review the two knowledge_gained halves before trusting)")


if __name__ == "__main__":
    main()
