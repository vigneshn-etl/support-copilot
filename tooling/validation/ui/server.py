#!/usr/bin/env python3
"""
Data Validation Studio — web UI backend.

Same shape as tooling/lineage-viz: FastAPI serving a single-page UI + a small
JSON API. Reads the validation catalog (catalog.db) and the composer to turn a
picked (screen, view, scope) into a CH-correct, consistency-annotated query.

Run locally (needs a real disk for SQLite + the config repo on disk):
  CONFIG_DIR=/path/to/trd-configs \
  CATALOG_DB=/path/to/support-copilot/customers/TRD/lineage/catalog.db \
  uvicorn server:app --port 8770 --reload
(or ./run.sh)
"""
import json, os, sqlite3, sys
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

ROOT = Path(__file__).resolve().parent
VALID = ROOT.parent                      # tooling/validation
sys.path.insert(0, str(VALID))
import compose as composer                # compose.compose(url, cfg, which, catalog)
import compare as cmpmod                  # execute + compare vs UI

HUB = VALID.parent.parent                # support-copilot
CONFIG_DIR = os.environ.get("CONFIG_DIR", "")
CATALOG_DB = os.environ.get(
    "CATALOG_DB", str(HUB / "customers" / "TRD" / "lineage" / "catalog.db"))
CLIENT = os.environ.get("CLIENT", "TRD")
CH_DSN = os.environ.get("CH_DSN", "")     # read-only ClickHouse DSN (server-side only)

# product grain levels observed in real requests (aggBy=level:<x>)
GRAINS = ["stylecolor", "style", "class", "subclass", "department"]

app = FastAPI(title="Data Validation Studio")


def db():
    if not Path(CATALOG_DB).exists():
        raise HTTPException(500, f"catalog not found: {CATALOG_DB} — build it with "
                                 f"build_catalog.py on a real disk.")
    con = sqlite3.connect(f"file:{CATALOG_DB}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


@app.get("/api/config")
def config():
    return {"client": CLIENT, "config_dir": CONFIG_DIR,
            "catalog": CATALOG_DB, "catalog_present": Path(CATALOG_DB).exists(),
            "config_present": bool(CONFIG_DIR) and Path(CONFIG_DIR).exists(),
            "ch_available": bool(CH_DSN),   # is read-only CH wired? (creds stay server-side)
            "grains": GRAINS}


@app.get("/api/modules")
def modules():
    con = db()
    rows = con.execute("SELECT tab, count(*) n FROM view_index "
                       "WHERE tab IS NOT NULL GROUP BY tab ORDER BY tab").fetchall()
    con.close()
    return [{"module": r["tab"], "views": r["n"]} for r in rows]


@app.get("/api/screens")
def screens(module: str):
    con = db()
    rows = con.execute(
        "SELECT DISTINCT screen FROM view_index WHERE tab=? AND screen IS NOT NULL "
        "ORDER BY screen", (module,)).fetchall()
    con.close()
    return [r["screen"] for r in rows]


@app.get("/api/views")
def views(module: str, screen: str):
    con = db()
    rows = con.execute(
        "SELECT vi.view, vi.model, vi.pivot, vi.base, co.verdict "
        "FROM view_index vi LEFT JOIN consistency co ON co.pivot=vi.pivot "
        "WHERE vi.tab=? AND vi.screen=? ORDER BY vi.view", (module, screen)).fetchall()
    con.close()
    return [dict(r) for r in rows]


@app.get("/api/pivot")
def pivot(pivot: str):
    con = db()
    p = con.execute("SELECT * FROM pivots WHERE pivot=?", (pivot,)).fetchone()
    c = con.execute("SELECT * FROM consistency WHERE pivot=?", (pivot,)).fetchone()
    sib = []
    if c and c["base"]:
        sib = [r["pivot"] for r in con.execute(
            "SELECT pivot FROM consistency WHERE base=? AND verdict='majority' "
            "AND pivot!=? LIMIT 8", (c["base"], pivot)).fetchall()]
    con.close()
    if not p:
        raise HTTPException(404, f"pivot not in catalog: {pivot}")
    out = dict(p)
    for k in ("grain", "metrics", "metric_aggs"):
        try: out[k] = json.loads(out[k]) if out[k] else None
        except Exception: pass
    out["consistency"] = dict(c) if c else None
    out["siblings"] = sib
    return out


@app.get("/api/compose")
def compose(pivot: str, grain: str = "stylecolor", criteria: str = "hist",
            flowStatus: str = "", topMembers: str = ""):
    if not CONFIG_DIR or not Path(CONFIG_DIR).exists():
        raise HTTPException(500, "CONFIG_DIR (trd-configs) not set/found — needed to read the pivotdefn.")
    from urllib.parse import quote
    url = (f"api/pivot3/listData?aggBy=level:{quote(grain)}&appName=Assortment"
           f"&defnId={quote(pivot)}&flowStatus={quote(flowStatus)}")
    if topMembers:
        url += f"&topMembers={quote(topMembers)}"
    sql = composer.compose(url, CONFIG_DIR, criteria,
                           CATALOG_DB if Path(CATALOG_DB).exists() else None)
    return {"pivot": pivot, "grain": grain, "criteria": criteria, "sql": sql}


@app.get("/api/execute")
def execute(pivot: str, grain: str = "stylecolor", criteria: str = "hist",
            weeks: str = "", expected: str = "{}",
            flowStatus: str = "", topMembers: str = ""):
    """Compose → run on ClickHouse → summarize → compare to UI values.
    CH_DSN lives server-side only (never sent to the browser)."""
    if not CH_DSN:
        raise HTTPException(400, "CH_DSN not set — a read-only ClickHouse DSN is required to execute.")
    wlist = [w.strip() for w in weeks.split(",") if w.strip()]
    if not wlist:
        raise HTTPException(400, "provide 'weeks' (comma list of week ids).")
    sql = compose(pivot, grain, criteria, flowStatus, topMembers)["sql"]
    info = cmpmod.chv.probe_version(CH_DSN)
    if not info.get("version"):
        raise HTTPException(502, f"ClickHouse unreachable: {info.get('version_error')}")
    try:
        header, rows = cmpmod.run(sql, CH_DSN, wlist, 200000)
    except Exception as e:
        raise HTTPException(502, f"query failed on CH: {e}")
    summary = cmpmod.summarize(header, rows)
    exp = json.loads(expected or "{}")
    match, details = None, []
    if exp:
        ok, det = cmpmod.compare(summary, exp)
        match = ok
        details = [{"metric": d[0], "ui": d[1], "db": d[2], "verdict": d[3]} for d in det]
    return {"version": info["version"], "weeks": len(wlist),
            "summary": summary, "match": match, "details": details}


@app.get("/")
def index():
    return FileResponse(ROOT / "static" / "index.html")


app.mount("/static", StaticFiles(directory=ROOT / "static"), name="static")
