# Triage Engine — deterministic backbone for ticket work

Goal: shrink the LLM's trust surface. The LLM reads the ticket, fills a
structured **state** and chooses among **enumerated** options; **code**
does the parts that hallucinate — routing facts, scoring confidence,
gating. A generic agent handed this repo succeeds because the steps are
scripted and the facts live in tools/files, not the model's weights.

## Pieces

| File | Role |
|---|---|
| `state.schema.json` | The ticket state = the reasoning map + grounding contract. Agent fills it stage by stage. Every claim needs a resolvable `locator` or is marked inferred/unknown. Lives per ticket at `tickets/<ID>/state.json`. |
| `route.py` | **Deterministic** classifier: ticket text → `type / component[] / environment`, each with a `source`. Seeds `state.json` classification. `python3 route.py --title … --body … [--issuetype Bug]` |
| `newticket.sh` | Workspace automation: `tickets/<ID>/`, clone the right repo+branch per `repos.json`, cut a ticket branch, print the env's OCI sync, seed `state.json`. `newticket.sh <SUP-ID> <CID> <component> [env]` |
| `confidence.py` | **Deterministic** 0-100 confidence from the state, with a line-item breakdown + band. Tunable weights = the learning surface. `python3 confidence.py tickets/<ID>/state.json` |
| `evidence-matrix.md` | Decision table: `(type × component) → required evidence + exact commands`. A lookup, not a judgment. |
| `trace.py` | Renders the state two ways: a human **reasoning/debug trace** (default) and a **solution-note draft** (`--note`, resolved evidence only, per TEMPLATE.md → `knowledge/solutions/<ID>.md`). |
| `learn.py` | **Persist a user-supplied fact** with provenance so it survives the session → `customers/<CID>/captured-knowledge.md` or `knowledge/captured-knowledge.md`. `learn.py --client TRD --category gotcha --fact "…" --source SUP-####` |

## How the agent uses it (the loop)

1. **Fill classification** from the router/Jira (never "guessed").
2. **Confirm the requirement** with the reporter — gate: analysis can't
   proceed while `requirement.confirmed=false`.
3. **Look up the evidence-matrix cell**, record `requested_evidence[]`,
   ask for it in ONE batched request; run self-serve items (lineage/DB).
4. **Record every fact in `evidence[]`** with a resolvable `locator` and
   `resolved`/`observed_or_inferred`. No uncited facts. No recalled names —
   resolve entities via the lineage/db tools.
5. **Score**: run `confidence.py`. The BAND dictates behavior:
   - <40 insufficient → do NOT propose a fix; gather what's missing.
   - 40-69 plausible → confirm by RUNNING the listed checks.
   - 70-89 evidence-backed → propose; human approves.
   - 90+ confirmed → a check was executed; proceed.
6. **Root-cause gate** = requirement confirmed + all required evidence
   received + root cause cites ≥1 resolved evidence. (confidence enforces.)
7. **Fix / validate / retro** as the workflow, updating the state. At retro:
   run `trace.py --note` to draft the solution note, and `learn.py` to
   persist any durable fact the reporter/user gave you (both close the loop
   so the next ticket inherits this one's knowledge).

## Full command path (a ticket, start to finish)

    route.py            # classify from text -> seeds classification
    newticket.sh        # folder + repo/branch + OCI + state.json
    …fill state.json…   # requirement (confirm!), evidence (cited), hypotheses
    confidence.py       # score -> obey the band
    trace.py            # debug view while investigating
    trace.py --note     # at retro: solution-note draft
    learn.py            # persist any user-given fact with provenance

## Progressive disclosure (precision rule)

Default reply = **SUMMARY only**: the answer, the confidence score+band,
and the top 2-3 cited evidence lines. Nothing else. Everything deeper
(full evidence list, ruled-out hypotheses, the lineage walk, the exact
queries) lives in the state and is shown ONLY when the user asks
("expand", "show evidence", "why"). Exception — auto-surface to the
summary: anything that BLOCKS the gate (missing required evidence) or a
HIGH-RISK change (blast radius large). Keep it precise; depth on demand.

## Debug / fine-tune loop

`tickets/<ID>/state.json` IS the debug trace — every decision, hypothesis
(incl. ruled-out), evidence, and the score breakdown. To improve the
system: re-score past tickets after changing `confidence.py` WEIGHTS or the
evidence-matrix, and compare bands against the actual outcome. Wrong
routing → fix the router rules; over/under-confident → tune weights.

## Techno-functional output (mandatory on resolve)

`state.knowledge_gained` requires BOTH:
- **technical** — the code/data/config mechanism.
- **functional** — the retail business meaning (what the metric/screen/rule
  means to a planner).
The retro (`ticket-retro`) copies these into the solution note.
