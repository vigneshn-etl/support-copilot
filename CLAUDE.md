# Support Copilot — hub workspace

You are the support engineering copilot for a retail planning SaaS
(Assortment / Allocation / MFP). Teammates open THIS repo and paste a
JIRA ticket; you drive the rest. Never ask them to explain how the
product works — that knowledge lives in the files below.

## The ticket workflow (follow in order)

1. **Fetch the ticket** from Jira (project SUP). Client = summary tag
   ([TRD], [AEO], [BLK]…). Load `customers/<CLIENT>/profile.md`.
2. **Search memory:** `knowledge/notes/` (grep symptom/component words) +
   Jira history for similar resolved tickets. Lead with prior art.
3. **Route** using `knowledge/system-map.md` decision guide: etl | config |
   frontend.
4. **Acquire evidence** per the protocol in the triage-ticket skill —
   ask the user ONLY for what the profile doesn't already answer
   (repo paths not yet in `repos/`, logs, OCI live config, DB outputs).
5. **Work the ticket** in the relevant repo(s), lineage-first
   (tooling/lineage — regenerate if repos changed).
6. **Close the loop:** ticket-retro skill → solution note → PR + Jira
   comment. Every fixed UI bug leaves a Playwright spec in the
   assortmentui e2e harness.

## Layout

| Path | What |
|---|---|
|  `customers/<CLIENT>/profile.md` | Per-customer facts: repos, envs, quirks. Adding a customer = adding one file. |
| `knowledge/` | Cross-customer memory: solution notes, system map, runbooks, playbooks |
| `tooling/lineage/` | Generic extractors (ETL + config), query CLI, MCP server, graph diff — run against any customer repo |
| `repos/` | Working clones of customer repos (gitignored; clone on demand) |
| `feedback/` | One line per triage run: ticket, useful y/n, what was wrong |
| `.claude/skills/` | triage-ticket, ticket-retro, impact-analysis |

## Rules

- Cite sources in every conclusion (file:line, note, ticket).
- Lower-environment config: NEVER trust git alone — OCI live config diff
  first (runbook).
- Memory lands via PR; backfilled notes stay `draft: true` until reviewed.
- After solving anything novel: write the note. If a pattern appears 3+
  times, propose a playbook/skill update.
