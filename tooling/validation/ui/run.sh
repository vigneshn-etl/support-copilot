#!/usr/bin/env bash
# Launch the Data Validation Studio locally.
# Prereqs: pip install -r requirements.txt ; build the catalog first:
#   python3 ../build_catalog.py --config-dir /path/to/trd-configs
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
: "${CONFIG_DIR:?set CONFIG_DIR to your trd-configs path (needed to read pivotdefns)}"
export CONFIG_DIR
export CATALOG_DB="${CATALOG_DB:-$HERE/../../../customers/TRD/lineage/catalog.db}"
export CLIENT="${CLIENT:-TRD}"
cd "$HERE"
echo "catalog : $CATALOG_DB"
echo "config  : $CONFIG_DIR"
echo "open    : http://localhost:${PORT:-8770}"
exec uvicorn server:app --port "${PORT:-8770}" --reload
