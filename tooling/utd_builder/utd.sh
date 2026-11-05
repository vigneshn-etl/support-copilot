#!/usr/bin/env bash
# Unit test document builder wrapper: installs deps on first use, then runs build_utd.js.
#   tooling/utd_builder/utd.sh init SUP-1234 --client BELK --shots ~/Desktop/shots
#   tooling/utd_builder/utd.sh tickets/SUP-1234/utd/SUP-1234_UTD.json
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v node >/dev/null || { echo "utd: Node.js 18+ is required (brew install node)" >&2; exit 2; }
if [ ! -d "$DIR/node_modules/docx" ]; then
  echo "utd: first run — installing dependencies…" >&2
  # A root-owned ~/.npm (old npm bug) breaks install; fall back to a private cache.
  (cd "$DIR" && npm install --silent --no-audit --no-fund 2>/dev/null) \
    || (cd "$DIR" && npm install --silent --no-audit --no-fund --cache "$DIR/.npm-cache") \
    || { echo "utd: npm install failed — run: cd $DIR && npm install" >&2; exit 2; }
fi
exec node "$DIR/build_utd.js" "$@"
