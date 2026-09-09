---
name: triage-ticket
description: >
  Triage a JIRA ticket (SUP project): classify it, find prior solutions,
  identify the owning repo/team, and propose a diagnosis plan. Use when the
  user mentions a SUP-#### ticket, says "triage", "pick up this ticket",
  "new ticket", "look at this bug", or pastes a ticket description.
---

# Triage a ticket

## 1. Pull the ticket
Fetch the JIRA issue (Atlassian MCP), including comments. Note the client
tag in the summary ([TRD], [AEO], [BLK], [EE], [GAP], [KW]…) and issue type.

## 2. Search memory FIRST — never re-diagnose a known problem
- `grep -ril "<symptom keywords>" knowledge/notes/` — read any hits fully.
- Search JIRA for similar resolved tickets:
  `project = SUP AND statusCategory = Done AND text ~ "<keywords>"`.
- If a prior note matches, lead your answer with it: "SUP-XXXX solved this
  same symptom — root cause was …, check that first."

## 3. Classify and route
Read `knowledge/system-map.md` (decision guide) to determine the owning
repo: etl | config | frontend. State the routing explicitly — this is what
makes triage useful between teams.

## 4. Follow the playbook for the type
**Bug / data-issue (ETL):**
- Ask the user for: exact table/metric/screen, client, batch date, and
  application logs if a UI error is involved. Don't guess what you can ask.
- Use lineage tools (lineage_upstream / lineage_impact) on the suspect
  tables. Read the provenance scripts to reason about the transform.
**Config:** identify the viewdefn/metric/config key involved; ask for the
view name and expected vs actual.
**Feature/change:** run lineage_impact on touched tables, list all repos
involved, surface similar past changes from notes.
**Deploy/chore:** find the matching runbook note (e.g. constant-table
deploys recur weekly — there should be a note; if none exists, say so and
create one after).

## 5. Output format
- **Prior art:** matching notes/tickets, or "none found".
- **Routing:** owning repo/team + why (one line).
- **Diagnosis plan:** ordered steps with the specific tables/files/queries.
- **Questions for reporter:** only what's actually needed.
- Offer to post this as a JIRA comment on the ticket.

## 6. If you end up doing the work
When the ticket is resolved, invoke the ticket-retro skill — the session
must end with a solution note in knowledge/notes/.

## Evidence acquisition protocol

Never ask for evidence generically — request exactly what the issue type
needs, and fetch what you can yourself:

| Issue smell | Evidence to acquire | How |
|---|---|---|
| Wrong/missing data, all screens | lineage upstream + batch flow logs for the flow (`flows` field on edges) | lineage MCP; ask user for batch log if needed |
| Metric wrong on SOME views (QA/staging) | **live config from OCI, diffed vs repo** | knowledge/runbooks/fetch-live-config.md |
| Metric wrong on SOME views (prod) | repo viewdefn/pivot diff vs sibling metric | config repo + combined lineage |
| UI behavior (refresh/filter/click) | repro via browser; ticket Looms/screenshots | knowledge/runbooks/ui-repro.md |
| Data right in DB, wrong on screen | pivot SQL grain check (bottomLevels) + viewdefn formula | trd-configs lineage + CLAUDE.md traps |
| Inbound/load failure | reject exports, intermediate export files (line vs record count) | see note SUP-4254 |

Rules:
- For QA/staging config issues, NEVER trust the repo alone — run the live
  config diff first (manual changes are common).
- Every UI bug that gets fixed should leave behind a Playwright spec named
  SUP-XXXX.spec.ts in the assortmentui e2e harness.

## Workflow contract (see knowledge/workflow.md)

This skill executes stages 1–5: INTAKE → CLASSIFY → SCOPE → INVESTIGATE →
ROOT-CAUSE GATE. Draft JIRA writes at each stage (labels cc-<type>,
cc-layer:<x>, cc-triaged; evidence-request and root-cause comments) and
ask the user to approve posting. The root-cause comment must include the
validation plan sketch — hand off to the validate-fix skill for stages
6–7 and ticket-retro for stage 8. No fix work before the root-cause gate
passes with cited evidence.

## Intake dialogue (run FIRST, before any analysis)

Behave like a guided bot. Collect these in AT MOST two question turns,
prefilling everything derivable and asking only for confirmation:

1. **Ticket** — the only free-text input. If the user's message already
   contains SUP-####, don't ask.
2. **Type** — options: Bug | Enhancement/Task. PREFILL from the Jira
   issue type + description; ask user to confirm/correct.
3. **Component** — options: ETL | Config | Software (UI/backend) |
   Hybrid. PREFILL from system-map decision guide; confirm/correct.
4. **Customer** — PREFILL from the summary tag ([TRD]...); only ask if
   missing/ambiguous.
5. **Code source** — read `customers/<CLIENT>/repos.json` (repo + branch
   per layer). Then ask: "Use the git repo (branch <X> — may drift from
   the environment) or environment-specific code from OCI?" If OCI:
   check knowledge/runbooks/fetch-live-config.md — if the commands are
   still TODO, say exactly: "OCI access commands are not configured yet
   — proceeding with git ref; flag me if this issue is
   environment-specific." Never silently pick.

Then proceed to INVESTIGATE. During investigation, when evidence is
needed that only the user has (runtime logs, screenshots, network
responses, DB query output), ASK for the specific artifact — name the
exact log file/host or the exact SQL — one batched request, not a drip.

Rules: never re-ask something answered earlier in the session; never ask
what Jira already says (confirm instead); if the user pre-answers
everything in one message, skip straight to analysis.

## Triage engine (deterministic backbone — tooling/triage/)

Work every ticket through a structured **state** file, not free prose. This
shrinks hallucination: the LLM fills the state + picks enumerated options;
code scores and gates.

0. **Spin up the workspace**: classify the text with
   `tooling/triage/route.py` (gives type/component/env + source), then
   `tooling/triage/newticket.sh <SUP-ID> <CID> <component> [env]` — clones
   the right repo+branch per `repos.json`, cuts a ticket branch, prints the
   env's OCI sync, seeds `state.json`.
1. **Complete `tickets/<SUP-ID>/state.json`** against
   `tooling/triage/state.schema.json`. Fill `classification` from route.py —
   mark the SOURCE (jira-issuetype / router / reporter-confirmed), never
   "guessed".
2. **Confirm the requirement** (`requirement.confirmed`) with the reporter
   before analysis. This is the MAIN understanding — echo it back, get yes.
3. **Look up `tooling/triage/evidence-matrix.md`** for the (type × component)
   cell → record `requested_evidence[]`, ask for it in ONE batched request,
   run the self-serve items (lineage/DB).
4. **Record every fact in `evidence[]`** with a resolvable `locator` +
   `resolved` + observed/inferred. NEVER state a fact you didn't retrieve;
   NEVER type an entity name you didn't resolve via the lineage/db tools.
5. **Score**: `python3 tooling/triage/confidence.py tickets/<ID>/state.json`.
   Obey the band: <40 gather more (no fix); 40-69 run checks to confirm;
   70-89 propose; 90+ proceed. The score is the gate, not your feeling.

## Output discipline (precision / progressive disclosure)

Default reply = SUMMARY only: the answer + `confidence score [band]` + the
top 2-3 cited evidence. Nothing more. Full evidence, ruled-out hypotheses,
lineage walks, exact queries live in state.json and are shown ONLY on
request ("expand" / "show evidence" / "why"). Auto-surface to summary ONLY:
missing required evidence (gate blocker) or a large blast radius. Precise
first; depth on demand.

## Always end with (techno-functional) — and SHOW it

Populate `state.knowledge_gained.technical` AND `.functional` (retail
business meaning), and **display both in the chat at ticket close** (an
explicit exception to summary-only), labelled:

> **Learned**
> · **Technical:** <mechanism>
> · **Functional (retail):** <what it means to a planner>

**Display is the user's choice** (`modes/settings.json` `learning_display`,
overridable in chat): `coach` = one-line `📎 learned — technical: … ·
functional: …` per notable step + full pair at close; `end` (default) = full
pair at close only; `quiet` = don't show, still captured, offer at close.
CAPTURE to `knowledge_gained` + the solution note happens every time regardless
of display — we are techno-functional consultants.

## At retro (close the loop — code, not memory)

- `python3 tooling/triage/trace.py tickets/<ID>/state.json --note` → drafts
  the solution note (resolved evidence + techno-functional) into
  `knowledge/solutions/<ID>.md`. Review the two `knowledge_gained` halves,
  flip `draft:` when a human confirms.
- If the reporter/user gave a durable fact this ticket, persist it:
  `python3 tooling/triage/learn.py --client <CID> --category <cat> --fact
  "…" --source <SUP-ID>` → `captured-knowledge.md`. Next ticket inherits it.
- Use `trace.py` (no `--note`) any time as the **debug view** — it shows the
  full reasoning map + the confidence breakdown that produced the band.

## Assistance mode (keep yourself sharp — tooling/triage/MODES.md)

Pick a mode at intake, record it in `state.mode` (default `pair`):
- **tutor** — YOU author each decision + every SQL/config change; the agent
  reviews/critiques and does NOT hand you a finished query unless you ask. It
  runs predict-the-score before revealing confidence.
- **pair** — agent proposes with reasoning; you approve/redirect.
- **autopilot** — agent runs the whole loop (tickets you don't need to learn from).

At close-out, regardless of mode: `tooling/learning/skill_ledger.py log` what
you actually did (authored/reviewed/accepted/cold), and
`tooling/learning/flashcards.py due` to drill what this ticket taught.

## ClickHouse questions → clickhouse-docs MCP

For any ClickHouse semantics/error question during triage (function behavior,
engine/FINAL, aggregation combinators, DB::Exception, settings), consult the
`clickhouse-docs` MCP instead of recalling — cite the doc as evidence, and
confirm the behavior on the customer's version with
`tooling/validation/ch_validate.py` (fleet is mostly 21.4). Docs inform
reasoning only; never wire them into the deterministic query composer.
