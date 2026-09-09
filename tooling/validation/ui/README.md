# Data Validation Studio (UI)

A single-page web tool — same design language as the ETL Lineage Explorer
(`tooling/lineage-viz`) — that turns a picked **screen → view → scope** into a
**ClickHouse-correct, consistency-annotated validation query** you can run and
cross-check against the UI.

## What it shows

- **Toolbar:** module → screen → view, plus grain (`aggBy`), criteria
  (HIST/FLOW), and optional `flowStatus` / `topMembers` — mirroring the app's
  own scope pickers.
- **Center:** the composed SQL with a verdict bar (✓ consistent / ⚠ outlier /
  ⚠ no-op) and syntax-tinted comments; **Copy SQL** to run it yourself.
- **Side panel — pivot contract:** base view, grain (`bottomLevels`), per-metric
  aggregation family (additive `sum` / snapshot `argMax` / first `argMin`), the
  FLOW/HIST criteria with no-op flags, and the sibling pivots on the same base
  to reconcile against.

Everything is exact-key lookups over `catalog.db` + the composer — no DB
connection required to generate the query.

## Run (locally)

    pip install -r requirements.txt
    # 1) build the catalog on a real disk (once, and after config changes):
    python3 ../build_catalog.py --config-dir /path/to/trd-configs
    # 2) launch (compose only):
    CONFIG_DIR=/path/to/trd-configs ./run.sh      # -> http://localhost:8770
    # 2b) launch WITH execution (compose → run → compare):
    CONFIG_DIR=/path/to/trd-configs \
    CH_DSN=http://ro_user:pass@ch-host:8123 ./run.sh

## Execute & compare

With `CH_DSN` set (a **read-only** ClickHouse DSN — stays server-side, never
sent to the browser), the panel under the SQL runs the composed query and
diffs it against the UI:
- **weeks** — the history window (comma list of week ids, e.g. `202540,202541`).
- **expected UI JSON** — the numbers off the screen, e.g. `{"choice_count":125,"dmd_u":84213}`.
- **Run & compare** → shows CH version, the DB summary (choice count + metric
  totals, computed with the correct per-metric aggregation), and a MATCH /
  MISMATCH verdict per metric. A mismatch localizes a criteria/filter/aggregation bug.

The server probes `version()` + capabilities (21.4-safe) before running.

`CATALOG_DB` defaults to `customers/TRD/lineage/catalog.db`; override via env.

## Notes

- Needs a real filesystem (SQLite + the config repo) — run on your machine, not
  inside Cowork (the mount can't serve SQLite).
- To actually execute the composed query and compare values, pair with
  `../ch_validate.py` once read-only ClickHouse access is available.
- Higher product grains (class/department) are emitted with a hierarchy-join
  TODO until the M_Meta join lands; stylecolor/style resolve directly.
