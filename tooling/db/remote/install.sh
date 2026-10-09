#!/usr/bin/env bash
# Install the read-only gate on a QA host.
#   usage: tooling/db/remote/install.sh <ssh-alias> [--authorize]
#   e.g.   tooling/db/remote/install.sh qa-processor
# Default (login mode): only copies the gate to ~/.s5_ro on the host.
# --authorize (forced-command mode): also creates a dedicated local key and
# appends its restricted line to the host's authorized_keys.
set -euo pipefail

HOST="${1:?usage: install.sh <ssh-alias> [--authorize]}"
DEST="${S5_RO_DEST:-~/.s5_ro}"   # shared install: S5_RO_DEST=/data/external/support-copilot
AUTHORIZE="${2:-}"
HERE="$(cd "$(dirname "$0")" && pwd)"
KEY="$HOME/.ssh/s5_copilot_ro"
SSH=(ssh -o BatchMode=yes -o RemoteCommand=none -o RequestTTY=no -T "$HOST")

# 1. gate files -> ~/.s5_ro (700), targets.json template (600) if absent
"${SSH[@]}" "umask 027; mkdir -p $DEST && chmod 750 $DEST"
for f in s5_ro_gate.py ../readonly_guard.py; do
  "${SSH[@]}" "cat > $DEST/$(basename "$f") && chmod 640 $DEST/$(basename "$f")" < "$HERE/$f"
done
"${SSH[@]}" "umask 027; [ -f $DEST/targets.json ] && echo 'targets.json kept' || { cat > $DEST/targets.json; chmod 640 $DEST/targets.json; echo 'targets.json created from example - fill passwords on host'; }" \
  < "$HERE/targets.example.json"

# 2. forced-command mode only: dedicated key + restricted authorized_keys line
if [[ "$AUTHORIZE" == "--authorize" ]]; then
  [[ -f "$KEY" ]] || ssh-keygen -t ed25519 -f "$KEY" -C "s5-copilot-ro" -N ""
  LINE="restrict,command=\"/usr/bin/python3 \$HOME/.s5_ro/s5_ro_gate.py\" $(cat "$KEY.pub")"
  printf '%s\n' "$LINE" | "${SSH[@]}" 'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys;
    read -r l; k=$(echo "$l" | awk "{print \$(NF-1)}");
    grep -qF "$k" ~/.ssh/authorized_keys && echo "key already authorized" || { echo "$l" >> ~/.ssh/authorized_keys; echo "key authorized (forced command)"; }'
fi

cat <<EOF

Next:
  1. On $HOST: edit ~/.s5_ro/targets.json and fill the read-only passwords.
  2. Login mode: connections.json -> { "ssh": "$HOST", "gate": "TRD" }
     Test: echo "SELECT current_user" | ssh -o RemoteCommand=none -T $HOST "python3 ~/.s5_ro/s5_ro_gate.py TRD postgres"
  Forced-command mode (--authorize) only — add to ~/.ssh/config (copy HostName/User/ProxyJump from '$HOST'; NO RemoteCommand):
       Host ${HOST}-ro
         HostName <same as $HOST>
         User <same as $HOST>
         IdentityFile $KEY
         IdentitiesOnly yes
         RequestTTY no
     Test:  echo "SELECT current_user" | ssh ${HOST}-ro "TRD postgres"
EOF
