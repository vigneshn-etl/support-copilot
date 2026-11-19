"""
Compose one read-only ClickHouse query for (pivot, columns, scope, filters, grain).

  WITH <family CTEs: scope products/locations, weeks, qualification — named exactly like
        the pivot's session temp tables>,
       U AS (<one SELECT per read, grouped by grain + s5flowstatus>  UNION ALL …),
       G AS (SELECT grain, s5flowstatus, <columns over measures> FROM U GROUP BY …)
  SELECT … FROM G                 -- rows   (what pivot3/listData returns per row)
  SELECT <view formulas> FROM G   -- totals (the screen's rollup, mathjs -> CH)
"""
import json, re
from pathlib import Path

import metric_map as mm
from core import formulas as F

FAMILY_DIR = "families"


# ---------------------------------------------------------------- families
def load_families(mdir):
    fams = {}
    for f in sorted((Path(mdir) / FAMILY_DIR).glob("*.sql")):
        txt = f.read_text()
        meta = dict(re.findall(r"^--\s*@(detect|time)\s+(\S+)", txt, re.M))
        ctes, cur = [], None
        for line in txt.splitlines():
            m = re.match(r"^--\s*@cte\s+(\S+)", line)
            if m:
                cur = [m.group(1), []]
                ctes.append(cur)
            elif cur is not None and not line.lstrip().startswith("--"):
                cur[1].append(line)
        fams[f.stem] = {"detect": meta.get("detect"), "time": meta.get("time", "history"),
                        "ctes": [(n, "\n".join(b).strip()) for n, b in ctes], "path": str(f)}
    return fams


def include_names(cfg, pivot):
    """every FTL a pivot pulls in, recursively."""
    seen, todo = [], [(cfg / "pivot" / f"{pivot}.pivotdefn").read_text(errors="replace")]
    while todo:
        for name in mm._INCLUDE.findall(todo.pop()):
            if name in seen:
                continue
            seen.append(name)
            for d in (cfg / "pivot" / "include", cfg / "pivot", cfg / "library"):
                if (d / name).exists():
                    todo.append((d / name).read_text(errors="replace"))
                    break
    return seen


def detect_family(fams, pivot_text):
    for name, f in fams.items():
        if f["detect"] and f["detect"] in pivot_text:
            return name
    return None


# ---------------------------------------------------------------- params
def q(v):
    return "'" + str(v).replace("\\", "\\\\").replace("'", "''") + "'"


def qlist(vs):
    return ", ".join(q(v) for v in vs)


def weeks_subquery(dims, start, end):
    t = dims["time"]
    return (f"SELECT {t['week']} FROM {t['table']} "
            f"WHERE {t['week']} >= {q(start)} AND {t['week']} <= {q(end)}")


def family_params(fam, dims, req, pivot_params):
    sc, fl = req["scope"], req["filters"]
    pl = dims["product"]["levels"][sc["productLevel"]]
    ll = dims["location"]["levels"][sc["locationLevel"]]
    use_hist = fam["time"] == "history"
    start, end = ((sc.get("historyStart"), sc.get("historyEnd")) if use_hist
                  else (sc.get("startSales") or sc.get("start"), sc.get("endSales") or sc.get("end")))
    if not (start and end):
        raise ValueError(f"scope needs {'historyStart/historyEnd' if use_hist else 'start/end'}")
    fdef = dims["filters"]
    def leaf(fid):
        vals = fl.get(fid) or fdef[fid].get("all") or []
        return qlist(vals) if vals else "''"
    prod_and, loc_and = [], []
    loc_attrs = set(fdef.get("location_attributes", []))
    for fid, vals in fl.items():
        if fid in fdef or not vals:
            continue
        (loc_and if fid in loc_attrs else prod_and).append(f"AND {fid} IN ({qlist(vals)})")
    gen = req.get("general", {})
    rc = gen.get("rcpt_weeks") or []
    prodlife_vals = fl.get("merchcat") or fdef["merchcat"].get("all") or []
    skip = {"product", "stylecolor", "style"}
    p = {
        "SCOPED_PRODUCT_LEVEL": pl["id"], "SCOPED_PRODUCT": q(sc["productMember"]),
        "SCOPED_LOCATION_LEVEL": ll["id"], "SCOPED_LOCATION": q(sc["locationMember"]),
        "LEAF_TIME": weeks_subquery(dims, start, end),
        "LEAF_PRODLIFE": leaf("merchcat"), "LEAF_CLUSTER": leaf("grade"),
        "LEAF_FLOW_STATUS": ", ".join(str(int(x)) for x in req.get("flowStatus") or dims["flow_status"]["default"]),
        "RCPT_START": q(rc[0]) if rc else "''", "RCPT_END": q(rc[-1]) if rc else "''",
        "PRODUCT_FILTER_AND": " ".join(prod_and), "LOCATION_FILTER_AND": " ".join(loc_and),
        "PRODUCT_LEVEL_COLS": "".join(f"{v['id']}, " for v in dims["product"]["levels"].values()
                                      if v["id"] not in skip),
        "LOCATION_LEVEL_COLS_Y": ", ".join(f"y.{v['id']} AS {v['id']}" for v in
                                           dims["location"]["levels"].values() if v["id"] != "location"),
        "ONORDER_UNION": ("UNION ALL SELECT product AS stylecolor FROM trd_p_onorder_agg "
                          "WHERE product IN (SELECT product FROM SCOPE_PRODUCTS) AND on_order_u > 0")
                         if "FP" in prodlife_vals else "",
    }
    for k, v in pivot_params.items():                 # *_CRITERIA etc. straight from the pivot
        p.setdefault(k, " ".join(mm._strip_comments(v).split()))
    return p, (start, end)


def render(text, params):
    missing = set()
    def sub(m):
        if m.group(1) in params:
            return str(params[m.group(1)])
        missing.add(m.group(1))
        return m.group(0)
    out = re.sub(r"\$\{([A-Za-z0-9_]+)\}", sub, text)
    # pivot text scraped by metric_map carries unknown ${X} as __X__
    out = re.sub(r"__([A-Z][A-Z0-9_]*)__", lambda m: str(params[m.group(1)]) if m.group(1) in params
                 else m.group(0), out)
    return out, missing


# ---------------------------------------------------------------- grain
def grain_cols(dims, agg_by):
    """aggBy 'level:stylecolor' (or 'level:class,level:store') -> [(alias, sql expr)]."""
    out = []
    for part in [x for x in (agg_by or "").split(",") if x.strip()]:
        lvl = part.split(":", 1)[-1].strip()
        if lvl in dims["product"]["levels"]:
            out.append((lvl, f"b.{dims['product']['levels'][lvl]['id']}"))
        elif lvl in dims["location"]["levels"]:
            col = dims["location"]["levels"][lvl]["id"]
            out.append((lvl, f"c.{col}"))
        elif lvl in ("week", "time"):
            out.append(("week", "a.time"))
        else:
            raise ValueError(f"unknown grain level '{lvl}' (not in dimensions.json)")
    return out


# ---------------------------------------------------------------- columns
_MREF = re.compile(r"\{m:([^}]+)\}")


def needed(fx, cols):
    """columns closure -> (ordered columns, measures, reads, missing)."""
    seen, order, meas, missing = set(), [], {}, []
    def visit(c):
        if c in seen:
            return
        seen.add(c)
        row = fx["columns"].get(c)
        if row is None:
            missing.append(c)
            return
        e = row["expr"]
        for mid in _MREF.findall(e):
            if mid in fx["measures"]:
                meas[mid] = fx["measures"][mid]
            else:
                missing.append(f"measure {mid}")
        for ident in mm._IDENT.findall(_MREF.sub(" ", e)):
            if ident in fx["columns"] and ident != c:
                visit(ident)
        order.append(c)
    for c in cols:
        visit(c)
    reads = {m["read"] for m in meas.values()}
    return order, meas, reads, missing


_VIEW_AGG = {"sum": "sum", "mean": "avg", "avg": "avg", "count": "count", "size": "count",
             "min": "min", "max": "max", "first": "any", "last": "anyLast"}


def view_formula_sql(formula, cols_available):
    """mathjs rollup formula over pivot rows -> CH over G. sum(1) -> count()."""
    def call(m):
        fn, arg = m.group(1).lower(), m.group(2).strip()
        if arg == "1" and fn in ("sum", "count", "size"):
            return "count()"
        return f"{_VIEW_AGG.get(fn, fn)}({arg})"
    expr = re.sub(r"\b(sum|mean|avg|count|size|min|max|first|last)\s*\(\s*([^()]*?)\s*\)", call,
                  formula, flags=re.I)
    unknown = [i for i in mm._IDENT.findall(expr)
               if i not in cols_available and i.lower() not in mm._KW
               and expr[expr.find(i) + len(i):].lstrip()[:1] != "("]
    return expr, unknown


def compose(req, ctx):
    """req: normalized request. ctx: {cfg, mdir, dims, fams, client}.
    -> {'sql_rows','sql_totals','family','columns','warnings',…}"""
    dims, cfg, mdir = ctx["dims"], ctx["cfg"], ctx["mdir"]
    pivot = req["pivot"]
    fam_name = detect_family(ctx["fams"], " ".join(include_names(cfg, pivot)))
    if not fam_name:
        raise ValueError(f"pivot {pivot}: no qualification family matches its includes "
                         f"(add customers/{ctx['client']}/metrics/families/<family>.sql)")
    fam = ctx["fams"][fam_name]
    pv = mm.Pivot(cfg / "pivot" / f"{pivot}.pivotdefn", cfg, dims["tenant"])
    params, weeks = family_params(fam, dims, req, pv.params)
    warnings = []

    fx = F.load(mdir, pivot)
    metrics = req["metrics"]                      # [{label, data_index, view_formula}]
    want = []
    for m in metrics:
        want.append(m["data_index"])
        if m.get("view_formula"):
            want += mm._pivot_cols_in(m["view_formula"])
    want = list(dict.fromkeys(w for w in want if w))
    order, meas, reads, missing = needed(fx, want)
    if missing:
        warnings.append(f"no formula for: {', '.join(dict.fromkeys(missing))}")

    # family CTEs
    ctes = []
    for name, body in fam["ctes"]:
        sql, miss = render(body, params)
        if miss:
            raise ValueError(f"family {fam_name} CTE {name}: unfilled params {sorted(miss)}")
        ctes.append(f"{name} AS (\n{sql}\n)")
    cte_names = {n for n, _ in fam["ctes"]}

    # reads -> U
    g = grain_cols(dims, req["aggBy"])
    gsel = ", ".join(f"{e} AS g_{a}" for a, e in g)
    ggrp = ", ".join(f"g_{a}" for a, _ in g)
    mids = {mid: f"m{i}" for i, mid in enumerate(meas)}
    parts = []
    for rid in sorted(reads):
        r = fx["reads"].get(rid)
        if not r:
            warnings.append(f"read {rid} missing from formulas.csv")
            continue
        frm, miss = render(r["from_sql"], params)
        for t in set(re.findall(r"\b\w+_SESSION\b", frm)) - cte_names:
            raise ValueError(f"read {rid} needs session table {t}; family {fam_name} has no CTE for it")
        frm = re.sub(r"\b(\w+\.)?(prodlife|cluster)\s+IN\s*\(\s*''\s*\)", "1", frm)
        sel = []
        for mid, col in mids.items():
            if meas[mid]["read"] == rid:
                expr, _ = render(meas[mid]["expr"], params)
                sel.append(f"toFloat64({expr}) AS {col}")
            else:
                sel.append(f"toFloat64(0) AS {col}")
        lead = (gsel + ", ") if gsel else ""
        grp = "GROUP BY " + ", ".join(x for x in [ggrp, "s5flowstatus"] if x)
        parts.append(f"SELECT {lead}b.s5flowstatus AS s5flowstatus, {', '.join(sel)}\nFROM {frm}\n{grp}")
    if not parts:
        raise ValueError("nothing to read: none of the requested metrics resolved to a measure")

    def col_sql(c):
        return _MREF.sub(lambda m: f"{mids.get(m.group(1), '0')}", fx["columns"][c]["expr"])
    gcols = ", ".join(f"{col_sql(c)} AS {c}" for c in order)
    glead = (ggrp + ", ") if ggrp else ""
    G = (f"SELECT {glead}s5flowstatus, {gcols}\nFROM U\nGROUP BY " +
         ", ".join(x for x in [ggrp, "s5flowstatus"] if x))
    with_sql = "WITH\n" + ",\n".join(ctes + ["U AS (\n" + "\nUNION ALL\n".join(parts) + "\n)",
                                             f"G AS (\n{G}\n)"])
    out_cols = [f"g_{a}" for a, _ in g] + ["s5flowstatus"] + [m["data_index"] for m in metrics
                                                           if m["data_index"] in order]
    sql_rows = f"{with_sql}\nSELECT {', '.join(dict.fromkeys(out_cols))}\nFROM G\nORDER BY {', '.join(out_cols[:len(g) + 1])}"
    tot, tot_cols = [], []
    for m in metrics:
        f = m.get("view_formula")
        if not f:
            continue
        e, unknown = view_formula_sql(f, set(order))
        if unknown:
            warnings.append(f"{m['label']}: rollup formula uses {unknown} not in G")
            continue
        alias = f"t{len(tot)}"
        tot.append(f"{e} AS {alias}")
        tot_cols.append((alias, m["label"]))
    sql_totals = f"{with_sql}\nSELECT {', '.join(tot)}\nFROM G" if tot else None
    return {"family": fam_name, "weeks": weeks, "columns": order, "grain": [a for a, _ in g],
            "sql_rows": sql_rows, "sql_totals": sql_totals, "totals_map": tot_cols,
            "warnings": warnings, "params": {k: v for k, v in params.items()
                                             if not k.endswith("_CRITERIA") and len(str(v)) < 300},
            "criteria": {k: v for k, v in params.items() if k.endswith("_CRITERIA")}}
