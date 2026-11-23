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
import json, os, sqlite3, subprocess, sys
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

ROOT = Path(__file__).resolve().parent
VALID = ROOT.parent                      # tooling/validation
sys.path.insert(0, str(VALID))
import compose as composer                # compose.compose(url, cfg, which, catalog)
import compare as cmpmod                  # execute + compare vs UI
import route_resolver as rr               # app URL -> screen/model/pivot
import view_metrics as vmet               # viewdefn label metrics -> CH exprs
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent / "triage"))
import repo_sync_check as reposync         # is the tool checkout current with origin?
import config_sync as cfgsync             # repo vs live-QA (OCI overlay) config sources
try:
    import members as members_mod          # live scope/filter members from read-only DB
except Exception:
    members_mod = None

HUB = VALID.parent.parent                # support-copilot
CLIENT = os.environ.get("CLIENT", "TRD")
ENV = os.environ.get("DVS_ENV", "qa")
# default: what QA actually runs (git base + OCI overlay), when it has been pulled
CONFIG_DIR = os.environ.get("CONFIG_DIR") or str(cfgsync.effective_dir(CLIENT, ENV) or "")
CATALOG_DB = os.environ.get(
    "CATALOG_DB", str(HUB / "customers" / "TRD" / "lineage" / "catalog.db"))
CH_DSN = os.environ.get("CH_DSN", "")     # read-only ClickHouse DSN (server-side only)

# Config source switching: 'repo' = whatever CONFIG_DIR/CATALOG_DB you launched
# with; an env (e.g. 'qa') = the OCI-overlaid effective dir synced via config_sync.
REPO_CONFIG_DIR, REPO_CATALOG = CONFIG_DIR, CATALOG_DB
ACTIVE = {"source": "repo"}


def _build_catalog(config_dir, catalog_db):
    Path(catalog_db).parent.mkdir(parents=True, exist_ok=True)
    r = subprocess.run([sys.executable, str(VALID / "build_catalog.py"),
                        "--config-dir", str(config_dir), "--db", str(catalog_db)],
                       capture_output=True, text=True)
    return r.returncode == 0, (r.stderr or r.stdout)[-600:]

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
            "source": ACTIVE["source"],
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


# ---- metric map (customers/<CLIENT>/metrics/metric_map.csv, built by metric_map.py)
_MDIR = HUB / "customers" / CLIENT / "metrics"
METRIC_MAP = os.environ.get("METRIC_MAP") or str(
    _MDIR / f"metric_map_{ENV}.csv" if (_MDIR / f"metric_map_{ENV}.csv").exists() else _MDIR / "metric_map.csv")
_MM = {"mtime": None, "rows": []}


def metric_rows():
    import csv
    p = Path(METRIC_MAP)
    if not p.exists():
        raise HTTPException(500, f"metric map not found: {p} — run metric_map.py")
    if _MM["mtime"] != p.stat().st_mtime:
        with open(p, newline="") as f:
            _MM["rows"] = list(csv.DictReader(f))
        _MM["mtime"] = p.stat().st_mtime
    return _MM["rows"]


@app.get("/api/metrics/search")
def metrics_search(q: str, limit: int = 300):
    """display name / dataIndex search -> every screen occurrence, grouped by name."""
    ql = q.strip().lower()
    if len(ql) < 2:
        return {"groups": [], "total": 0}
    hits = [(i, r) for i, r in enumerate(metric_rows())
            if ql in r["display_name"].lower() or ql in r["data_index"].lower()]
    # exact name matches first, then by name, then resolved first
    hits.sort(key=lambda x: (x[1]["display_name"].lower() != ql, x[1]["display_name"].lower(),
                             x[1]["status"] != "resolved", x[1]["top_nav"], x[1]["left_nav"]))
    groups = {}
    for i, r in hits[:limit]:
        g = groups.setdefault(r["display_name"], [])
        g.append({"id": i, **{k: r[k] for k in (
            "data_index", "top_nav", "left_nav", "screen_view", "viewdefn", "view_section",
            "pivot", "status", "variants", "base_formula", "modules")}})
    return {"groups": [{"name": k, "rows": v} for k, v in groups.items()], "total": len(hits)}


@app.get("/api/metrics/row/{rid}")
def metrics_row(rid: int):
    rows = metric_rows()
    if not 0 <= rid < len(rows):
        raise HTTPException(404, "no such metric row")
    return {"id": rid, **rows[rid]}


# ---- v2: the simple Studio (scope bar like Assortment UI) on the validation core
import validate as vcore
from fastapi import Body
import spec_api

def _studio_user():
    u = os.environ.get("STUDIO_USER")
    if not u:
        try:
            u = subprocess.run(["git", "config", "user.email"], capture_output=True, text=True,
                               cwd=str(HUB)).stdout.strip().split("@")[0]
        except Exception:
            u = ""
    return u or "unknown"

spec_api.CTX.update({"spec_dir": HUB / "customers" / CLIENT / "spec",
                     "metric_map_rows": lambda: metric_rows(), "user": _studio_user()})
app.include_router(spec_api.router)

import sync_api


def _on_qa_config(cfg_dir, qa_map):
    """after Pull metrics from QA: compose against the fresh QA config and map."""
    global CONFIG_DIR, METRIC_MAP
    CONFIG_DIR, METRIC_MAP = str(cfg_dir), str(qa_map)
    _V2.clear()
    vcore._MAP.clear()


sync_api.CTX.update({"client": CLIENT, "env": ENV, "on_config": _on_qa_config})
app.include_router(sync_api.router)


@app.on_event("startup")
def _warm():
    v2_ctx()

_V2 = {}


def v2_ctx():
    if "ctx" not in _V2:
        _V2["ctx"] = vcore.context(CLIENT, CONFIG_DIR or None)
        spec_api.CTX["schema"] = _V2["ctx"]["schema"]
        sync_api.CTX["dims"] = spec_api.CTX["dims"] = _V2["ctx"]["dims"]
    return _V2["ctx"]


def _screen_rows():
    return [r for r in metric_rows() if r.get("pivot")]


@app.get("/api/v2/meta")
def v2_meta():
    d = v2_ctx()["dims"]
    return {"client": CLIENT,
            "product_levels": list(d["product"]["levels"]),
            "location_levels": list(d["location"]["levels"]),
            "price_status": d["filters"]["merchcat"].get("all", []),
            "flow_status": [{"id": int(k), "name": v} for k, v in d["flow_status"]["values"].items()],
            "attribute_filters": {
                "product": sorted({c for c in v2_ctx()["schema"].get(d["product"]["hier_table"], set())
                                   if c.endswith("_name") or c.startswith(("cc_", "sty_", "irw_"))}),
                "location": d["filters"].get("location_attributes", [])}}


@app.get("/api/v2/members/{kind}")
def v2_members(kind: str):
    if members_mod is None:
        raise HTTPException(500, "members provider unavailable")
    try:
        rows = members_mod.get_members(CLIENT, kind)
    except Exception as e:
        raise HTTPException(502, f"{e}")
    if kind == "week":
        rows = sorted(rows, key=lambda r: r["id"])
    return rows


@app.get("/api/v2/doctor")
def v2_doctor():
    """setup checks with fixes (doctor.py); the gate is probed by /api/v2/db."""
    import doctor
    return doctor.run(CLIENT, quick=True)


@app.get("/api/v2/db")
def v2_db():
    """quick read-only gate probe (the Studio shows a status pill)."""
    from core import run as R
    try:
        R.query(CLIENT, "qa", "SELECT 1", timeout=20)
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)[:200]}


@app.get("/api/v2/screens")
def v2_screens():
    """{top_nav: {left_nav: [screen_view…]}} for every screen that shows pivot data."""
    tree = {}
    for r in _screen_rows():
        tree.setdefault(r["top_nav"], {}).setdefault(r["left_nav"], [])
        v = r["screen_view"] or "(main)"
        if v not in tree[r["top_nav"]][r["left_nav"]]:
            tree[r["top_nav"]][r["left_nav"]].append(v)
    return tree


@app.get("/api/v2/screen")
def v2_screen(top: str, left: str, view: str):
    """data calls (one per pivot) on a screen, each with its metrics."""
    v = "" if view == "(main)" else view
    calls = {}
    for r in _screen_rows():
        if r["top_nav"] != top or r["left_nav"] != left or r["screen_view"] != v:
            continue
        c = calls.setdefault((r["pivot"], r["viewdefn"]), {"pivot": r["pivot"], "viewdefns": [], "metrics": [],
                                          "route": None, "top_nav_id": r["top_nav_id"],
                                          "screen_id": r["screen_id"]})
        if r["viewdefn"] not in c["viewdefns"]:
            c["viewdefns"].append(r["viewdefn"])
        key = (r["display_name"], r["data_index"], r["view_formula"])
        if key not in {(m["label"], m["data_index"], m["view_formula"]) for m in c["metrics"]}:
            c["metrics"].append({"label": r["display_name"], "data_index": r["data_index"],
                                 "view_formula": r["view_formula"], "viewdefn": r["viewdefn"],
                                 "status": r["status"], "renderer": r["renderer"],
                                 "variants": r.get("variants", "")})
    # rollup bars first (that's what people check), then by size
    return sorted(calls.values(), key=lambda c: (not any("rollup" in v.lower() for v in c["viewdefns"]),
                                                 -len(c["metrics"])))


@app.get("/api/v2/route")
def v2_route(url: str):
    """paste an S5 URL -> top/left/view (via the confdefn route + metric map)."""
    out = rr.resolve_url(CONFIG_DIR, url)
    views = set(out.get("views") or [])
    for r in _screen_rows():
        if r["viewdefn"] in views or (out.get("pivot") and r["pivot"] == out["pivot"]):
            return {"top": r["top_nav"], "left": r["left_nav"], "view": r["screen_view"] or "(main)",
                    "pivot": out.get("pivot"), "warnings": out.get("warnings", [])}
    raise HTTPException(404, f"route not matched: {out.get('warnings')}")


@app.post("/api/v2/validate")
def v2_validate(req: dict = Body(...), rows_limit: int = 500, sql_only: bool = False):
    req.setdefault("client", CLIENT)
    req.setdefault("env", "qa")
    res = vcore.validate(req, v2_ctx(), sql_only=sql_only)
    if res.get("rows") and len(res["rows"]) > rows_limit:
        res["rows_truncated"] = len(res["rows"])
        res["rows"] = res["rows"][:rows_limit]
    res["request_json"] = {k: v for k, v in req.items()}
    return res


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


def _csv(s):
    return [x.strip() for x in (s or "").split(",") if x.strip()]


def _ch_scope_subquery(scope_kind, members):
    """Build a compact CH hierarchy subquery for a scope selection, e.g.
    'SELECT stylecolor FROM trd_stylecolor_hier_attr WHERE department IN (...)'.
    Driven by members_queries.json → ch_hierarchy. Returns None if unconfigured."""
    if members_mod is None or not members:
        return None
    hq = (members_mod.QUERIES.get(CLIENT, {}) or {}).get("ch_hierarchy") or {}
    for dim, cfg in hq.items():
        if not isinstance(cfg, dict):
            continue                       # skip _readme etc.
        col = (cfg.get("scopes") or {}).get(scope_kind)
        if col:
            leaf, table = cfg["leaf"], cfg["table"]
            vcol = cfg.get("version_col")
            inlist = ", ".join("'" + str(m).replace("'", "''") + "'" for m in members)
            if vcol:
                # latest version per leaf, then filter scope on that current row
                # (mirrors the pivots: (product, updated_at) IN (…max…))
                return (f"SELECT {leaf} FROM {table} "
                        f"WHERE ({leaf}, {vcol}) IN (SELECT {leaf}, max({vcol}) FROM {table} GROUP BY {leaf}) "
                        f"AND {col} IN ({inlist})")
            return f"SELECT {leaf} FROM {table} WHERE {col} IN ({inlist})"
    return None


@app.get("/api/compose")
def compose(pivot: str, grain: str = "stylecolor", criteria: str = "hist",
            flowStatus: str = "", topMembers: str = "",
            weeks: str = "", location: str = "", cluster: str = "", department: str = "",
            channel: str = "", prodlife: str = "", metrics: str = "",
            items: str = "", itemCol: str = "product", view: str = "", labels: str = "raw",
            timeKind: str = "", timeValues: str = "", timeWindow: str = "", timeDept: str = ""):
    if not CONFIG_DIR or not Path(CONFIG_DIR).exists():
        raise HTTPException(500, "CONFIG_DIR (trd-configs) not set/found — needed to read the pivotdefn.")
    from urllib.parse import quote
    url = (f"api/pivot3/listData?aggBy=level:{quote(grain)}&appName=Assortment"
           f"&defnId={quote(pivot)}&flowStatus={quote(flowStatus)}")
    if topMembers:
        url += f"&topMembers={quote(topMembers)}"
    filters = {"weeks": _csv(weeks), "location": _csv(location), "cluster": _csv(cluster),
               "department": _csv(department), "channel": _csv(channel), "flowStatus": flowStatus,
               "prodlife": _csv(prodlife), "metrics": _csv(metrics),
               "items": _csv(items), "item_col": itemCol or "product"}
    # Time picker: resolve a selection (range/floorset/quarter/season/…) to a
    # concrete week set live via the read-only DB; falls back to explicit weeks.
    if timeKind and members_mod:
        try:
            r = members_mod.resolve_time(CLIENT, timeKind, _csv(timeValues),
                                         window=(timeWindow or None), dept=(timeDept or None))
            if r["weeks"]:
                filters["weeks"] = r["weeks"]
                filters["time_note"] = r["note"]
        except Exception as e:
            filters["time_note"] = f"time resolve failed: {e}"
    # Scope → a compact ClickHouse hierarchy SUBQUERY (department→stylecolors via
    # trd_stylecolor_hier_attr, channel→stores via trd_store_hier_attr). No giant
    # inlined IN lists, no cross-DB round-trip — all in CH alongside the agg.
    if filters["department"]:
        sq = _ch_scope_subquery("department", filters["department"])
        if sq:
            filters["product_subquery"] = sq
    if filters["channel"]:
        sq = _ch_scope_subquery("channel", filters["channel"])
        if sq:
            filters["location_subquery"] = sq
    # view-label metrics: compose the screen's named metrics (formulas → CH) so
    # the DB output matches the UI 1:1. Falls back to raw columns if the view has
    # no formula columns (e.g. a grid view) or none are groundable.
    if labels == "view" and view:
        try:
            vms = vmet.build_view_metrics(CONFIG_DIR, view)
            if vms:
                filters["view_metrics"] = vms
        except Exception:
            pass
    sql = composer.compose(url, CONFIG_DIR, criteria,
                           CATALOG_DB if Path(CATALOG_DB).exists() else None,
                           filters=filters)
    return {"pivot": pivot, "grain": grain, "criteria": criteria, "sql": sql,
            "weeks": filters.get("weeks") or [], "time_note": filters.get("time_note", "")}


@app.get("/api/execute")
def execute(pivot: str, grain: str = "stylecolor", criteria: str = "hist",
            weeks: str = "", expected: str = "{}",
            flowStatus: str = "", topMembers: str = "",
            location: str = "", cluster: str = "", department: str = "", channel: str = "",
            prodlife: str = "", metrics: str = "", items: str = "", itemCol: str = "product"):
    """Compose → run on ClickHouse → summarize → compare to UI values.
    CH_DSN lives server-side only (never sent to the browser). `weeks` is the
    already-resolved week set (the Time picker resolves range/floorset/quarter →
    weeks at compose time and passes them here)."""
    if not CH_DSN:
        raise HTTPException(400, "CH_DSN not set — a read-only ClickHouse DSN is required to execute.")
    wlist = [w.strip() for w in weeks.split(",") if w.strip()]
    if not wlist:
        raise HTTPException(400, "provide 'weeks' (comma list of week ids), or pick a Time range/floorset.")
    # compose WITHOUT inlining weeks (keep :HISTORY_WEEKS for the runner to substitute),
    # but WITH the scope filters so the executed query matches the composed one.
    sql = compose(pivot, grain, criteria, flowStatus, topMembers,
                  weeks="", location=location, cluster=cluster, department=department,
                  channel=channel, prodlife=prodlife, metrics=metrics,
                  items=items, itemCol=itemCol)["sql"]
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


@app.get("/api/members/{kind}")
def members(kind: str, refresh: bool = False):
    """Live scope/filter members (department, class, location, cluster, week,
    floorset, flow_status) from the read-only DB, for the picker dropdowns."""
    if members_mod is None:
        raise HTTPException(500, "members provider unavailable")
    try:
        return members_mod.get_members(CLIENT, kind, refresh=refresh)
    except Exception as e:
        raise HTTPException(502, f"{e}")


@app.get("/api/repo-freshness")
def repo_freshness(fetch: bool = True):
    """Is the support-copilot checkout current with origin? Powers the UI 'sync'
    nudge so UI-only users get the same prompt as the ticket workflow."""
    try:
        o, _ = reposync.check(do_fetch=fetch)
        return o
    except Exception as e:
        return {"is_git": False, "status": "unknown", "note": str(e)}


@app.get("/api/config-sources")
def config_sources():
    """List the config sources (repo + synced envs) with freshness, and which
    one is active."""
    try:
        st = cfgsync.status(CLIENT)
    except Exception as e:
        raise HTTPException(500, f"{e}")
    st["active"] = ACTIVE["source"]
    return st


@app.post("/api/config-source")
def set_config_source(source: str):
    """Switch the active config source. 'repo' restores the launch config;
    an env (e.g. 'qa') points at its OCI-overlaid effective dir (must be synced
    first). Rebuilds that source's catalog if missing."""
    global CONFIG_DIR, CATALOG_DB
    if source == "repo":
        CONFIG_DIR, CATALOG_DB = REPO_CONFIG_DIR, REPO_CATALOG
    else:
        d = cfgsync.effective_dir(CLIENT, source)
        if not d:
            raise HTTPException(400, f"source '{source}' not synced yet — click Sync first")
        cat = str(Path(d) / "lineage" / "catalog.db")
        if not Path(cat).exists():
            ok, msg = _build_catalog(str(d), cat)
            if not ok:
                raise HTTPException(500, f"catalog build failed for {source}: {msg}")
        CONFIG_DIR, CATALOG_DB = str(d), cat
    ACTIVE["source"] = source
    return {"active": source, "config_dir": CONFIG_DIR,
            "catalog_present": Path(CATALOG_DB).exists(),
            "config_present": bool(CONFIG_DIR) and Path(CONFIG_DIR).exists()}


@app.post("/api/sync-config")
def sync_config(env: str = "qa", print_cmds: bool = False):
    """Sync a live env: git base + `oci os object sync` overlay + build effective
    (+ its catalog). Runs git/oci on the host — needs creds + VPN (your Mac)."""
    try:
        res = cfgsync.sync_env(CLIENT, env, print_cmds=print_cmds)
    except Exception as e:
        raise HTTPException(500, f"{e}")
    if res.get("ok") and not res.get("catalog_built"):
        # sync_env already builds the catalog; only build here if it didn't
        d = cfgsync.effective_dir(CLIENT, env)
        if d:
            ok, msg = _build_catalog(str(d), str(Path(d) / "lineage" / "catalog.db"))
            res["catalog_built"] = ok
            if not ok:
                res["catalog_error"] = msg
    return res


@app.get("/api/resolve-url")
def resolve_url(url: str):
    """Resolve a pasted S5 app URL to {tab(module), screen, view, pivot, model}
    by walking the confdefn pathSlots — so the UI can auto-select the screen."""
    if not CONFIG_DIR or not Path(CONFIG_DIR).exists():
        raise HTTPException(500, "CONFIG_DIR (trd-configs) not set/found.")
    cat = CATALOG_DB if Path(CATALOG_DB).exists() else None
    return rr.resolve_url(CONFIG_DIR, url, cat)


@app.get("/api/whoami")
def whoami():
    """Which DB account actually runs the composer's detail/scope + execution
    queries, and whether it is read-only. Powers the Studio's read-only badge so
    it is explicit the tool queries via s5_copilot_ro, not an admin proxy."""
    if members_mod is None:
        raise HTTPException(500, "db layer unavailable")
    try:
        return members_mod.whoami(CLIENT)
    except Exception as e:
        raise HTTPException(502, f"{e}")


@app.get("/")
def index():
    return FileResponse(ROOT / "static" / "index.html")


app.mount("/static", StaticFiles(directory=ROOT / "static"), name="static")
