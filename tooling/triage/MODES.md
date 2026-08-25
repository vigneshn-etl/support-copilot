# Assistance modes — solve the ticket AND keep the human sharp

The copilot is powerful enough to do the whole ticket. That's exactly the
risk: if it always does everything, the person driving it drifts from author
to prompter and their SQL/config/debugging muscle detrains. These modes let
YOU choose, per ticket, how much you do — so the tool trains you instead of
replacing you.

Set the mode at intake (record it in `state.json` as `mode`). Default is
**pair**. The engine, the state, the score, the trace are identical in every
mode — only *who makes each decision* changes.

## The three modes

**tutor** — you're the author, the copilot is your reviewer.
At each decision point the copilot *stops and hands you the wheel*: it lays out
the enumerated options and the evidence it gathered, then asks YOU to decide,
and only then confirms or corrects with the reasoning. You draft the SQL /
config change; it critiques like a senior would. Slowest, highest learning.
Use it on the skills you want to keep.

**pair** (default) — the copilot proposes, you approve.
It makes each call and shows its reasoning in the summary; you accept or
redirect. Moderate speed, moderate engagement. The everyday setting.

**autopilot** — the copilot runs the whole loop and hands you the result.
Only for tickets you don't need to learn from (routine, or a layer you're
already strong in and just want cleared). Fastest, zero training value — use it
deliberately, not by default.

## What changes at each stage

| Stage | tutor (you decide, AI reviews) | pair (AI proposes, you approve) | autopilot |
|---|---|---|---|
| Classify | AI shows the signals; **you** pick type/component/env; AI confirms | AI classifies, shows why | AI classifies |
| Requirement | **You** restate it; AI checks your restatement against the ticket | AI drafts the restatement; you confirm with reporter | AI drafts |
| Evidence | AI lists the matrix cell; **you** say what to gather first and predict what you'll find | AI gathers, shows citations | AI gathers |
| Root cause | **You** name the cause + rule out the alternatives; AI stress-tests | AI proposes cause; you sanity-check | AI concludes |
| Score | **Predict-the-score first** (`confidence.py --predict`) before the reveal | AI shows the score | AI shows the score |
| Fix (SQL/config) | **You author it**; AI reviews line-by-line and won't "fix it for you" | AI drafts; you review before applying | AI drafts |
| Retro | **You** write the techno-functional note; AI fills gaps | AI drafts the note; you edit | AI drafts |

## The learning tools (wire these into tutor/pair)

- **Predict-the-score** — before revealing confidence, elicit the user's guess:
  `python3 tooling/triage/confidence.py <state> --predict` (prints the prompt),
  then `--predict --guess <N> --guess-weak "…"` to compare + log. Trains the
  judgment that atrophies fastest: "is this diagnosis actually solid?"
- **Flashcards** — every resolved ticket's `knowledge_gained` becomes recall
  practice: `tooling/learning/flashcards.py build|due|show|grade`. Drill a few
  when due; the tool already wrote the study material.
- **Skill ledger** — after each ticket, log what YOU actually did:
  `tooling/learning/skill_ledger.py log --skill sql --action authored|reviewed|
  accepted|cold --ticket <ID>`. `report` shows the authored-vs-accepted balance
  and flags a skill you've stopped exercising. Makes erosion visible.

## Agent etiquette for tutor mode

When `mode = tutor`, the agent MUST:
1. Stop at each stage above and ask the user to make the call **before**
   revealing its own answer (no leading the witness).
2. For any SQL / config edit, ask the user to draft it; respond as a reviewer
   (what's right, what's risky, what you'd change) — do **not** hand over a
   finished query unless the user asks.
3. Run the predict-the-score step before showing confidence.
4. Prompt the user to log the ledger action and grade any due flashcards at
   close-out.

The rule of thumb: in tutor mode the agent's job is to make the human's
thinking better, not to do the human's thinking.
