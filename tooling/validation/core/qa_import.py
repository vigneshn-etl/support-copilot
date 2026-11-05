"""
Import metrics from a client's QA config into the Metrics Catalog (as drafts).

Use it once per regression cycle, when QA is known-correct: the catalog is maintained by
hand for correctness in between, and an import only ADDS what the catalog lacks. It never
edits a catalog row; where QA and the catalog disagree it reports both.

Where the definitions come from (one QA config pull, config_sync.effective_dir):
  uidefn/conf/*.confdefn      top nav > screen > views -> model / dataApi
  uidefn/view/*.viewdefn      screen columns: dataIndex, label, client (rollup) formula
  uidefn/model/*.modeldefn    model -> pivotdefn
  pivot/*.pivotdefn + pivot/include/*.ftl   the SQL that computes each column
  customers/<C>/metrics/ch_schema.json      ClickHouse columns per table
  customers/<C>/metrics/metric_map_<env>.csv  the screen columns (built from the files above)

How a column is linked down to table columns (core.formulas layers the pivot SQL):
  read     one scan of a base table: FROM + WHERE   -> source, period, time window, locations
  measure  one aggregate inside a read             -> measure (agg, expr, filter)
  column   a formula over measures / columns       -> metric (simple | derived | ratio)
  screen   view column + client formula            -> binding (metric, period, rollup)

The WHERE of a read is matched conjunct by conjunct against READ_RULES (the platform's
session-table vocabulary). A conjunct no rule knows blocks every measure of that read:
the import reports it, it never guesses. Hindsighting reads are history/on-order facts
over a week window; Assortment reads are plan rows picked by latest version / snapshot /
plan horizon (NEEDS_ENGINE), which the composer does not model yet, so they are blocked
with that reason.

  python3 -m core.qa_import --client TRD --pivot HistoryFit            # dry run -> report
  python3 -m core.qa_import --client TRD --pivot HistoryFit --apply    # add drafts
"""
import argparse, csv, datetime, hashlib, json, re, sys
from collections import Counter
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent.parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))
import metric_map as mm                    # noqa: E402
from core import formulas as F, spec as SP  # noqa: E402

HUB = HERE.parent.parent
PERIOD_OF = {None: "ty", "": "ty", "ty": "ty", "ly": "ly", "lly": "lly"}
NEEDS_ENGINE = {
    "latest_version": "plan rows are picked by latest updated_at per product (source versioning)",
    "snapshot": "rows are picked by snapshot_version (OP/RP snapshots)",
    "plan_window": "weeks come from the plan horizon (trd_PlanMeta / d_time index), not a week window",
    "dc_locations": "location set includes DCs (stocking locations)",
    "rank_band": "rank bands (items ranked by a metric, cut into quintiles of the item count)",
    "sku_grain": "SKU-grain table (needs a SKU source and the SKU level in the product hierarchy)",
    "array_rows": "rows pack locations/values into arrays (needs arrayJoin sources)",
    "base_grain": "a distinct count taken per finer item (e.g. per stylecolor) and then summed (needs a measure base grain)",
}


def missing_source(table, cols):
    """why a read's table can't be used yet (never auto-added: a source's grain is a human call)."""
    if any(c.startswith("arr_") for c in cols):
        return f"needs engine support - {NEEDS_ENGINE['array_rows']}"
    if "_sku" in table and "x_stylecolor" in cols:
        return f"needs engine support - {NEEDS_ENGINE['sku_grain']}"
    return f"table {table} is not a catalog source (add it under Spec → Sources)"


# ---------------------------------------------------------------- text helpers
def _strip_parens(s):
    s = s.strip()
    while s.startswith("(") and s.endswith(")"):
        dm = mm._depth_map(s)
        if all(d > 0 for d in dm[1:-1]):
            s = s[1:-1].strip()
        else:
            break
    return s


def split_and(s):
    """top-level AND conjuncts (outside parens and quotes)."""
    s = _strip_parens(s or "")
    if not s:
        return []
    dm, parts, last = mm._depth_map(s), [], 0
    masked = SP._mask(s)
    for m in re.finditer(r"\band\b", masked, re.I):
        if dm[m.start()] == 0:
            parts.append(s[last:m.start()])
            last = m.end()
    parts.append(s[last:])
    return [_strip_parens(p) for p in parts if p.strip()]


def call(s):
    """'fn(a, b)' spanning the whole string -> (fn, [args]) else (None, None)."""
    s = _strip_parens(s)
    m = re.match(r"([A-Za-z_]\w*)\s*\(", s)
    if not m or not s.endswith(")"):
        return None, None
    dm = mm._depth_map(s)
    if not all(d > 0 for d in dm[m.end():-1]):
        return None, None
    return m.group(1), mm._split_top(s[m.end():-1])


def unwrap_cast(s):
    s = _strip_parens(s)
    while True:
        m = re.fullmatch(r"(?:CAST\s*\((.*)\s+as\s+\w+\s*\)|toFloat(?:32|64)\s*\((.*)\))", s, re.I | re.S)
        if not m:
            return s
        s = _strip_parens(m.group(1) or m.group(2))


def strip_alias(s, aliases=("a", "b", "c")):
    return re.sub(r"\b(?:%s)\.(?=[A-Za-z_])" % "|".join(aliases), "", s)


def norm(s):
    """canonical text: no table aliases, single spaces, keywords lower-case, numbers as floats."""
    s = " ".join(strip_alias(_strip_parens(s or "")).split())
    out, i = [], 0
    for m in SP.STR.finditer(s):
        out.append(s[i:m.start()].lower())
        out.append(m.group(0))
        i = m.end()
    s = "".join(out) + s[i:].lower()
    s = re.sub(r"(?<![\w.])(\d+\.\d+|\d+e-?\d+)(?![\w.])", lambda m: repr(float(m.group(1))), s)
    s = re.sub(r"\s*([=<>!+\-*/,()])\s*", r"\1", s)
    return s


def cols_in(expr):
    """identifiers that name columns: no SQL type names (CAST … AS Float32)."""
    return [i for i in SP.idents(expr) if not mm._TYPES.match(i)]


NULLSAFE = re.compile(r"\b(?:coalesce|ifNull)\s*\(\s*\(?\s*(\{m:[^}]+\}|[A-Za-z_]\w*)\s*\)?\s*,\s*0\s*\)", re.I)


def strip_casts(e):
    """CAST(x AS T) / toFloat64(x) anywhere -> (x): types don't change a metric's value."""
    while True:
        m = re.search(r"\b(CAST|toFloat(?:32|64)|toDecimal\d*)\s*\(", e, re.I)
        if not m:
            return e
        dm = mm._depth_map(e)
        o = m.end() - 1
        c = next((i for i in range(o + 1, len(e)) if e[i] == ")" and dm[i] == dm[o]), None)
        if c is None:
            return e
        inner = e[o + 1:c]
        if m.group(1).upper() == "CAST":
            idm = mm._depth_map(inner)
            cut = [k.start() for k in re.finditer(r"\s+as\s+", inner, re.I) if idm[k.start()] == 0]
            inner = inner[:cut[-1]] if cut else mm._split_top(inner)[0]
        elif m.group(1).lower().startswith("todecimal"):
            inner = mm._split_top(inner)[0]
        e = e[:m.start()] + "(" + inner.strip() + ")" + e[c + 1:]


def conj_key(conds):
    return tuple(sorted(norm(c) for c in conds if norm(c) not in ("", "1=1")))


# ---------------------------------------------------------------- reads
def from_parts(sql):
    """FROM text -> (table, [(join table, alias)], [where conjuncts]); a '( select * FROM T
    [CROSS JOIN X] WHERE … ) a' wrapper is opened (its WHERE belongs to the scan)."""
    s, conds, joins = sql.strip(), [], []
    if s.startswith("("):
        dm = mm._depth_map(s)
        close = next(i for i in range(1, len(s)) if s[i] == ")" and dm[i] == 0)
        inner = s[1:close].strip()
        if re.match(r"select\b", inner, re.I):
            f = mm._top_kw(inner, "from")
            inner = inner[f + 4:] if f >= 0 else inner
        t, j, c = from_parts(inner)
        rest = s[close + 1:]
        w = mm._top_kw(rest, "where")
        if w >= 0:
            c += split_and(rest[w + 5:])
            rest = rest[:w]
        j2 = re.findall(r"\bjoin\s+([\w.]+)(?:\s+as)?\s+(\w+)", rest, re.I)
        return t, j + [(a, b) for a, b in j2], c
    w = mm._top_kw(s, "where")
    head = s if w < 0 else s[:w]
    if w >= 0:
        tail = s[w + 5:]
        for kw in ("group", "order", "limit", "settings", "having"):
            k = mm._top_kw(tail, kw)
            if k >= 0:
                tail = tail[:k]
        conds = split_and(tail)
    t = head.split()[0]
    joins = [(a, b) for a, b in re.findall(r"\bjoin\s+([\w.]+)(?:\s+as)?\s*(\w+)?", head, re.I)]
    return t, joins, conds


def inner_items(sql):
    """'( SELECT a, sum(x) AS x_x … FROM T … ) a' -> {x_x: 'sum(x)'}: the pre-aggregate a read wraps."""
    s = sql.strip()
    if not s.startswith("("):
        return {}
    dm = mm._depth_map(s)
    close = next(i for i in range(1, len(s)) if s[i] == ")" and dm[i] == 0)
    inner = s[1:close].strip()
    m = re.match(r"select\s+", inner, re.I)
    f = mm._top_kw(inner, "from")
    if not m or f < 0:
        return {}
    out = {}
    for it in mm._split_top(inner[m.end():f]):
        a, e, star = mm._item(it)
        if a and e and not star and e.strip() != a:
            out[a] = e
    g = mm._top_kw(inner, "group")
    out["__group__"] = _group_keys(inner[g:]) if g >= 0 else set()
    return out


def _group_keys(s):
    """GROUP BY a, b, … -> {a, b} (aliases dropped, aggregation placeholders ignored)."""
    s = re.sub(r"^group\s+by\s+", "", s.strip(), flags=re.I)
    for kw in ("having", "order", "limit", "settings", "with"):
        k = mm._top_kw(s, kw)
        if k >= 0:
            s = s[:k]
    return {strip_alias(x).strip() for x in mm._split_top(s) if x.strip() and not x.strip().startswith("__")}


def read_rules(t):
    """(role, regex on the de-aliased conjunct); groups name the period where it has one."""
    P = r"(?:(?P<p>TY|LY|LLY)_)?"
    W = rf"{t}_ty_ly_lly_week_SESSION"
    return [
        ("population", rf"^(?:x_)?product IN \(SELECT (?:distinct )?(?:product|stylecolor) FROM {t}_{P}(?:PRODUCT|sku_hier_attr|PRODLIST)_SESSION\)$"),
        ("population", rf"^\(?(?:x_)?product IN \(SELECT (?:distinct )?product FROM {t}_{P}PRODUCT_SESSION\) OR (?:x_)?product in \(select distinct product from {t}_flow_sku_hier_attr_SESSION\)\)?$"),
        ("window_selected", rf"^time IN \(select (?P<p>ty|ly|lly)_week_id from {W}\)$"),
        ("window_last", rf"^time IN \(select max\((?P<p>ty|ly|lly)_week_id\) from {W}\)$"),
        ("window_first", rf"^time IN \(select min\((?P<p>ty|ly|lly)_week_id\) from {W}\)$"),
        ("window_receipt", r"^time (?:>=|<=) (?:(?P<p>ly|lly)_)?final_rcpt_(?:start|end)$"),
        ("receipt_toggle", r"^if\(rcpt_filter_enabled = 1, rec_u > 0, rec_u >= 0\)$"),
        ("level", r"^(?P<lv>prodlife|cluster) IN \(__LEAF_(?:PRODLIFE|CLUSTER)__\)$"),
        ("locations", rf"^location IN \(SELECT (?:x_)?location FROM {t}_(?P<inv>INV_)?LOCATION_SESSION\)$"),
        ("latest_version", rf"^\((?:x_)?(?:product|stylecolor)(?:, snapshot_version)?, updated_at\) (?:IN|in) \(SELECT product(?:, snapshot_version)?, max_?\(?updated_at\)? FROM .*\)$"),
        ("snapshot", r"^snapshot_version = '[^']*'$"),
        ("plan_window", rf"^time in \(select id from {t}_d_time where indx .*\)$"),
    ]


def inv_has_dc(cfg, tenant):
    """INV_LOCATION = stores only unless the stocking-location UNION is live (history_base_tables.ftl)."""
    f = Path(cfg) / "pivot" / "include" / "history_base_tables.ftl"
    if not f.exists():
        return None
    sql = mm._strip_comments(f.read_text(errors="replace"))
    m = re.search(r"_INV_LOCATION_\$\{SESSION_ID\}(.*?);", sql, re.S)
    return bool(m and re.search(r"\bunion\b", m.group(1), re.I))


class Read:
    def __init__(self, rid, table, from_sql, tenant, sources, inv_dc, schema_cols=None):
        self.rid, self.table, self.inv_dc = rid, table, inv_dc
        self.inner = inner_items(from_sql)
        self.outer_group = set()
        self.source_id = next((s for s, r in sources.items() if r["table"] == table), None)
        self.periods, self.window, self.snap, self.locations = set(), None, None, None
        self.levels, self.row_filters, self.blocked, self.notes, self.conjuncts = set(), [], [], [], []
        t, joins, conds = from_parts(from_sql)
        self.joins = joins
        if t and t != table and t in {s["table"] for s in sources.values()} | {table}:
            self.table = table = t                    # layering may name a joined subquery's table
        self.source_id = next((s for s, r in sources.items() if r["table"] == table), None)
        # (SELECT location, max(<attr> = '<v>') AS flag FROM <t>_store_hier_attr GROUP BY location)
        self.loc_flags = {a: f"loc.{c} = {v}" for c, v, a in re.findall(
            rf"\(\s*SELECT\s+location\s*,\s*max\(\s*(\w+)\s*=\s*('[^']*')\s*\)\s+AS\s+(\w+)\s+FROM\s+"
            rf"{tenant}_store_hier_attr\s+GROUP\s+BY\s+location\s*\)", from_sql, re.I)}
        rules = read_rules(tenant)
        for c in conds:
            text = " ".join(strip_alias(c).split())
            role, gd = None, {}
            for r, rx in rules:
                m = re.match(rx, text, re.I)
                if m:
                    role, gd = r, m.groupdict()
                    break
            if role is None:
                cols = set(cols_in(text))
                have = sources.get(self.source_id, {}).get("_cols")
                if cols and (all(x in have for x in cols) if have else
                             re.fullmatch(r"[\w.]+ *(?:[<>=!]+ *[\w.']+|(?:NOT )?IN \('[^()]*'\))", text, re.I)):
                    role = "row_filter"
                    self.row_filters.append(text)
                else:
                    role = "unknown"
                    self.blocked.append(f"read {rid}: no rule for '{text}'")
            self.conjuncts.append({"text": text, "role": role})
            if "p" in gd and (gd["p"] or role != "window_receipt"):
                self.periods.add(PERIOD_OF[(gd["p"] or "").lower()])
            if role.startswith("window_"):
                self.window = "receipt" if role == "window_receipt" else "selected"
                self.snap = {"window_last": "last", "window_first": "first"}.get(role, self.snap)
            elif role == "receipt_toggle":
                self.notes.append("QA also needs rec_u > 0 when the receipt filter is on (screen toggle)")
            elif role == "level":
                self.levels.add(gd["lv"].lower())
            elif role == "locations":
                if gd.get("inv") and inv_dc:
                    self.blocked.append(f"read {rid}: {NEEDS_ENGINE['dc_locations']}")
                self.locations = "scope"
            elif role in NEEDS_ENGINE:
                self.blocked.append(f"read {rid}: needs engine support - {NEEDS_ENGINE[role]}")
        if len(self.periods) > 1:
            self.blocked.append(f"read {rid}: mixed periods {sorted(self.periods)}")
        self.period = next(iter(self.periods), "ty")
        if not self.source_id:
            self.blocked.append(f"read {rid}: {missing_source(table, schema_cols or set())}")
        src = sources.get(self.source_id) or {}
        if src.get("time_key") and not self.window:
            self.blocked.append(f"read {rid}: no week window recognised on a time-keyed table")
        if not src.get("time_key"):
            self.window = "none"
        have = {x.strip() for x in (src.get("level_filters") or "").split(",") if x.strip()}
        if src and self.levels != have:
            self.notes.append(f"level filters: QA {sorted(self.levels)} vs source {sorted(have)}")
        self.location_set = self.locations or "scope"

    def report(self):
        return {"read": self.rid, "table": self.table, "source_id": self.source_id, "period": self.period,
                "window": self.window, "snapshot": self.snap, "location_set": self.location_set,
                "row_filters": self.row_filters, "conjuncts": self.conjuncts, "blocked": self.blocked,
                "notes": self.notes}


# ---------------------------------------------------------------- measures
def _loc_attr(cond, tenant):
    m = re.fullmatch(rf"location IN \(SELECT location FROM {tenant}_store_hier_attr WHERE (\w+) = ('[^']*')\)",
                     cond, re.I)
    return f"loc.{m.group(1)} = {m.group(2)}" if m else None


def parse_measure(expr, read, tenant, cols, aliases=None):
    """pivot aggregate -> {agg, expr, conds, notes} or {blocked}. aliases: {joined name: source column}
    for names that are the source's own key (stylecolor = product on a stylecolor-grain table)."""
    e = strip_alias(re.sub(r"\b[a-d]\.", "", expr))
    notes = []
    if read.inner:                                  # the read pre-aggregates in a subquery: look through it
        same_grain = read.inner.get("__group__") and read.inner["__group__"] == read.outer_group
        one = re.fullmatch(r"(sum|max|min|any)\s*\(\s*(\w+)\s*\)", e.strip(), re.I)
        if one and one.group(2) in read.inner and mm._CONST.match(read.inner[one.group(2)]):
            return {"const": True}
        if one and one.group(2) in read.inner:
            ie = unwrap_cast(strip_alias(re.sub(r"\b[a-d]\.", "", read.inner[one.group(2)])))
            fn_, args_ = call(ie)
            finer = (read.inner.get("__group__") or set()) - read.outer_group
            if same_grain:
                e = ie                              # one inner row per output row: the outer agg is identity
                notes.append(f"pre-aggregated per {sorted(read.inner['__group__'])}: outer {one.group(1)}() is identity")
            elif fn_ and fn_.lower() in ("countif", "count", "uniqexact", "uniqexactif") and one.group(1).lower() == "sum":
                key = re.sub(r"^distinct\s+", "", args_[0], flags=re.I).strip()
                if finer == {key} or (aliases or {}).get(key) in finer:
                    e = ie                          # sum over items of [item counted] = distinct items
                    notes.append(f"sum of per-{key} distinct {key} = distinct {key}")
                else:
                    return {"blocked": f"needs engine support - {NEEDS_ENGINE['base_grain']}: "
                                       f"per {sorted(finer)} then summed: {read.inner[one.group(2)][:90]}"}
            elif not (fn_ and fn_.lower() in ("sum", "sumif") and one.group(1).lower() == "sum"):
                return {"blocked": f"needs engine support - {NEEDS_ENGINE['base_grain']}: "
                                   f"{one.group(1)}() per {sorted(finer)}: {read.inner[one.group(2)][:90]}"}
        e = re.sub(r"\b[A-Za-z_]\w*\b", lambda m: f"({read.inner[m.group(0)]})" if m.group(0) in read.inner
                   and not mm._CONST.match(read.inner[m.group(0)]) else m.group(0), e)
        if any(mm._CONST.match(read.inner.get(i, "x")) for i in cols_in(e)):
            return {"blocked": f"constant 0 in this read: {expr}"}
        e = mm.collapse_sums(re.sub(r"\b[a-d]\.", "", e))
    e = unwrap_cast(e)
    fn, args = call(e)
    f = (fn or "").lower()
    conds = []
    if f in ("sum", "max", "min", "avg") and len(args) == 1:
        agg, x = f, args[0]
    elif f in ("sumif", "maxif", "minif", "avgif") and len(args) == 2:
        agg, x, conds = f[:-2], args[0], split_and(args[1])
    elif f in ("countif", "count") and args and re.match(r"distinct\s", args[0], re.I):
        agg, x = "count_distinct", re.sub(r"^distinct\s+", "", args[0], flags=re.I)
        conds = split_and(args[1]) if len(args) > 1 else []
    elif f in ("uniqexact", "uniq", "uniqexactif", "uniqif"):
        agg, x = "count_distinct", args[0]
        conds = split_and(args[1]) if len(args) > 1 else []
    else:
        return {"blocked": f"aggregate shape not recognised: {expr}"}
    snap, keep = read.snap, []
    m = re.fullmatch(r"multiIf\(\s*store_flag\s*=\s*1\s*,\s*(\w+)\s*,\s*null\s*\)", x.strip(), re.I)
    if m:                                        # distinct stores only = store_flag rows
        x, conds = m.group(1), conds + ["store_flag = 1"]
    for k, v in (aliases or {}).items():
        if re.fullmatch(rf"\s*{k}\s*", x):
            x = v
            notes.append(f"{k} = {v} at this table's grain")
    W = rf"{tenant}_ty_ly_lly_week_SESSION"
    for c in conds:
        c = " ".join(c.split())
        m = re.fullmatch(rf"time = \(select (max|min)\((ty|ly|lly)_week_id\) from {W}\)", c, re.I)
        if m:
            if m.group(2).lower() != read.period:
                return {"blocked": f"snapshot week of {m.group(2)} inside a {read.period} read"}
            snap = "last" if m.group(1).lower() == "max" else "first"
            continue
        if re.fullmatch(r"1\s*=\s*1", c):
            continue
        if re.fullmatch(r"store_flag\s*=\s*1", c, re.I):
            if read.inv_dc:
                return {"blocked": f"store_flag=1 with DCs in INV_LOCATION: {NEEDS_ENGINE['dc_locations']}"}
            notes.append("store_flag=1 dropped: INV_LOCATION is stores only")
            continue
        fl = re.fullmatch(r"(\w+)\s*=\s*1", c)
        if fl and fl.group(1) in read.loc_flags:
            keep.append(read.loc_flags[fl.group(1)])
            notes.append(f"'{c}' -> {read.loc_flags[fl.group(1)]} (QA: ever in that channel; catalog: latest store attributes)")
            continue
        la = _loc_attr(c, tenant)
        if la:
            keep.append(la)
            notes.append(f"'{c}' -> {la} (latest store attributes)")
            continue
        bad = [i for i in cols_in(c) if i not in cols]
        if bad:
            return {"blocked": f"filter '{c}' uses {bad}, not columns of {read.table}"}
        keep.append(c)
    bad = [i for i in cols_in(x) if i not in cols]
    if bad:
        return {"blocked": f"expression '{x}' uses {bad}, not columns of {read.table}"}
    if snap:
        if agg == "sum":
            agg = "last_at_max_week" if snap == "last" else "first_at_min_week"
        elif agg == "count_distinct" and snap == "last":
            agg = "count_lastval"
        else:
            return {"blocked": f"{agg} at the {snap} week has no catalog agg"}
    return {"agg": agg, "expr": " ".join(x.split()), "conds": read.row_filters + keep, "notes": notes}


def measure_sig(m):
    """identity of a measure for matching: source, expr, agg, filter conjuncts, window, locations."""
    agg = SP.LEGACY_AGGS.get(m["agg"], m["agg"])
    conds = split_and(m.get("filter") or "")
    if agg == "sum_funded":
        agg, conds = "sum", conds + [SP.FUNDED]
    return (m["source_id"], norm(m["expr"]), agg, conj_key(conds), m.get("time_window") or "selected",
            m.get("location_set") or "scope")


# ---------------------------------------------------------------- formula equivalence
def _case_to_if(s):
    """CASE WHEN a THEN b [WHEN …] ELSE c END -> if(a, b, …) (nesting-safe)."""
    while True:
        m = re.search(r"\bcase\b", s, re.I)
        if not m:
            return s
        depth, i, end = 0, m.start(), None
        for t in re.finditer(r"\bcase\b|\bend\b", s[m.start():], re.I):
            depth += 1 if t.group(0).lower() == "case" else -1
            if depth == 0:
                end = m.start() + t.end()
                break
        if end is None:
            raise ValueError("unbalanced CASE")
        body = s[m.end():end - 3]
        parts = re.split(r"\b(when|then|else)\b", _case_to_if(body), flags=re.I)
        arms, other, k = [], "0", 1
        while k < len(parts):
            kw = parts[k].lower()
            if kw == "when":
                arms.append([parts[k + 1], None])
            elif kw == "then":
                arms[-1][1] = parts[k + 1]
            else:
                other = parts[k + 1]
            k += 2
        out = other
        for c, v in reversed(arms):
            out = f"if({c}, {v}, {out})"
        s = s[:i] + f"({out})" + s[end:]


def _totals(s):
    """total(x) -> one atom per distinct x: a total over all rows is not a function of this row."""
    while True:
        m = re.search(r"\btotal\s*\(", s, re.I)
        if not m:
            return s
        d, i = 1, m.end()
        while d and i < len(s):
            d += {"(": 1, ")": -1}.get(s[i], 0)
            i += 1
        key = re.sub(r"\W+", "_", " ".join(s[m.end():i - 1].split())).strip("_")
        s = s[:m.start()] + f"__total__{key}" + s[i:]


def to_py(expr):
    s = _case_to_if(_totals(expr))
    s = re.sub(r"<>", "!=", s)
    s = re.sub(r"(?<![<>!=])=(?!=)", "==", s)
    s = re.sub(r"\band\b", " and ", s, flags=re.I)
    s = re.sub(r"\bor\b", " or ", s, flags=re.I)
    s = re.sub(r"\bnot\b", " not ", s, flags=re.I)
    s = re.sub(r"\bif\s*\(", "_if(", s, flags=re.I)
    s = re.sub(r"\bround\s*\(", "_round(", s, flags=re.I)
    s = s.replace("@", "__at_")
    return s


def _if(c, a, b):
    return np.float64(a if c else b)                # 0 / 0 -> nan, not ZeroDivisionError


def _round(x, n=0):
    return np.round(x, int(n))


def equivalent(e1, e2, samples=60, seed=7):
    """same value for random atom values (zeros and negatives included, so guards are exercised)."""
    p1, p2 = to_py(e1), to_py(e2)
    atoms = sorted(set(re.findall(r"[A-Za-z_]\w*", p1 + " " + p2)) - {"_if", "_round", "and", "or", "not"})
    rng = np.random.default_rng(seed)
    pool = [0.0, 1.0, 3.0, -2.0, 0.5, 1234.5678, 17.0]
    with np.errstate(all="ignore"):
        for k in range(samples):
            env = {a: np.float64(rng.choice(pool) if k % 3 == 0 else rng.uniform(-5, 500)) for a in atoms}
            env.update(_if=_if, _round=_round)
            try:
                v1, v2 = np.float64(eval(p1, {}, env)), np.float64(eval(p2, {}, env))
            except Exception:
                return False
            if np.isnan(v1) and np.isnan(v2):
                continue
            if not np.isclose(v1, v2, rtol=1e-9, atol=1e-9, equal_nan=True):
                return False
    return True


def metric_sql(m):
    """a catalog metric as one expression (the engine's ratio guard spelled out)."""
    if m.get("type") == "ratio":
        body = f"({m['expr']}) / ({m['denominator']})"
        if str(m.get("round") or "").strip():
            body = f"round({body}, {m['round']})"
        return f"if(({m['denominator']}) > 0, {body}, 0)"
    return m["expr"]


def expand(name, period, metrics, measures, depth=0):
    """name@period -> expression over measure atoms 'id' (ty) / 'id__ly'."""
    if depth > 30:
        raise ValueError(f"{name}: too deep")
    if name in metrics and not (metrics[name].get("type") == "simple" and metrics[name]["expr"].strip() == name
                                and name in measures):
        e = metric_sql(metrics[name])
        out, i = [], 0
        for m in re.finditer(r"([A-Za-z_]\w*)(@(ty|ly|lly)\b)?", SP._mask(e)):
            w = m.group(1)
            if w not in metrics and w not in measures:
                continue
            if e[m.end():].lstrip()[:1] == "(":
                continue
            if w == name and w in measures:                # x = f(x): the measure underneath
                out.append(e[i:m.start()] + SP.pcol(w, m.group(3) or period))
            else:
                out.append(e[i:m.start()] + "(" + expand(w, m.group(3) or period, metrics, measures, depth + 1) + ")")
            i = m.end()
        return "".join(out) + e[i:]
    if name in measures:
        return SP.pcol(name, period)
    raise ValueError(f"'{name}' is not a measure or metric")


# ---------------------------------------------------------------- columns -> metrics
class Ref:
    __slots__ = ("kind", "id", "period")

    def __init__(self, kind, id_, period):
        self.kind, self.id, self.period = kind, id_, period


RATIO = re.compile(r"^case\s+when\s+(?P<g>.+?)\s*>\s*0\s+then\s+(?P<body>.+?)\s+else\s+0\s+end$", re.I | re.S)
TAG = re.compile(r"^(?:(ty|ly|lly)_)?(.+?)(?:_(ty|ly|lly))?$")


def metric_id_for(col, period):
    """column name -> catalog id without the period tag (ly_net_sls_u -> net_sls_u)."""
    c = re.sub(r"__b\d+$", "", col)
    m = TAG.match(c)
    tag = m.group(1) or m.group(3)
    if tag and tag == period:
        return m.group(2)
    return c


def split_ratio(e):
    """'CASE WHEN g > 0 THEN round(n / d, r) ELSE 0 END' -> (g, n, d, r) else None."""
    m = RATIO.match(" ".join(e.split()))
    if not m:
        return None
    g, body = _strip_parens(m.group("g")), _strip_parens(m.group("body"))
    fn, args = call(body)
    r = ""
    if fn and fn.lower() == "round" and (len(args) == 1 or len(args) == 2 and args[1].strip().isdigit()):
        body, r = _strip_parens(args[0]), (args[1].strip() if len(args) == 2 else "0")
    dm = mm._depth_map(body)
    cuts = [i for i, ch in enumerate(body) if ch == "/" and dm[i] == 0]
    if len(cuts) != 1:
        return None
    return g, _strip_parens(body[:cuts[0]]), _strip_parens(body[cuts[0] + 1:]), r


class Translator:
    def __init__(self, cfg, client, spec, schema, pivot, rows, env="qa"):
        self.cfg, self.client, self.tenant, self.env = Path(cfg), client, client.lower(), env
        self.spec, self.schema, self.pivot, self.rows = spec, schema, pivot, rows
        self.sources = {sid: {**s, "_cols": set(schema.get(s["table"], ()))} for sid, s in spec["sources"].items()}
        self.inv_dc = inv_has_dc(self.cfg, self.tenant)
        dp = HUB / "customers" / client.upper() / "metrics" / "dimensions.json"
        prod = json.loads(dp.read_text()).get("product", {}) if dp.exists() else {}
        sku = json.loads(dp.read_text()).get("product_sku", {}) if dp.exists() else {}
        self.canon = {b: a for a, b in (sku.get("sources") or {}).items()}   # history_sku -> history
        self.aliases = {prod["base_grain"]: prod["base_key"]} \
            if prod.get("base_grain") and prod.get("base_grain") != prod.get("base_key") else {}
        self.cat_sig = {}
        for mid, m in spec["measures"].items():
            self.cat_sig.setdefault(measure_sig(m), mid)
        self.reads, self.measures, self.metrics, self.cols = {}, {}, {}, {}
        self.blocked = {}

    # -- layering
    def run(self):
        need = set()
        for r in self.rows:
            need.add(r["data_index"])
            if r.get("view_formula"):
                need.update(mm._pivot_cols_in(r["view_formula"]))
        self.L, self.status = F.layer_pivot(self.cfg, self.pivot, self.tenant,
                                            {t: set(c) for t, c in self.schema.items() if c}, sorted(need))
        for rid, r in self.L.reads.items():
            bid = int(rid.rsplit("#", 1)[1])
            self.reads[rid] = Read(rid, r["table"], r["from_sql"], self.tenant, self.sources, self.inv_dc,
                                   set(self.schema.get(from_parts(r["from_sql"])[0] or r["table"]) or ()))
            self.reads[rid].outer_group = _group_keys(self.L.blocks[bid].group_sql or "")
        return self

    # -- measures
    def measure(self, token):
        """'{m:rid:name}' -> Ref to a catalog or proposed measure (or raises Blocked)."""
        key = token
        if key in self.cols:
            return self.cols[key]
        rid, name = token.rsplit(":", 1)
        rd, m = self.reads[rid], self.L.measures[token]
        if rd.blocked:
            raise Blocked("; ".join(rd.blocked))
        src = self.sources[rd.source_id]
        pm = parse_measure(m["expr"], rd, self.tenant, src["_cols"],
                           {k: v for k, v in self.aliases.items() if v == src.get("item_key")})
        if pm.get("const"):
            self.cols[key] = Ref("const", "0", rd.period)
            return self.cols[key]
        if "blocked" in pm:
            raise Blocked(f"{name}: {pm['blocked']}")
        row = {"source_id": rd.source_id, "expr": pm["expr"], "agg": pm["agg"],
               "filter": " AND ".join(pm["conds"]), "time_window": rd.window, "location_set": rd.location_set}
        cs = self.canon.get(rd.source_id)                 # a SKU read of a measure the catalog has per stylecolor
        if cs and set(cols_in(row["expr"] + " " + row["filter"])) <= self.sources.get(cs, {}).get("_cols", set()):
            row["source_id"] = cs
        sig = measure_sig(row)
        mid = self.cat_sig.get(sig)
        notes = pm["notes"] + rd.notes
        if mid:
            st = "same"
        else:
            base = re.sub(r"_x$", "", name)
            mid = metric_id_for(base, rd.period)
            st = "new"
            hit = next((k for k, v in self.measures.items() if v["sig"] == sig), None)
            if hit:
                mid = hit
            else:
                if rd.source_id in self.canon and row["source_id"] == rd.source_id:
                    mid += "_sku"                         # only readable at SKU grain
                def taken(i):                             # measures and metrics share one name space
                    met = self.spec["metrics"].get(i) or (self.metrics.get(i) or {})
                    return (i in self.spec["measures"] or (i in self.measures and self.measures[i]["sig"] != sig)
                            or (met and norm(met.get("expr", "")) != i))
                while taken(mid):
                    notes.append(f"id {mid} is taken by a different measure or metric")
                    mid = mid + "_qa"
        rec = self.measures.setdefault(mid, {"id": mid, "status": st, "sig": sig, **row, "rollup": "sum",
                                             "label": "", "notes": notes, "from": []})
        rec["from"].append(f"{self.pivot}:{token[1:-1] if token.startswith('{') else token}")
        ref = Ref("measure", mid, rd.period)
        self.cols[key] = ref
        return ref

    # -- columns
    def column(self, name, stack=()):
        if name in self.cols:
            return self.cols[name]
        if name in self.blocked:
            raise Blocked(self.blocked[name])
        if name in stack:
            raise Blocked(f"{name}: circular")
        try:
            ref = self._column(name, stack + (name,))
        except Blocked as b:
            self.blocked[name] = str(b)
            raise
        self.cols[name] = ref
        return ref

    def _column(self, name, stack):
        e = self.L.columns.get(name)
        if re.search(r"\browNumberIn(Block|AllBlocks)\s*\(|\brank\s*\(\s*\)\s*over", e or "", re.I):
            raise Blocked(f"{name}: needs engine support - {NEEDS_ENGINE['rank_band']}")
        if e is None:
            raise Blocked(f"{name}: not a column of pivot {self.pivot} ({self.status.get(name, 'not layered')})")
        e = strip_casts(" ".join(e.split()))
        while NULLSAFE.search(e):
            e = NULLSAFE.sub(r"\1", e)
        e = re.sub(r"^(?:__[A-Z][A-Z0-9_]*__\s*)+", "", e)     # ${LEAF_DIMENSION_GROUPS_COMMA}: group columns ahead
        ph = re.search(r"__[A-Z][A-Z0-9_]*__", e)
        if ph:
            raise Blocked(f"{name}: depends on screen placeholder {ph.group(0)} in '{e[:120]}'")
        w = re.fullmatch(r"(sum|max|min|any|anyLast)\(\s*(\{m:[^}]+\})\s*\)|(\{m:[^}]+\})", e, re.I)
        if w:
            ref = self.measure((w.group(2) or w.group(3))[3:-1])
            if ref.kind == "const":
                raise Blocked(f"{name}: constant 0 in this pivot")
            if w.group(1) and w.group(1).lower() == "max":
                self.measures[ref.id]["rollup"] = "max"
            return ref
        if re.fullmatch(r"[A-Za-z_]\w*", e):
            return self.column(e, stack)
        # formula over measures and columns
        refs, i, out = [], 0, []
        masked = SP._mask(e)
        toks = list(re.finditer(r"\{m:[^}]+\}|[A-Za-z_]\w*", masked))
        for t in toks:
            w_ = t.group(0)
            if w_.startswith("{m:"):
                r = self.measure(w_[3:-1])
            else:
                nxt = masked[t.end():].lstrip()[:1]
                if nxt == "(" or w_.lower() in SP.KW or w_.lower() in ("round", "else", "end", "null") \
                        or mm._TYPES.match(w_):
                    continue
                if (t.start() and masked[t.start() - 1] == "."):
                    continue
                r = self.column(w_, stack)
            out.append(e[i:t.start()] + f"⟨{len(refs)}⟩")
            refs.append(r)
            i = t.end()
        tmpl = "".join(out) + e[i:]
        lin = re.fullmatch(r"\s*sum\s*\((.*)\)\s*", tmpl, re.I | re.S)
        if lin and re.fullmatch(r"[\s()+\-\d.\u27e8\u27e9]*", lin.group(1)) and mm._atom(tmpl.strip()):
            tmpl = lin.group(1)                     # sum(a + b) of measures = a + b
        agg = re.search(r"\b(sum|max|min|count|avg)\s*\(", tmpl, re.I)
        if agg:
            raise Blocked(f"{name}: aggregate {agg.group(1)}() over a computed column: {e}")
        live = [r for r in refs if r.kind != "const"]
        if refs and not live:
            raise Blocked(f"{name}: constant 0 in this pivot")
        periods = {r.period for r in live} or {"ty"}
        per = next(iter(periods)) if len(periods) == 1 else "ty"
        def render(s):
            def one(m):
                r = refs[int(m.group(1))]
                return "0" if r.kind == "const" else r.id + ("" if r.period == per else "@" + r.period)
            return re.sub("⟨(\\d+)⟩", one, s)
        rt = split_ratio(tmpl)
        mid = metric_id_for(name, per)
        notes = []
        if not refs:
            raise Blocked(f"{name}: no table column behind '{e}' (row attribute, not a metric)")
        if rt and equivalent(render(rt[0]).replace("@", "__at_"), render(rt[2]).replace("@", "__at_")):
            row = {"type": "ratio", "expr": render(rt[1]), "denominator": render(rt[2]), "round": rt[3]}
        elif rt:
            r_ = f"round(({render(rt[1])}) / ({render(rt[2])}), {rt[3]})" if rt[3] else \
                f"({render(rt[1])}) / ({render(rt[2])})"
            row = {"type": "derived", "expr": f"if(({render(rt[0])}) > 0, {r_}, 0)", "denominator": "", "round": ""}
            notes.append(f"QA guards on '{render(rt[0])}' but divides by '{render(rt[2])}' - check with the owner")
        else:
            row = {"type": "derived", "expr": " ".join(render(tmpl).split()), "denominator": "", "round": ""}
        return self.add_metric(mid, row, per, notes, f"{self.pivot}:{name} = {e}")

    def add_metric(self, mid, row, per, notes, src):
        """match the catalog by meaning (same id, then any id), else propose; -> Ref."""
        cat, measures = self.spec["metrics"], {**self.spec["measures"], **{k: v for k, v in self.measures.items()}}
        mets = {**cat, **{k: v for k, v in self.metrics.items() if v["status"] == "new"}}
        tmp = dict(mets)
        probe = "∀probe"
        tmp[probe] = row
        try:
            mine = expand(probe, "ty", tmp, measures)
        except ValueError as e:
            raise Blocked(f"{mid}: {e}")
        def same_as(k):
            try:
                return equivalent(mine, expand(k, "ty", mets, measures))
            except ValueError:
                return False
        if mid in cat:
            if same_as(mid):
                self._note_metric(mid, "same", row, notes, src, cat[mid])
                return Ref("metric", mid, per)
            hit = next((k for k in cat if k != mid and same_as(k)), None)
            if hit:
                self._note_metric(mid, "differs", row, notes + [f"QA's meaning equals catalog '{hit}'"],
                                  src, cat[mid])
                return Ref("metric", hit, per)
            # QA's formula differs from the catalog metric of that id: propose QA's own, never bind to it
            notes = notes + [f"differs from catalog '{mid}' ({cat[mid].get('type')}: {cat[mid].get('expr')})"]
            mid += "_qa"
        hit = next((k for k in mets if same_as(k)), None)
        if hit:
            if hit not in self.metrics:
                self._note_metric(hit, "same", row, notes + [f"QA column '{mid}' = catalog '{hit}'"], src, cat.get(hit))
            else:
                self.metrics[hit]["from"].append(src)
            return Ref("metric", hit, per)
        while mid in self.metrics and not equivalent(mine, expand(mid, "ty", mets, measures)):
            notes.append(f"id {mid} is taken by a different QA column")
            mid += "_qa"
        if mid not in self.metrics:
            self.metrics[mid] = {"id": mid, "status": "new", **row, "label": "", "notes": notes, "from": [src],
                                 "catalog": None}
        else:
            self.metrics[mid]["from"].append(src)
        return Ref("metric", mid, per)

    def _note_metric(self, mid, st, row, notes, src, cat):
        rec = self.metrics.setdefault(mid, {"id": mid, "status": st, **row, "label": "", "notes": notes,
                                            "from": [], "catalog": {k: cat.get(k, "") for k in
                                                                    ("type", "expr", "denominator", "round")}
                                            if cat else None})
        rec["from"].append(src)

    # -- screen columns
    def bindings(self):
        cat = {(b["viewdefn"], b["data_index"]): b for b in self.spec["bindings"] if b["pivot"] == self.pivot}
        out, seen = [], set()
        for r in self.rows:
            k = (r["viewdefn"], r["data_index"])
            if k in seen:
                continue
            seen.add(k)
            b = {"pivot": self.pivot, "viewdefn": k[0], "data_index": k[1], "label": r["display_name"],
                 "screen": r.get("screen_view", ""), "view_formula": r.get("view_formula", ""), "notes": []}
            try:
                if k[1] not in self.L.columns and r.get("view_formula") and \
                        mm._pivot_cols_in(r["view_formula"]) != [k[1]]:
                    ref = self.client_metric(k[1], r["view_formula"])
                else:
                    ref = self.column(k[1])
                if ref.kind == "measure":
                    ref = self.add_metric(metric_id_for(k[1], ref.period),
                                          {"type": "simple", "expr": ref.id, "denominator": "", "round": ""},
                                          ref.period, [], f"{self.pivot}:{k[1]} (a measure on screen)")
                b.update(metric_id=ref.id, period=ref.period,
                         rollup_formula=self.rollup(r.get("view_formula", ""), ref.period))
                if self.metrics.get(ref.id, {}).get("status") == "differs":
                    b["notes"].append(f"metric {ref.id}: QA differs from the catalog")
            except Blocked as e:
                if "needs engine support" in str(e) or self._ranked(k[1]):
                    b.update(status="blocked", metric_id="", period="", rollup_formula="",
                             why=str(e) if "needs engine" in str(e) else
                             f"{k[1]}: needs engine support - {NEEDS_ENGINE['rank_band']}")
                    out.append(self._vs_catalog(b, cat.get(k)))
                    continue
                raw = any(p.startswith(k[1] + ":") and "raw column" in p for p in self.L.problems)
                if r.get("status") in ("unresolved", "no_pivot") or raw \
                        or not self.L.columns.get(k[1]) and not r.get("view_formula"):
                    b.update(status="attribute", metric_id="", period="ty", rollup_formula="", why=str(e))
                else:
                    b.update(status="blocked", metric_id="", period="", rollup_formula="", why=str(e))
                out.append(self._vs_catalog(b, cat.get(k)))
                continue
            except Blocked2 as e:
                b.update(status="blocked", metric_id=ref.id, period=ref.period, rollup_formula="", why=str(e))
                out.append(self._vs_catalog(b, cat.get(k)))
                continue
            b["status"] = "ok"
            out.append(self._vs_catalog(b, cat.get(k)))
        return out

    def _ranked(self, col):
        """the QA metric map shows the column is a rank band (the layering can't follow it)."""
        return any(r["data_index"] == col and "rowNumberInBlock" in (r.get("base_formula") or "")
                   for r in self.rows)

    def rollup(self, f, per):
        if not f:
            return ""
        out, i = [], 0
        masked = SP._mask(f)
        for t in re.finditer(r"[A-Za-z_]\w*", masked):
            w = t.group(0)
            if masked[t.end():].lstrip()[:1] == "(" or w.lower() in SP.KW:
                continue
            try:
                r = self.column(w)
            except Blocked as e:
                raise Blocked2(f"rollup '{f}': {e}")
            out.append(f[i:t.start()] + self.name_for(w, r) + ("" if r.period == per else "@" + r.period))
            i = t.end()
        return "".join(out) + f[i:]

    def name_for(self, col, r):
        """the screen's own name when a catalog/proposed metric by that name means the same."""
        cand = metric_id_for(col, r.period)
        if cand == r.id:
            return cand
        mets = {**self.spec["metrics"], **{k: v for k, v in self.metrics.items() if v["status"] == "new"}}
        meas = {**self.spec["measures"], **self.measures}
        if cand in mets:
            try:
                if equivalent(expand(cand, "ty", mets, meas), expand(r.id, "ty", mets, meas)):
                    return cand
            except ValueError:
                pass
        return r.id

    def client_metric(self, di, f):
        """a screen-only column (no pivot column): row value = its formula on one row."""
        row = re.sub(r"\b(sum|max|min|avg|mean|first|last)\s*\(\s*([^()]*?)\s*\)", r"(\2)", f, flags=re.I)
        out, i, refs = [], 0, []
        masked = SP._mask(row)
        for t in re.finditer(r"[A-Za-z_]\w*", masked):
            w = t.group(0)
            if masked[t.end():].lstrip()[:1] == "(" or w.lower() in SP.KW:
                continue
            r = self.column(w)
            refs.append(r)
            out.append(row[i:t.start()] + self.name_for(w, r))
            i = t.end()
        per = {r.period for r in refs}
        if len(per) != 1:
            raise Blocked(f"{di}: screen formula mixes periods")
        expr = " ".join(("".join(out) + row[i:]).split())
        return self.add_metric(metric_id_for(di, next(iter(per))), {"type": "derived", "expr": expr,
                               "denominator": "", "round": ""}, next(iter(per)),
                               ["screen-only column: row value = the client formula on one row (no 0-guard)"],
                               f"{self.pivot}:{di} = {f} (client formula)")

    def _vs_catalog(self, b, c):
        if b["status"] == "attribute":
            b["status"] = "same" if c else "attribute"
            return b
        if b["status"] == "blocked":
            b["catalog"] = {k: c.get(k, "") for k in ("metric_id", "period", "rollup_formula")} if c else None
            return b
        if not c:
            b["status"] = "new"
            return b
        b["catalog"] = {k: c.get(k, "") for k in ("metric_id", "period", "rollup_formula")}
        same_m = (c.get("metric_id") == b["metric_id"]) and ((c.get("period") or "ty") == b["period"])
        cr = c.get("rollup_formula", "")
        try:
            cr_n = self.rollup(cr, b["period"])      # catalog rollup in the same names as QA's
        except (Blocked, Blocked2, ValueError):
            cr_n = cr
        same_r = norm(cr) == norm(b["rollup_formula"]) or norm(cr_n) == norm(b["rollup_formula"]) or bool(
            cr and b["rollup_formula"] and (_rollup_equiv(cr, b["rollup_formula"])
                                           or _rollup_equiv(cr_n, b["rollup_formula"])))
        if not c.get("metric_id"):
            b["status"] = "unbound"           # catalog has the column but no metric yet
            known = {**self.spec["metrics"], **self.metrics, **self.spec["measures"], **self.measures}
            unk = sorted({w for w in re.findall(r"[A-Za-z_]\w*", SP._mask(cr))
                          if w.lower() not in SP.KW and w not in known
                          and not re.search(rf"\b{w}\s*\(", cr)})
            if cr and unk and b["rollup_formula"]:
                b["fill_rollup"] = True       # catalog rollup names columns the catalog lacks
                b["notes"].append(f"catalog rollup uses {unk}; filled with QA's rollup")
        elif same_m and same_r:
            b["status"] = "same"
        else:
            b["status"] = "changed"
            if not same_m:
                b["notes"].append(f"metric: catalog {c.get('metric_id')}@{c.get('period') or 'ty'} vs QA "
                                  f"{b['metric_id']}@{b['period']}")
            if not same_r:
                b["notes"].append("rollup formula differs")
        return b


def _ternary(f):
    """top-level 'a ? b : c' (mathjs) -> if(a, b, c)."""
    dm = mm._depth_map(f)
    q = next((i for i, ch in enumerate(f) if ch == "?" and dm[i] == 0), None)
    c = next((i for i, ch in enumerate(f) if ch == ":" and dm[i] == 0 and q is not None and i > q), None)
    if q is None or c is None:
        return f
    return f"if({f[:q]}, {f[q + 1:c]}, {_ternary(f[c + 1:])})"


def _rollup_equiv(a, b):
    def atoms(f):
        f = re.sub(r"\b(sum|max|min|avg|mean|count|size)\s*\(\s*([A-Za-z_]\w*(?:@\w+)?|1)\s*\)",
                   lambda m: f"{m.group(1).lower()}__{m.group(2).replace('@', '__')}", f, flags=re.I)
        return _ternary(f)
    try:
        return equivalent(atoms(a), atoms(b))
    except Exception:
        return False


class Blocked(Exception):
    pass


class Blocked2(Exception):
    pass


# ---------------------------------------------------------------- screens
def pop_includes(cfg, pivot):
    f = Path(cfg) / "pivot" / f"{pivot}.pivotdefn"
    return sorted(i for i in mm._INCLUDE.findall(f.read_text(errors="replace")) if "product" in i.lower()) \
        if f.exists() else []


_CRIT = re.compile(r'params\.(\w*SELECTION_CRITERIA)\s*=\s*"""(.*?)"""', re.S)
POP_KEYS = ("population_id", "step", "rule_id", "kind", "source_id", "time_window", "condition", "row_filter", "group_level",
            "applies_when")


def _cond(c):
    """a criteria param as a rule condition: outer parens off, one line."""
    c = " ".join((c or "").split())
    while c.startswith("(") and c.endswith(")") and mm._depth_map(c)[-1] == 0 and \
            all(d > 0 for d in mm._depth_map(c)[1:-1]):
        c = c[1:-1].strip()
    return c


def pop_params(cfg, pivot):
    """{param: condition}: the pivot's item thresholds (FLOW_ / HIST_TABLE_SELECTION_CRITERIA)."""
    f = Path(cfg) / "pivot" / f"{pivot}.pivotdefn"
    return {k: _cond(v) for k, v in _CRIT.findall(f.read_text(errors="replace"))} if f.exists() else {}


def _pop_slug(changed):
    nums = sorted({n for c in changed for n in re.findall(r"[<>]=?\s*(-?\d+(?:\.\d+)?)", c)})
    return ("GT" + nums[0].replace("-", "M").replace(".", "_")) if len(nums) == 1 else \
        "C" + hashlib.md5("|".join(changed).encode()).hexdigest()[:6]


def screen_for(cfg, pivot, spec):
    """a screen's population: a catalog screen with the same population includes AND the same item
    thresholds (params.*SELECTION_CRITERIA, set per pivot); thresholds differ -> a population variant."""
    if pivot in spec["screens"]:
        return {"pivot": pivot, "status": "same", **{k: spec["screens"][pivot].get(k, "") for k in
                                                    ("population_id", "time_mode", "split_by_class", "item_grain")}}
    mine, my_par = pop_includes(cfg, pivot), pop_params(cfg, pivot)
    cands = sorted([(p, s) for p, s in spec["screens"].items() if mine and pop_includes(cfg, p) == mine],
                   key=lambda ps: bool(re.search(r"_(GTM?\d|C[0-9a-f]{6})", ps[1]["population_id"])))
    for p, s in cands:
        if pop_params(cfg, p) == my_par:
            return {"pivot": pivot, "status": "new", "population_id": s["population_id"],
                    "time_mode": s.get("time_mode") or "history", "split_by_class": s.get("split_by_class") or "yes", "item_grain": s.get("item_grain") or "stylecolor",
                    "notes": [f"same population includes and thresholds as {p}: {', '.join(mine)}; "
                              f"row settings copied from {p} - check split_by_class / row_periods"]}
    if cands:
        p, s = cands[0]
        their = pop_params(cfg, p)
        swap = {their[k]: my_par[k] for k in their if k in my_par and their[k] != my_par[k]}
        base = [dict(r) for r in spec["populations"] if r["population_id"] == s["population_id"]]
        hit = {k for r in base for k in swap if _cond(r.get("condition")).lower() == k.lower()}
        if set(swap) - hit:
            return {"pivot": pivot, "status": "blocked", "population_id": "",
                    "why": f"thresholds differ from {p} but no rule of {s['population_id']} carries "
                           f"{sorted(set(swap) - hit)}"}
        rules = [{**{k: r.get(k, "") for k in POP_KEYS},
                  "condition": swap.get(next((k for k in swap if k.lower() == _cond(r.get("condition")).lower()), None),
                                        r.get("condition", ""))} for r in base]
        sig = sorted(tuple(str(r[k]) for k in POP_KEYS[1:]) for r in rules)
        for pid in sorted({r["population_id"] for r in spec["populations"]}):      # reuse an identical variant
            if sorted(tuple(str(r.get(k, "")) for k in POP_KEYS[1:]) for r in spec["populations"]
                      if r["population_id"] == pid) == sig:
                return {"pivot": pivot, "status": "new", "population_id": pid, "time_mode": s.get("time_mode") or "history",
                        "split_by_class": s.get("split_by_class") or "yes", "item_grain": s.get("item_grain") or "stylecolor",
                        "notes": [f"same includes as {p}; thresholds match population {pid}; "
                                  f"row settings copied from {p} - check split_by_class / row_periods"]}
        root = re.sub(r"_(GTM?\d[\w]*|C[0-9a-f]{6})$", "", s["population_id"])   # variants derive from the root
        pid = f"{root}_{_pop_slug(list(swap.values()))}"
        for r in rules:
            r["population_id"] = pid
        return {"pivot": pivot, "status": "new", "population_id": pid, "time_mode": s.get("time_mode") or "history",
                "split_by_class": s.get("split_by_class") or "yes", "item_grain": s.get("item_grain") or "stylecolor", "population": rules,
                "notes": [f"population {pid} = {s['population_id']} with {pivot}'s thresholds: "
                          + "; ".join(f"{a} -> {b}" for a, b in swap.items()),
                          f"row settings copied from {p} - check split_by_class / row_periods"]}
    return {"pivot": pivot, "status": "blocked", "population_id": "",
            "why": f"no catalog screen builds its items with {mine or 'these includes'} - define the population first"}


# ---------------------------------------------------------------- run / apply
def load_inputs(client, env="qa", cfg=None):
    import config_sync as CS
    mdir = HUB / "customers" / client.upper() / "metrics"
    cfg = Path(cfg) if cfg else CS.effective_dir(client, env)
    mp = mdir / f"metric_map_{env}.csv"
    schema = json.loads((mdir / "ch_schema.json").read_text())
    rows = list(csv.DictReader(open(mp, newline="")))
    stale = mp.stat().st_mtime < max((p.stat().st_mtime for p in (cfg / "pivot").glob("*.pivotdefn")), default=0)
    return cfg, rows, schema, stale


def translate(client, pivots, spec, env="qa", cfg=None, inputs=None):
    """inputs: (cfg, metric map rows, schema) to skip the files (tests)."""
    cfg, rows, schema, stale = (*inputs, False) if inputs else load_inputs(client, env, cfg)
    rep = {"client": client, "env": env, "config_dir": str(cfg), "metric_map_stale": stale,
           "ran_at": datetime.datetime.now().isoformat(timespec="seconds"),
           "pivots": [], "reads": [], "measures": [], "metrics": [], "bindings": [], "screens": []}
    merged_m, merged_k = {}, {}
    for pv in pivots:
        prow = [r for r in rows if r.get("pivot") == pv]
        if not prow:
            rep["pivots"].append({"pivot": pv, "error": "no screen column uses this pivot in the QA metric map"})
            continue
        T = Translator(cfg, client, spec, schema, pv, prow, env).run()
        T.measures, T.metrics = merged_k, merged_m       # one id space across pivots
        bnd = T.bindings()
        rep["pivots"].append({"pivot": pv, "columns": len(bnd), "reads": len(T.reads),
                              "problems": T.L.problems})
        rep["reads"] += [{"pivot": pv, **r.report()} for r in T.reads.values()]
        rep["bindings"] += bnd
        rep["screens"].append(screen_for(cfg, pv, spec))
    blocked_scr = {s["pivot"]: s["why"] for s in rep["screens"] if s["status"] == "blocked"}
    for b in rep["bindings"]:
        if b["status"] in ("new", "unbound") and b["pivot"] in blocked_scr:
            b["status"], b["why"] = "needs_screen", blocked_scr[b["pivot"]]
    for m in merged_k.values():
        c = spec["measures"].get(m["id"])
        if m["status"] == "same" and c and (c.get("rollup") or "sum") != m["rollup"]:
            m["notes"].append(f"rollup: catalog {c.get('rollup') or 'sum'}, QA {m['rollup']} (same value at one row per item)")
    rep["measures"] = [{k: v for k, v in m.items() if k != "sig"} for m in merged_k.values()]
    rep["metrics"] = list(merged_m.values())
    rep["counts"] = {
        "bindings": dict(Counter(b["status"] for b in rep["bindings"])),
        "measures": dict(Counter(m["status"] for m in rep["measures"])),
        "metrics": dict(Counter(m["status"] for m in rep["metrics"])),
        "blocked_reasons": dict(Counter(_reason(b["why"]) for b in rep["bindings"]
                                        if b["status"] in ("blocked", "needs_screen"))),
    }
    return rep


def _reason(why):
    m = re.search(r"needs engine support - (.+)", why)
    if m:
        return "needs engine: " + m.group(1)
    if "no rule for" in why:
        return "read filter not in the vocabulary"
    return re.sub(r"^[\w.]+: ", "", why)[:80]


def qa_ref(rep, item):
    h = hashlib.sha1(json.dumps({k: item.get(k) for k in ("expr", "agg", "filter", "denominator", "round", "type",
                                                          "metric_id", "period", "rollup_formula")},
                                sort_keys=True, default=str).encode()).hexdigest()[:12]
    return {"from": item.get("from") or f"{item.get('pivot')}.{item.get('viewdefn')}.{item.get('data_index')}",
            "config_dir": rep["config_dir"], "ran_at": rep["ran_at"], "hash": h}


def apply(store, rep, user, pick=None):
    """add what the catalog lacks, as drafts with origin qa_import (FK order: measures, metrics,
    screens, bindings). 'new' bindings are added; 'unbound' ones (catalog row, no metric) get
    the metric filled in. Nothing else is touched. pick: optional {(pivot, viewdefn, data_index)}."""
    def chosen(b):
        return pick is None or (b["pivot"], b["viewdefn"], b["data_index"]) in pick
    new_b = [b for b in rep["bindings"] if b["status"] == "new" and chosen(b)]
    fill_b = [b for b in rep["bindings"] if b["status"] == "unbound" and chosen(b)]
    mets = {m["id"]: m for m in rep["metrics"] if m["status"] == "new"}
    meas = {m["id"]: m for m in rep["measures"] if m["status"] == "new"}
    need_m, need_k = [], set()
    def visit(n):
        if n in mets and n not in need_m:
            for i, _ in SP.refs(mets[n]["expr"]) + SP.refs(mets[n].get("denominator", "")):
                if i != n:
                    visit(i)
            if n in meas:
                need_k.add(n)
            need_m.append(n)                      # dependencies first
        elif n in meas:
            need_k.add(n)
    for b in new_b + fill_b:
        visit(b["metric_id"])
        for i, _ in SP.refs(b.get("rollup_formula", "")):
            visit(i)
    today = datetime.date.today().isoformat()
    def note(x):
        return f"imported from QA config {today}" + "".join(f"; {n}" for n in x.get("notes", []))
    added = {"measures": [], "metrics": [], "screens": [], "bindings": [], "filled": []}
    for mid in sorted(need_k):
        m = meas[mid]
        store.upsert("measures", {"measure_id": mid, "label": m.get("label") or mid, "source_id": m["source_id"],
                                  "expr": m["expr"], "agg": m["agg"], "filter": m["filter"],
                                  "time_window": m["time_window"], "location_set": m["location_set"],
                                  "rollup": m["rollup"], "origin": "qa_import",
                                  "qa_ref": json.dumps(qa_ref(rep, m)), "notes": note(m)}, user)
        added["measures"].append(mid)
    for mid in need_m:
        m = mets[mid]
        store.upsert("metrics", {"metric_id": mid, "label": m.get("label") or mid, "type": m["type"],
                                 "expr": m["expr"], "denominator": m["denominator"], "round": m["round"],
                                 "origin": "qa_import", "qa_ref": json.dumps(qa_ref(rep, m)), "notes": note(m)}, user)
        added["metrics"].append(mid)
    added["populations"] = []
    for s in rep["screens"]:                              # population variants first (screens refer to them)
        if s["status"] == "new" and s.get("population") and any(b["pivot"] == s["pivot"] for b in new_b) \
                and s["population_id"] not in added["populations"]:
            for r in s["population"]:
                store.upsert("populations", {**r, "origin": "qa_import", "notes": note(s)}, user)
            added["populations"].append(s["population_id"])
    for s in rep["screens"]:
        if s["status"] == "new" and any(b["pivot"] == s["pivot"] for b in new_b):
            store.upsert("screens", {"pivot": s["pivot"], "population_id": s["population_id"],
                                     "time_mode": s["time_mode"], "split_by_class": s["split_by_class"],
                                     **({"item_grain": s["item_grain"]} if s.get("item_grain", "stylecolor") != "stylecolor" else {}),
                                     "origin": "qa_import", "notes": note(s)}, user)
            added["screens"].append(s["pivot"])
    for b in new_b:
        store.upsert("bindings", {"pivot": b["pivot"], "viewdefn": b["viewdefn"], "data_index": b["data_index"],
                                  "label": b["label"], "metric_id": b["metric_id"], "period": b["period"],
                                  "rollup_formula": b["rollup_formula"], "origin": "qa_import",
                                  "qa_ref": json.dumps(qa_ref(rep, b)), "notes": note(b)}, user)
        added["bindings"].append(f"{b['pivot']}.{b['viewdefn']}.{b['data_index']}")
    for b in fill_b:
        row = {"pivot": b["pivot"], "viewdefn": b["viewdefn"], "data_index": b["data_index"],
               "metric_id": b["metric_id"], "period": b["period"], "qa_ref": json.dumps(qa_ref(rep, b)),
               "notes": note(b)}
        if b["rollup_formula"] and (b.get("fill_rollup") or not (b.get("catalog") or {}).get("rollup_formula")):
            row["rollup_formula"] = b["rollup_formula"]
        store.upsert("bindings", row, user)
        added["filled"].append(f"{b['pivot']}.{b['viewdefn']}.{b['data_index']}")
    return added


def save(rep, client):
    d = HUB / "customers" / client.upper() / "metrics" / "qa_import"
    d.mkdir(exist_ok=True)
    p = d / f"{datetime.datetime.now():%Y%m%d-%H%M%S}-{'+'.join(x['pivot'] for x in rep['pivots'])[:80]}.json"
    p.write_text(json.dumps(rep, indent=1, default=str))
    mets = {m["id"]: m for m in rep["metrics"]}
    with open(p.with_suffix(".csv"), "w", newline="") as f:     # the review sheet: one row per screen column
        w = csv.writer(f)
        w.writerow(["pivot", "viewdefn", "data_index", "label", "status", "metric_id", "period", "metric_status",
                    "metric_type", "metric_formula", "rollup_formula", "catalog", "why / notes"])
        for b in rep["bindings"]:
            m = mets.get(b.get("metric_id") or "", {})
            f_ = metric_sql(m) if m.get("type") else ""
            w.writerow([b["pivot"], b["viewdefn"], b["data_index"], b["label"], b["status"], b.get("metric_id", ""),
                        b.get("period", ""), m.get("status", ""), m.get("type", ""), f_, b.get("rollup_formula", ""),
                        json.dumps(b.get("catalog")) if b.get("catalog") else "",
                        "; ".join(filter(None, [b.get("why", "")] + b.get("notes", []) + m.get("notes", [])))])
    return p


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--client", default="TRD")
    ap.add_argument("--env", default="qa")
    ap.add_argument("--pivot", action="append", required=True)
    ap.add_argument("--config-dir")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--user", default="qa_import")
    a = ap.parse_args()
    spec_dir = HUB / "customers" / a.client.upper() / "spec"
    spec = SP.load(spec_dir)
    rep = translate(a.client, a.pivot, spec, a.env, a.config_dir)
    p = save(rep, a.client)
    print(json.dumps(rep["counts"], indent=1))
    if rep["metric_map_stale"]:
        print("WARNING: metric_map is older than the QA config - run Pull metrics from QA first")
    print("report:", p)
    if a.apply:
        from core import catalog_db, spec_store
        if catalog_db.use_db():
            with catalog_db.connect() as c:
                have = {r["version"] for r in c.execute("SELECT version FROM schema_migrations").fetchall()}
            missing = [v for v in ("002_binding_period", "003_qa_import") if v not in have]
            if missing:
                sys.exit(f"run migrations {missing} first (migrations/dvs, as psql)")
        store = catalog_db.CatalogDB(a.client.lower(), a.env) if catalog_db.use_db() else spec_store.SpecStore(spec_dir)
        print(json.dumps(apply(store, rep, a.user), indent=1))


if __name__ == "__main__":
    main()
