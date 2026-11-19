"""Studio API: keep the Metrics Catalog aligned with QA (Sync with QA DB, Pull metrics from QA).
Long steps (OCI pull + metric map rebuild) run as a background job the UI polls."""
import json, subprocess, sys, threading, time, traceback
from pathlib import Path
from fastapi import APIRouter, Body, HTTPException

from core import qa_align as QA, qa_import as QI, run as R
import spec_api

router = APIRouter(prefix="/api/v2/sync")
CTX = {}          # set by server.py: {"client", "env", "dims", "on_config": fn(new_cfg_dir, new_map)}
JOBS = {}
SCOPE = {"HistoryFit", "HistoryFitTYLY", "HistoryFitTYLYTranspose"}     # phase 1: Style Color Review
HERE = Path(__file__).resolve().parent.parent


def _job(kind, fn):
    if JOBS.get(kind, {}).get("state") == "running":
        raise HTTPException(409, f"{kind} is already running")
    JOBS[kind] = {"state": "running", "step": "starting", "started": time.time()}
    def run():
        try:
            JOBS[kind].update(state="done", result=fn(lambda s: JOBS[kind].update(step=s)))
        except Exception as e:
            JOBS[kind].update(state="failed", error=f"{type(e).__name__}: {e}", trace=traceback.format_exc()[-2000:])
    threading.Thread(target=run, daemon=True).start()
    return JOBS[kind]


def _mdir():
    return QA.mdir(CTX["client"])


@router.get("/status")
def status():
    import config_sync as CS
    st = CS.status(CTX["client"])
    m = _mdir()
    return {"jobs": {k: {x: v for x, v in j.items() if x != "result"} for k, j in JOBS.items()},
            "config": next((s for s in st["sources"] if s["source"] == CTX["env"]), {}),
            "maps": {n: int(p.stat().st_mtime) for n in ("metric_map.csv", f"metric_map_{CTX['env']}.csv")
                     if (p := m / n).exists()},
            "runs": QA.last_runs(CTX["client"]), "scope": sorted(SCOPE)}


@router.get("/job/{kind}")
def job(kind: str):
    if kind not in JOBS:
        raise HTTPException(404, kind)
    return JOBS[kind]


@router.get("/run/{name}")
def run_file(name: str):
    p = QA.runs_dir(CTX["client"]) / Path(name).name
    if not p.exists():
        raise HTTPException(404, name)
    return json.loads(p.read_text())


@router.post("/qa-db")
def qa_db():
    def go(step):
        step("describing tables on QA ClickHouse")
        sp = spec_api.spec()
        rep = QA.qa_db(CTX["client"], CTX["env"], sp, CTX["dims"],
                       lambda q: R.query(CTX["client"], CTX["env"], q, timeout=120),
                       _mdir() / "ch_schema.json")
        spec_api.CTX["schema"].update({t["table"]: set(t.get("types", {})) | spec_api.CTX["schema"].get(t["table"], set())
                                       for t in rep["tables"] if t["status"] != "missing"})
        return QA.save_run(CTX["client"], "qa_db", rep)
    return _job("qa_db", go)


@router.post("/qa-metrics")
def qa_metrics(body: dict = Body(default={})):
    """refresh=true: pull QA config from OCI and rebuild the QA metric map first (~6 min)."""
    client, env = CTX["client"], CTX["env"]
    def go(step):
        m = _mdir()
        qa_map = m / f"metric_map_{env}.csv"
        if body.get("refresh") or not qa_map.exists():
            import config_sync as CS
            step("pulling QA config from OCI (git base + bucket overlay)")
            res = CS.sync_env(client, env)
            if not res.get("ok"):
                raise RuntimeError(f"config pull failed: {res.get('hint')} {[r['err'][-300:] for r in res.get('results', []) if r['rc']]}")
            step("rebuilding the QA metric map from QA's live config")
            cfg = CS.effective_dir(client, env)
            r = subprocess.run([sys.executable, str(HERE / "metric_map.py"), "--config-dir", str(cfg), "--client", client,
                                "--env", env, "--out", str(qa_map)], capture_output=True, text=True, cwd=str(HERE))
            if r.returncode != 0:
                raise RuntimeError("metric map rebuild failed: " + r.stderr[-800:])
            if CTX.get("on_config"):
                CTX["on_config"](cfg, qa_map)
        step("comparing QA screens with the catalog")
        rep = QA.qa_metrics(client, spec_api.spec(), SCOPE, qa_map, m / "metric_map.csv")
        return QA.save_run(client, "qa_metrics", rep)
    return _job("qa_metrics", go)


@router.post("/qa-metrics/apply")
def apply(body: dict = Body(...)):
    """add the chosen new QA columns (and screens) to the catalog as drafts."""
    items, screens = body.get("items") or [], body.get("screens") or []
    if not items and not screens:
        raise HTTPException(422, "nothing selected")
    user = body.get("user") or spec_api.CTX.get("user", "")
    try:
        return QA.apply_new(spec_api.store(), items, user, screens)
    except ValueError as e:
        raise HTTPException(422, str(e))


@router.post("/qa-import")
def qa_import(body: dict = Body(default={})):
    """dry run: translate QA's pivots into catalog rows (report only, nothing written)."""
    pivots = body.get("pivots") or sorted(SCOPE)
    def go(step):
        step(f"translating {', '.join(pivots)} from the QA config")
        rep = QI.translate(CTX["client"], pivots, spec_api.spec(), CTX["env"])
        rep["file"] = QI.save(rep, CTX["client"]).name
        return rep
    return _job("qa_import", go)


@router.post("/qa-import/apply")
def qa_import_apply(body: dict = Body(...)):
    """add a saved import's new rows (or the picked bindings and what they need) as drafts."""
    p = QI.HUB / "customers" / CTX["client"].upper() / "metrics" / "qa_import" / Path(body.get("file", "")).name
    if not p.exists():
        raise HTTPException(404, "import report not found - run the dry run first")
    rep = json.loads(p.read_text())
    pick = {tuple(x) for x in body["pick"]} if body.get("pick") else None
    user = body.get("user") or spec_api.CTX.get("user", "")
    try:
        return QI.apply(spec_api.store(), rep, user, pick)
    except Exception as e:
        raise HTTPException(422, f"{type(e).__name__}: {e}")
