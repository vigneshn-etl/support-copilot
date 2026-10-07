# Support Copilot: feature guide

> **Lost? Type `help` in the chat at any time.** Use `help <topic>` for one
> feature (e.g. `help lineage`, `help qa sync`) or `what can you do?` for the list.

The copilot is an S5 Stratos support engineer that already knows our platform:
ETL → config → frontend → backend, every customer's repos, QA databases and OCI
buckets, plus every past solution. **You never need to explain how the product
works.** Give it a ticket or a question, and it drives.

---

## 30-second start

1. Open this folder in **Claude Code** (`cd support-copilot && claude`) or **Cowork**.
2. Paste a ticket id: `SUP-4678`. That's it. It triages, investigates, proposes
   a fix, validates and writes the retro, asking you at each gate.
3. Not working a ticket? Pick from the menu it shows, or ask in plain words.

**First-time setup (5 min):** enable the Atlassian (Jira) connector in Claude
settings, `pip install sqlglot`, and (for QA push) run `oci setup config` once.

---

## What it can do

### 🎫 1. Solve a ticket, end to end
Triage → root cause (with cited evidence) → fix → push to QA → validate → retro.
Two hard gates: **no fix without evidence, no close without proof.**

| Say | What happens |
|---|---|
| `SUP-4678` / `pick up SUP-4678` | Reads Jira, classifies (bug / data / config / enhancement…), finds similar past tickets, picks the right repo + branch |
| `solve it` | Full workflow; drafts every Jira comment for your approval |
| `tutor mode` / `pair` / `autopilot` | How hands-on you want to be (default **pair**: I propose, you approve) |

*Saves:* the "where do I even start" hour, plus re-discovering things a teammate already solved.

### 🔍 2. Analyze a ticket (understand it, no fix)
`analyze SUP-4678` returns classification, scope, evidence and the root cause
with a **confidence score** (0–100, computed, not guessed).

### 🧬 3. Data lineage: "where does this number come from?"
One graph per customer: **source file → ETL (Vertica/PG/CH) → pivot → model → screen.**

| Say | |
|---|---|
| `what feeds trd_h_prodstd?` | upstream chain with the scripts |
| `what breaks if I change <table/script/column>?` | downstream impact, down to the screens |
| `where does CC count on Style Review come from?` | screen → pivot → tables → files |
| `which scripts should I review for this change?` | blast-radius list |

*Visual explorer:* `cd tooling/lineage-viz && ./run.sh TRD` → http://127.0.0.1:8000

### 🧮 4. Validate a metric / compose SQL
Builds an **independent** ClickHouse query that recomputes a screen's number
from the main tables, so you can prove the UI right or wrong.

| Say | |
|---|---|
| `validate Net Sls U on Style Review for 011 MENS JEANS 2026-W10` | composed CH-correct SQL with provenance |
| paste a `pivot3/listData` URL | the scope is parsed from the request itself |

*Full UI (Data Validation Studio):* `cd tooling/validation/ui && ./run.sh` → http://localhost:8770

### 🗄️ 5. Query live QA databases (read-only)
`check in TRD QA how many styles have str_dc_flag='Y'` runs a SELECT over SSH
against QA Vertica/PG/CH. Writes are blocked by a guard.
Ask `which databases can you query?` to see the targets.

### ☁️ 6. Push a config fix to QA (OCI)
Once your config edits are in `JIRAs/<SUP-ID>/<repo>/`, the copilot **offers**
to sync them to the client's QA bucket:

1. **Pull:** download live QA.
2. **Diff:** a 3-way diff against your branch, file by file.
3. **Review:** what will change. It flags teammates' hand edits and stale or broken QA copies.
4. **Push:** you approve one plan_id.
5. **Verify:** md5-check every file. A backup is kept, so you can roll back.

Works for every client and brand (`all` for AEO's aeo/aer/tsn/uns or KW's 4 brands).

| Say | |
|---|---|
| `push my SUP-4678 changes to QA` | pull + diff + review, then waits for you |
| `push to all AEO brands` | one combined plan for 4 brands |
| `roll back the aer push` | restores the backup |

*Saves:* manual compare-and-paste into OCI, and the silent regressions it causes.
Details: `knowledge/runbooks/qa-config-sync.md`.

### 🌐 7. Check live QA/staging config vs git (drift)
`is TRD QA config different from git for StyleReview?` syncs the env bucket and
diffs it. Lower envs drift, so check before you conclude.

### 📚 8. Ask how something works
`what is bottomLevels?` · `how does a viewdefn reach the screen?` ·
`what does funded APS mean to a planner?`. Answers come from our primers,
glossary, cheatsheets and past notes, **with the source cited**.
Full-text search covers every note, runbook and LMS course.

### 💡 9. Teach it something (capture knowledge)
`remember: AEO fixes must be replicated to UNS/TSN/AER` saves the fact with
provenance, so the next person inherits it. After a ticket, `write the retro`
turns it into a reusable solution note.

### 🎓 10. Grow your own skills
- **Tutor mode:** you drive, and it coaches and reviews like a senior.
- **Learnings:** every ticket yields a *Technical* and a *Functional (retail)* lesson.
  Say `coach` (live), `end` (at close) or `quiet`.
- **Flashcards:** `python3 tooling/learning/flashcards.py due`, built from past tickets.
- **Calibration:** predict the confidence score before it's revealed.

### 🛠️ Admin only
- **Utilization dashboard:** `cd tooling/metrics && ./run.sh` → http://localhost:8771.
- **Extend the copilot:** add skills, knowledge, customer profiles and tools.

---

## What it will never do without you

- Post or edit Jira comments or labels. It **drafts**, and you approve.
- `git commit` / `push`, or merge PRs.
- Push to QA OCI without your approval of that exact plan. It never touches staging or prod.
- Write to any database (read-only guard).

## Tips that make it 10× better

- **Paste the ticket id, not a summary.** It reads Jira itself.
- **Say the customer and screen** (`AEO Style Review`), and lineage does the rest.
- **Ask "why?" and "how sure?"** Every conclusion has a source and a confidence score.
- **Correct it.** `that's wrong, the branch is release/2025.10` gets saved for everyone.
- After solving, **say `retro`**. That's how the copilot gets smarter for the team.

## Troubleshooting

| Problem | Fix |
|---|---|
| It doesn't seem to know the setup | `Read CLAUDE.md and follow the ticket workflow for SUP-XXXX` |
| Jira not reachable | enable the Atlassian connector in Claude settings |
| QA push: `oci … failed` | run `oci setup config` and check bucket access (VPN) |
| DB query fails | ask `which databases can you query?`; QA SSH/VPN must be up |
| Lineage looks stale | `tooling/lineage/regen.sh` (repo changed since last graph) |

---
*Maintainers: every new skill, tool or MCP must be added here.
`python3 tooling/guide_check.py` fails if one is missing.*
