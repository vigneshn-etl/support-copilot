# Support Copilot

AI-assisted support engineering for our retail planning products
(Assortment / Allocation / MFP). Clone this repo, open it with Claude
(Cowork or Claude Code), paste a JIRA ticket — Claude triages it against
our collected knowledge: past solutions, lineage graphs, customer
profiles, and debugging runbooks.

## Quick start (one-time, ~5 minutes)

1. **Clone** this repo and open the folder in **Cowork** (select folder)
   or **Claude Code** (`cd support-copilot && claude`).
2. **Connect Jira**: enable the Atlassian connector in Claude settings
   (your own Atlassian login).
3. **Python deps** (for lineage tooling): `pip install sqlglot`.
4. Optional: clone the customer repos you work on into `repos/`
   (gitignored) — see `customers/<CLIENT>/profile.md` for which repos.

Claude reads `CLAUDE.md` automatically when the folder is opened — you do
NOT need to explain anything about how our ETL/config/frontend works.
Skills (triage, retro, impact-analysis) and the lineage MCP server
register automatically from `.claude/skills/` and `.mcp.json`.

## Starting a conversation

Just state the ticket — the workflow in CLAUDE.md takes over:

- `Triage SUP-4310`
- `New ticket SUP-4321, [AEO] metric wrong in Style Review — start`
- `What breaks if we change trd_h_prodstd?` (impact analysis)
- `Where does the CC count on Style Review Summary come from?` (lineage)
- `We just fixed SUP-4310 — write the retro` (capture the solution)

If Claude ever seems unaware of the setup, say:
`Read CLAUDE.md and follow the ticket workflow for SUP-XXXX.`

## What's in here

| Path | What |
|---|---|
| `CLAUDE.md` | The agent's operating manual — ticket workflow + rules |
| `knowledge/notes/` | One solution note per resolved ticket (searchable memory) |
| `knowledge/system-map.md` | Which repo/team owns which kind of issue |
| `knowledge/runbooks/` | How to fetch evidence: OCI live config, UI repro, chat-capture prompt |
| `customers/<CLIENT>/` | Per-customer profile + generated lineage graphs (open `lineage_e2e.html` in a browser: file → screen lineage) |
| `tooling/lineage/` | Generic extractors — run against any customer repo to (re)generate graphs |
| `.claude/skills/` | triage-ticket, ticket-retro, impact-analysis |
| `feedback/` | One line per triage: was it useful? Feeds improvement |

## Regenerating lineage (when customer code changes)

```bash
python3 tooling/lineage/extract.py --repo repos/<client>-etl --out customers/<CLIENT>/lineage
python3 tooling/lineage/extract_config.py --repo repos/<client>-configs
python3 tooling/lineage/merge_graphs.py --etl-graph customers/<CLIENT>/lineage/graph.json
```

Note: lineage graphs committed here are snapshots of the customer repos at
generation time (see `generated_at` in each graph's meta). Lower-env
config may differ from git — see `knowledge/runbooks/fetch-live-config.md`.

## Contributing knowledge

- Resolve a ticket → run the `ticket-retro` skill (or the capture prompt
  in `knowledge/runbooks/capture-prompt.md` for chats outside this repo).
- All notes land via PR. Backfilled/uncertain notes: `draft: true`.
- Pattern seen 3+ times → propose a playbook in `knowledge/playbooks/`.
