---
ticket: SUP-0000
title: One-line ticket title
client: TRD            # client tag from the ticket, e.g. TRD/AEO/BLK/EE/GAP
type: bug              # bug | data-issue | feature | config | deploy
repos: [etl]           # etl | config | frontend (all that were touched)
components: []         # tables, screens, batch flows, config keys involved
symptom: "What the user/reporter actually saw, in their words"
resolved: 2026-01-01
draft: false           # true until a human who worked the ticket reviews it
---

## Problem

2-4 sentences. What was reported, business impact, which client/environment.

## Diagnosis path

The order things were checked — including dead ends (they save the next
person the most time):

- Suspected X → ruled out because …
- Checked lineage upstream of <table> → found …
- **Root cause:** …

## Fix

What was changed, where. Reference PRs/commits (ticket ID in commit message
makes these findable).

- `repo/path/file.sql` — what changed
- PR: <link>

## Verification

How we knew it was fixed (query run, screen checked, batch re-run…).

## Knowledge gained (techno-functional — required)

**Technical:** the code/data/config mechanism learned (a table/view/trigger
behavior, a pivot grain rule, a config binding…). One or two sentences.

**Functional:** the retail business meaning — what this metric / screen /
rule means to a planner or the merchandising process. (We are
techno-functional consultants; both halves are mandatory.)

## Gotchas

Anything surprising that future-you should know (timezones, client-specific
config, ordering constraints…). Delete section if none.
