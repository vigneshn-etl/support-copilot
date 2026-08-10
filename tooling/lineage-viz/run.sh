#!/usr/bin/env bash
# Build the TRD lineage DB, classify load-modes, and serve the explorer.
# Usage:  ./run.sh [CUSTOMER_ID]   (default TRD)
set -euo pipefail
cd "$(dirname "$0")"
CID="${1:-TRD}"
CID_LC="$(printf '%s' "$CID" | tr '[:upper:]' '[:lower:]')"

GRAPH="../etl-trd-batch/lineage/graph.json"
REPO="../etl-trd-batch"
DB="workspaces/${CID}/lineage_${CID_LC}.db"

echo "→ building $DB from $GRAPH"
python3 load_sqlite.py --graph "$GRAPH" --repo "$REPO" --out "$DB"
echo "→ classifying load modes"
python3 classify_loadmode.py --db "$DB" --repo "$REPO"
echo "→ building batch script execution DAGs"
python3 batch_scope.py --db "$DB" --repo "$REPO" --registry registry/customers.json --customer "$CID"
echo "→ serving on http://127.0.0.1:8000  (Ctrl-C to stop)"
python3 server.py
