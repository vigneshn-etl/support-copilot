"""
Compose by replaying the pivot's own rendered SQL — generic for every pivot family.

  1. render the pivotdefn exactly as darwin would for this scope/filters/aggBy (core.darwin)
  2. parse it, then layer only the requested columns into reads → measures → columns
     (core.formulas.Layering); formulas_override.csv can replace any column by name
  3. CTEs = only the session temp tables those reads (transitively) need, verbatim
  4. U = one SELECT per read grouped exactly as the pivot groups that read;
     G = columns over U grouped like the pivot's output block; totals = view formulas over G
The pivot's heavy union/rank/band layers are never executed — G replaces them.
"""
import csv, re
from pathlib import Path

import metric_map as mm
from core import darwin as D, formulas as F
from core.compose import view_formula_sql, _MREF

_CREATE = re.compile(r"^\s*create\s+(?:temporary\s+)?table\s+(?:if\s+not\s+exists\s+)?([\w.]+)(.*?)"
                     r"\bas\b\s*(?=(?:select|with|\())(.*)$", re.S | re.I)
_CREATE_EMPTY = re.compile(r"^\s*create\s+(?:temporary\s+)?table\s+(?:if\s+not\s+exists\s+)?([\w.]+)", re.I)
_INSERT = re.compile(r"^\s*insert\s+into\s+([\w.]+)\s*(?:\([^)]*\))?\s*(.*)$", re.S | re.I)


def temp_tables(statements):
    """{name: sql} for CREATE … AS SELECT (+ INSERT INTO … SELECT unioned in)."""
    defs, order = {}, []
    for st in statements:
        s = st.strip()
        if not s:
            continue
        m = _CREATE.match(s)
        if m:
            name, body = m.group(1), m.group(3).strip()
            if name not in defs:                     # CREATE … IF NOT EXISTS: first wins
                defs[name] = [body]
                order.append(name)
            continue
        m = _CREATE_EMPTY.match(s)
        if m and m.group(1) not in defs:
            defs[m.group(1)] = []
            order.append(m.group(1))
            continue
        m = _INSERT.match(s)
        if m and m.group(1) in defs:
            defs[m.group(1)].append(m.group(2).strip())
    return {n: "\nUNION ALL\n".join(f"SELECT * FROM ({b})" if len(defs[n]) > 1 else b
                                    for b in defs[n]) for n in order if defs[n]}, order


def _refs(sql, names):
    return {n for n in names if re.search(rf"\b{re.escape(n)}\b", sql)}


def cte_closure(seed_sql, temps, order):
    need, todo = set(), [seed_sql]
    while todo:
        for n in _refs(todo.pop(), temps.keys()) - need:
            need.add(n)
            todo.append(temps[n])
    return [n for n in order if n in need]


def _group_aliases(group_sql):
    """'s5flowstatus, b.stylecolor' -> [('s5flowstatus','s5flowstatus'), ('b.stylecolor','stylecolor')]"""
    out = []
    for g in mm._split_top(group_sql or ""):
        g = g.strip()
        if not g:
            continue
        m = re.search(r"([A-Za-z_]\w*)\s*$", g)
        out.append((g, m.group(1) if m else f"k{len(out)}"))
    return out


def overrides(mdir, pivot):
    p = Path(mdir) / "formulas_override.csv"
    out = {}
    if p.exists():
        with open(p, newline="") as f:
            for r in csv.DictReader(f):
                if r["pivot"] == pivot and r["kind"] == "column":
                    out[r["name"]] = r["expr"]
    return out


def compose(req, ctx, weeks_hist, weeks_asst, level_index=None):
    dims, cfg = ctx["dims"], ctx["cfg"]
    pivot = req["pivot"]
    levels = [p.split(":", 1)[-1].strip() for p in req["aggBy"].split(",") if p.strip()]
    li = len(levels) - 1 if level_index is None else level_index
    pparams, fields, flags = D.pivot_fields(cfg, pivot)
    history = bool(req.get("history", True))
    params = D.build_params(req, dims, pivot, pparams, history, weeks_hist, weeks_asst, levels[:li + 1])
    rend = D.render_pivot(cfg, pivot, params, n_groupings=len(levels), level_index=li)
    pro = [mm._strip_comments(x) for x in rend["prologue"]]
    agg = mm._strip_comments(rend["agg"])
    statements = [s for x in pro for s in mm._split_top(x, ";")]
    temps, order = temp_tables(statements)
    # resolver over the rendered SQL
    blocks, creators = mm.parse_blocks("\n;\n".join(statements + [agg]))
    n_out = len(mm.parse_blocks(agg)[0])
    out_id = [(len(blocks) - n_out, rend["agg_field"])] if n_out else None
    if not out_id:
        raise ValueError(f"{pivot}: rendered aggregation SQL has no SELECT")
    schema = ctx["schema"]
    res = mm.Resolver(blocks, creators, schema)
    res.prefix = dims["tenant"] + "_"
    L = F.Layering(pivot, res, blocks, creators, dims["tenant"] + "_")
    ov = overrides(ctx["mdir"], pivot)
    want = []
    for m in req["metrics"]:
        want.append(m["data_index"])
        if m.get("view_formula"):
            want += mm._pivot_cols_in(m["view_formula"])
    want = list(dict.fromkeys(w for w in want if w))
    warnings, top_bids, unresolved, outputs = [], [], [], {}
    for c in want:
        if c in ov:
            outputs[c] = c
            continue
        (_, node), rr = mm.best_render(res, out_id, c)
        if node is None or node["kind"] in ("unresolved",):
            unresolved.append(c)
            continue
        if node["kind"] == "expr":
            top_bids.append(node["bid"])
        tok, needs = L.define(node)
        if needs:                                   # bare measure as output: pivot sums it
            L.columns.setdefault(f"o__{c}", f"sum({tok})")
            tok = f"o__{c}"
        outputs[c] = tok
    for c, e in ov.items():
        L.columns[c] = e
        warnings.append(f"column {c}: formula overridden by formulas_override.csv")
    if unresolved:
        warnings.append(f"not produced by {pivot} at this grain: {', '.join(unresolved)}")
    if L.problems:
        warnings += [f"formula: {p}" for p in dict.fromkeys(L.problems)]
    if not L.measures:
        raise ValueError("none of the requested metrics resolved to base-table measures")

    # columns closure (overrides may reference other columns)
    order_cols, seen = [], set()
    def visit(c):
        if c in seen or c not in L.columns:
            return
        seen.add(c)
        for ident in mm._IDENT.findall(_MREF.sub(" ", L.columns[c])):
            if ident != c:
                visit(ident)
        order_cols.append(c)
    for c in want:
        if c in outputs:
            visit(outputs[c])
    used_m = {mid for c in order_cols for mid in _MREF.findall(L.columns[c])}
    meas = {mid: L.measures[mid] for mid in L.measures if mid in used_m}
    reads = sorted({m["read"] for m in meas.values()})

    # output grouping = the pivot output block's GROUP BY (e.g. stylecolor, s5flowstatus)
    out_group = []
    for bid in top_bids:
        out_group = _group_aliases(blocks[bid].group_sql)
        if out_group:
            break
    out_keys = [a for _, a in out_group]
    mcol = {mid: f"m{i}" for i, mid in enumerate(meas)}
    parts, read_keys = [], {}
    for rid in reads:
        bid = int(rid.rsplit("#", 1)[1])
        b = blocks[bid]
        gk = _group_aliases(b.group_sql)
        read_keys[rid] = [a for _, a in gk]
        sel = [f"{e} AS {a}" for e, a in gk]
        for mid, col in mcol.items():
            sel.append(f"toFloat64({meas[mid]['expr']}) AS {col}" if meas[mid]["read"] == rid
                       else f"toFloat64(0) AS {col}")
        grp = ("\nGROUP BY " + ", ".join(e for e, _ in gk)) if gk else ""
        parts.append((rid, sel, f"FROM {b.from_sql}{grp}"))
    keys = list(dict.fromkeys(k for r in reads for k in read_keys[r]))
    lvl_set = set(levels[:li + 1]) | {"s5flowstatus"}
    # output grain = requested levels (+ s5flowstatus when the pivot keeps it); other keys
    # are dimension placeholders ('LocationRoot' AS location …) and must not split rows
    gkeys = [k for k in out_keys if k in keys and k in lvl_set] or \
            [k for k in keys if k in lvl_set] or [k for k in out_keys if k in keys]
    # a read grouped by none of the grain keys is a scope-wide scalar the pivot CROSS JOINs
    scalar = {rid for rid in reads if gkeys and not set(read_keys[rid]) & set(gkeys)}
    grouped = [r for r in reads if r not in scalar]
    union, union0 = [], []
    for rid, sel, tail in parts:
        if rid in scalar:
            own = [x for x in sel if not x.startswith("toFloat64(0)")
                   and not re.match(r"^[^ ]+ AS (?!m\d)", x)]
            union0.append("SELECT " + ", ".join(own) + "\n" + tail)
            continue
        missing = [k for k in keys if k not in read_keys[rid]]
        lost = [k for k in missing if k in gkeys]
        if lost:
            warnings.append(f"read {rid} is not grouped by {lost}")
        union.append("SELECT " + ", ".join([f"NULL AS {k}" for k in missing] + sel) + "\n" + tail)
    scalar_m = {mid for mid in meas if meas[mid]["read"] in scalar}

    def col_expr(c):
        e = L.columns[c]
        # AGG({m:scalar}) -> the scope-wide value itself (CROSS JOIN semantics)
        e = re.sub(r"\b(sum|max|min|any|anyLast)\s*\(\s*\{m:([^}]+)\}\s*\)",
                   lambda m: f"(SELECT {m.group(1)}({mcol[m.group(2)]}) FROM U0)" if m.group(2) in scalar_m
                   else m.group(0), e)
        return _MREF.sub(lambda m: (f"(SELECT sum({mcol[m.group(1)]}) FROM U0)" if m.group(1) in scalar_m
                                    else mcol.get(m.group(1), "0")), e)
    G = ("SELECT " + ", ".join(gkeys + [f"{col_expr(c)} AS {c}" for c in order_cols])
         + "\nFROM U" + ("\nGROUP BY " + ", ".join(gkeys) if gkeys else ""))
    if not union:                                   # everything scope-wide
        union = ["SELECT " + ", ".join(f"toFloat64(0) AS {c}" for c in mcol.values())]
    seed = "\n".join(b for _, _, b in parts) + "\n" + "\n".join(m["expr"] for m in meas.values())
    cte_names = cte_closure(seed, temps, order)
    tail_ctes = (["U0 AS (\n" + "\nUNION ALL\n".join(union0) + "\n)"] if union0 else []) + \
                ["U AS (\n" + "\nUNION ALL\n".join(union) + "\n)", f"G AS (\n{G}\n)"]
    plan = {"temps": {n: temps[n] for n in cte_names}, "order": cte_names, "tail": tail_ctes}
    ctes = [f"{n} AS (\n{temps[n]}\n)" for n in cte_names]
    with_sql = "WITH\n" + ",\n".join(ctes + tail_ctes)
    leftover = sorted(set(re.findall(rf"\b{dims['tenant']}_\w+_{D.SESSION}\b", with_sql)) - set(cte_names))
    if leftover:
        raise ValueError(f"session tables used but never created by the pivot: {leftover}")
    # R = the pivot's output columns by their real names (internal names may be namespaced)
    R_sel = gkeys + [f"{outputs[c]} AS {c}" if outputs[c] != c else c for c in want if c in outputs]
    tail_ctes.append("R AS (\nSELECT " + ", ".join(dict.fromkeys(R_sel)) + "\nFROM G\n)")
    plan["tail"] = tail_ctes
    with_sql = "WITH\n" + ",\n".join(ctes + tail_ctes)
    out_cols = gkeys + [m["data_index"] for m in req["metrics"] if m["data_index"] in outputs]
    sql_rows = f"{with_sql}\nSELECT {', '.join(dict.fromkeys(out_cols))}\nFROM R" + \
               (f"\nORDER BY {', '.join(gkeys)}" if gkeys else "")
    tot, tmap = [], []
    for m in req["metrics"]:
        f = m.get("view_formula")
        if not f:
            continue
        e, unknown = view_formula_sql(f, set(outputs))
        if unknown:
            warnings.append(f"{m['label']}: rollup formula uses {unknown} not computed")
            continue
        tot.append(f"{e} AS t{len(tot)}")
        tmap.append((f"t{len(tmap)}", m["label"]))
    sql_totals = f"{with_sql}\nSELECT {', '.join(tot)}\nFROM R" if tot else None
    rows_select = sql_rows[len(with_sql):]
    tot_select = sql_totals[len(with_sql):] if sql_totals else None
    return {"engine": "replay", "family": f"replay:{rend['agg_field']}", "columns": order_cols,
            "plan": plan, "rows_select": rows_select, "totals_select": tot_select,
            "grain": gkeys, "level": levels[li], "sql_rows": sql_rows, "sql_totals": sql_totals,
            "totals_map": tmap, "warnings": warnings, "ctes": cte_names,
            "criteria": {k: " ".join(mm._strip_comments(v).split()) for k, v in pparams.items()
                         if k.endswith("_CRITERIA")},
            "weeks": (weeks_hist[0], weeks_hist[-1]) if history and weeks_hist else
                     ((weeks_asst[0], weeks_asst[-1]) if weeks_asst else None)}


# ---------------------------------------------------------------- materialize
# ClickHouse inlines every CTE reference and our read-only account cannot raise
# max_ast_elements, and the guard caps query text at 200k chars. So, like darwin's
# temp tables, compute each session table once (dependency order) and inline the small
# ones as ONE array-of-tuples literal (1 AST node, any row count), pruned to the columns
# used downstream. Large ones stay CTEs (cheap once their own deps are literals).
LIT_BUDGET_TABLE = 60000
LIT_BUDGET_TOTAL = 140000


def _plain_type(t):
    m = re.fullmatch(r"LowCardinality\((.*)\)", t)
    return _plain_type(m.group(1)) if m else t


def _lit(v, t=None):
    """Python value -> ClickHouse literal."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, (int, float)):
        return repr(v) if v == v and v not in (float("inf"), float("-inf")) else \
            ("nan" if v != v else ("inf" if v > 0 else "-inf"))
    if isinstance(v, (list, tuple)):
        inner = ",".join(_lit(x) for x in v)
        return f"[{inner}]" if isinstance(v, list) else f"({inner}{',' if len(v) == 1 else ''})"
    return "'" + str(v).replace("\\", "\\\\").replace("'", "\\'") + "'"


def literal_table(cols, types, rows):
    tps = [_plain_type(t) if not t.startswith("Nullable") else
           "Nullable(" + _plain_type(t[9:-1]) + ")" for t in types]
    if len(cols) == 1:                           # ('x') is a scalar, not a 1-tuple
        body = ",".join(_lit(r[0], types[0]) for r in rows)
        return f"SELECT arrayJoin(CAST([{body}] AS Array({tps[0]}))) AS {cols[0]}"
    tup = f"Tuple({', '.join(tps)})"
    body = ",".join("(" + ",".join(_lit(v, t) for v, t in zip(r, types)) + ")" for r in rows)
    sel = ", ".join(f"tupleElement(_t, {i + 1}) AS {c}" for i, c in enumerate(cols))
    return f"SELECT {sel} FROM (SELECT arrayJoin(CAST([{body}] AS Array({tup}))) AS _t)"


MAX_SQL = 125000          # gate passes SQL as one argv string (Linux MAX_ARG_STRLEN 128 KiB)


def _too_big(e):
    return "exit 168" in str(e) or "TOO_BIG_AST" in str(e) or "exit 167" in str(e)


def materialize(plan, rows_select, totals_select, query_fn, workers=2):
    """Lazily materialize session tables: only those the final query reaches, and a
    dependency only when ClickHouse rejects the inlined AST (code 167/168).
    -> (final_with_sql, session_info). query_fn(sql) -> (cols, types, rows, ms)."""
    import threading
    from concurrent.futures import ThreadPoolExecutor
    order, temps = plan["order"], plan["temps"]
    form, info, lock = {}, {}, threading.RLock()
    deps = {n: [d for d in order if d != n and re.search(rf"\b{d}\b", temps[n])] for n in order}
    final_text = "\n".join(plan["tail"]) + (rows_select or "") + (totals_select or "")
    downstream = {n: "\n".join(temps[m] for m in order if m != n and re.search(rf"\b{n}\b", temps[m]))
                  for n in order}

    def body(n):
        return form.get(n, temps[n])

    def closure(text):
        need, todo = set(), [text]
        while todo:
            t = todo.pop()
            for n in order:
                if n not in need and re.search(rf"\b{n}\b", t):
                    need.add(n)
                    if not info.get(n, {}).get("inlined"):
                        todo.append(body(n))
        return [n for n in order if n in need]

    def with_for(text):
        ns = closure(text)
        return ("WITH\n" + ",\n".join(f"{n} AS (\n{body(n)}\n)" for n in ns) + "\n") if ns else ""

    def resolve(n, force_deps=False):
        with lock:
            if info.get(n, {}).get("done"):
                return
        if force_deps:
            for d in deps[n]:
                resolve(d)
        try:
            cols, types, data, ms = query_fn(with_for(temps[n]) + f"SELECT * FROM (\n{temps[n]}\n)")
        except RuntimeError as e:
            if _too_big(e) and not force_deps and deps[n]:
                return resolve(n, force_deps=True)
            raise
        idents = set(mm._IDENT.findall(downstream[n] + final_text))
        keep = list(range(len(cols))) if ("*" in downstream[n] or not idents) else \
            ([i for i, c in enumerate(cols) if c in idents] or [0])
        lit = None
        if cols and data:
            lit = literal_table([cols[i] for i in keep], [types[i] for i in keep],
                                [[r[i] for i in keep] for r in data])
        elif cols:
            lit = "SELECT " + ", ".join(f"CAST(defaultValueOfTypeName('{_plain_type(types[i])}') AS "
                                        f"{_plain_type(types[i])}) AS {cols[i]}" for i in keep) + " WHERE 0"
        with lock:
            info[n] = {"rows": len(data), "ms": ms, "done": True,
                       "inlined": bool(lit and len(lit) <= LIT_BUDGET_TABLE)}
            if info[n]["inlined"]:
                form[n] = lit

    def assemble():
        head = with_for(final_text)
        return (head.rstrip("\n") + ",\n" if head else "WITH\n") + ",\n".join(plan["tail"])

    # every table the final query can reach, materialized bottom-up in parallel waves
    # (all deps of a wave are literals, so each query is small and fast)
    need, todo = set(), [final_text]
    while todo:
        t = todo.pop()
        for n in order:
            if n not in need and re.search(rf"\b{n}\b", t):
                need.add(n)
                todo.append(temps[n])
    pending = [n for n in order if n in need]
    while pending:
        wave = [n for n in pending if all(info.get(d, {}).get("done") for d in deps[n] if d in need)]
        if not wave:
            raise ValueError(f"session-table dependency cycle among {pending}")
        with ThreadPoolExecutor(workers) as ex:
            list(ex.map(resolve, wave))
        pending = [n for n in pending if n not in wave]
    with_sql = assemble()
    if len(with_sql) + len(rows_select or "") > MAX_SQL:
        big = sorted(((len(form[n]), n) for n in closure(final_text) if info.get(n, {}).get("inlined")),
                     reverse=True)
        raise ValueError(f"composed query is {len(with_sql) // 1000} KB, over the gate's ~125 KB limit "
                         f"(largest inlined session tables: {[(n, sz) for sz, n in big[:3]]}); "
                         f"narrow the scope or raise the gate limit")
    for v in info.values():
        v.pop("done", None)
    return with_sql, info
