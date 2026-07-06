# Runbook: capture knowledge from any Claude chat

Paste the prompt below at the end of any Claude conversation where a
ticket/issue was worked. Save the output to `knowledge/notes/<TICKET>.md`
in the support-copilot hub via PR.

---

## The prompt (copy everything in the block)

```
We're done with this issue. Now distill this entire conversation into a
solution note for our team knowledge base. This note will be read by
Claude in future sessions to solve similar issues faster, so optimize it
for machine retrieval and reuse, not for narrative.

Produce ONE markdown file, exactly this structure:

---
ticket: SUP-XXXX            # ask me if you don't know it
title: <one-line issue title>
client: <TRD|AEO|BLK|EE|GAP|KW|...>   # from ticket tag; ask if unclear
type: <bug|data-issue|feature|config|deploy|investigation>
repos: [<etl|config|frontend>]         # every repo we touched or ruled out
components: [<concrete table/screen/config-file/batch-step names>]
symptom: "<what the reporter/user actually saw, in their words>"
resolved: <YYYY-MM-DD>
effort: <rough total effort, e.g. 4h, 2d — ask me>
draft: false
---

## Problem
2-4 sentences: what was reported, business impact, environment (QA/prod),
which client.

## Diagnosis path
The ORDER we checked things, as short bullets — including every dead end:
- Suspected X -> ruled out because <evidence>
- Checked <query/file/log> -> found <observation>
- **Root cause:** <precise statement>
Dead ends are mandatory: they save the next person the most time.

## Fix
Exactly what changed and where. File paths with repo prefix
(e.g. trd-configs/uidefn/view/X.viewdefn), PR/commit refs if any, actual
code/SQL/config snippets for the key change (before -> after).

## Verification
How we proved it was fixed: exact queries run with expected vs actual,
screens checked, batch re-runs, test specs added.

## Gotchas
Anything surprising a future engineer must know: client-specific quirks,
ordering constraints, things that LOOK related but aren't, validations to
add, "this also exists in N other places" warnings. If we found a
reusable pattern (a bug class, not just a bug), state it as a general
rule. Delete this section only if truly nothing.

Rules:
- DISTILL, don't transcribe. No conversation blow-by-blow, no pleasantries.
- Every claim cites its evidence (file:line, query output, log excerpt).
- Frontmatter values must be greppable: real table names, real file names,
  no vague descriptions.
- If information is missing for any field (ticket number, dates, whether a
  check was done outside this chat), ASK me before writing — do not invent.
- If we tried an approach that FAILED entirely, still capture it under
  Diagnosis path — failed approaches are knowledge.
- Also tell me at the end, in one sentence outside the file: does this
  look like a recurring pattern that should become a playbook/skill rule?
```

---

## Notes

- The structure matches `knowledge/TEMPLATE.md` — keep them in sync.
- For older chats where memory is fuzzy, let Claude ask its gap questions;
  answer what you can and set `draft: true` if gaps remain.
- Batch-capture: you can paste this in several old chats in one sitting;
  file each result under its ticket number.
