# ETL Lineage Visualization Tool

A localhost tool to explore upstream/downstream data lineage for the shell+SQL
ETL batches (Vertica / Postgres / ClickHouse). Pick a customer → batch → target
table and see which scripts produced it, from which sources, with what
transformation, and whether each step is a **full** or **incremental** load.

See `../ETL-Lineage-Viz-Tool-Proposal.md` for the architecture and decisions.

## Quick start

```bash
pip install -r requirements.txt
./run.sh TRD          # builds the DB, classifies load modes, serves the UI
# open http://127.0.0.1:8000
```

No graph server to run — the lineage graph is a per-customer SQLite file.

## Two views (switch top-left)

- **Table lineage** — pick a table, see upstream/downstream sources with transform
  type and full/incremental load mode. Toggle immediate vs full chain.
- **Batch scripts** — pick a batch (daily / weekly / intraday / …), see the
  script execution DAG rooted at its main `.sh`. Grey edges = a script calls
  another; amber edges = a script runs a SQL step. Hover a SQL step to see the
  tables it writes (with load mode) and reads.

## Pieces

| File | Role |
|---|---|
| `registry/customers.json` | Source of truth: customers, repos, batch→main-script, db path |
| `registry/credentials.example.json` | SSH/git config template (copy to `credentials.json`, gitignored) |
| `load_sqlite.py` | Builds `lineage.db` from the extractor's `graph.json` |
| `classify_loadmode.py` | Tags each edge full / incremental / view / file_move (§5 heuristics) |
| `batch_scope.py` | Walks each batch's main `.sh` to build the script execution DAG (`.sh→.sh` calls + `.sh→.sql` runs) and true batch membership |
| `graph_service.py` | Read-only graph access + cycle-safe recursive-CTE traversal |
| `server.py` | FastAPI backend + serves the single-page UI |
| `static/index.html` | The explorer (Cytoscape.js): dropdowns, full-lineage toggle, hover panel |
| `query.py` | CLI: `find / upstream / downstream / edge / stats` |
| `export_static.py` | Write a self-contained HTML snapshot of one table's lineage |

## Rebuilding after scripts change

```bash
# 1. regenerate graph.json in the customer repo (upstream extractor)
python3 ../etl-trd-batch/lineage/extract.py
# 2. reload + reclassify
python3 load_sqlite.py --graph ../etl-trd-batch/lineage/graph.json --repo ../etl-trd-batch --out workspaces/TRD/lineage_trd.db
python3 classify_loadmode.py --db workspaces/TRD/lineage_trd.db --repo ../etl-trd-batch
```

The UI shows a **staleness banner** when on-disk script hashes no longer match the
built graph.

## Known limitations (candidates for the next enhancements)

- **Dynamic SQL (§5.1):** statements built at runtime via `sed` into `.sql`
  stencils (e.g. `bash/fullload/12.6_ch_load_phistory_sales.sh`) are not yet
  parsed, so a few tables (e.g. `trd_p_history_sales`) show no upstream. Edges
  with no resolvable SQL are marked `unknown`, never dropped silently.
- **Batch scoping** currently uses the extractor's directory-derived `flows`.
  True orchestrator-rooted scoping (walk each batch's main `.sh`) is a planned
  refinement.
- **Load-mode** is heuristic; spot-check marquee tables.
- **New-customer clone flow** (SSH clone + `.sh` batch mapping UI) is speced but
  not yet wired; TRD is registered directly against the existing repo/graph.
