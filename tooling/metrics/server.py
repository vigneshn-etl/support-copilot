#!/usr/bin/env python3
"""
Admin Metrics Dashboard — how the copilot is being used.
Same design language as the Lineage Explorer / Validation Studio.

Run (admin):
  USER_EMAIL=vignesh.n@s5stratos.com python3 tooling/metrics/server.py
  # or ./run.sh   -> http://localhost:8771
"""
import json, os, sys
from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

ROOT = Path(__file__).resolve().parent
HUB = ROOT.parent.parent
sys.path.insert(0, str(ROOT))
import rollup as rollup_mod

USER_EMAIL = os.environ.get("USER_EMAIL", "")
app = FastAPI(title="Copilot Metrics")


def _admin_emails():
    try:
        return set(json.loads((HUB / "modes" / "roles.json").read_text()).get("admin_emails", []))
    except Exception:
        return set()


@app.get("/api/config")
def config():
    return {"user": USER_EMAIL, "is_admin": USER_EMAIL in _admin_emails()}


@app.get("/api/metrics")
def metrics():
    return rollup_mod.rollup()


@app.get("/")
def index():
    return FileResponse(ROOT / "static" / "index.html")


app.mount("/static", StaticFiles(directory=ROOT / "static"), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=int(os.environ.get("PORT", "8771")))
