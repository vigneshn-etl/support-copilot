"""Studio API for the metric spec (customers/<CLIENT>/spec): browse, lint, edit, approve,
coverage of a screen, and a one-metric preview on the current scope."""
import csv, re
from pathlib import Path
from fastapi import APIRouter, Body, HTTPException

from core import spec as SP
from core.spec_store import SpecStore, KEYS
from core import catalog_db

router = APIRouter(prefix="/api/v2/spec")
CTX = {}          # set by server.py: {"spec_dir", "schema", "metric_map_rows", "user"}


def store():
    if catalog_db.use_db():
        return catalog_db.CatalogDB(catalog_db.tenant_for(CTX["spec_dir"]))
    return SpecStore(CTX["spec_dir"])


def spec(include_drafts=True):
    return SP.load(CTX["spec_dir"], include_drafts)


def expand(sp, name, depth=0):
    """metric/measure -> plain formula over base columns, e.g. (sum(shp_r) - sum(ret_r))."""
    if depth > 12:
        return name
    if name in sp["measures"]:
        m = sp["measures"][name]
        a = SP.LEGACY_AGGS.get(m["agg"], m["agg"])
        agg = {"sum": "sum", "sum_funded": "sumFunded", "count_distinct": "countDistinct",
               "last_at_max_week": "lastWeek", "first_at_min_week": "firstWeek",
               "count_lastval": "countDistinctLastWeek"}.get(a, a)
        f = f" | {m['filter']}" if m.get("filter") else ""
        return f"{agg}({m['expr']}{f})"
    if name in sp["metrics"]:
        m = sp["metrics"][name]
        def wrap(x):
            return f"({x})" if re.search(r"\s[-+*/]\s", x) else x
        def sub(e):
            def one(mm):
                n = mm.group(0)
                if n == name and n in sp["measures"]:
                    return expand(sp, n, depth + 1)
                if n != name and (n in sp["metrics"] or n in sp["measures"]):
                    return wrap(expand(sp, n, depth + 1))
                return n
            return SP.ID.sub(one, e)
        if m["type"] == "ratio":
            return f"{wrap(sub(m['expr']))} / {wrap(sub(m['denominator']))}"
        return sub(m["expr"])
    return name


def leaves(sp, name, seen=None):
    """base columns a metric reads (for the as-built comparison)."""
    seen = seen if seen is not None else set()
    if name in seen:
        return set()
    seen.add(name)
    if name in sp["measures"]:
        m = sp["measures"][name]
        return set(SP.idents(m["expr"]))        # value columns only; filters live in the read's WHERE
    if name in sp["metrics"]:
        m = sp["metrics"][name]
        out = set()
        for i in SP.idents(m["expr"]) + SP.idents(m.get("denominator", "")):
            out |= leaves(sp, i, seen) if (i != name or i in sp["measures"]) else set()
        return out
    return set()


@router.get("")
def get_spec():
    sp = spec()
    files = {}
    for f in KEYS:
        cols, rows = store().read(f)
        files[f] = {"columns": cols, "rows": rows, "keys": KEYS[f]}
    issues = SP.lint(sp, CTX["schema"], CTX.get("dims"))
    exp = {m: expand(sp, m) for m in list(sp["metrics"]) + list(sp["measures"])}
    used = {}
    for b in sp["bindings"]:
        if b.get("metric_id"):
            used.setdefault(b["metric_id"], []).append(f"{b['viewdefn']} · {b['label']}")
    return {"files": files, "lint": issues, "expanded": exp, "used_by": used}


@router.get("/meta")
def meta():
    sp = spec()
    return {"aggs": [{"id": "sum", "help": "add up over items, stores and weeks"},
                     {"id": "sum_funded", "help": "sum over funded store-weeks only (strcntwk_funded > 0)"},
                     {"id": "count_distinct", "help": "count distinct values (e.g. products, weeks)"},
                     {"id": "last_at_max_week", "help": "value at the LAST week of the window (stock: EOH)"},
                     {"id": "first_at_min_week", "help": "value at the FIRST week of the window (BOH)"},
                     {"id": "count_lastval", "help": "count distinct values in the LAST week only"},
                     {"id": "max", "help": "largest value"}, {"id": "min", "help": "smallest value"},
                     {"id": "avg", "help": "average of rows"}],
            "windows": [{"id": "selected", "help": "the scope's weeks (history or assortment)"},
                        {"id": "receipt", "help": "receipt-week filter if set, else the scope's weeks"},
                        {"id": "none", "help": "no time axis (e.g. on-order)"}],
            "location_sets": [{"id": "scope", "help": "stores in the selected location"}],
            "rollups": [{"id": "sum", "help": "add across items"},
                        {"id": "max", "help": "largest across items (week counts, store counts)"}],
            "metric_types": [{"id": "simple", "help": "exactly one measure"},
                             {"id": "derived", "help": "arithmetic over measures/metrics"},
                             {"id": "ratio", "help": "numerator / denominator, 0 when denominator ≤ 0"}],
            "periods": [{"id": "ty", "help": "this year (the scope's weeks)"},
                        {"id": "ly", "help": "last year: calendar weeks whose cctytime is a TY week"},
                        {"id": "lly", "help": "two years back, mapped from LY the same way"}],
            "rule_kinds": [{"id": "having", "help": "items whose totals over the window pass a condition"},
                           {"id": "where", "help": "items with any row matching a filter"},
                           {"id": "classify", "help": "assign a class (e.g. flow status) per item"},
                           {"id": "combine", "help": "boolean of rule ids: which items are in"}],
            "sources": {sid: {"table": s["table"], "columns": sorted(CTX["schema"].get(s["table"], set()))}
                        for sid, s in sp["sources"].items()},
            "names": sorted(set(sp["metrics"]) | set(sp["measures"])),
            "populations": sorted({p["population_id"] for p in sp["populations"]}),
            "user": CTX.get("user", ""),
            "store": "ucm.dvs" if catalog_db.use_db() else "csv"}


@router.post("/{file}")
def save(file: str, body: dict = Body(...)):
    row, user = body.get("row") or {}, body.get("user") or CTX.get("user", "")
    if file not in KEYS:
        raise HTTPException(404, file)
    st = store()
    # lint the would-be spec before writing
    cols, rows = st.read(file)
    k = st.key(file, row)
    trial = [r for r in rows if st.key(file, r) != k] + [{**{c: "" for c in cols}, **row,
                                                         "status": "draft", "version": "1"}]
    sp = spec()
    key = SP.FILES[file]
    sp[file] = {r[key]: r for r in trial} if key else trial
    errs = [i for i in SP.lint(sp, CTX["schema"], CTX.get("dims")) if i["level"] == "error" and i["file"] == file
            and (i["key"] == k or i["key"] == row.get(key or ""))]
    if errs and not body.get("force"):
        raise HTTPException(422, {"lint": errs})
    try:
        saved = st.upsert(file, row, user)
    except ValueError as e:
        raise HTTPException(422, str(e))
    return {"row": saved, "lint": errs}


@router.post("/{file}/status")
def status(file: str, body: dict = Body(...)):
    s = body.get("status")
    if s not in ("approved", "draft", "retired"):
        raise HTTPException(422, "status must be approved, draft or retired")
    try:
        return {"row": store().set_status(file, body.get("key") or {}, s, body.get("user") or CTX.get("user", ""))}
    except ValueError as e:
        raise HTTPException(404, str(e))


@router.get("/changelog")
def changelog(limit: int = 200):
    return store().changelog(limit)


@router.get("/coverage")
def coverage(pivot: str, viewdefn: str = ""):
    """a screen section's columns: spec metric, its formula, the pivot's as-built formula, drift."""
    sp = spec()
    built = {}
    for r in CTX["metric_map_rows"]():
        if r["pivot"] == pivot and (not viewdefn or r["viewdefn"] == viewdefn):
            built.setdefault(r["data_index"], r)
    out = []
    for b in sp["bindings"]:
        if b["pivot"] != pivot or (viewdefn and b["viewdefn"] != viewdefn):
            continue
        mid = b.get("metric_id") or ""
        r = built.get(b["data_index"], {})
        piv_leaves = {c.split(".")[-1] for c in (r.get("base_columns") or "").split("|") if c}
        sl = leaves(sp, mid) if mid else set()
        drift = ""
        if mid and piv_leaves and sl and (piv_leaves - {"time", "product", "location"}) != (sl - {"time", "product", "location"}):
            drift = "reads different base columns: spec " + ", ".join(sorted(sl - piv_leaves) or ["—"]) + \
                    " · pivot " + ", ".join(sorted(piv_leaves - sl) or ["—"])
        vf = r.get("view_formula", "")
        if b.get("rollup_formula", "") != vf:
            drift = (drift + " · " if drift else "") + f"screen rollup formula changed: '{vf}'"
        m = sp["metrics"].get(mid, {})
        out.append({**b, "spec_formula": expand(sp, mid) if mid else "",
                    "metric_status": m.get("status", ""), "metric_version": m.get("version", ""),
                    "pivot_formula": r.get("base_formula", ""), "pivot_expr": r.get("pivot_expr", ""),
                    "view_formula": vf, "drift": drift})
    return out
