#!/usr/bin/env python3
"""
Which persona mode do I resolve to? — a deterministic check outside chat.

  python3 modes/whoami.py                 # uses git config user.email
  python3 modes/whoami.py --email you@s5stratos.com
"""
import argparse, json, subprocess
from pathlib import Path

ROLES = Path(__file__).resolve().parent / "roles.json"


def git_email():
    try:
        return subprocess.check_output(["git", "config", "user.email"],
                                       text=True).strip()
    except Exception:
        return ""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--email", default=None)
    a = ap.parse_args()
    r = json.loads(ROLES.read_text())
    email = a.email or git_email()
    admins = r.get("admin_emails", [])
    mode = "admin" if email in admins else r.get("default_mode", "user")
    print(f"email : {email or '(none found — pass --email)'}")
    print(f"mode  : {mode}")
    if mode != "admin":
        print("note  : admin is owner-restricted; '/mode admin' will stay user for you.")


if __name__ == "__main__":
    main()
