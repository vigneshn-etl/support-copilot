---
name: copilot-help
description: >
  Quick help on what the support copilot can do and how to use it. Use when the
  user says "help", "help <topic>", "what can you do", "how do I use this",
  "what features", "guide", "show me examples", "I'm new", "?", or seems unsure
  what to ask. Answers from GUIDE.md and offers to start the feature right away.
---

# Copilot help

Source of truth: `GUIDE.md` (repo root). Read it, answer from it, and don't invent
features. If something isn't there, check `knowledge/INDEX.md`, then say so.

## `help` / "what can you do" (no topic)

Reply in **≤ 12 lines**:
1. One line: what the copilot is ("a support engineer that already knows our
   platform. Give it a ticket or a question").
2. The numbered feature list from GUIDE.md "What it can do": just the title +
   one example prompt each. Filter by persona (users don't see Admin).
3. Close with: "Say `help <topic>` for details, or just try one, e.g.
   `SUP-1234`."

## `help <topic>`

Match the topic to a GUIDE.md section (lineage, validate, qa sync / oci / push,
db / query, drift, learn / capture, tutor / modes, retro, jira…). Reply with:
- what it does (1–2 lines), **when to use it**, 2–3 example prompts to copy,
  what you need (connector, VPN, edit clone…), and the deeper doc link;
- then **offer to run it now** on their real ticket/table/screen.

## Contextual tips (proactive, sparingly)

At most **one tip per session**, only when it clearly helps the current task
(e.g. they're hand-comparing QA config → mention QA sync; they're grepping
for a table's source → mention lineage). Format: `💡 Tip: …` in one line.

## "Is it safe?" / "what will it do on its own?"

Quote GUIDE.md "What it will never do without you". Be exact.

## Feedback

If the user says the guide was confusing or a feature is missing, append one
line to `feedback/` (date, what was unclear) and tell them it's logged.
