# The Ticket Workflow — decision stages, gates, and JIRA contract

Principle: **JIRA is the shared ledger; chat is the workbench.** Every
stage reads the ticket and writes its output back (comment/label/link) —
drafted by Claude, approved by the engineer. Nothing important lives only
in a chat session.

Stage skills: `triage-ticket` covers 1–5; `validate-fix` covers 6–7;
`ticket-retro` covers 8.

## Stages

### 1. INTAKE
- Fetch ticket + comments + attachments (read Looms/screenshots).
- Search `knowledge/notes/` + JIRA history for prior art.
- **JIRA:** none yet.
- Exit: ticket understood in reporter's terms; prior art found or "none".

### 2. CLASSIFY — bug | data-issue | enhancement | config-change | deploy | question
- Bug = behavior deviates from design. Data-issue = data wrong/stale.
  Enhancement = new/changed behavior requested. Ambiguous → ask reporter
  ON THE TICKET.
- **JIRA:** label `cc-<type>` (e.g. cc-bug); comment if reclassified from
  the reporter's issue type.
- Exit: one type chosen, defensible in one sentence.

### 3. SCOPE — customer + layer(s)
- Customer from summary tag → load `customers/<CLIENT>/profile.md`.
- Layer via system-map decision guide: `etl | config | frontend | db |
  hybrid` (hybrid = name every layer). Wrong-everywhere ⇒ etl;
  one-view-only ⇒ config; interaction ⇒ frontend; "changed by itself" ⇒
  check db triggers (customers/<CLIENT>/db/README.md).
- **JIRA:** labels `cc-layer:<x>` (multiple allowed).
- Exit: owning layer(s) + repos identified.

### 4. INVESTIGATE — evidence acquisition (protocol in triage skill)
- Get what's needed, in order of cheapness: repos (clone/pull) → lineage
  (impact/upstream) → config cheatsheets/db README → OCI live-config diff
  (lower envs!) → DB queries (read-only MCP or ask) → logs (ask) → UI
  repro (Chrome/Looms).
- Ask the reporter for missing inputs AS A JIRA COMMENT (so answers
  persist), not just in chat.
- **JIRA:** evidence-request comment when inputs are needed.
- Exit: enough evidence to state a root cause, or a documented block.

### 5. ROOT-CAUSE GATE  ⛔
- Statement must cite evidence: file:line, query result, log excerpt,
  config diff. "Probably X" without a citation does not pass.
- If confirmable by one more check (a query, a diff), DO that check.
- **JIRA:** root-cause comment: cause, evidence, proposed fix, and the
  validation plan sketch (see stage 6 — plan is written BEFORE the fix).
- Human approves before any fix work starts.
- Loop back to 4 if evidence is insufficient.

### 6. FIX — with validation plan written FIRST
- Write the validation plan before touching code (what will prove the
  fix, incl. pre-fix snapshot to compare against — capture the "pre"
  state NOW, before the fix destroys it).
- Implement following repo conventions (CLAUDE.md of the repo). Ticket ID
  in branch + commits. Regenerate lineage if data flows changed.
- **JIRA:** link PR; comment summarizing the change.
- Exit: PR open, validation plan attached to the ticket.

### 7. VALIDATION GATE  ⛔  — the deciding block
- Execute the plan from `validate-fix` skill. Evidence or it didn't
  happen: numbers, screenshots, test output — posted to the ticket.
- No validation pass = no close, no exceptions. A fix that can't be
  validated is a hypothesis, not a fix.
- **JIRA:** validation-results comment with artifacts; transition to the
  QA/deploy status per team process.

### 8. RETRO — memory flywheel
- `ticket-retro` skill → solution note (incl. diagnosis dead ends and
  the validation recipe that worked) → PR to knowledge repo.
- **JIRA:** final comment linking the note. Label `cc-noted`.
- Feedback line in `feedback/` (was the copilot useful? what was wrong?).

## JIRA label vocabulary

`cc-bug|cc-data-issue|cc-enhancement|cc-config-change|cc-deploy|cc-question`,
`cc-layer:etl|config|frontend|db`, `cc-triaged`, `cc-noted`.
(cc = claude-copilot. Labels make JQL dashboards free:
`label = cc-triaged AND statusCategory != Done`.)

## Rules that make this trustworthy

1. Claude drafts every JIRA write; a human approves (until the team
   votes to automate a specific stage).
2. Gates are hard: no fix before an evidence-cited root cause; no close
   before validation proof.
3. Pre-state is captured before the fix (you can't prove improvement
   without a baseline).
4. Lower-env evidence beats repo assumptions (OCI diff, live DB).
5. Every session that touches a ticket ends with the ticket updated —
   the ledger is never behind.
