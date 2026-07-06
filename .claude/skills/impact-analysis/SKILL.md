---
name: impact-analysis
description: >
  Analyze data lineage impact in this ETL repo. Use whenever the user asks
  what feeds a table, what breaks if a table/script/column changes, where a
  table's data comes from, why data looks wrong or stale (root cause), how
  data flows between Vertica/Postgres/ClickHouse, or which scripts to review
  for a change. Triggers: "impact", "blast radius", "upstream", "downstream",
  "lineage", "what breaks", "where does <table> come from", "what populates".
---

# Impact Analysis (lineage-backed)

Answer lineage questions from `tooling/lineage/graph.json` — never from grep alone.
All commands run from the repo root.

## Workflow

1. **Resolve the node.** Table names are `engine.table` (engines: `vertica`,
   `postgres`, `clickhouse`, `file`). If unsure of the exact name:

       python3 tooling/lineage/query.py find <partial-name>

2. **Pick the question type:**

   | User asks | Run |
   |---|---|
   | What breaks if I change X / blast radius | `python3 tooling/lineage/query.py impact <X>` |
   | What feeds X / where does X come from | `python3 tooling/lineage/query.py upstream <X> -d 3` |
   | What consumes X | `python3 tooling/lineage/query.py downstream <X> -d 3` |
   | How does data get from A to B | `python3 tooling/lineage/query.py path <A> <B>` |
   | Data wrong/stale in X (root cause) | `upstream <X> -d 4`, then read the provenance scripts |

3. **Read provenance.** Every edge prints `file.sql:line` or `script.sh:line`.
   Open those files to explain *how* the data moves (join logic, filters),
   not just that an edge exists.

4. **Cross-DB hops** appear as `file.*` nodes (dashed edges in the viewer):
   a Vertica/CH export writes the file, a psql `\copy` / clickhouse-client
   stdin load consumes it. Treat `export -> file -> load` as one logical hop
   when explaining flows.

5. **If the graph looks stale or missing a table** (recent script changes,
   node not found): regenerate, then retry:

       python3 tooling/lineage/extract.py

   If `tooling/lineage/coverage.json` shows the relevant SQL as unparsed, say so —
   don't guess. Fall back to reading the actual script and flag the parser gap.

## Answer format

- Lead with the direct answer (affected tables / origin / path).
- Group by engine; note client-facing endpoints (Postgres app tables,
  ClickHouse serving tables) explicitly — those are the risky ones.
- List the scripts/SQL files to review, with paths.
- For impact questions, end with a short "safe change checklist" specific
  to the affected flows (which orchestrator: daily/weekly/intraday).

## Notes

- A table may exist in multiple engines (e.g. `trd_eohdata_stylecolor` in
  vertica AND postgres) — they are different nodes; disambiguate before
  answering, or use `--all` to include both.
- `*_deprecated*` dirs and `database_changes/` are excluded from the graph
  by design (see `tooling/lineage/extract.py` DEFAULT_CONFIG).
