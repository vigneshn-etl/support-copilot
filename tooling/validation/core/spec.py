"""
Spec engine — compose a validation query from OUR spec, never from the pivot.

Spec files (customers/<CLIENT>/spec/*.csv, edited in the Studio, versioned per row):
  sources.csv      fact tables: item / location / time keys, which level filters apply
  measures.csv     one aggregate on one source: expr, agg, filter, time_window, location_set, rollup
  metrics.csv      what screens show: simple | derived | ratio (num / den, 0 when den <= 0)
  populations.csv  which items a screen family covers (having / where / classify / combine rules)
  screens.csv      pivot (data call) -> population, time mode, row split
  bindings.csv     screen column (viewdefn + dataIndex) -> metric, + the screen's rollup formula

Query shape (every rule has one slot; provenance comments name the rule ids):
  1 SCOPE       P (products, latest version, product filters)  L (locations)  W_<window> (weeks)
  2 POPULATION  pop_<rule> per rule  ->  Q (item, class)
  3 MEASURES    one grouped scan per (source, time_window, location_set) -> U
  4 METRICS     G: measures re-combined at the grain, metrics computed on top
  5 ROLLUP      totals = the screen's rollup formula over G rows
"""
import csv, re
from pathlib import Path

ID = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
KW = {"and", "or", "not", "in", "is", "null", "case", "when", "then", "else", "end", "if",
      "multiif", "sum", "avg", "min", "max", "count", "true", "false", "as"}
AGGS = ("sum", "sum_funded", "last_at_max_week", "first_at_min_week", "count_distinct", "count_lastval",
        "max", "min", "avg")
LEGACY_AGGS = {"snapshot_last": "last_at_max_week", "snapshot_first": "first_at_min_week"}
FUNDED = "strcntwk_funded > 0.000001"
WINDOWS = ("selected", "receipt", "none")
METRIC_TYPES = ("simple", "derived", "ratio")
PERIODS = ("ty", "ly", "lly")            # ly weeks = calendar weeks whose cctytime is a ty week
PREV = {"ly": "ty", "lly": "ly"}
AT = re.compile(r"@(ty|ly|lly)\b")
ACTIVE = ("approved", "draft")


def q(v):
    return "'" + str(v).replace("\\", "\\\\").replace("'", "\\'") + "'"


def qlist(vs):
    return ", ".join(q(v) for v in vs)


# ---------------------------------------------------------------- load
FILES = {"sources": "source_id", "measures": "measure_id", "metrics": "metric_id",
         "populations": None, "screens": "pivot", "bindings": None}


def load(spec_dir, include_drafts=True):
    from core import catalog_db
    if catalog_db.use_db():
        return catalog_db.load_spec(catalog_db.tenant_for(spec_dir), include_drafts=include_drafts)
    d = Path(spec_dir)
    out = {}
    for name, key in FILES.items():
        p = d / f"{name}.csv"
        rows = list(csv.DictReader(open(p, newline=""))) if p.exists() else []
        rows = [r for r in rows if r.get("status", "approved") != "retired"
                and (include_drafts or r.get("status", "approved") in ("approved", "bound", "n/a", ""))]
        out[name] = {r[key]: r for r in rows} if key else rows
    return out


STR = re.compile(r"'(?:[^'\\]|\\.)*'")


def _mask(expr):
    """blank out string literals (same length) so identifiers inside quotes are ignored."""
    return STR.sub(lambda m: "'" + " " * (len(m.group(0)) - 2) + "'", expr or "")


TOTAL = re.compile(r"\btotal\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)", re.I)   # share of total: sum over all rows
LOC = re.compile(r"\bloc\.([A-Za-z_][A-Za-z0-9_]*)")     # measure filter on a location attribute


def loc_refs(expr):
    """location attributes a measure filter reads as loc.<attr> (e.g. loc.selling_channel)."""
    return list(dict.fromkeys(LOC.findall(_mask(expr))))


def idents(expr):
    e = AT.sub(lambda m: " " * len(m.group(0)), _mask(expr))
    e = LOC.sub(lambda m: " " * len(m.group(0)), e)
    return [m.group(0) for m in ID.finditer(e)
            if m.group(0).lower() not in KW and not (e[m.end():].lstrip()[:1] == "(")
            and not m.group(0)[0].isdigit()]


# ---------------------------------------------------------------- lint
def lint(spec, schema, dims=None):
    """-> [{file, key, level: error|warn, msg}] — run before every save and compose."""
    out = []
    def err(f, k, m, lvl="error"):
        out.append({"file": f, "key": k, "level": lvl, "msg": m})
    src = spec["sources"]
    for sid, s in src.items():
        cols = schema.get(s["table"])
        if cols is None:
            err("sources", sid, f"table {s['table']} not on ClickHouse (ch_schema.json)")
            continue
        for k in ("item_key", "location_key", "time_key"):
            if s.get(k) and s[k] not in cols:
                err("sources", sid, f"{k} {s[k]} is not a column of {s['table']}")
    for mid, m in spec["measures"].items():
        s = src.get(m["source_id"])
        if not s:
            err("measures", mid, f"unknown source {m['source_id']}")
            continue
        cols = schema.get(s["table"], set())
        if LEGACY_AGGS.get(m["agg"], m["agg"]) not in AGGS:
            err("measures", mid, f"agg must be one of {AGGS}")
        if m["time_window"] not in WINDOWS:
            err("measures", mid, f"time_window must be one of {WINDOWS}")
        if m["time_window"] != "none" and not s.get("time_key"):
            err("measures", mid, f"source {s['source_id']} has no time axis; use time_window none")
        if LEGACY_AGGS.get(m["agg"], m["agg"]) in ("last_at_max_week", "first_at_min_week", "count_lastval") \
                and m["time_window"] == "none":
            err("measures", mid, "a snapshot needs a time window")
        for i in idents(m["expr"]) + idents(m.get("filter", "")):
            if i not in cols:
                err("measures", mid, f"{i} is not a column of {s['table']}")
        if loc_refs(m["expr"]):
            err("measures", mid, "loc.<attr> is for the filter only")
        if loc_refs(m.get("filter", "")):
            if not s.get("location_key"):
                err("measures", mid, f"source {s['source_id']} has no location key for loc.<attr>")
            elif dims:
                lt = dims["location"]["hier_table"]
                for a in loc_refs(m["filter"]):
                    if schema.get(lt) is not None and a not in schema[lt]:
                        err("measures", mid, f"loc.{a} is not a column of {lt}")
        if m["rollup"] not in ("sum", "max"):
            err("measures", mid, "rollup must be sum or max")
    names = set(spec["measures"]) | set(spec["metrics"])
    for mid, m in spec["metrics"].items():
        if m["type"] not in METRIC_TYPES:
            err("metrics", mid, f"type must be one of {METRIC_TYPES}")
        if m["type"] == "ratio" and not m.get("denominator"):
            err("metrics", mid, "ratio needs a denominator")
        for i in idents(m["expr"]) + idents(m.get("denominator", "")):
            if i not in names:
                err("metrics", mid, f"{i} is not a measure or metric")
            elif i == mid and i not in spec["measures"]:
                err("metrics", mid, "refers to itself")
    for f, rows in (("measures", spec["measures"].values()), ("metrics", spec["metrics"].values())):
        for m in rows:
            for fld in ("expr", "filter", "denominator"):
                for bad in re.findall(r"@(\w+)", _mask(m.get(fld) or "")):
                    if bad not in PERIODS or f == "measures":
                        err(f, m.get("measure_id") or m.get("metric_id"),
                            f"@{bad}: periods are {', '.join('@' + x for x in PERIODS)}, in metric formulas only")
    for b in spec["bindings"]:
        if (b.get("period") or "ty") not in PERIODS:
            err("bindings", f"{b['viewdefn']}.{b['data_index']}", f"period must be one of {PERIODS}")
        if b.get("metric_id") and b["metric_id"] not in spec["metrics"]:
            err("bindings", f"{b['viewdefn']}.{b['data_index']}", f"metric {b['metric_id']} does not exist")
        for i in idents(b.get("rollup_formula", "")):
            if i not in names:
                err("bindings", f"{b['viewdefn']}.{b['data_index']}",
                    f"rollup formula uses {i}, which is not in the spec", "warn")
    for pv, s in spec["screens"].items():
        rp = [p.strip() for p in (s.get("row_periods") or "ty").split(",") if p.strip()]
        if any(p not in PERIODS for p in rp):
            err("screens", pv, f"row_periods must be from {PERIODS}, e.g. ty or ty,ly")
        for i in idents(s.get("row_filter", "")):
            if i not in names:
                err("screens", pv, f"row filter uses {i}, which is not a measure or metric")
    return out


def refs(expr):
    """-> [(name, period or None)]: identifiers in a formula, with an explicit @period if given."""
    e = _mask(expr)
    out = []
    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)(@(ty|ly|lly)\b)?", e):
        w, nxt = m.group(1), e[m.end():].lstrip()[:1]
        if w.lower() in KW or nxt == "(" or (m.start() and e[m.start() - 1] in "@."):
            continue
        out.append((w, m.group(3)))
    return out


def pcol(name, period):
    """column name of a measure/metric in a period: ty keeps the plain name."""
    return name if period in (None, "", "ty") else f"{name}__{period}"


def at_period(expr, period, names):
    """formula evaluated in `period`: name -> name__period, name@ly -> name__ly (only spec names)."""
    e, out, i = _mask(expr or ""), [], 0
    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)(@(ty|ly|lly)\b)?", e):
        w = m.group(1)
        if w not in names or e[m.end():].lstrip()[:1] == "(" or (m.start() and e[m.start() - 1] in "@."):
            continue
        out.append((expr or "")[i:m.start()] + pcol(w, m.group(3) or period))
        i = m.end()
    return "".join(out) + (expr or "")[i:]


# ---------------------------------------------------------------- closure
def closure_p(spec, wants):
    """[(metric, period)] -> (ordered [(metric, period)], sorted [(measure, period)]) needed."""
    order, meas, seen = [], set(), set()
    def visit(n, p):
        if (n, p) in seen:
            return
        seen.add((n, p))
        if n in spec["metrics"]:
            m = spec["metrics"][n]
            for i, ip in refs(m["expr"]) + refs(m.get("denominator", "")):
                if i == n and i in spec["measures"]:
                    meas.add((i, ip or p))
                elif i != n or ip:
                    visit(i, ip or p)
            order.append((n, p))
        elif n in spec["measures"]:
            meas.add((n, p))
        else:
            raise ValueError(f"'{n}' is not a spec measure or metric")
    for n, p in wants:
        visit(n, p or "ty")
    return order, sorted(meas)


def closure(spec, metric_ids):
    """metrics -> (ordered metrics, measures) needed, dependency order."""
    order, meas, seen = [], set(), set()
    def visit(n):
        if n in seen:
            return
        seen.add(n)
        if n in spec["metrics"]:
            m = spec["metrics"][n]
            for i in idents(m["expr"]) + idents(m.get("denominator", "")):
                if i != n or i in spec["measures"]:
                    visit(i) if i != n else meas.add(i)
            order.append(n)
        elif n in spec["measures"]:
            meas.add(n)
        else:
            raise ValueError(f"'{n}' is not a spec measure or metric")
    for m in metric_ids:
        visit(m)
    return order, sorted(meas)


# ---------------------------------------------------------------- compose
def _qualify(expr, alias="a."):
    """measure expr/filter name source columns (lint enforces) -> prefix the scan alias;
    loc.<attr> -> the scope location row (L, joined as l)."""
    out, i = [], 0
    expr = LOC.sub(r"l.\1", expr or "")
    masked = _mask(expr)
    for mm in ID.finditer(masked):
        w = mm.group(0)
        nxt = masked[mm.end():].lstrip()[:1]
        prev = expr[max(0, mm.start() - 1):mm.start()]
        if w.lower() in KW or nxt == "(" or prev == "." or re.fullmatch(r"\d.*", w) \
                or (w == "l" and nxt == "."):
            continue
        out.append(expr[i:mm.start()] + alias + w)
        i = mm.end()
    return "".join(out) + (expr or "")[i:]


def _measure_sql(m, src, wcte):
    expr, f, a = _qualify(m["expr"]), _qualify((m.get("filter") or "").strip()), m["agg"]
    a = LEGACY_AGGS.get(a, a)
    if a == "sum_funded":
        f = f"{_qualify(FUNDED)} AND ({f})" if f else _qualify(FUNDED)
        a = "sum"
    cond = f"({f})" if f else None
    if a == "sum":
        return f"sumIf({expr}, {cond})" if cond else f"sum({expr})"
    if a == "count_distinct":
        return f"uniqExactIf({expr}, {cond})" if cond else f"uniqExact({expr})"
    if a in ("last_at_max_week", "first_at_min_week", "count_lastval"):
        fn = "min" if a == "first_at_min_week" else "max"
        t = f"a.{src['time_key']} = (SELECT {fn}(wk) FROM {wcte})"
        agg = "uniqExactIf" if a == "count_lastval" else "sumIf"
        return f"{agg}({expr}, {t}{' AND ' + cond if cond else ''})"
    if a in ("max", "min", "avg"):
        return f"{a}If({expr}, {cond})" if cond else f"{a}({expr})"
    raise ValueError(f"agg {a}")


def _metric_sql(m):
    if m["type"] == "ratio":
        num, den = m["expr"], m["denominator"]
        r = m.get("round") or ""
        body = f"({num}) / ({den})"
        body = f"round({body}, {r})" if r else body
        return f"if(({den}) > 0, {body}, 0)"
    return m["expr"]


def _py(e):
    """an engine SQL expression as python (post step)."""
    e = re.sub(r"\bif\s*\(", "_if(", e)
    e = re.sub(r"\bround\s*\(", "_round(", e)
    e = re.sub(r"\bAND\b", " and ", e, flags=re.I)
    e = re.sub(r"\bOR\b", " or ", e, flags=re.I)
    e = e.replace("<>", "!=")
    return re.sub(r"(?<![<>!=])=(?!=)", "==", e)


def apply_post(rows, post):
    """share-of-total columns on the fetched rows: totals over all rows, then each row's value."""
    if not post:
        return rows
    num = lambda v: float(v) if v not in (None, "", "\\N", "nan") else 0.0
    tot = {f"__t_{t}": sum(num(r.get(t)) for r in rows) for p in post for t in p["totals"]}
    fn = {"_if": lambda c, a, b: a if c else b, "_round": lambda x, n=0: round(x, int(n))}
    code = [(p["col"], compile(_py(p["expr"]), p["col"], "eval")) for p in post]
    for r in rows:
        env = {**{k: num(v) for k, v in r.items() if not k.startswith("g_")}, **tot}
        for c, cc in code:
            try:
                env[c] = r[c] = eval(cc, {"__builtins__": {}, **fn}, env)
            except ZeroDivisionError:
                env[c] = r[c] = 0.0
    return rows


def _grain(dims, levels):
    out = []
    for lvl in levels:
        if lvl in dims["product"]["levels"]:
            out.append((lvl, f"h.{dims['product']['levels'][lvl]['id']}"))
        elif lvl in dims["location"]["levels"]:
            out.append((lvl, f"l.{dims['location']['levels'][lvl]['id']}"))
        elif lvl in ("week", "time"):
            out.append(("week", "a.time"))
        else:
            raise ValueError(f"unknown grain level '{lvl}'")
    return out


_VIEW_AGG = {"sum": "sum", "mean": "avg", "avg": "avg", "count": "count", "size": "count",
             "min": "min", "max": "max", "first": "any", "last": "anyLast"}


def rollup_sql(formula):
    def call(m):
        fn, arg = m.group(1).lower(), m.group(2).strip()
        if arg == "1" and fn in ("sum", "count", "size"):
            return "count()"
        return f"{_VIEW_AGG.get(fn, fn)}({arg})"
    return re.sub(r"\b(sum|mean|avg|count|size|min|max|first|last)\s*\(\s*([^()]*?)\s*\)", call,
                  formula, flags=re.I)


def _q_literal(name, rows):
    """an item set fetched beforehand, as a literal CTE (two-phase run)."""
    if not rows:
        return f"-- {name}: no items (fetched beforehand)\nSELECT '' AS item, toUInt8(0) AS class WHERE 0"
    body = ",".join(f"({q(i)},{int(float(c or 0))})" for i, c in rows)
    return (f"-- {name}: {len(rows)} items fetched beforehand (two-phase run)\n"
            f"SELECT tupleElement(t, 1) AS item, toUInt8(tupleElement(t, 2)) AS class FROM (SELECT arrayJoin([{body}]) AS t)")


def compose(req, spec, dims, weeks, items=None):
    """items: optional {'Q': [(item, class)], 'Q_ly': …} fetched by a first query (see q_queries)."""
    """req: normalized (scope ids, filters, general, flowStatus, aggBy, pivot, metrics[{label,
    data_index, view_formula}]); weeks: {'selected': [...], 'receipt': [...]}."""
    warnings, prov, q_queries = [], {}, {}
    pivot = req["pivot"]
    scr = spec["screens"].get(pivot)
    if not scr:
        raise ValueError(f"no spec for data call '{pivot}' (screens.csv) — add the screen family first")
    if (scr.get("item_grain") or "stylecolor") != "stylecolor":    # e.g. sku: items from the SKU hierarchy
        key = f"product_{scr['item_grain']}"
        if key not in dims:
            raise ValueError(f"screen {pivot}: item_grain {scr['item_grain']} needs dimensions.json {key}")
        dims = {**dims, "product": dims[key]}
    pop = [p for p in spec["populations"] if p["population_id"] == scr["population_id"]]
    if not pop:
        raise ValueError(f"population {scr['population_id']} has no rules")
    tenant = dims["tenant"]
    sc, fl = req["scope"], req["filters"]
    fdef = dims["filters"]
    price = fl.get("merchcat") or fdef["merchcat"].get("all") or []
    grade = fl.get("grade") or fdef["grade"].get("all") or []
    level_vals = {"prodlife": price, "cluster": grade}

    # ---- bindings: screen columns -> spec metrics
    binds = {(b["viewdefn"], b["data_index"]): b for b in spec["bindings"] if b["pivot"] == pivot}
    out_metrics, unbound = [], []
    for m in req["metrics"]:
        b = binds.get((m.get("viewdefn"), m["data_index"])) or next(
            (x for (v, di), x in binds.items() if di == m["data_index"]), None)
        mid = (b or {}).get("metric_id") or (m["data_index"] if m["data_index"] in spec["metrics"] else "")
        per = (m.get("period") or (b or {}).get("period") or "ty").lower()
        if not mid:                                       # unbound x_ly / x_lly -> metric x in that period
            sm = re.fullmatch(r"(.+)_(ly|lly)", m["data_index"])
            if sm and sm.group(1) in spec["metrics"]:
                mid, per = sm.group(1), sm.group(2)
                prov[m["label"]] = f"inferred: {mid} @{per} from the column name (no binding)"
        if not mid:
            unbound.append(m["label"])
            continue
        if per not in PERIODS:
            raise ValueError(f"{m['label']}: period must be one of {PERIODS}")
        out_metrics.append({**m, "metric_id": mid, "period": per, "col": pcol(mid, per),
                            "rollup": (b or {}).get("rollup_formula") or m.get("view_formula") or ""})
    if unbound:
        warnings.append(f"no spec metric for: {', '.join(unbound)} (add it in Spec → Metrics)")
    if not out_metrics:
        raise ValueError("none of the selected columns has a spec metric yet")
    want = [(m["metric_id"], m["period"]) for m in out_metrics]
    for m in out_metrics:                                 # rollup formulas may name extra ids
        for i, ip in refs(m["rollup"]):
            if i in spec["metrics"] or i in spec["measures"]:
                want.append((i, ip or m["period"]))
    row_pers = [p.strip().lower() for p in (scr.get("row_periods") or "ty").split(",") if p.strip()]
    if any(p not in PERIODS for p in row_pers):
        raise ValueError(f"screen {pivot}: row_periods must be from {PERIODS}")
    row_filter = (scr.get("row_filter") or "").strip()
    for i, ip in refs(row_filter):                        # the screen's row filter needs its columns
        if i in spec["metrics"] or i in spec["measures"]:
            want.append((i, ip or "ty"))
    want = list(dict.fromkeys(want))
    mets, meas = closure_p(spec, want)
    periods = [p for p in PERIODS if any(x[1] == p for x in mets + meas) or p in row_pers]
    for p in periods:                                     # lly needs ly's weeks to map from
        if PREV.get(p) and PREV[p] not in periods:
            periods.insert(PERIODS.index(p) - 1, PREV[p])
    periods = [p for p in PERIODS if p in periods]
    sfx = {p: "" if p == "ty" else f"_{p}" for p in PERIODS}
    names = set(spec["metrics"]) | set(spec["measures"])

    # ---- 1 SCOPE
    P_lv, L_lv = dims["product"]["levels"], dims["location"]["levels"]
    pcols = list(dict.fromkeys([dims["product"]["key"]] + [v["id"] for v in P_lv.values()]))
    lcols = list(dict.fromkeys([dims["location"]["key"]] + [v["id"] for v in L_lv.values()] +
                               [a for mid, _ in meas for a in loc_refs(spec["measures"][mid].get("filter", ""))]))
    loc_attrs = set(fdef.get("location_attributes", []))
    p_and = " ".join(f"AND {k} IN ({qlist(v)})" for k, v in fl.items()
                     if v and k not in fdef and k not in loc_attrs)
    l_and = " ".join(f"AND {k} IN ({qlist(v)})" for k, v in fl.items() if v and k in loc_attrs)
    ph, lh = dims["product"]["hier_table"], dims["location"]["hier_table"]
    ctes = [
        ("P", f"-- scope: products in {sc['productLevel']} {sc['productMember']}, latest version, product filters\n"
              f"SELECT {', '.join(pcols)} FROM {ph}\n"
              f"WHERE {P_lv[sc['productLevel']]['id']} = {q(sc['productMember'])} {p_and}\n"
              f"ORDER BY updated_at DESC LIMIT 1 BY {dims['product']['key']}"),
        ("L", f"-- scope: locations in {sc['locationLevel']} {sc['locationMember']}, location filters\n"
              f"SELECT {', '.join(lcols)} FROM {lh}\n"
              f"WHERE {L_lv[sc['locationLevel']]['id']} = {q(sc['locationMember'])} {l_and}\n"
              f"ORDER BY updated_at DESC LIMIT 1 BY {dims['location']['key']}"),
    ]
    tdef = dims.get("time") or {}
    for w, wl in weeks.items():
        if wl and "@" not in w:
            ctes.append((f"W_{w}", f"-- weeks: {w} window ({wl[0]} .. {wl[-1]}, {len(wl)} weeks)\n"
                                   f"SELECT arrayJoin([{qlist(wl)}]) AS wk"))
    for p in periods:
        if p == "ty":
            continue
        for w in [x for x in weeks if "@" not in x and weeks[x]]:
            given = weeks.get(f"{w}@{p}")
            if given:                                     # explicit LY weeks from the screen
                ctes.append((f"W_{w}{sfx[p]}", f"-- weeks: {w} window, {p.upper()} as selected on screen "
                                                f"({given[0]} .. {given[-1]})\n"
                                                f"SELECT arrayJoin([{qlist(given)}]) AS wk"))
            elif tdef.get("table"):
                ctes.append((f"W_{w}{sfx[p]}", f"-- weeks: {w} window, {p.upper()} = calendar weeks whose "
                                                f"{tdef['ty_week']} is in the {PREV[p].upper()} window\n"
                                                f"SELECT DISTINCT {tdef['week']} AS wk FROM {tdef['table']}\n"
                                                f"WHERE {tdef['ty_week']} IN (SELECT wk FROM W_{w}{sfx[PREV[p]]})"))
            else:
                raise ValueError(f"{p.upper()} needs a calendar mapping (dimensions.json time.table) "
                                 f"or explicit {w}@{p} weeks")

    # ---- 2 POPULATION
    srcs = dict(spec["sources"])
    for a, b in (dims["product"].get("sources") or {}).items():   # same measure, this grain's table
        if b in srcs:
            srcs[a] = srcs[b]
    def level_where(s, alias=""):
        parts = []
        for lc in [x.strip() for x in (s.get("level_filters") or "").split(",") if x.strip()]:
            parts.append(f"{alias}{lc} IN ({qlist(level_vals.get(lc, []))})")
        return parts
    def version_where(s, where, alias=""):
        # versioned source: row filter + each item's latest version in the window (QA PS_ASST_PRODUCT_MAX)
        rf = (s.get("row_filter") or "").strip()
        parts = [rf] if rf else []
        lb = (s.get("latest_by") or "").strip()
        if lb:
            key, lk = s["item_key"], s.get("location_key")
            inner = [w.replace(alias, "") for w in where if not (lk and w.startswith(f"{alias}{lk} "))] + parts
            parts.append(f"({alias}{key}, {alias}{lb}) IN (SELECT {key}, max({lb}) FROM {s['table']} "
                         f"WHERE {' AND '.join(inner)} GROUP BY {key})")
        return parts
    fs = req.get("flowStatus") or dims["flow_status"]["default"]
    rcpt_on = "1" if (req.get("general") or {}).get("rcpt_weeks") else "0"   # QA: on when receipt weeks are picked
    def flags(e):
        return re.sub(r"\brcpt_filter_enabled\b", rcpt_on, e or "")
    for per in periods:
        x = sfx[per]
        rule_sql, classify, combine, up = {}, None, None, None
        for r in sorted(pop, key=lambda r: int(r["step"])):
            cond_when = (r.get("applies_when") or "").strip()
            if cond_when:
                m = re.match(r"(\w+)\s+in\s+price_status", cond_when, re.I)
                if m and m.group(1) not in price:
                    prov[f"{r['rule_id']}{x}"] = f"skipped: {cond_when} is false"
                    rule_sql[r["rule_id"]] = None
                    continue
            if r["kind"] == "combine":
                combine = r
                continue
            if r["kind"] == "classify_up":                # class decided per group (e.g. style), after classify
                up = r
                continue
            s = srcs[r["source_id"]]
            where = [f"{s['item_key']} IN (SELECT {dims['product']['key']} FROM P)"]
            if r["time_window"] != "none" and s.get("time_key"):
                where.append(f"{s['time_key']} IN (SELECT wk FROM W_{r['time_window']}{x})")
            if r["kind"] == "having":
                where += level_where(s)
            if r.get("row_filter"):
                where.append(f"({flags(r['row_filter'])})")
            head = f"-- population rule {r['population_id']}.{r['rule_id']} [{per.upper()}] v{r['version']} ({r['status']}): {r.get('notes', '')}\n"
            gl = (r.get("group_level") or "").strip()
            if gl and r["kind"] in ("having", "where"):  # decided per group (e.g. stylecolor), every item of it in
                lvl, key = dims["product"]["levels"][gl]["id"], dims["product"]["key"]
                grp = (f"SELECT h.__grp AS grp FROM (SELECT * FROM {s['table']} WHERE {' AND '.join(where)}) AS a\n"
                       f"  ANY LEFT JOIN (SELECT {key} AS __k, {lvl} AS __grp FROM P) AS h ON a.{s['item_key']} = h.__k\n"
                       + (f"  GROUP BY h.__grp HAVING {flags(r['condition'])}" if r["kind"] == "having"
                          else "  GROUP BY h.__grp"))
                sql = (f"{head}-- decided per {gl}: every item of a passing {gl}\n"
                       f"SELECT {key} AS item FROM P WHERE {lvl} IN (\n{grp})")
            elif r["kind"] == "having":
                sql = (f"{head}SELECT {s['item_key']} AS item FROM {s['table']}\nWHERE {' AND '.join(where)}\n"
                       f"GROUP BY {s['item_key']}\nHAVING {flags(r['condition'])}")
            elif r["kind"] == "where":
                sql = f"{head}SELECT DISTINCT {s['item_key']} AS item FROM {s['table']}\nWHERE {' AND '.join(where)}"
            elif r["kind"] == "classify":
                sql = (f"{head}SELECT {s['item_key']} AS item, toUInt8({flags(r['condition'])}) AS class FROM {s['table']}\n"
                       f"WHERE {' AND '.join(where)}\nGROUP BY {s['item_key']}")
                classify = r["rule_id"]
            else:
                raise ValueError(f"population rule kind {r['kind']}")
            rule_sql[r["rule_id"]] = sql
            ctes.append((f"pop_{r['rule_id']}{x}", sql))
        if not combine:
            raise ValueError(f"population {scr['population_id']} has no combine rule")
        def combine_sql(expr):
            toks = re.findall(r"\(|\)|AND|OR|NOT|\w+", expr, re.I)
            out = []
            for t in toks:
                u = t.upper()
                if u in ("AND", "OR", "NOT", "(", ")"):
                    out.append(u)
                elif t in rule_sql:
                    out.append("0" if rule_sql[t] is None else f"item IN (SELECT item FROM pop_{t}{x})")
                else:
                    raise ValueError(f"combine refers to unknown rule {t}")
            return " ".join(out)
        if up:
            if not classify:
                raise ValueError(f"population {scr['population_id']}: classify_up needs a classify rule first")
            lvl = dims["product"]["levels"][up["group_level"]]["id"]
            key = dims["product"]["key"]
            memb = combine_sql(combine["condition"]).replace("item IN", "c2.item IN")
            ctes.append((f"pop_{up['rule_id']}{x}",
                         f"-- population rule {up['population_id']}.{up['rule_id']} [{per.upper()}] v{up['version']} "
                         f"({up['status']}): {up.get('notes', '')}\n"
                         f"-- each item takes its {up['group_level']}'s class, decided over the population's items\n"
                         f"SELECT c.item AS item, u.class AS class FROM pop_{classify}{x} AS c\n"
                         f"ANY LEFT JOIN P AS h ON c.item = h.{key}\n"
                         f"ANY LEFT JOIN (SELECT h2.{lvl} AS grp, toUInt8({up['condition']}) AS class\n"
                         f"  FROM pop_{classify}{x} AS c2 ANY LEFT JOIN P AS h2 ON c2.item = h2.{key}\n"
                         f"  WHERE {memb} GROUP BY grp) AS u ON h.{lvl} = u.grp"))
            classify = up["rule_id"]
        if classify:
            qsql = (f"-- population {scr['population_id']} [{per.upper()}]: {combine['condition']}\n"
                    f"SELECT item, class FROM pop_{classify}{x}\nWHERE ({combine_sql(combine['condition'])})\n"
                    f"  AND class IN ({', '.join(str(int(v)) for v in fs)})")
        else:
            qsql = (f"-- population {scr['population_id']} [{per.upper()}]: {combine['condition']}\n"
                    f"SELECT {dims['product']['key']} AS item, toUInt8(0) AS class FROM P WHERE ({combine_sql(combine['condition']).replace('item IN', dims['product']['key'] + ' IN')})")
        if items is not None and f"Q{x}" in items:
            qsql = _q_literal(f"Q{x}", items[f"Q{x}"])
        ctes.append((f"Q{x}", qsql))
        q_queries[f"Q{x}"] = "WITH\n" + ",\n".join(f"{n} AS (\n{b}\n)" for n, b in ctes) + f"\nSELECT item, class FROM Q{x}"

    # rows = items of every row period (e.g. TY items + LY-only items); one class per item, TY's first
    multi = len(row_pers) > 1
    if multi:
        ctes.append(("R", f"-- screen rows: items in {' or '.join(p.upper() for p in row_pers)}; class from the first\n"
                          "SELECT item, argMin(class, o) AS class FROM (\n" +
                          "\n  UNION ALL\n".join(f"  SELECT item, class, {k} AS o FROM Q{sfx[p]}"
                                                 for k, p in enumerate(row_pers)) +
                          "\n) GROUP BY item"))

    # ---- 3 MEASURES: one scan per (source, window, location_set, period)
    levels = [p.split(":", 1)[-1].strip() for p in req["aggBy"].split(",") if p.strip()]
    g = _grain(dims, levels[-1:])                      # validate the requested (deepest) level
    split = (scr.get("split_by_class") or "").lower() in ("yes", "true", "1")
    gk = [f"g_{a}" for a, _ in g] + (["class"] if split else [])
    scans = {}
    for mid, per in meas:
        m = spec["measures"][mid]
        scans.setdefault((m["source_id"], m["time_window"], m["location_set"], per), []).append((mid, per))
    mcol = {(mid, per): f"m_{pcol(mid, per)}" for mid, per in meas}
    parts = []
    for (sid, win, lset, per), ms in scans.items():
        s, x = srcs[sid], sfx[per]
        where = [f"a.{s['item_key']} IN (SELECT item FROM Q{x})"]
        if win != "none":
            where.append(f"a.{s['time_key']} IN (SELECT wk FROM W_{win}{x})")
        if s.get("location_key") and lset == "scope":
            where.append(f"a.{s['location_key']} IN (SELECT {dims['location']['key']} FROM L)")
        where += level_where(s, "a.")
        where += version_where(s, where, "a.")
        joins = [f"ANY LEFT JOIN {'R' if multi else 'Q' + x} AS qq ON a.{s['item_key']} = qq.item",
                 f"ANY LEFT JOIN P AS h ON a.{s['item_key']} = h.{dims['product']['key']}"]
        if s.get("location_key"):
            joins.append(f"ANY LEFT JOIN L AS l ON a.{s['location_key']} = l.{dims['location']['key']}")
        sel = [f"{e} AS g_{a}" for a, e in g] + (["qq.class AS class"] if split else [])
        for k in meas:
            sel.append(f"toFloat64({_measure_sql(spec['measures'][k[0]], s, f'W_{win}{x}')}) AS {mcol[k]}"
                       if k in ms else f"toFloat64(0) AS {mcol[k]}")
        head = (f"-- scan {sid} ({s['table']}) {per.upper()} window={win} locations={lset}: "
                f"{', '.join(k[0] for k in ms)}\n")
        # filter the facts before the joins: CH 21.4 does not push WHERE below a JOIN
        parts.append(f"{head}SELECT {', '.join(sel)}\nFROM (SELECT * FROM {s['table']} AS a\n"
                     f"      WHERE {' AND '.join(where)}) AS a\n" + "\n".join(joins) +
                     (f"\nGROUP BY {', '.join(gk)}" if gk else ""))
    if parts and all(e.startswith("h.") for _, e in g):  # every population item is a row (QA reads all bases)
        rq = "R" if multi else f"Q{sfx[row_pers[0]]}"
        sel = [f"{e} AS g_{a}" for a, e in g] + (["qq.class AS class"] if split else []) + \
              [f"toFloat64(0) AS {mcol[k]}" for k in meas]
        parts.append(f"-- screen rows: every population item, with or without facts\n"
                     f"SELECT {', '.join(sel)}\nFROM {rq} AS qq\n"
                     f"ANY LEFT JOIN P AS h ON qq.item = h.{dims['product']['key']}" +
                     (f"\nGROUP BY {', '.join(gk)}" if gk else ""))
    ctes.append(("U", "\nUNION ALL\n".join(parts)))

    # ---- 4 METRICS at the grain
    gsel = [f"{'max' if spec['measures'][mid]['rollup'] == 'max' else 'sum'}"
            f"({mcol[(mid, per)]}) AS {pcol(mid, per)}" for mid, per in meas]
    late, late_sel = set(), []                            # total(x): needs every row first
    for mid, per in mets:
        if mid in spec["measures"]:
            continue
        m = spec["metrics"][mid]
        mm_ = {**m, "expr": at_period(m["expr"], per, names), "denominator": at_period(m.get("denominator", ""), per, names)}
        deps = {(i, ip or per) for i, ip in refs(m["expr"]) + refs(m.get("denominator", ""))}
        if TOTAL.search(m["expr"] + " " + (m.get("denominator") or "")) or deps & late:
            late.add((mid, per))
            late_sel.append((mm_, pcol(mid, per)))
        else:
            gsel.append(f"{_metric_sql(mm_)} AS {pcol(mid, per)}")
    chain = [f"-- metrics at grain {', '.join(gk) or '(total)'}\n"
             f"SELECT {', '.join(gk + gsel)}\nFROM U" + (f"\nGROUP BY {', '.join(gk)}" if gk else "")]
    # share of total (total(x) = sum of x over the screen's rows): evaluated on the fetched rows, since
    # CH 21.4 re-runs an inlined CTE per reference and window functions need a setting readonly can't set
    post = [{"col": c, "expr": _metric_sql({**m_, "expr": TOTAL.sub(lambda t: f"__t_{t.group(1)}", m_["expr"]),
                                            "denominator": TOTAL.sub(lambda t: f"__t_{t.group(1)}", m_["denominator"])}),
             "totals": sorted(set(TOTAL.findall(m_["expr"] + " " + m_["denominator"])))} for m_, c in late_sel]
    late_cols = {c for _, c in late_sel}
    post_need = {i for p_ in post for i in idents(p_["expr"]) if not i.startswith("__t_")} | \
                {t for p_ in post for t in p_["totals"]}
    if row_filter:
        chain.append(f"-- screen row filter: {row_filter}\nSELECT * FROM G{len(chain) - 1}\n"
                     f"WHERE {at_period(row_filter, 'ty', names)}")
    top = req.get("top")
    if top:                                               # screen Limit + Sort By: rollup over the top n rows
        by = next((m for m in out_metrics if top["by"] in (m["label"], m["data_index"], m["metric_id"])), None)
        if not by:
            raise ValueError(f"top: sort column {top['by']} is not among the selected columns")
        chain.append(f"-- screen limit: top {int(top['n'])} rows by {by['label']}\n"
                     f"SELECT * FROM G{len(chain) - 1}\n"
                     f"ORDER BY {by['col']} {'ASC' if top.get('asc') else 'DESC'} LIMIT {int(top['n'])}")
    for k, body in enumerate(chain):
        ctes.append(("G" if k == len(chain) - 1 else f"G{k}", body))
    with_sql = "WITH\n" + ",\n".join(f"{n} AS (\n{b}\n)" for n, b in ctes)
    out_cols = list(dict.fromkeys(gk + [m["col"] for m in out_metrics if m["col"] not in late_cols]
                                  + sorted(post_need - late_cols)))
    sql_rows = f"{with_sql}\nSELECT {', '.join(out_cols)}\nFROM G" + (f"\nORDER BY {', '.join(gk)}" if gk else "")

    # ---- 5 ROLLUP (the screen's own formula, owned by the spec binding)
    tot, tmap = [], []
    for m in out_metrics:
        if not m["rollup"]:
            continue
        e = rollup_sql(at_period(m["rollup"], m["period"], names))
        have = {pcol(n, p) for n, p in mets + meas} - late_cols
        missing = [i for i in idents(e) if i not in have]
        if missing:
            warnings.append(f"{m['label']}: rollup formula uses {missing}, not in the spec")
            continue
        tot.append(f"{e} AS t{len(tot)}")
        tmap.append((f"t{len(tmap)}", m["label"]))
    sql_totals = f"{with_sql}\nSELECT {', '.join(tot)}\nFROM G" if tot else None

    lines = sql_rows.count("\n") + 1
    return {"engine": "spec", "family": scr["population_id"], "grain": gk,
            "columns": [pcol(n, p) for n, p in mets], "measures": [pcol(n, p) for n, p in meas],
            "periods": periods, "post": post, "q_queries": q_queries, "sql_rows": sql_rows, "sql_totals": sql_totals, "totals_map": tmap,
            "warnings": warnings, "provenance": {
                "population": [f"{r['rule_id']} v{r['version']} ({r['status']})" for r in pop],
                "metrics": {m["label"]: f"{m['metric_id']}{'' if m['period'] == 'ty' else '@' + m['period']} "
                                        f"v{spec['metrics'][m['metric_id']]['version']} "
                                        f"({spec['metrics'][m['metric_id']]['status']})" for m in out_metrics},
                "skipped": prov},
            "metric_map": {m["label"]: m["col"] for m in out_metrics},
            "sql_lines": lines,
            "criteria": {r["rule_id"]: r["condition"] or r.get("row_filter") for r in pop}}
