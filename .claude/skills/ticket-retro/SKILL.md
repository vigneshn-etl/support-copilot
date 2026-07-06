---
name: ticket-retro
description: >
  Capture a resolved ticket as a reusable solution note in knowledge/notes/.
  Use when a ticket/bug/task is done, fixed, resolved, or closed; when the
  user says "retro", "write it up", "capture this", "document what we did";
  or at the end of any session where a SUP ticket was worked on.
---

# Ticket retro — distill the session into memory

## 1. Gather
- The ticket ID and final state (ask if unknown).
- What THIS session actually did: the diagnosis path including dead ends,
  the fix (files/PRs/commits), how it was verified.
- If parts happened outside this session, ask the user to fill gaps —
  especially ruled-out suspects (they save the most future time).

## 2. Write the note
- Copy structure from `knowledge/TEMPLATE.md` → `knowledge/notes/<TICKET>.md`.
- Frontmatter complete (client, type, repos, components, symptom) — it is
  the search index. Components = concrete table/screen/config names.
- Distill. No transcript. Diagnosis path as short bullets. `draft: false`
  (the human is in the loop right now — this is the review).

## 3. Close the loop
- Post a summary comment on the JIRA ticket (Atlassian MCP): root cause +
  fix + link/path to the note. Ask before posting.
- If the ETL repo's data flows changed: remind to run
  `python3 lineage/extract.py` and commit lineage artifacts.
- If this is the 3rd+ note with the same pattern (grep for the root-cause
  keywords), say so and propose promoting it to knowledge/playbooks/ and/or
  a skill update.

## 4. Estimation hook
Append actual effort if the user shares it (`effort: 3h` in frontmatter) —
future estimates for similar tickets are grounded in these.
