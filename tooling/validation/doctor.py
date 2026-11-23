"""Setup check for the Data Validation Studio. Each check -> ok + a fix you can act on.

    python3 tooling/validation/doctor.py [--client TRD]
Exit 0 when everything needed to run validations is in place.
"""
import argparse, importlib, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
HUB = HERE.parent.parent
sys.path.insert(0, str(HERE))


def _check(name, fn):
    try:
        ok, detail, fix = fn()
    except Exception as e:
        ok, detail, fix = False, str(e)[:300], ""
    return {"check": name, "ok": ok, "detail": detail, "fix": "" if ok else fix}


def _deps():
    missing = []
    for m in ("fastapi", "uvicorn", "psycopg", "numpy"):
        try:
            importlib.import_module(m)
        except Exception:
            missing.append(m)
    return (not missing, "python packages ok" if not missing else f"missing: {', '.join(missing)}",
            "pip install -r tooling/validation/ui/requirements.txt (studio.sh does this)")


def _git_user():
    u = subprocess.run(["git", "config", "user.email"], capture_output=True, text=True, cwd=HUB).stdout.strip()
    return bool(u), u or "not set", 'git config --global user.email "you@s5stratos.com" (edits are recorded under it)'


def _qa_ssh():
    r = subprocess.run(["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=8", "-o", "RemoteCommand=none", "-T",
                        "qa-processor", "true"],
                       capture_output=True, text=True, timeout=20)
    return (r.returncode == 0, "ssh qa-processor ok" if r.returncode == 0 else (r.stderr.strip()[-200:] or "failed"),
            "VPN on? Add a 'Host qa-processor' entry (HostName internal-qa-processor, your User + key) to ~/.ssh/config")


def _qa_gate(client):
    def f():
        from core import run as R
        R.query(client, "qa", "SELECT 1", timeout=30)
        return True, "read-only gate answers", ""
    return f


def _dvs_env():
    from core import catalog_db as C
    return (C.configured(), f"{C.ENV_FILE}" if C.configured() else f"{C.ENV_FILE} missing or incomplete",
            f"create {C.ENV_FILE} with DVS_DB_HOST=localhost, DVS_DB_PORT=15432, DVS_DB_NAME=ucm, "
            "DVS_DB_USER=dvs_app, DVS_DB_PASSWORD=<ask the DVS owner, privately>")


def _catalog():
    from core import catalog_db as C, tunnel
    if not C.configured():
        return False, "skipped: no ~/.config/dvs/.env", "fix the check above first"
    n = C.connect().execute("SELECT count(*) AS n FROM dvs.metrics").fetchone()["n"]
    t = tunnel.status()
    via = f" via {t['ssh']}" if t["ssh"] else ""
    return True, f"catalog reachable{via}: {n} metrics", ""


def _catalog_fix(res):
    if not res["ok"] and "tunnel" in res["detail"]:
        res["fix"] = ("ssh <you>@internal-dev-ucm-0 must work without a password prompt; "
                      "or set DVS_TUNNEL_SSH in ~/.config/dvs/.env")
    return res


def _config(client):
    def f():
        import config_sync as cs
        d = cs.effective_dir(client, "qa") or cs.effective_dir(client, "repo")
        return (bool(d), str(d) if d else "no config clone",
                f"python3 tooling/validation/config_sync.py --client {client} --sync-env qa "
                "(needs GitHub access + OCI CLI; studio.sh runs it)")
    return f


def run(client="TRD", quick=False):
    out = [_check("python packages", _deps), _check("git user", _git_user), _check("config", _config(client)),
           _check("ssh qa-processor", _qa_ssh)]
    if out[-1]["ok"] and not quick:
        out.append(_check("QA read-only gate", _qa_gate(client)))
    out.append(_check("~/.config/dvs/.env", _dvs_env))
    out.append(_catalog_fix(_check("catalog DB", _catalog)))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--client", default="TRD")
    a = ap.parse_args()
    res = run(a.client)
    for r in res:
        print(f"{'✓' if r['ok'] else '✗'} {r['check']:<20} {r['detail']}")
        if r["fix"]:
            print(f"  → {r['fix']}")
    sys.exit(0 if all(r["ok"] for r in res) else 1)


if __name__ == "__main__":
    main()
