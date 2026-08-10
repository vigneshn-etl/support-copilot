# Lineage tooling

One set of graphs, two consumers:

- **The agent** (support copilot) reads the **JSON** graph via the lineage
  MCP (`.mcp.json` → `mcp_server.py`) and `query.py`.
- **Humans** use the **web viz** (`tooling/lineage-viz/`, FastAPI + Cytoscape)
  which reads a **SQLite** built from the same JSON.

## The one source of truth

Graphs live under **`customers/<CID>/lineage/`** (per customer):

| File | What | Consumer |
|---|---|---|
| `graph.json` | ETL lineage (Vertica/PG/CH + files) | agent, viz |
| `config_graph.json` | config lineage (screen←model←pivot←CH) | build step |
| `combined_graph.json` | ETL + config merged | build step |
| `pivot_graph.json` | pivot temp-table DAGs | build step |
| **`unified_graph.json`** | **everything: file → ETL → pivot temp → pivot → model → screen** | **agent (default)**, viz |
| `unified_<cid>.db` | SQLite of the unified graph | web viz only |

The agent's MCP/CLI default to `unified_graph.json` for the customer set by
`LINEAGE_CLIENT` (default TRD). Override with `LINEAGE_GRAPH=<path>`.

## Build / regenerate (one command)

```
tooling/lineage/regen.sh <CID> <etl-repo> <config-repo>
# e.g. tooling/lineage/regen.sh TRD ../etl-trd-batch ../trd-configs
```
Runs: extract (ETL) → extract_config → merge → pivot_lineage → merge_pivot
→ unified_load. Rerun after repo changes. Generated JSON/DB are gitignored
(regenerable); commit the code, not the artifacts.

## Files

**Build (`tooling/lineage/`)**: `extract.py` (ETL), `extract_config.py`
(config), `merge_graphs.py`, `pivot_lineage.py`, `merge_pivot.py`,
`classify_loadmode.py`, `batch_scope.py`, `unified_load.py` (JSON→SQLite),
`diff.py` (PR data-impact).

**Agent access (`tooling/lineage/`)**: `query.py` (CLI: find/upstream/
downstream/impact/path/stats), `mcp_server.py` (the lineage MCP).

**Web viz (`tooling/lineage-viz/`)**: `server.py` (FastAPI), `graph_service.py`,
`unified_service.py` (3-scope: ETL/Pivot/E2E), `static/` (Cytoscape UI),
`registry/customers.json`, `run.sh`. Start: `cd tooling/lineage-viz && python3 server.py`.
