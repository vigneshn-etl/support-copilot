#!/usr/bin/env bash
# Start the Data Validation Studio:  tooling/validation/studio.sh [CLIENT]
# venv + deps, config clone if missing, setup check, then serve on :${PORT:-8770}.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
export CLIENT="${1:-${CLIENT:-TRD}}"
VENV="$HERE/ui/.venv"
[ -d "$VENV" ] || python3 -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -q --upgrade pip >/dev/null 2>&1 || true
pip install -q -r "$HERE/ui/requirements.txt"

if [ -z "${CONFIG_DIR:-}" ] && [ "$(python3 "$HERE/config_sync.py" --client "$CLIENT" --dir qa)" = "(not synced: qa)" ]; then
  echo "· no QA config yet: cloning + pulling the OCI overlay (needs GitHub + OCI CLI)"
  LOG="$(mktemp)"
  if ! python3 "$HERE/config_sync.py" --client "$CLIENT" --sync-env qa >"$LOG" 2>&1; then
    echo "  ! config download failed:"
    python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: print(open(sys.argv[1]).read()[-800:]); sys.exit()
for r in d.get("results",[]):
    if r["rc"]: print("   ", r["cmd"][:120]); print("     ", (r["err"] or r["out"]).strip()[-400:])
print("    hint:", d.get("hint",""))' "$LOG"
  fi
  rm -f "$LOG"
fi

MDIR="$HERE/../../customers/$CLIENT/metrics"
CFG="$(python3 "$HERE/config_sync.py" --client "$CLIENT" --dir qa)"
if [ ! -s "$MDIR/metric_map_qa.csv" ] && [ ! -s "$MDIR/metric_map.csv" ] && [ -d "$CFG" ]; then
  echo "· building the metric map from QA config (about 4 minutes, first run only)"
  python3 "$HERE/metric_map.py" --config-dir "$CFG" --client "$CLIENT" --env qa \
    --out "$MDIR/metric_map_qa.csv" | tail -1 || echo "  ! metric map build failed"
fi

echo "· setup check"
python3 "$HERE/doctor.py" --client "$CLIENT" || echo "  ! fix the ✗ items above; the Studio starts anyway (SQL-only works offline)"

cd "$HERE/ui"
echo "· open http://localhost:${PORT:-8770}"
exec python3 -m uvicorn server:app --loop asyncio --port "${PORT:-8770}"
