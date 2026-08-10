#!/usr/bin/env bash
# Regenerate the full lineage graph for one customer, end to end.
# Produces the ONE set of graphs under customers/<CID>/lineage/ used by BOTH
# the agent (JSON via the lineage MCP/CLI) and the web tool (SQLite).
#
# Usage:  tooling/lineage/regen.sh <CID> <etl-repo> <config-repo>
#   e.g.  tooling/lineage/regen.sh TRD ../etl-trd-batch ../trd-configs
set -euo pipefail

CID="${1:?usage: regen.sh <CID> <etl-repo> <config-repo>}"
ETL="${2:?etl repo path}"
CFG="${3:?config repo path}"

HERE="$(cd "$(dirname "$0")" && pwd)"          # tooling/lineage
HUB="$(cd "$HERE/../.." && pwd)"               # support-copilot
OUT="$HUB/customers/$CID/lineage"
mkdir -p "$OUT"
client="$(echo "$CID" | tr '[:upper:]' '[:lower:]')"

echo "== [$CID] ETL lineage =="
python3 "$HERE/extract.py"        --repo "$ETL" --out "$OUT"
echo "== [$CID] config lineage =="
python3 "$HERE/extract_config.py" --repo "$CFG" --client "$client" \
  && cp "$CFG/lineage/config_graph.json" "$OUT/" 2>/dev/null || true
echo "== [$CID] merge ETL+config =="
python3 "$HERE/merge_graphs.py" --etl-graph "$OUT/graph.json" \
  --config-graph "$OUT/config_graph.json" --out "$OUT/combined_graph.json" 2>/dev/null || \
  cp "$CFG/lineage/combined_graph.json" "$OUT/" 2>/dev/null || true
echo "== [$CID] pivot lineage =="
python3 "$HERE/pivot_lineage.py"  --configs "$CFG" --client "$client" --out "$OUT/pivot_graph.json"
echo "== [$CID] fold pivot into unified =="
python3 "$HERE/merge_pivot.py"    --combined "$OUT/combined_graph.json" \
  --pivot "$OUT/pivot_graph.json" --out "$OUT/unified_graph.json"
echo "== [$CID] load SQLite for the web viz =="
python3 "$HERE/unified_load.py"   --graph "$OUT/unified_graph.json" \
  --out "$OUT/unified_${client}.db"

echo "== done. graphs in $OUT =="
echo "   agent uses: unified_graph.json (LINEAGE_CLIENT=$CID)"
echo "   web  uses:  unified_${client}.db  (tooling/lineage-viz/run.sh)"
