#!/usr/bin/env bash
# One-command check that this machine can reach the QA databases via the
# read-only gate. Prints which prerequisite is missing.
#   usage: tooling/db/check_access.sh [CLIENT]      (default TRD)
set -uo pipefail
CLIENT="${1:-TRD}"
HOST="qa-processor"
GATE="python3 /data/external/support-copilot/s5_ro_gate.py"
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=10 -o RemoteCommand=none -o RequestTTY=no -T "$HOST")
fail=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; echo "        -> $2"; fail=1; }

echo "Checking DB access for $CLIENT"
command -v python3 >/dev/null && ok "python3 installed" || bad "python3 missing" "install Python 3"

if "${SSH[@]}" true 2>/dev/null; then ok "ssh $HOST works"
else bad "cannot ssh to $HOST" "add a '$HOST' alias (key, VPN) to ~/.ssh/config"; exit 1; fi

if "${SSH[@]}" "test -r /data/external/support-copilot/s5_ro_gate.py" 2>/dev/null; then ok "gate readable on host"
else bad "gate folder not readable" "ask an admin to add your login to the 'automaton' group"; exit 1; fi

for e in postgres vertica clickhouse; do
  out=$(echo "SELECT 1" | "${SSH[@]}" "$GATE $CLIENT $e" 2>&1)
  if [ $? -eq 0 ]; then ok "$CLIENT/$e query through gate"
  else bad "$CLIENT/$e: $(echo "$out" | head -1)" "if 'no target', that engine isn't configured for $CLIENT on the host yet"; fi
done
[ $fail -eq 0 ] && echo "All good." || echo "Some checks failed (see above)."
exit $fail
