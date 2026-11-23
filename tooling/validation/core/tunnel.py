"""SSH tunnel to the UCM Postgres (DVS catalog), opened with the caller's own SSH login.

Settings (env or ~/.config/dvs/.env, all optional):
  DVS_TUNNEL_SSH     ssh target for the jump host; default internal-dev-ucm-0 with the
                     User from your qa-processor ssh config when that host has none
  DVS_TUNNEL_TARGET  db host:port as seen from the jump host (default 172.16.50.218:5432)
  DVS_TUNNEL=off     never open a tunnel (DB reached directly)
Only used when DVS_DB_HOST is localhost.
"""
import atexit, getpass, os, socket, subprocess, threading, time

JUMP = "internal-dev-ucm-0"
TARGET = "172.16.50.218:5432"
_state = {"proc": None, "port": None, "ssh": None, "error": None}
_lock = threading.Lock()


def _open(port):
    try:
        with socket.create_connection(("127.0.0.1", port), timeout=1):
            return True
    except OSError:
        return False


def _ssh_user(host):
    try:
        out = subprocess.run(["ssh", "-G", host], capture_output=True, text=True, timeout=5).stdout
        return next((l.split(None, 1)[1] for l in out.splitlines() if l.startswith("user ")), None)
    except Exception:
        return None


def ssh_target(vals=None):
    """jump host to use; borrows the qa-processor User when the jump host has no ssh config."""
    v = (vals or {}).get("DVS_TUNNEL_SSH") or os.environ.get("DVS_TUNNEL_SSH")
    if v:
        return v
    me = getpass.getuser()
    if _ssh_user(JUMP) in (None, me):
        qa = _ssh_user("qa-processor")
        if qa and qa != me:
            return f"{qa}@{JUMP}"
    return JUMP


def ensure(vals):
    """make sure DVS_DB_HOST:DVS_DB_PORT answers; opens/reuses an ssh -L when it is local.
    -> None, or an error string."""
    host, port = vals.get("DVS_DB_HOST", ""), int(vals.get("DVS_DB_PORT") or 0)
    if host not in ("localhost", "127.0.0.1") or not port:
        return None
    if (vals.get("DVS_TUNNEL") or os.environ.get("DVS_TUNNEL", "")).lower() == "off":
        return None
    with _lock:
        if _open(port):
            return None                                   # ours, or one you started yourself
        p = _state["proc"]
        if p and p.poll() is None:
            p.terminate()
        target = vals.get("DVS_TUNNEL_TARGET") or os.environ.get("DVS_TUNNEL_TARGET") or TARGET
        ssh = ssh_target(vals)
        cmd = ["ssh", "-N", "-o", "BatchMode=yes", "-o", "ConnectTimeout=8", "-o", "ServerAliveInterval=15",
               "-o", "ServerAliveCountMax=4", "-o", "ExitOnForwardFailure=yes",
               "-L", f"{port}:{target}", ssh]
        p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
        _state.update(proc=p, port=port, ssh=ssh, error=None)
        for _ in range(40):                               # up to ~10 s
            if _open(port):
                return None
            if p.poll() is not None:
                break
            time.sleep(0.25)
        err = (p.stderr.read() if p.poll() is not None else "") or "no answer on the tunnel port"
        p.terminate() if p.poll() is None else None
        _state["error"] = f"tunnel via {ssh} failed: {err.strip()[-300:]} (VPN on? ssh {ssh} works?)"
        return _state["error"]


def status():
    p = _state["proc"]
    return {"ssh": _state["ssh"], "port": _state["port"], "error": _state["error"],
            "owned": bool(p and p.poll() is None)}


@atexit.register
def _close():
    p = _state["proc"]
    if p and p.poll() is None:
        p.terminate()
