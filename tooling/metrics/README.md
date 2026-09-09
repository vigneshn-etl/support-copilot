# Copilot Metrics (admin)

"How is the copilot being used?" — utilization, quality, and knowledge-growth
numbers, aggregated from the artifacts the engine already produces. No new
instrumentation: every worked ticket is a `tickets/<ID>/state.json`, and this
reads those + solution notes + the learning logs.

## Run

    pip install fastapi uvicorn
    USER_EMAIL=you@s5stratos.com ./run.sh      # -> http://localhost:8771
    # or the CLI summary:
    python3 rollup.py            # text
    python3 rollup.py --json     # machine-readable (the dashboard reads this)

`USER_EMAIL` is matched against `modes/roles.json` `admin_emails` for the
admin/user badge (soft — this is a local view, not access control).

## What it shows

- **Utilization** — tickets worked, by component / type / client / stage /
  assistance mode, and by **owner** (once states carry one — see below).
- **Quality** — requirement-confirmed rate, root-cause run-confirmed rate,
  prior-art reuse rate, confidence-band distribution + average.
- **Knowledge growth** — solution notes, notes, captured facts, customers.
- **Learning** — skill-ledger totals and calibration trend.
- **Gaps** — what to do to make the metrics richer.

## Per-person metrics

`newticket.sh` now seeds `state.owner` from `git config user.email`, so as the
team works tickets through the engine, `by_owner` fills in automatically. For
richer team analytics later, centralize the states (commit them, or have the
reasoner-mode agent post state as a Jira comment) and point this rollup at the
aggregate.
