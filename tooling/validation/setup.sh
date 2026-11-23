#!/usr/bin/env bash
# One-time setup of the Data Validation Studio:  tooling/validation/setup.sh
# Safe to re-run: each step checks first and only changes what is missing.
# Needs the VPN on. Python packages: ui/requirements.txt. Then start with studio.sh.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
HUB="$(cd "$HERE/../.." && pwd)"
CLIENT="${1:-${CLIENT:-TRD}}"
QA_HOST="internal-qa-processor"; UCM_HOST="internal-dev-ucm-0"
CFG_REPO="s5-stratos/trd-configs"
BUCKET="internal-qa-config"; PREFIX="trd/asst/"; REGION="us-chicago-1"
ENV_FILE="$HOME/.config/dvs/.env"
SSHO=(-n -o BatchMode=yes -o ConnectTimeout=8 -o RemoteCommand=none -T)
TODO=()

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; TODO+=("$*"); }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }
ask()  { local a; read -r -p "  $1 [${2:-}]: " a; echo "${a:-${2:-}}"; }
yes()  { local a; read -r -p "  $1 [Y/n]: " a; [[ ! "$a" =~ ^[Nn] ]]; }

step "1. Tools"
command -v python3 >/dev/null && python3 -c 'import sys; sys.exit(sys.version_info < (3, 9))' \
  && ok "python3 $(python3 -V 2>&1 | cut -d' ' -f2)" || bad "python 3.9+ missing: brew install python"
command -v git >/dev/null && ok "git" || bad "git missing: xcode-select --install"
for t in oci gh; do
  if command -v "$t" >/dev/null; then ok "$t"
  elif command -v brew >/dev/null && yes "$t is missing. Install it with Homebrew?"; then
    brew install "$( [ "$t" = oci ] && echo oci-cli || echo gh )" >/dev/null && ok "$t installed" || bad "$t install failed"
  else bad "$t missing: brew install $( [ "$t" = oci ] && echo oci-cli || echo gh )"; fi
done

step "2. Git identity"
EMAIL="$(git -C "$HUB" config user.email || true)"
if [ -z "$EMAIL" ]; then
  EMAIL="$(ask "Your work email (Studio edits are recorded under it)" "")"
  [ -n "$EMAIL" ] && git config --global user.email "$EMAIL"
fi
[ -n "$EMAIL" ] && ok "git user.email $EMAIL" || bad "git user.email not set"

step "3. SSH to QA and UCM"
KEY=""; for k in id_ed25519 id_rsa; do [ -f "$HOME/.ssh/$k" ] && { KEY="~/.ssh/$k"; break; }; done
if [ -z "$KEY" ] && yes "No SSH key found. Create one (~/.ssh/id_ed25519)?"; then
  ssh-keygen -q -t ed25519 -N "" -C "$EMAIL" -f "$HOME/.ssh/id_ed25519" && KEY="~/.ssh/id_ed25519"
  echo "  Send this public key to the infra team for $QA_HOST and $UCM_HOST access:"; cat "$HOME/.ssh/id_ed25519.pub"
fi
if ! grep -qE '^\s*Host\s+.*\bqa-processor\b' "$HOME/.ssh/config" 2>/dev/null; then
  U="$(ask "Your SSH username on QA" "${EMAIL%@*}")"
  mkdir -p "$HOME/.ssh"; touch "$HOME/.ssh/config"; chmod 600 "$HOME/.ssh/config"
  cp "$HOME/.ssh/config" "$HOME/.ssh/config.bak.dvs"
  printf '\nHost qa-processor\n  HostName %s\n  User %s\n  IdentityFile %s\n' "$QA_HOST" "$U" "${KEY:-~/.ssh/id_ed25519}" \
    >> "$HOME/.ssh/config"
  ok "added Host qa-processor to ~/.ssh/config (backup: config.bak.dvs)"
fi
U="$(ssh -G qa-processor 2>/dev/null | awk '/^user /{print $2}')"
ssh "${SSHO[@]}" qa-processor true 2>/dev/null && ok "ssh qa-processor ($U)" \
  || bad "ssh qa-processor failed: VPN on? is your key on $QA_HOST?"
ssh "${SSHO[@]}" "$U@$UCM_HOST" true 2>/dev/null && ok "ssh $U@$UCM_HOST" \
  || bad "ssh $U@$UCM_HOST failed: ask infra for access with the same key"

step "4. Catalog DB login (~/.config/dvs/.env)"
if grep -q '^DVS_DB_PASSWORD=.\+' "$ENV_FILE" 2>/dev/null; then ok "$ENV_FILE"
else
  read -r -s -p "  dvs_app password (ask Vignesh privately; input hidden): " PW; echo
  if [ -n "$PW" ]; then
    mkdir -p "$(dirname "$ENV_FILE")"; umask 077
    printf 'DVS_DB_HOST=localhost\nDVS_DB_PORT=15432\nDVS_DB_NAME=ucm\nDVS_DB_USER=dvs_app\nDVS_DB_PASSWORD=%s\n' "$PW" > "$ENV_FILE"
    chmod 600 "$ENV_FILE"; unset PW; ok "wrote $ENV_FILE"
  else bad "no password entered: re-run setup.sh when you have it"; fi
fi

step "5. GitHub ($CFG_REPO)"
if GIT_SSH_COMMAND="ssh -o BatchMode=yes" git ls-remote "git@github.com:$CFG_REPO.git" HEAD </dev/null >/dev/null 2>&1; then ok "over SSH"
else
  command -v gh >/dev/null && ! gh auth status >/dev/null 2>&1 && yes "Log in to GitHub with gh (browser)?" && gh auth login -w -p https
  command -v gh >/dev/null && gh auth status >/dev/null 2>&1 && gh auth setup-git >/dev/null 2>&1
  git ls-remote "https://github.com/$CFG_REPO.git" HEAD </dev/null >/dev/null 2>&1 && ok "over HTTPS (gh login)" \
    || bad "no GitHub access to $CFG_REPO: ask for access, then gh auth login"
fi

step "6. OCI (QA config bucket)"
if command -v oci >/dev/null; then
  if [ ! -f "$HOME/.oci/config" ]; then
    echo "  OCI CLI is not configured. It needs your user + tenancy OCIDs and an API key uploaded in the OCI console."
    yes "Run 'oci setup config' now?" && oci setup config
  fi
  oci os object list -bn "$BUCKET" --prefix "$PREFIX" --limit 1 --region "$REGION" </dev/null >/dev/null 2>&1 \
    && ok "bucket $BUCKET readable" || bad "cannot read OCI bucket $BUCKET ($REGION): check ~/.oci/config / ask for access"
fi

step "7. Python packages"
VENV="$HERE/ui/.venv"
[ -d "$VENV" ] || python3 -m venv "$VENV"
"$VENV/bin/pip" install -q --upgrade pip >/dev/null 2>&1
"$VENV/bin/pip" install -q -r "$HERE/ui/requirements.txt" && ok "installed ui/requirements.txt" || bad "pip install failed"
PY="$VENV/bin/python"

step "8. QA config + metric map"
CFG="$("$PY" "$HERE/config_sync.py" --client "$CLIENT" --dir qa)"
if [ ! -d "$CFG" ]; then
  echo "  downloading the $CLIENT QA config (git + OCI)…"
  "$PY" "$HERE/config_sync.py" --client "$CLIENT" --sync-env qa >/dev/null 2>&1 || true
  CFG="$("$PY" "$HERE/config_sync.py" --client "$CLIENT" --dir qa)"
fi
[ -d "$CFG" ] && ok "config $CFG" || bad "QA config download failed (fix GitHub/OCI above, then re-run)"
MDIR="$HUB/customers/$CLIENT/metrics"
if [ -d "$CFG" ] && [ ! -s "$MDIR/metric_map_qa.csv" ] && [ ! -s "$MDIR/metric_map.csv" ]; then
  echo "  building the metric map (about 4 minutes)…"
  "$PY" "$HERE/metric_map.py" --config-dir "$CFG" --client "$CLIENT" --env qa \
    --out "$MDIR/metric_map_qa.csv" >/dev/null 2>&1 && ok "metric map built" || bad "metric map build failed"
elif [ -d "$CFG" ]; then ok "metric map present"; fi

step "9. Final check"
"$PY" "$HERE/doctor.py" --client "$CLIENT"
if [ ${#TODO[@]} -eq 0 ]; then
  printf '\nAll set. Start the Studio with:  tooling/validation/studio.sh\n'
else
  printf '\nStill to fix (then re-run setup.sh):\n'; printf '  - %s\n' "${TODO[@]}"
fi
