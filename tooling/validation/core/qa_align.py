"""
Keep the Metrics Catalog aligned with a client's QA environment.

  qa_db(...)        Sync with QA DB: DESCRIBE every table the catalog reads, flag columns the
                    catalog uses that QA ClickHouse does not have, and report data freshness.
  qa_metrics(...)   Pull metrics from QA: diff QA's live screens (metric map built from the
                    OCI-overlaid config) against the catalog bindings: new / removed columns,
                    changed screen rollups, and where QA's pivot differs from git.
  apply_new(...)    add chosen new QA columns (and screens) to the catalog as drafts.

Nothing here changes an existing catalog row: formulas stay owned by the catalog; QA changes
are reported for a human to accept.
"""
import csv, datetime, json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from core import spec as SP

HUB = Path(__file__).resolve().parents[3]


def mdir(client):
    return HUB / "customers" / client.upper() / "metrics"


def runs_dir(client):
    d = mdir(client) / "sync_runs"
    d.mkdir(exist_ok=True)
    return d


def save_run(client, kind, report):
    """keep every run (local json); the Studio lists them."""
    ts = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    report = {**report, "kind": kind, "ran_at": datetime.datetime.now().isoformat(timespec="seconds")}
    (runs_dir(client) / f"{ts}-{kind}.json").write_text(json.dumps(report, indent=1, default=str))
    return report


def last_runs(client, limit=10):
    out = []
    for f in sorted(runs_dir(client).glob("*.json"), reverse=True)[:limit]:
        r = json.loads(f.read_text())
        out.append({"file": f.name, "kind": r.get("kind"), "ran_at": r.get("ran_at"),
                    "counts": r.get("counts", {})})
    return out


# ---------------------------------------------------------------- Sync with QA DB
def catalog_columns(spec, dims):
    """{table: {column: [who uses it]}} for every column the catalog and scope read."""
    need = {}
    def use(t, c, who):
        if t and c:
            need.setdefault(t, {}).setdefault(c, []).append(who)
    for sid, s in spec["sources"].items():
        for k in ("item_key", "location_key", "time_key"):
            use(s["table"], s.get(k), f"source {sid}.{k}")
        for lf in (s.get("level_filters") or "").split(","):
            use(s["table"], lf.strip(), f"source {sid}.level_filters")
    for mid, m in spec["measures"].items():
        s = spec["sources"].get(m["source_id"], {})
        for c in SP.idents(m["expr"]) + SP.idents(m.get("filter", "")):
            use(s.get("table"), c, f"measure {mid}")
        for a in SP.loc_refs(m.get("filter", "")):
            use(dims["location"]["hier_table"], a, f"measure {mid} (loc.{a})")
        if SP.LEGACY_AGGS.get(m["agg"], m["agg"]) == "sum_funded":
            use(s.get("table"), "strcntwk_funded", f"measure {mid} (sum_funded)")
    for r in spec["populations"]:
        s = spec["sources"].get(r.get("source_id"), {})
        for c in SP.idents(r.get("condition", "")) + SP.idents(r.get("row_filter", "")):
            if r["kind"] != "combine":
                use(s.get("table"), c, f"rule {r['population_id']}.{r['rule_id']}")
    for dim in ("product", "location"):
        d = dims[dim]
        use(d["hier_table"], d["key"], f"scope {dim} key")
        use(d["hier_table"], d.get("latest_by", "updated_at"), f"scope {dim} latest version")
        for lv, x in d["levels"].items():
            use(d["hier_table"], x["id"], f"scope {dim} level {lv}")
    t = dims.get("time") or {}
    if t.get("table"):
        use(t["table"], t["week"], "calendar week")
        use(t["table"], t["ty_week"], "calendar LY mapping")
    return need


def qa_db(client, env, spec, dims, query, schema_path=None):
    """query(sql) -> (cols, rows, ms). -> report; refreshes ch_schema.json for these tables."""
    need = catalog_columns(spec, dims)
    def describe(t):
        try:
            _, rows, _ = query(f"DESCRIBE TABLE {t}")
            return t, {r[0]: r[1] for r in rows}, None
        except Exception as e:
            return t, None, str(e)[:300]
    with ThreadPoolExecutor(4) as ex:
        desc = list(ex.map(describe, sorted(need)))
    tables, issues = [], []
    for t, cols, err in desc:
        uses = need[t]
        if cols is None:
            issues.append({"level": "error", "table": t, "column": "", "msg": f"table not readable on QA: {err}",
                           "used_by": sorted({w for v in uses.values() for w in v})[:8]})
            tables.append({"table": t, "status": "missing", "columns": 0, "used": len(uses)})
            continue
        missing = [c for c in uses if c not in cols]
        for c in missing:
            issues.append({"level": "error", "table": t, "column": c, "msg": "column not on QA",
                           "used_by": uses[c][:8]})
        tables.append({"table": t, "status": "ok" if not missing else "columns missing",
                       "columns": len(cols), "used": len(uses), "missing": missing,
                       "types": {c: cols[c] for c in uses if c in cols}})
    # freshness: latest week loaded per time-keyed source
    def fresh(s):
        try:
            _, rows, _ = query(f"SELECT max({s['time_key']}), count() FROM {s['table']}")
            return s["source_id"], rows[0][0], rows[0][1]
        except Exception as e:
            return s["source_id"], None, str(e)[:200]
    srcs = [s for s in spec["sources"].values() if s.get("time_key")]
    with ThreadPoolExecutor(3) as ex:
        fr = {sid: {"latest_week": w, "rows": n} for sid, w, n in ex.map(fresh, srcs)}
    for s in spec["sources"].values():
        if not s.get("time_key"):
            fr[s["source_id"]] = {"latest_week": "n/a (no time axis)", "rows": ""}
    if schema_path:                                   # keep the cached schema current
        cache = json.loads(Path(schema_path).read_text()) if Path(schema_path).exists() else {}
        for t, cols, _ in desc:
            if cols is not None:
                cache[t] = sorted(cols)
        Path(schema_path).write_text(json.dumps(cache, indent=1, sort_keys=True))
    counts = {"tables": len(tables), "tables_ok": sum(t["status"] == "ok" for t in tables),
              "errors": len(issues)}
    return {"env": env, "counts": counts, "tables": tables, "issues": issues, "freshness": fr}


# ---------------------------------------------------------------- Pull metrics from QA
def _rows(p):
    with open(p, newline="") as f:
        return list(csv.DictReader(f))


def _by_key(rows, pivots):
    out = {}
    for r in rows:
        if r["pivot"] in pivots and r.get("data_index"):
            k = (r["pivot"], r["viewdefn"], r["data_index"])
            cur = out.setdefault(k, {**r, "screens": set()})
            cur["screens"].add(r.get("screen_view") or "")
    return out


def qa_metrics(client, spec, pivots, qa_map, git_map=None):
    """pivots: the data calls in scope (e.g. Style Color Review). -> report"""
    qa = _by_key(_rows(qa_map), pivots)
    git = _by_key(_rows(git_map), pivots) if git_map and Path(git_map).exists() else {}
    binds = {(b["pivot"], b["viewdefn"], b["data_index"]): b for b in spec["bindings"] if b["pivot"] in pivots}
    in_catalog = set(spec["screens"])
    new, removed, rollup, pivot_changed, unbound = [], [], [], [], []
    for k, r in sorted(qa.items()):
        b = binds.get(k)
        item = {"pivot": k[0], "viewdefn": k[1], "data_index": k[2], "label": r["display_name"],
                "screens": sorted(x for x in r["screens"] if x), "view_formula": r.get("view_formula", ""),
                "base_formula": r.get("base_formula", ""), "status": r.get("status", "")}
        if not b:
            item["metric_guess"] = k[2] if k[2] in spec["metrics"] else ""
            item["screen_in_catalog"] = k[0] in in_catalog
            new.append(item)
        else:
            if (b.get("rollup_formula") or "") != (r.get("view_formula") or ""):
                rollup.append({**item, "catalog_rollup": b.get("rollup_formula", "")})
            if not b.get("metric_id") and b.get("status") != "n/a":
                unbound.append(item)
        g = git.get(k)
        if g and (g.get("base_formula") or "") != (r.get("base_formula") or ""):
            pivot_changed.append({**item, "git_formula": g.get("base_formula", "")})
        elif git and not g:
            pivot_changed.append({**item, "git_formula": "(not in git)"})
    for k, b in sorted(binds.items()):
        if k not in qa:
            removed.append({"pivot": k[0], "viewdefn": k[1], "data_index": k[2], "label": b.get("label", ""),
                            "metric_id": b.get("metric_id", "")})
    screens = []
    for p in sorted(pivots):
        cols = [k for k in qa if k[0] == p]
        screens.append({"pivot": p, "in_catalog": p in in_catalog, "qa_columns": len(cols),
                        "bound": sum(1 for k in cols if binds.get(k, {}).get("metric_id")),
                        "new": sum(1 for x in new if x["pivot"] == p)})
    counts = {"qa_columns": len(qa), "new": len(new), "removed": len(removed), "rollup_changed": len(rollup),
              "pivot_changed_vs_git": len(pivot_changed), "unbound": len(unbound)}
    return {"counts": counts, "screens": screens, "new": new, "removed": removed, "rollup_changed": rollup,
            "pivot_changed_vs_git": pivot_changed, "unbound": unbound}


def apply_new(store, items, user, screens=(), today=None):
    """add screens (drafts) first, then the chosen new columns as draft bindings."""
    today = today or datetime.date.today().isoformat()
    added = {"screens": [], "bindings": []}
    for s in screens:
        store.upsert("screens", {"pivot": s["pivot"], "population_id": s["population_id"],
                                 "time_mode": s.get("time_mode", "history"),
                                 "split_by_class": s.get("split_by_class", "yes"),
                                 "notes": f"added from QA config {today}"}, user)
        added["screens"].append(s["pivot"])
    for it in items:
        store.upsert("bindings", {"pivot": it["pivot"], "viewdefn": it["viewdefn"], "data_index": it["data_index"],
                                  "label": it.get("label") or it["data_index"],
                                  "metric_id": it.get("metric_id") or it.get("metric_guess") or "",
                                  "period": it.get("period") or "ty",
                                  "rollup_formula": it.get("view_formula", ""),
                                  "notes": f"pulled from QA config {today}"}, user)
        added["bindings"].append(f"{it['viewdefn']}.{it['data_index']}")
    return added
