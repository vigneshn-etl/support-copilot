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
