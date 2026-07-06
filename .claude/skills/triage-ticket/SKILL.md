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
