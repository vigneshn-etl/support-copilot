#!/usr/bin/env python3
"""
Validate S5 screen numbers against the DB — one JSON in, one JSON out.
Built for automation (Playwright) and used by the Data Validation Studio.

  python3 validate.py --request req.json            # compose + run on QA, JSON to stdout
  python3 validate.py --request - < req.json        # same, from stdin
  python3 validate.py --request req.json --sql-only # compose only (no DB)
  python3 validate.py --check-dimensions --client TRD

Request (any of the screen / scope forms; see tooling/validation/core/README.md):
{
  "client": "TRD", "env": "qa",
  "route": "#/bottom-up/hindsighting/style-color-review/summary-view",   # or "screen": {...}
  "defnId": "HistoryFit", "aggBy": "level:stylecolor",                  # from pivot3/listData
  "section": "rollup",                                                    # optional viewdefn filter
  "scope": {"productLevel": "department", "productMember": "DP-48",      # ids or names
            "locationLevel": "channel", "locationMember": "CH-2",
            "historyStart": "2025_W37", "historyEnd": "2025_W40"},
  "filters": {"merchcat": ["FP", "MD"]},                                  # or [{filterId, filterSet}]
  "flowStatus": [0, 1, 2],
  "period": "ly",                                                         # optional: a panel of LY / LLY rows
  "top": {"n": 100, "by": "R$ Sales"},                                    # optional: screen Limit + Sort By
  "metrics": ["R$ Sales", "net_sls_u"],                                   # optional: labels or dataIndex
  "expected": {"totals": {"R$ Sales": "$4.95M"}, "rows": [...], "rowKey": "id"}
}
"""
import argparse, csv, json, re, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import metric_map as mm
from core import compose as C, run as R, replay as RP, spec as SP

HUB = HERE.parent.parent
_QA_CFG = HUB / "customers" / "TRD" / "config" / "effective" / "qa"     # QA live config (config_sync.py)
DEFAULT_CFG = {"TRD": _QA_CFG if (_QA_CFG / "pivot").exists() else HUB.parent / "trd-configs"}


# ---------------------------------------------------------------- context
def context(client, cfg_dir=None):
    mdir = HUB / "customers" / client / "metrics"
    cfg = Path(cfg_dir or DEFAULT_CFG.get(client) or "").resolve()
    if not (cfg / "pivot").exists():
        raise SystemExit(f"config dir not found for {client}: {cfg} (pass --config-dir)")
    dims = json.loads((mdir / "dimensions.json").read_text())
    schema = {t: set(c) for t, c in json.loads((mdir / "ch_schema.json").read_text()).items() if c}
    return {"client": client, "cfg": cfg, "mdir": mdir, "dims": dims, "schema": schema,
            "fams": C.load_families(mdir)}


_MAP = {}


def metric_rows(mdir, env="qa"):
    p = Path(mdir) / f"metric_map_{env}.csv"          # the env's live config, when pulled
    p = p if p.exists() else Path(mdir) / "metric_map.csv"
    if p not in _MAP:
        with open(p, newline="") as f:
            _MAP[p] = list(csv.DictReader(f))
    return _MAP[p]


# ---------------------------------------------------------------- normalize
def _wk(w):
    return re.sub(r"^(\d{4})[-_ ]?W(\d{1,2})$", lambda m: f"{m.group(1)}_W{int(m.group(2)):02d}",
                  str(w).strip(), flags=re.I)


def lookup_member(ctx, req, dim, level, value, warnings):
    """name or id -> id via the hier table (latest version)."""
    d = ctx["dims"][dim]
    lv = d["levels"].get(level)
    if not lv:
        raise ValueError(f"{dim} level '{level}' not in dimensions.json")
    sql = (f"SELECT DISTINCT {lv['id']} FROM {d['hier_table']} "
           f"WHERE {lv['id']} = {C.q(value)} OR {lv['name']} = {C.q(value)} LIMIT 3")
    _, rows, _ = R.query(ctx["client"], req["env"], sql)
    ids = [r[0] for r in rows]
    if not ids:
        raise ValueError(f"{dim} {level} '{value}' not found in {d['hier_table']}")
    if len(ids) > 1:
        warnings.append(f"{dim} '{value}' matched several {level} ids {ids}; using {ids[0]}")
    return ids[0]


def find_level(ctx, req, dim, value):
    """level unknown (e.g. {"product": "048. Wovens"}) -> first level whose id/name matches."""
    d = ctx["dims"][dim]
    for lvl, lv in d["levels"].items():
        sql = (f"SELECT {lv['id']} FROM {d['hier_table']} WHERE {lv['id']} = {C.q(value)} "
               f"OR {lv['name']} = {C.q(value)} LIMIT 1")
        _, rows, _ = R.query(ctx["client"], req["env"], sql)
        if rows:
            return lvl, rows[0][0]
    raise ValueError(f"{dim} '{value}' not found at any level")


def normalize(raw, ctx):
    w = []
    req = {"client": raw.get("client", ctx["client"]), "env": raw.get("env", "qa"), "warnings": w}
    cap = raw.get("capture") or {}                      # raw payloads straight from the browser
    sc = dict(cap.get("scope", {}).get("params") or cap.get("scope") or {})
    sc.update(raw.get("scope") or {})
    ld = cap.get("listData") or {}
    # scope: ids or names; weeks as list or start/end
    for dim, lk, mk, short in (("product", "productLevel", "productMember", "product"),
                               ("location", "locationLevel", "locationMember", "location")):
        if sc.get(mk) and sc.get(lk):
            v = sc[mk]
            ids = ctx["dims"][dim]["levels"][sc[lk]]
            if not re.fullmatch(r"[A-Z]{1,4}-[\w-]+|\d+|[0-9a-f-]{36}", str(v)):
                sc[mk] = lookup_member(ctx, req, dim, sc[lk], v, w)
        elif sc.get(short):
            sc[lk], sc[mk] = find_level(ctx, req, dim, sc[short])
        else:
            raise ValueError(f"scope needs {lk}+{mk} (or '{short}': name)")
    if sc.get("weeks"):
        ws = [_wk(x) for x in sc["weeks"]]
        sc["historyStart"], sc["historyEnd"] = min(ws), max(ws)
        if len(ws) == 2:
            w.append(f"weeks {ws} read as an inclusive range")
    for k in ("historyStart", "historyEnd", "start", "end", "startSales", "endSales"):
        if sc.get(k):
            sc[k] = _wk(sc[k])
    req["scope"] = sc
    # filters
    f = raw.get("filters", cap.get("filterSelections") or {})
    if isinstance(f, list):
        f = {x["filterId"]: x.get("filterSet") or [] for x in f}
    req["general"] = {k: v for k, v in f.items() if ctx["dims"]["filters"].get(k, {}).get("kind") == "general"}
    req["filters"] = {k: v for k, v in f.items() if k not in req["general"]}
    req["flowStatus"] = raw.get("flowStatus") or ld.get("flowStatus")
    if isinstance(req["flowStatus"], str):
        req["flowStatus"] = [int(x) for x in req["flowStatus"].split(",") if x.strip()]
    req["aggBy"] = raw.get("aggBy") or ld.get("aggBy") or "level:stylecolor"
    # screen -> pivot + views
    views, pivot = [], None
    defn = raw.get("defnId") or raw.get("pivot") or ld.get("defnId")
    if defn:
        pivot = mm.model_pivot(ctx["cfg"], defn, None)
        mf = ctx["cfg"] / "uidefn" / "model" / f"{defn}.modeldefn"
        if mf.exists():
            try:
                req["history"] = bool(json.loads(mf.read_text()).get("historyFlag"))
            except Exception:
                pass
    route = raw.get("route") or cap.get("route")
    if route:
        import route_resolver as rr
        rr_out = rr.resolve_url(str(ctx["cfg"]), route)
        views = rr_out.get("views") or []
        pivot = pivot or rr_out.get("pivot")
        w += [f"route: {x}" for x in rr_out.get("warnings", [])]
    scr = raw.get("screen") or {}
    rows = metric_rows(ctx["mdir"])
    if scr and not views:
        def m(a, b):
            return not b or (a or "").strip().lower() == str(b).strip().lower()
        hit = [r for r in rows if m(r["top_nav"], scr.get("topNav")) and m(r["left_nav"], scr.get("leftNav"))
               and m(r["screen_view"], scr.get("view"))]
        views = list(dict.fromkeys(r["viewdefn"] for r in hit))
        pivot = pivot or next((r["pivot"] for r in hit if r["pivot"]), None)
    if raw.get("viewdefn"):
        views = [raw["viewdefn"]] if isinstance(raw["viewdefn"], str) else raw["viewdefn"]
    sec = raw.get("section") or scr.get("section")
    if sec and views:
        keep = [v for v in views if sec.lower().replace(" ", "") in v.lower()]
        if keep:
            views = keep
        else:
            w.append(f"section '{sec}' matched no view of {views}; using all")
    if not pivot:
        raise ValueError("could not resolve the pivot: give defnId, route, or screen")
    req["pivot"], req["views"] = pivot, views
    req.setdefault("history", bool(sc.get("historyStart")))
    # darwin PivotFilterDto: level filters -> their dimension, attributes -> product/location
    fdef, cbd = ctx["dims"]["filters"], {}
    for fid, vals in req["filters"].items():
        if not vals:
            continue
        if fdef.get(fid, {}).get("kind") == "leaf":
            cbd.setdefault(fdef[fid]["dimension"], {})[fid] = vals
        elif fid in fdef.get("location_attributes", []):
            cbd.setdefault("location", {})[fid] = vals
        else:
            cbd.setdefault("product", {})[fid] = vals
    req["conditions_by_dimension"] = cbd
    # metrics
    cand = [r for r in rows if r["pivot"] == pivot and (not views or r["viewdefn"] in views)]
    want = [str(x).lower() for x in (raw.get("metrics") or [])]
    seen, metrics = set(), []
    for r in cand:
        if want and r["display_name"].lower() not in want and r["data_index"].lower() not in want:
            continue
        k = (r["display_name"], r["data_index"], r["view_formula"])
        if k in seen:
            continue
        seen.add(k)
        metrics.append({"label": r["display_name"], "data_index": r["data_index"],
                        "view_formula": r["view_formula"], "viewdefn": r["viewdefn"],
                        "renderer": r["renderer"]})
    if want:
        got = {m["label"].lower() for m in metrics} | {m["data_index"].lower() for m in metrics}
        for x in want:
            if x not in got:
                # not on these views: accept a raw pivot column
                metrics.append({"label": x, "data_index": x, "view_formula": "", "viewdefn": "", "renderer": ""})
                w.append(f"metric '{x}' not on the screen's views; validating pivot column '{x}'")
    if not metrics:
        raise ValueError(f"no metrics for pivot {pivot} views {views}")
    # same label on several columns (LY / ACT / Var LY…): make the result key unique
    from collections import Counter
    dup = Counter(m["label"] for m in metrics)
    for m in metrics:
        if dup[m["label"]] > 1:
            m["label"] = f"{m['label']} ({m['data_index']})"
    per = (raw.get("period") or "").lower()
    if per:                                       # TY/LY panels: same columns, that year's rows
        for m in metrics:
            m["period"] = per
    req["metrics"] = metrics
    req["top"] = raw.get("top") or None
    req["expected"] = raw.get("expected") or {}
    return req


# ---------------------------------------------------------------- compare
def parse_ui(v):
    """'$4.95M' -> (4950000, 5000); '56.34%' -> (0.5634, 0.00005); 198766 -> (198766, 0.5)."""
    if isinstance(v, (int, float)):
        return float(v), 0.5 if float(v).is_integer() else 10 ** -6 * max(1, abs(v))
    s = str(v).strip().replace(",", "").replace("$", "").replace("(", "-").replace(")", "")
    mult, pct = 1.0, s.endswith("%")
    s = s.rstrip("%")
    if s and s[-1] in "KMB":
        mult = {"K": 1e3, "M": 1e6, "B": 1e9}[s[-1]]
        s = s[:-1]
    dec = len(s.split(".")[1]) if "." in s else 0
    val = float(s) * mult
    tol = 0.5 * 10 ** -dec * mult
    if pct:
        val, tol = val / 100, tol / 100
    return val, tol


def compare(res, expected, req):
    out = {"totals": [], "rows": None}
    ok = True
    for label, ev in (expected.get("totals") or {}).items():
        av = res["totals"].get(label)
        e, tol = parse_ui(ev)
        tol = max(tol, (expected.get("tolerance") or {}).get(label, 0))
        good = av is not None and isinstance(av, (int, float)) and abs(av - e) <= tol + 1e-9
        ok &= good
        out["totals"].append({"metric": label, "expected": ev, "expected_value": e,
                              "db": av, "diff": None if av is None or isinstance(av, str) else av - e,
                              "tolerance": tol, "match": good})
    er = expected.get("rows")
    if er:
        key = expected.get("rowKey", "id")
        gk = f"g_{res['resolved']['grain'][0]}" if res["resolved"]["grain"] else None
        db = {str(r.get(gk)): r for r in res["rows"]} if gk else {}
        miss, bad, n = [], [], 0
        for e in er:
            k = str(e.get(key))
            r = db.get(k)
            if r is None:
                miss.append(k)
                continue
            for c, ev in e.items():
                if c == key or c not in r or not isinstance(r[c], (int, float)):
                    continue
                n += 1
                try:
                    e_, tol = parse_ui(ev)
                except Exception:
                    continue
                if abs(r[c] - e_) > max(tol, 1e-6 * abs(e_)):
                    bad.append({"key": k, "col": c, "expected": ev, "db": r[c]})
        extra = sorted(set(db) - {str(e.get(key)) for e in er})
        ok &= not miss and not bad and not extra
        out["rows"] = {"compared_values": n, "mismatches": len(bad), "sample": bad[:25],
                       "missing_in_db": miss[:50], "n_missing_in_db": len(miss),
                       "extra_in_db": extra[:50], "n_extra_in_db": len(extra)}
    return ok, out


# ---------------------------------------------------------------- main
TWO_PHASE_MAX = 2000          # page size: gate returns at most 2100 lines
TWO_PHASE_ITEMS = 12_000      # items per period, fetched in pages
TWO_PHASE_MAX_SQL = 125_000   # gate passes SQL as one argv string (MAX_ARG_STRLEN 128 KiB)


def validate(raw, ctx, sql_only=False, with_rows=True):
    t0 = time.time()
    res = {"status": "ERROR", "warnings": []}
    try:
        req = normalize(raw, ctx)
        res["warnings"] += req.pop("warnings")
        def wq(s, e):
            if not (s and e):
                return []
            if sql_only:                             # no DB round trip just to compose
                import members
                ws = sorted(w["id"] for w in members.get_members(req["client"], "week") if s <= w["id"] <= e)
                if ws:
                    return ws
            try:
                return [r[0] for r in R.query(req["client"], req["env"],
                        f"SELECT week FROM {ctx['dims']['time']['table']} WHERE week >= {C.q(s)} "
                        f"AND week <= {C.q(e)} ORDER BY week", timeout=30)[1]]
            except Exception:
                if not sql_only:
                    raise
                import members                       # DB down: compose from the cached week list
                res["warnings"].append("weeks taken from the cached member list (DB unreachable)")
                return sorted(w["id"] for w in members.get_members(req["client"], "week")
                              if s <= w["id"] <= e)
        sc = req["scope"]
        wh = wq(sc.get("historyStart"), sc.get("historyEnd"))
        wa = wq(sc.get("startSales") or sc.get("start"), sc.get("endSales") or sc.get("end"))
        engine = raw.get("engine") or "spec"
        if engine == "family":
            comp = C.compose(req, ctx)
        elif engine == "replay":
            comp = RP.compose(req, ctx, wh, wa)
        else:
            spec = SP.load(ctx["mdir"].parent / "spec")
            scr = spec["screens"].get(req["pivot"]) or {}
            sel = wh if scr.get("time_mode", "history") == "history" else wa
            rc = req["general"].get("rcpt_weeks") or []
            weeks = {"selected": sel, "receipt": wq(min(rc), max(rc)) if rc else sel}
            for key, gp in (("selected@ly", "ly_sales_weeks"), ("receipt@ly", "ly_rcpt_weeks")):
                lw = req["general"].get(gp) or []        # LY weeks chosen on screen beat the calendar
                if lw:
                    weeks[key] = wq(min(lw), max(lw))
            comp = SP.compose(req, spec, ctx["dims"], weeks)
            if not sql_only and comp.get("q_queries"):
                # two-phase: fetch each period's items once, then run the screen over a literal item list
                # (CH 21.4 re-runs an inlined CTE per reference); skipped when too big for the gate
                items, ok, t1 = {}, True, time.time()
                for qn, qq in comp["q_queries"].items():
                    items[qn] = []
                    while ok:                             # paged: the gate returns at most ~2100 lines
                        cols, _, rows, _ = R.fetch(req["client"], req["env"], f"SELECT item, class FROM ({qq}) "
                                                   f"ORDER BY item LIMIT {TWO_PHASE_MAX} OFFSET {len(items[qn])}")
                        items[qn] += [(r[0], r[1]) for r in rows]
                        if len(rows) < TWO_PHASE_MAX:
                            break
                        ok = len(items[qn]) < TWO_PHASE_ITEMS
                if ok:
                    c2 = SP.compose(req, spec, ctx["dims"], weeks, items=items)
                    if max(len(c2["sql_rows"]), len(c2["sql_totals"] or "")) < TWO_PHASE_MAX_SQL:
                        comp = c2
                        res["two_phase"] = {k: len(v) for k, v in items.items()}
                        res.setdefault("timing_pre", {})["items_ms"] = int((time.time() - t1) * 1000)
            res["provenance"] = comp["provenance"]
        res["warnings"] += comp["warnings"]
        res["request"] = {k: v for k, v in req.items() if k != "expected"}
        res["engine"] = comp.get("engine", "family")
        res["resolved"] = {"pivot": req["pivot"], "engine": comp.get("engine", "family"),
                           "family": comp["family"], "views": req["views"], "ctes": comp.get("ctes"),
                           "grain": comp["grain"], "weeks": comp.get("weeks") or (wh[:1] + wh[-1:]),
                           "metrics": req["metrics"], "criteria": comp["criteria"]}
        res["sql"] = {"rows": comp["sql_rows"], "totals": comp["sql_totals"]}
        if sql_only:
            res["status"] = "COMPOSED"
            return res
        timing = {}
        res["totals"] = {}
        if comp.get("plan"):                        # replay: materialize session tables first
            t1 = time.time()
            with_sql, sess = RP.materialize(comp["plan"], comp["rows_select"], comp["totals_select"],
                                            lambda q: R.fetch(req["client"], req["env"], q))
            timing["session_tables_ms"] = int((time.time() - t1) * 1000)
            res["session_tables"] = sess
            comp["sql_rows"] = with_sql + comp["rows_select"]
            comp["sql_totals"] = (with_sql + comp["totals_select"]) if comp["totals_select"] else None
            res["sql"] = {"rows": comp["sql_rows"], "totals": comp["sql_totals"]}
        if comp["sql_totals"]:
            cols, _, rows, timing["totals_ms"] = R.fetch(req["client"], req["env"], comp["sql_totals"])
            if rows:
                vals = dict(zip(cols, rows[0]))
                res["totals"] = {label: vals.get(alias) for alias, label in comp["totals_map"]}
        if with_rows or comp.get("post"):
            cols, _, rows, timing["rows_ms"] = R.fetch(req["client"], req["env"], comp["sql_rows"])
            res["rows"] = SP.apply_post([dict(zip(cols, r)) for r in rows], comp.get("post"))
            res["row_count"] = len(rows)
        res["timing_ms"] = timing
        if req["expected"]:
            ok, res["compare"] = compare(res, req["expected"], req)
            res["status"] = "MATCH" if ok else "MISMATCH"
        else:
            res["status"] = "OK"
    except Exception as e:
        res["error"] = f"{type(e).__name__}: {e}"
    res["elapsed_ms"] = int((time.time() - t0) * 1000)
    return res


def check_dimensions(ctx, env):
    """every level/filter column in dimensions.json exists on the CH hier tables."""
    sch = json.loads((ctx["mdir"] / "ch_schema.json").read_text())
    probs = []
    for dim in ("product", "location"):
        d = ctx["dims"][dim]
        cols = set(sch.get(d["hier_table"]) or [])
        for lvl, lv in d["levels"].items():
            for k in ("id", "name"):
                if lv[k] not in cols:
                    probs.append(f"{dim}.{lvl}.{k}={lv[k]} not a column of {d['hier_table']}")
    for f in ctx["dims"]["filters"].get("location_attributes", []):
        if f not in set(sch.get(ctx["dims"]["location"]["hier_table"]) or []):
            probs.append(f"location filter {f} not a column of the store hier")
    return probs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--request")
    ap.add_argument("--client", default="TRD")
    ap.add_argument("--config-dir")
    ap.add_argument("--out")
    ap.add_argument("--sql-only", action="store_true")
    ap.add_argument("--no-rows", action="store_true", help="totals only (faster)")
    ap.add_argument("--check-dimensions", action="store_true")
    a = ap.parse_args()
    if a.check_dimensions:
        ctx = context(a.client, a.config_dir)
        p = check_dimensions(ctx, "qa")
        print(json.dumps({"ok": not p, "problems": p}, indent=1))
        sys.exit(1 if p else 0)
    raw = json.load(sys.stdin if a.request in (None, "-") else open(a.request))
    ctx = context(raw.get("client", a.client), a.config_dir)
    res = validate(raw, ctx, a.sql_only, not a.no_rows)
    txt = json.dumps(res, indent=1, default=str)
    if a.out:
        Path(a.out).write_text(txt)
        print(json.dumps({k: res.get(k) for k in ("status", "error", "totals", "row_count", "elapsed_ms")},
                         indent=1, default=str))
    else:
        print(txt)
    sys.exit(0 if res["status"] in ("OK", "MATCH", "COMPOSED") else 1)


if __name__ == "__main__":
    main()
