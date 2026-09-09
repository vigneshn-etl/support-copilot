#!/usr/bin/env bash
# Admin metrics dashboard. Set USER_EMAIL so the admin badge resolves.
set -euo pipefail
cd "$(dirname "$0")"
export USER_EMAIL="${USER_EMAIL:-}"
echo "open: http://localhost:${PORT:-8771}"
exec uvicorn server:app --port "${PORT:-8771}"
