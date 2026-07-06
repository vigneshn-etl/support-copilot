# AI-Assisted Support Engineering — Build Plan

**Vision:** every JIRA ticket gets triaged against the team's full memory
(code, lineage, past solutions, client quirks) in minutes; every resolved
ticket makes the system smarter. Built as composable git assets — skills,
MCP servers, knowledge files, CI jobs — not a monolithic platform. Each
piece works standalone; together they form the platform.

---

## Phase 1 — Foundation (DONE, built this week)

| Asset | Where | What it does |
|---|---|---|
| Lineage extractor | `lineage/extract.py` | Parses all .sh/.sql, stitches cross-DB file hand-offs → `graph.json` (1,025 nodes / 1,712 edges, 99.4% parse rate) |
| Coverage gate | `lineage/coverage.json` | CI fails if parse rate < 99% — graph can never silently rot |
| Interactive explorer | `lineage/lineage.html` | Search any table, walk upstream/downstream, click-to-expand |
| Query CLI | `lineage/query.py` | `find / upstream / downstream / impact / path / stats` |
| Lineage MCP server | `lineage/mcp_server.py` + `.mcp.json` | Any Claude surface can query lineage as tools; auto-registered on repo open |
| PR diff tool | `lineage/diff.py` | Data-impact report for PRs (new/removed edges + transitively affected tables) |
| Knowledge base | `knowledge/` | Solution notes (1 per resolved ticket), system map, template; 3 seed notes backfilled from SUP |
| Skills | `.claude/skills/` | `impact-analysis`, `triage-ticket`, `ticket-retro` |
| Repo context | `CLAUDE.md` | Conventions + "lineage graph is source of truth" |

**Validated:** trial triage of SUP-4202 found the probable root cause
(viewdefn CC-count formula summing week-grain rows; 136 × 52 ≈ 7,068)
in minutes, citing prior art from seed notes SUP-4210 and SUP-4230.

## Phase 2 — Team adoption (next 2–4 weeks)

1. **Commit + wire CI** — push `lineage/`, `knowledge/`, `.claude/`,
   `.mcp.json`; enable the two GitHub Actions in `lineage/README.md`
   (regen-on-merge with coverage gate; PR data-impact comment).
2. **Connect the other two repos** — config layer + frontend get a
   CLAUDE.md each; fill the contracts section of `system-map.md`
   (ETL tables → screens, viewdefns → grids, config keys → batch behavior).
   Config repo is priority: most client tickets resolve there.
3. **Extract `knowledge/` into its own repo** shared by all three product
   repos. Add `knowledge/clients/<CLIENT>.md` profiles (env URLs, repos,
   id conventions, structural traps like AEO subsidiaries). Seed TRD/BLK/AEO
   from existing notes.
4. **Conventions** — ticket IDs mandatory in branch names + commit messages
   (links tickets ↔ diffs; the estimation and reuse features depend on it).
5. **Backfill memory** — batch-summarize ~100 recent closed SUP tickets
   into draft notes (same method as the 3 seeds); owners review, drop
   `draft: true`.
6. **Onboard the team** — each engineer: Claude seat, Atlassian connector
   auth, clone repos, 30-min demo (triage → work → retro on a live ticket).
7. **Baseline metrics** — time-to-triage, prior-art hit rate,
   time-to-resolution, assignee usefulness rating on triage output.

## Phase 3 — Deeper capabilities (1–2 months)

- **Drift detection** — scheduled job exports live state (SHOW CREATE TABLE
  from Vertica/PG/CH, live viewdefns) and diffs vs repo; weekly report.
  Fixes the "manual hotfix not in git" blind spot and pushes hotfixes back
  into the repo culturally.
- **Read-only QA database MCP** — Vertica/PG/CH with read-only creds, row
  limits, QA-only allowlist. Turns "probable root cause" into "confirmed"
  without asking the reporter to run queries.
- **Log access** — start with paste-into-chat (triage skill already asks);
  upgrade to an MCP that greps QA batch-host logs.
- **Estimation** — `effort:` field in notes + blast-radius size → grounded
  estimates for backlog grooming.

## Phase 4 — Autonomy ladder (earn each rung)

1. **Auto-triage** — Jira webhook: new SUP ticket → agent posts triage
   comment (prior art, routing, plan, questions) before anyone picks it up.
2. **Draft PRs** — for patterns with 3+ solved precedents.
3. **Consolidation agent** — weekly: cluster notes, promote recurring
   patterns to `knowledge/playbooks/` and skill updates, flag recurring
   defects as product-backlog signals.
4. **UI verification** — browser agent reproduces frontend tickets in QA.

## How it's used — the daily loop

- **Pick up ticket:** "triage SUP-1234" → prior art from notes, owning
  repo/team, ordered diagnosis plan, questions for reporter. Optionally
  posted as a Jira comment.
- **Before changing anything:** "what breaks if I change X" → blast radius
  with every script to review (lineage MCP).
- **Open PR:** CI comments the data impact (edge diff) automatically.
- **Close ticket:** "retro" → solution note committed, Jira comment posted,
  recurring-pattern check.
- **Onboarding/cross-team:** anyone asks "where does this table come from"
  or "whose bug is this" and gets a grounded, cited answer.

## Why it's useful

- **Engineers:** minutes instead of hours to first solid hypothesis; never
  re-diagnose a solved problem; blast radius known before every change.
- **Leads:** grounded estimates, recurring-defect visibility, PR review
  focused on data impact.
- **Between teams:** every ticket routed to the owning repo with evidence,
  not opinion.
- **The org:** tribal knowledge survives attrition; every client benefits
  from every other client's resolved issues.

## Guardrails (quality bar)

- Every agent answer must cite sources (script:line, note, ticket).
- All memory lands via PR — reviewed, versioned, revertible.
- Human approves every code change and every Jira comment (until Phase 4,
  rung by rung).
- Coverage/drift gates keep derived knowledge honest.
- If metrics don't improve by Phase 3, stop and reassess — the numbers
  decide, not the enthusiasm.
