#!/usr/bin/env python3
"""
Scrape every metric a customer's screens show and trace it down to ClickHouse
base columns -> one CSV (the metric map), one row per (screen, view, column).

    confdefn  : top nav > left nav > screen view  -> model / dataApi defnId
    viewdefn  : display name, dataIndex, client formula (mathjs)
    pivotdefn : dataIndex -> SQL expression, followed through params, <#include>
                FTLs and session temp tables down to a real CH table.column
    CH (QA)   : DESCRIBE TABLE confirms each base column exists

The map is the INDEPENDENT spec the composer builds from — review it, don't
trust it blindly: rows are pivot-derived until a human marks them approved.

Usage:
  python3 metric_map.py --config-dir ../../../trd-configs --client TRD
  python3 metric_map.py ... --refresh-schema      # re-DESCRIBE base tables on QA
  python3 metric_map.py ... --pivot HistoryFit --explain net_sls_r   # debug one
"""
import argparse, csv, json, re, sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
HUB = HERE.parent.parent

# ---------------------------------------------------------------- text prep
_TRIPLE = re.compile(r'"""(.*?)"""', re.S)
_PARAM = re.compile(r'^params\.([A-Za-z0-9_]+)\s*=\s*"""(.*?)"""', re.S | re.M)
_FIELD = re.compile(r'^([A-Za-z]+)\s*=\s*(\[|""")', re.M)
_INCLUDE = re.compile(r'<#include\s+"([^"]+)"\s*/?>')
_VAR = re.compile(r"\$\{([A-Za-z0-9_]+)\}")


def _strip_comments(sql):
    out, i, n, q = [], 0, len(sql), None
    while i < n:
        c = sql[i]
        if q:
            out.append(c)
            if c == q:
                q = None
            i += 1
        elif c in "'":
            q = c; out.append(c); i += 1
        elif sql.startswith("--", i):
            j = sql.find("\n", i)
            i = n if j < 0 else j
        elif sql.startswith("/*", i):
            j = sql.find("*/", i + 2)
            i = n if j < 0 else j + 2
        else:
            out.append(c); i += 1
    return "".join(out)


def _strip_ftl(sql):
    # keep the SQL inside <#if>/<#list> (both branches) — drop only the tags
    sql = re.sub(r"<#(?:global|assign|local)[^>]*>", " ", sql, flags=re.S)
    sql = re.sub(r"</?[#@][^>]*>", " ", sql)
    return sql


def _expand_includes(sql, cfg, depth=0):
    if depth > 6:
        return sql
    def repl(m):
        name = m.group(1)
        for d in (cfg / "pivot" / "include", cfg / "pivot", cfg / "library"):
            f = d / name
            if f.exists():
                return "\n" + _expand_includes(f.read_text(errors="replace"), cfg, depth + 1) + "\n"
        return f"\n/* missing include {name} */\n"
    return _INCLUDE.sub(repl, sql)


class Pivot:
    """Parsed pivotdefn: params, SQL chunks by field, expanded statements."""

    def __init__(self, path, cfg, tenant):
        self.path, self.name, self.cfg, self.tenant = path, path.stem, cfg, tenant
        t = path.read_text(errors="replace")
        self.params = {k: v for k, v in _PARAM.findall(t)}
        self.fields = self._fields(t)
        self.missing_vars = set()

    def _fields(self, t):
        """{field: [sql,...]} for prologueSQL(s)/aggregationSQLs/reverseAggSQLs/..."""
        out = {}
        marks = [(m.start(), m.group(1)) for m in _FIELD.finditer(t)] + [(len(t), None)]
        for (s, name), (e, _) in zip(marks, marks[1:]):
            if name and name != "params":
                out[name] = _TRIPLE.findall(t[s:e])
        return out

    def expand(self, sql):
        sql = _expand_includes(sql, self.cfg)
        sql = _strip_comments(sql)
        blk = {}                                # <#assign X>body</#assign>: a variable, not SQL
        sql = re.sub(r"<#assign\s+(\w+)\s*>(.*?)</#assign>",
                     lambda m: blk.__setitem__(m.group(1), m.group(2)) or " ", sql, flags=re.S)
        pv = {**self.params, **blk}
        for _ in range(6):                      # params may reference params
            new = _VAR.sub(lambda m: (_strip_comments(pv[m.group(1)])
                                      if m.group(1) in pv else m.group(0)), sql)
            if new == sql:
                break
            sql = new
        sql = _strip_ftl(sql)
        sql = sql.replace("${TENANT_ID}", self.tenant).replace("${SESSION_ID}", "SESSION")
        def other(m):
            self.missing_vars.add(m.group(1))
            if m.group(1) == "MAYBE_GROUP_BY":
                return " GROUP BY "
            if m.group(1).endswith("_COMMA"):
                return f"__{m.group(1)}__,"             # 'keys,' then the select list
            return "" if m.group(1).startswith("AGGREGATION_GROUPS") else f"__{m.group(1)}__"
        sql = _VAR.sub(other, sql)
        sql = re.sub(r"(__\w+_COMMA__,)\s*,", r"\1 ", sql)
        sql = re.sub(r"\$\{[^}]*\}", "__EXPR__", sql)   # ${a.b?c} style leftovers
        return sql

    def sql_sets(self):
        """(prologue_sql, output_sql) expanded. Output = the SQL whose final
        select IS the pivot result (reverseAgg > aggregation > last prologue)."""
        pro = []
        for f in ("prologueSQL", "prologueSQLs"):
            pro += self.fields.get(f, [])
        outs, field = [], None
        for f in ("reverseAggSQLs", "aggregationSQLs", "epilogueSQL", "query", "sql"):
            chunks = [c for c in self.fields.get(f, []) if c.strip()]
            if chunks and re.search(r"\bselect\b", chunks[0], re.I):
                outs, field = chunks, f
                break
        if not outs and pro:
            outs, field, pro = [pro[-1]], "prologueSQLs", pro[:-1]
        self.out_field = field
        return [self.expand(s) for s in pro if s.strip()], [self.expand(o) for o in outs]


# ---------------------------------------------------------------- SQL blocks
_KW = set("""select from where and or not as in is null case when then else end
distinct if on using join left right inner outer any all global array group by
order having limit union with interval true false like ilike between asc desc
settings final prewhere sample format engine memory create table exists insert
into values over partition rows range preceding following current row nulls
first last cross""".split())
_TYPES = re.compile(r"^(u?int\d+|float\d+|string|date(time)?\d*|decimal\d*|nullable|"
                    r"lowcardinality|array|tuple|uuid|bool)$", re.I)
_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?")
_CONST = re.compile(r"^\s*(?:CAST\(\s*)?(?:0|0\.0+|NULL|'')\s*(?:as\s+\w+\s*\))?\s*$", re.I)


def _depth_map(s):
    d, out, q = 0, [], None
    for c in s:
        if q:
            out.append(d)
            if c == q:
                q = None
            continue
        if c == "'":
            q = c
        if c == "(":
            out.append(d); d += 1; continue
        if c == ")":
            d -= 1
        out.append(d)
    return out


def _split_top(s, sep=","):
    parts, d, q, cur = [], 0, None, []
    for c in s:
        if q:
            cur.append(c)
            if c == q:
                q = None
            continue
        if c == "'":
            q = c
        elif c == "(":
            d += 1
        elif c == ")":
            d -= 1
        if c == sep and d == 0:
            parts.append("".join(cur)); cur = []
        else:
            cur.append(c)
    parts.append("".join(cur))
    return [p.strip() for p in parts if p.strip()]


def _top_kw(s, kw, start=0):
    """First position of keyword kw at paren depth 0 of s (relative), or -1."""
    dm = _depth_map(s)
    for m in re.finditer(rf"\b{kw}\b", s[start:], re.I):
        p = start + m.start()
        if dm[p] == 0:
            return p
    return -1


def _item(it):
    """select item -> (alias, expr, is_star)."""
    if it == "*" or re.fullmatch(r"\w+\.\*", it):
        return None, None, True
    dm = _depth_map(it)
    last = None
    for m in re.finditer(r"\s+as\s+([A-Za-z_]\w*)\s*$|\s+as\s+([A-Za-z_]\w*)\b", it, re.I):
        if dm[m.start()] == 0:
            last = m
    if last and it[last.end():].strip() == "":
        return (last.group(1) or last.group(2)), it[:last.start()].strip(), False
    m = re.fullmatch(r"(?:\w+\.)?([A-Za-z_]\w*)", it)
    if m:
        return m.group(1), it, False
    return None, it, False


class Block:
    __slots__ = ("id", "items", "star", "sources", "where", "having", "creates", "text", "arrayjoin",
                 "stmt_creates", "from_sql", "group_sql")


def parse_blocks(sql):
    """Every SELECT in sql -> Block with select items and FROM sources.
    Returns (blocks, temp_creators{table: [block ids]})."""
    blocks, creators = [], {}
    for stmt in _split_top(sql, ";"):
        creates = None
        m = re.match(r"\s*(?:create\s+(?:temporary\s+)?table\s+(?:if\s+not\s+exists\s+)?|"
                     r"insert\s+into\s+)([\w.]+)", stmt, re.I)
        if m:
            creates = m.group(1)
        dm = _depth_map(stmt)
        sel = [mm.start() for mm in re.finditer(r"\bselect\b", stmt, re.I)]
        local = {}
        for p in sel:
            base = dm[p]
            # block scope ends where depth drops below base, or next base-level UNION
            end = len(stmt)
            for i in range(p, len(stmt)):
                if dm[i] < base:
                    end = i; break
            for u in re.finditer(r"\bunion\s+(all|distinct)\b", stmt[p + 6:end], re.I):
                if dm[p + 6 + u.start()] == base:
                    end = p + 6 + u.start()
                    break
            body = stmt[p + 6:end]
            f = _top_kw(body, "from")
            b = Block()
            b.id, b.text, b.creates = len(blocks), body, None
            b.items, b.star, b.sources, b.where, b.having = {}, False, [], "", ""
            b.arrayjoin = {}
            b.stmt_creates, b.from_sql, b.group_sql = creates, "", ""
            sel_list = body if f < 0 else body[:f]
            for it in _split_top(sel_list):
                a, e, st = _item(it)
                if st:
                    b.star = True
                elif a:
                    b.items.setdefault(a, []).append(e)
            if f >= 0:
                rest = body[f + 4:]
                fe = len(rest)
                for kw in ("group", "order", "limit", "settings", "having"):
                    k = _top_kw(rest, kw)
                    if 0 <= k < fe:
                        fe = k
                b.from_sql = " ".join(rest[:fe].split())
                gb = _top_kw(rest, "group")
                if gb >= 0:
                    ge = len(rest)
                    for kw in ("having", "order", "limit", "settings", "with"):
                        k = _top_kw(rest, kw, gb + 5)
                        if 0 <= k < ge:
                            ge = k
                    b.group_sql = " ".join(re.sub(r"^group\s+by", "", rest[gb:ge].strip(), flags=re.I).split())
                cut = len(rest)
                for kw in ("where", "prewhere", "group", "having", "order", "limit", "settings"):
                    k = _top_kw(rest, kw)
                    if 0 <= k < cut:
                        cut = k
                frm = rest[:cut]
                w = _top_kw(rest, "where")
                if w >= 0:
                    we = len(rest)
                    for kw in ("group", "having", "order", "limit", "settings"):
                        k = _top_kw(rest, kw, w)
                        if 0 <= k < we:
                            we = k
                    b.where = " ".join(rest[w + 5:we].split())
                h = _top_kw(rest, "having")
                if h >= 0:
                    he = len(rest)
                    for kw in ("order", "limit", "settings"):
                        k = _top_kw(rest, kw, h)
                        if 0 <= k < he:
                            he = k
                    b.having = " ".join(rest[h + 6:he].split())
                # sources: subqueries (by absolute position) + table names
                abs0 = p + 6 + f + 4
                fdm = _depth_map(frm)
                i = 0
                while i < len(frm):
                    if frm[i] == "(" and fdm[i] == 0:
                        j = i + 1
                        while j < len(frm) and not (frm[j] == ")" and fdm[j] == 0):
                            j += 1
                        b.sources.append(("sub", abs0 + i, abs0 + j))
                        i = j + 1
                        continue
                    i += 1
                aj = re.search(r"\barray\s+join\b(.*)", frm, re.I | re.S)
                if aj:
                    for it in _split_top(aj.group(1)):
                        a_, e_, _ = _item(it.strip())
                        if a_ and e_:
                            b.arrayjoin[a_] = e_.split()[-1] if e_ else e_
                    frm = frm[:aj.start()]
                flat = frm
                while re.search(r"\([^()]*\)", flat):
                    flat = re.sub(r"\([^()]*\)", " __SUB__ ", flat)
                for t in re.findall(r"(?:^|\bjoin\b|,)\s*([A-Za-z_][\w.]*)", flat, re.I):
                    if t.lower() not in _KW and t != "__SUB__":
                        b.sources.append(("table", t.split(".")[-1]))
            blocks.append(b)
            local[p] = (b, base)
        # resolve subquery sources to the blocks inside them (direct children)
        for p, (b, base) in local.items():
            subs = []
            for s in b.sources:
                if s[0] == "sub":
                    inside = [(bd, bb.id) for pp, (bb, bd) in local.items() if s[1] < pp < s[2]]
                    top = min((bd for bd, _ in inside), default=None)
                    kids = [i for bd, i in inside if bd == top]
                    subs.append(("blocks", kids))
                else:
                    subs.append(s)
            b.sources = subs
        if creates:
            top = [b.id for p, (b, bd) in local.items() if bd == 0]
            creators.setdefault(creates, []).extend(top)
            for bid in top:
                blocks[bid].creates = creates
    return blocks, creators


# ---------------------------------------------------------------- resolution
class Resolver:
    def __init__(self, blocks, creators, schema):
        self.b, self.creators, self.schema = blocks, creators, schema
        self.memo = {}
        self.prefix = ""

    def _is_real(self, t):
        return t in self.schema or t.startswith(self.prefix)

    def _idents(self, expr):
        subqs = []
        masked = re.sub(r"'[^']*'", lambda m: (subqs.append(m.group(0)) or
                                               f"__subq{len(subqs) - 1}__"), expr)
        # don't resolve inside scalar subqueries — keep them as-is
        while re.search(r"\(\s*select\b", masked, re.I):
            m = re.search(r"\(\s*select\b", masked, re.I)
            d, j = 0, m.start()
            for j in range(m.start(), len(masked)):
                if masked[j] == "(":
                    d += 1
                elif masked[j] == ")":
                    d -= 1
                    if d == 0:
                        break
            subqs.append(" ".join(masked[m.start():j + 1].split()))
            masked = masked[:m.start()] + f"__subq{len(subqs) - 1}__" + masked[j + 1:]
        out = []
        for m in _IDENT.finditer(masked):
            w = m.group(0)
            nxt = masked[m.end():].lstrip()[:1]
            if nxt == "(" or w.lower() in _KW or _TYPES.match(w) or w.startswith("__"):
                continue
            if re.match(r"\d", w):
                continue
            out.append(w)
        return masked, out, subqs

    def col(self, bid, name, skip_alias=False, depth=0):
        """-> node dict {kind: leaf|expr|union|const|unresolved, ...}"""
        key = (bid, name, skip_alias)
        if key in self.memo:
            return self.memo[key]
        if depth > 40:
            return {"kind": "unresolved", "name": name, "why": "depth"}
        self.memo[key] = {"kind": "unresolved", "name": name, "why": "cycle"}
        b = self.b[bid]
        node = None
        if not skip_alias and name in b.items:
            variants = [e for e in b.items[name] if not _CONST.match(e)]
            if not variants:
                node = {"kind": "const", "name": name}
            else:
                e = variants[0]
                masked, ids, subqs = self._idents(e)
                if re.fullmatch(r"(?:\w+\.)?" + re.escape(name), e.strip()):
                    node = self.src(bid, name, depth + 1)       # bare passthrough
                else:
                    kids = {}
                    for ident in dict.fromkeys(ids):
                        bare = ident.split(".")[-1]
                        if bare == name or "." in ident or bare not in b.items:
                            kids[ident] = self.src(bid, bare, depth + 1)
                        else:
                            kids[ident] = self.col(bid, bare, False, depth + 1)
                    node = {"kind": "expr", "name": name, "bid": bid, "expr": " ".join(e.split()),
                            "masked": " ".join(masked.split()), "kids": kids, "subqs": subqs,
                            "where": b.where, "having": b.having}
        else:
            node = self.src(bid, name, depth + 1)
        self.memo[key] = node
        return node

    def src(self, bid, name, depth):
        """name as a column of block bid's FROM sources."""
        b = self.b[bid]
        if name in b.arrayjoin and b.arrayjoin[name] != name:
            n = self.src(bid, b.arrayjoin[name].split(".")[-1], depth + 1)
            if n["kind"] == "leaf":
                n = dict(n, note=f"ARRAY JOIN {b.arrayjoin[name]} as {name}")
            return n
        found = []
        for s in b.sources:
            if s[0] == "table":
                t = s[1]
                if t in self.creators:
                    vs = [self.col(k, name, False, depth) for k in self.creators[t]]
                    found.append(self._union(name, vs))
                elif t in self.schema:
                    if name in self.schema[t]:
                        found.append({"kind": "leaf", "name": name, "table": t,
                                      "verified": True, "where": b.where})
                    else:
                        found.append({"kind": "unresolved", "name": name,
                                      "why": f"not a column of {t}"})
                elif "SESSION" in t or not self._is_real(t):
                    found.append({"kind": "unresolved", "name": name,
                                  "why": f"temp table {t} not created in this pivot"})
                else:
                    found.append({"kind": "leaf", "name": name, "table": t,
                                  "verified": False, "where": b.where})
            elif s[0] == "blocks":
                vs = [self.col(k, name, False, depth) for k in s[1]]
                if vs:
                    found.append(self._union(name, vs))
        # FROM order wins (main table before joins); a real table without a
        # cached schema is assumed to carry the column (flagged unverified)
        for f in found:
            if f["kind"] != "unresolved":
                return f
        return found[0] if found else {"kind": "unresolved", "name": name, "why": "no source"}

    def _union(self, name, vs):
        live = [v for v in vs if v["kind"] not in ("const", "unresolved")]
        if not live:
            if any(v["kind"] == "const" for v in vs):
                return {"kind": "const", "name": name}
            return vs[0] if vs else {"kind": "unresolved", "name": name, "why": "empty"}
        if len(live) == 1:
            return live[0]
        return {"kind": "union", "name": name, "parts": live}


# ---------------------------------------------------------------- rendering
_AGG_COLLAPSE = re.compile(r"\b(sum|max|min)\(\s*\1\(([^()]*(?:\([^()]*\))*[^()]*)\)\s*\)", re.I)


def collapse_sums(e):
    """sum(sum(x)) / sum(sumIf(x,c)) -> inner: re-summing an additive sum is a
    no-op. sum(count distinct) is NOT collapsed (it's a real semantic step)."""
    changed = True
    while changed:
        changed = False
        for m in re.finditer(r"\bsum\(", e, re.I):
            dm = _depth_map(e)
            o = m.end() - 1
            c = next((i for i in range(o + 1, len(e)) if e[i] == ")" and dm[i] == dm[o]), None)
            if c is None:
                continue
            inner = e[o + 1:c].strip()
            while inner.startswith("(") and inner.endswith(")") and _atom(inner) \
                    and not re.match(r"[A-Za-z_]", inner):
                inner = inner[1:-1].strip()
            if re.match(r"(sum|sumIf)\(", inner, re.I) and _atom(inner):
                e = e[:m.start()] + inner + e[c + 1:]
                changed = True
                break
    return e


def _atom(v):
    """identifier, number, or a single fn(...) call spanning the whole string."""
    v = v.strip()
    if re.fullmatch(r"[\w.]+", v):
        return True
    m = re.match(r"[A-Za-z_]\w*\(", v)
    if not m or not v.endswith(")"):
        return v.startswith("(") and v.endswith(")") and _depth_map(v)[-1] == 0 and \
            all(d > 0 for d in _depth_map(v)[1:-1])
    dm = _depth_map(v)
    return all(d > 0 for d in dm[m.end():-1])


def _wrap(v):
    return v if _atom(v) else f"({v})"


def render(node, depth=0):
    """-> (base_formula, leaves{table.col}, chain[lines], unresolved[], filters[])."""
    k = node["kind"]
    if k == "leaf":
        tag = f"{node['table']}.{node['name']}"
        return node["name"], {tag: node["verified"]}, [], [], \
            [f"{node['table']}: {node['where']}"] if node.get("where") else []
    if k == "const":
        return "0", {}, [f"{node['name']} = 0 (constant in this pivot)"], [], []
    if k == "unresolved":
        return node["name"], {}, [], [f"{node['name']} ({node.get('why')})"], []
    if k == "union":
        parts = [render(p, depth + 1) for p in node["parts"]]
        leaves, chain, unres, filt = {}, [], [], []
        for f, l, c, u, w in parts:
            leaves.update(l); chain += c; unres += u; filt += w
        uniq = list(dict.fromkeys(p[0] for p in parts))
        formula = uniq[0] if len(uniq) == 1 else " + ".join(f"({u})" for u in uniq)
        return formula, leaves, chain, unres, filt
    # expr
    leaves, chain, unres, filt = {}, [], [], []
    expr = node["masked"]
    subs = {}
    for ident, kid in node["kids"].items():
        f, l, c, u, w = render(kid, depth + 1)
        leaves.update(l); chain += c; unres += u; filt += w
        subs[ident] = f
    chain.insert(0, f"{node['name']} = {node['expr']}")
    def rep(m):
        w = m.group(0)
        if w in subs:
            return _wrap(subs[w])
        return w
    out = _IDENT.sub(rep, expr)
    for i, q in enumerate(node.get("subqs", [])):
        out = out.replace(f"__subq{i}__", q)
    out = collapse_sums(out)
    if node.get("having"):
        filt.append(f"HAVING {node['having']}")
    return out, leaves, chain, unres, filt


# ---------------------------------------------------------------- screens
PARETO = ("ParetoSummary", "ParetoDetails")   # assortmentui ParetoAnalysis.epic.ts: defns.view[0] as its own defn


def scan_screens(cfg, conf_glob):
    rows = []
    for conf in sorted((cfg / "uidefn" / "conf").glob(conf_glob)):
        if re.search(r"_LG\d*\.confdefn$", conf.name):
            continue                                    # layout variants duplicate screens
        try:
            d = json.loads(conf.read_text())
        except Exception:
            continue
        for tab in d.get("tabs", []):
            def walk(o, names, persp, comp=None):
                if isinstance(o, dict):
                    ip = o.get("inPerspectives")
                    p2 = [p for p in persp if not ip or p in ip]
                    nm = names + ([o["name"]] if o.get("name") and o is not tab else [])
                    cp = o.get("componentProps") or {}
                    dn = cp.get("defns") or o.get("defns")
                    if isinstance(dn, dict) and dn.get("view"):
                        views = dn["view"] if isinstance(dn["view"], list) else [dn["view"]]
                        api = (cp.get("dataApi") or o.get("dataApi") or {}).get("defnId")
                        vs = [v for v in views if isinstance(v, str)]
                        base = {"app": conf.stem, "top_nav": tab.get("name") or tab.get("id"),
                                "top_nav_id": tab.get("id"), "screen_id": o.get("id"),
                                "path": nm, "modules": p2, "model": dn.get("model"), "defn_id": api}
                        if (o.get("component") or comp) in PARETO and vs:   # summary = view[0] fetched on its own model
                            rows.append({**base, "model": vs[0], "defn_id": None, "views": vs[:1]})
                            vs = vs[1:]
                        rows.append({**base, "views": vs})
                    for k, v in o.items():
                        if k != "defns":
                            walk(v, nm, p2, o.get("component") if k == "componentProps" else None)
                elif isinstance(o, list):
                    for v in o:
                        walk(v, names, persp)
            walk(tab, [], [p for p in (tab.get("inPerspectives") or d.get("perspectives") or [])])
    for s in list(rows):                                # worklist tabs live in the viewdefn (SKU View)
        for v in s["views"]:
            try:
                vd = json.loads((cfg / "uidefn" / "view" / f"{v}.viewdefn").read_text())
            except Exception:
                continue
            for t in vd.get("tabs") or [] if isinstance(vd, dict) else []:
                dn = (t.get("componentProps") or {}).get("defns") or {}
                vs = dn.get("view") if isinstance(dn.get("view"), list) else [dn.get("view")]
                if dn.get("model") and any(isinstance(x, str) for x in vs):
                    rows.append(dict(s, path=s["path"] + [t.get("name") or t.get("pathSlot") or v],
                                     model=dn["model"], defn_id=None, views=[x for x in vs if isinstance(x, str)]))
    return rows


def view_model(cfg, view):
    try:
        m = json.loads((cfg / "uidefn" / "view" / f"{view}.viewdefn").read_text()).get("model")
        return m if isinstance(m, str) and m else None
    except Exception:
        return None


def view_columns(cfg, view):
    f = cfg / "uidefn" / "view" / f"{view}.viewdefn"
    if not f.exists():
        return []
    try:
        d = json.loads(f.read_text())
    except Exception:
        return []
    out = []
    def walk(o, path):
        if isinstance(o, dict):
            di = o.get("dataIndex")
            if isinstance(di, str) and di and ":" not in di and di not in ("&", "_") \
                    and (o.get("text") or o.get("formula")):
                out.append({"section": ".".join(path) or "view", "dataIndex": di,
                            "text": o.get("text") or "", "formula": o.get("formula") or "",
                            "renderer": o.get("renderer") or "",
                            "visible": "N" if (o.get("visible") is False or o.get("hidden") is True) else "Y"})
            for k, v in o.items():
                if isinstance(v, (dict, list)) and k not in ("dataApi", "editor", "inputParams"):
                    walk(v, path + [k])
        elif isinstance(o, list):
            for v in o:
                walk(v, path)
    walk(d, [])
    return out


def model_pivot(cfg, model, defn_id):
    for cand in (defn_id, model):
        if not cand:
            continue
        p = cfg / "pivot" / f"{cand}.pivotdefn"
        m = cfg / "uidefn" / "model" / f"{cand}.modeldefn"
        if m.exists():
            try:
                pv = json.loads(m.read_text()).get("pivotDefn")
                if pv and (cfg / "pivot" / f"{pv}.pivotdefn").exists():
                    return pv
            except Exception:
                pass
        if p.exists():
            return cand
    return None


# ---------------------------------------------------------------- CH schema
def load_schema(path):
    try:
        return json.loads(Path(path).read_text())
    except Exception:
        return {}


def fetch_schema(tables, client, env, cache):
    sys.path.insert(0, str(HUB / "tooling" / "db"))
    import mcp_server
    def one(t):
        r = mcp_server.tool_query({"client": client, "env": env, "engine": "clickhouse",
                                   "sql": f"DESCRIBE TABLE {t}", "max_rows": 2000})
        if r.startswith("error") or r.startswith("no connection"):
            return t, None
        lines = r.splitlines()[1:]
        return t, [l.split("\t")[0] for l in lines if l.strip()]
    todo = sorted(t for t in tables if t not in cache)
    with ThreadPoolExecutor(6) as ex:
        for t, cols in ex.map(one, todo):
            cache[t] = cols or []                       # [] = not on CH (or no access)
            print(f"  schema {t}: {len(cols) if cols else 'MISSING'}", file=sys.stderr)
    return cache


# ---------------------------------------------------------------- main build
_VIEW_AGG = re.compile(r"\b(sum|mean|avg|count|size|min|max|first|last)\s*\(", re.I)


def pivot_resolver(cfg, name, tenant, schema, cache):
    if name in cache:
        return cache[name]
    pv = Pivot(cfg / "pivot" / f"{name}.pivotdefn", cfg, tenant)
    pro, outs = pv.sql_sets()
    blocks, creators = parse_blocks("\n;\n".join(pro + outs))
    # one output per aggregation level: first (outermost) block of each out SQL
    out_id, n = [], len(blocks)
    for o in reversed(outs):
        k = len(parse_blocks(o)[0])
        n -= k
        if k:
            out_id.insert(0, n)
    out_id = [(i, f"{pv.out_field}[{j}]") for j, i in enumerate(out_id)] or None
    r = Resolver(blocks, creators, schema)
    r.prefix = tenant + "_"
    cache[name] = (r, out_id, pv, blocks, creators)
    return cache[name]


def real_tables(blocks, creators, prefix):
    ts = set()
    for b in blocks:
        for s in b.sources:
            if s[0] == "table" and s[1] not in creators and "SESSION" not in s[1] \
                    and s[1].startswith(prefix):
                ts.add(s[1])
    return ts


def best_render(res, outs, col):
    """try every aggregation-level output; best = fully resolved, else most leaves."""
    best = None
    for oid, lvl in outs:
        node = res.col(oid, col)
        rr = render(node)
        score = (bool(rr[1]) and not rr[3], len(rr[1]), -len(rr[3]))
        if best is None or score > best[0]:
            best = (score, (lvl, node), rr)
        if score[0]:
            break
    return best[1], best[2]


def build(cfg, client, env, out_csv, schema_path, refresh, conf_glob):
    tenant = client.lower()
    screens = scan_screens(cfg, conf_glob)
    schema = load_schema(schema_path)
    pcache = {}
    # pass 1: collect real tables from every pivot the screens use
    def binding(s, v):
        vm = view_model(cfg, v)
        if vm and model_pivot(cfg, vm, None):
            return vm, model_pivot(cfg, vm, None)
        return s["model"], model_pivot(cfg, s["model"], s["defn_id"])
    def bindings(s, v):
        """the view's own model, plus the screen's model when it reads another pivot (a viewdefn shared by
        screens with different models: Size Views run HistoryAggregateViewsNestedAttributeGrid* on the SKU pivot)"""
        out = [binding(s, v)]
        sm = (s["model"], model_pivot(cfg, s["model"], s["defn_id"]))
        if sm[1] and sm[1] != out[0][1]:
            out.append(sm)
        return out
    pivots = sorted({b[1] for s in screens for v in s["views"] for b in bindings(s, v)} - {None})
    tables = set()
    for p in pivots:
        _, _, _, blocks, creators = pivot_resolver(cfg, p, tenant, schema, {})
        tables |= real_tables(blocks, creators, tenant + "_")
    if refresh or any(t not in schema for t in tables):
        print(f"describing {len([t for t in tables if t not in schema])} CH tables on {client} {env}…",
              file=sys.stderr)
        schema = fetch_schema(tables, client, env, schema)
        Path(schema_path).write_text(json.dumps(dict(sorted(schema.items())), indent=0))
    schema_sets = {t: set(c) for t, c in schema.items() if c}

    rows, seen = [], set()
    for s in screens:
        for v in s["views"]:
          for model, pv in bindings(s, v):
            res = out_id = None
            if pv:
                res, out_id, _, _, _ = pivot_resolver(cfg, pv, tenant, schema_sets, pcache)
            for c in view_columns(cfg, v):
                key = (s["app"], s["top_nav"], tuple(s["path"]), v, c["section"], c["dataIndex"], c["text"], pv)
                if key in seen:
                    continue
                seen.add(key)
                rows.append(row_for(dict(s, model=model), v, c, pv, res, out_id))
    # same display name, different base formula -> flag (label means different things)
    from collections import defaultdict
    forms = defaultdict(lambda: defaultdict(int))
    for r in rows:
        if r.get("base_formula"):
            forms[r["display_name"]][r["base_formula"]] += 1
    for r in rows:
        fs = forms.get(r["display_name"], {})
        if len(fs) > 1 and r.get("base_formula"):
            rank = sorted(fs, key=lambda k: -fs[k]).index(r["base_formula"]) + 1
            r["variants"] = f"{rank} of {len(fs)}" + (" (majority)" if rank == 1 else "")
        elif fs:
            r["variants"] = "1 of 1"
    cols = ["metric_key", "display_name", "data_index", "view_formula", "renderer", "visible",
            "top_nav", "left_nav", "screen_view", "modules", "viewdefn", "view_section", "app",
            "top_nav_id", "screen_id",
            "model", "pivot", "pivot_expr", "base_formula", "base_tables", "base_columns",
            "columns_verified", "filters", "derivation", "variants", "status", "notes"]
    Path(out_csv).parent.mkdir(parents=True, exist_ok=True)
    with open(out_csv, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in cols})
    # layered formulas (reads / measures / columns) for the validation core
    sys.path.insert(0, str(HERE))
    from core import formulas as F
    fr = F.build(cfg, client, schema_sets, rows, Path(out_csv).parent / "formulas.csv")
    print(f"formulas.csv: {sum(1 for r in fr if r['kind'] == 'column')} columns, "
          f"{sum(1 for r in fr if r['kind'] == 'measure')} measures, "
          f"{sum(1 for r in fr if r['kind'] == 'read')} reads, "
          f"{sum(1 for r in fr if r['kind'] == 'error')} pivot errors", file=sys.stderr)
    return rows


def _pivot_cols_in(formula):
    """pivot columns a mathjs view formula reads."""
    ids = []
    for m in _IDENT.finditer(formula):
        w = m.group(0)
        if formula[m.end():].lstrip()[:1] == "(" or w.lower() in _KW:
            continue
        ids.append(w)
    return list(dict.fromkeys(ids))


def row_for(s, v, c, pv, res, out_id):
    path = s["path"]
    r = {"display_name": c["text"], "data_index": c["dataIndex"], "view_formula": c["formula"],
         "renderer": c["renderer"], "visible": c["visible"], "top_nav": s["top_nav"],
         "left_nav": " > ".join(path[:-1]) if len(path) > 1 else (path[0] if path else ""),
         "screen_view": path[-1] if len(path) > 1 else "",
         "modules": "|".join(s["modules"]), "viewdefn": v, "view_section": c["section"],
         "app": s["app"], "model": s["model"] or "", "pivot": pv or "",
         "top_nav_id": s.get("top_nav_id") or "", "screen_id": s.get("screen_id") or "",
         "metric_key": f"{pv or '?'}.{c['dataIndex']}"}
    if not pv:
        r.update(status="no_pivot", notes="screen has no resolvable model/pivot")
        return r
    if out_id is None:
        r.update(status="no_sql", notes="pivot has no parseable output SQL")
        return r
    targets = [c["dataIndex"]]
    f = c["formula"]
    if f and f.strip() != f"sum({c['dataIndex']})":
        targets = _pivot_cols_in(f) or targets
    leaves, chain, unres, filt, direct, bases = {}, [], [], [], [], {}
    levels = set()
    for t in targets:
        (lvl, node), (bf, l, ch, u, w) = best_render(res, out_id, t)
        levels.add(lvl)
        bases[t] = bf
        leaves.update(l); chain += ch; unres += u; filt += w
        if node["kind"] == "expr":
            direct.append(f"{t} = {node['expr']}")
        elif node["kind"] == "const":
            unres.append(f"{t} (constant 0 in pivot)")
    # base formula: view formula with pivot cols substituted, else the pivot col's base
    if f and targets != [c["dataIndex"]]:
        base = _IDENT.sub(lambda m: (_wrap(bases[m.group(0)]) if m.group(0) in bases
                                     else m.group(0)), f)
        r["notes"] = f"client-side view formula over pivot cols {targets}"
    else:
        base = bases.get(c["dataIndex"], "")
    r["pivot_expr"] = " ; ".join(direct)
    if len(out_id) > 1:
        r["notes"] = ((r.get("notes") or "") + f" ; pivot output {'/'.join(sorted(levels))}").strip(" ;")
    r["base_formula"] = base
    tabs = sorted({k.rsplit(".", 1)[0] for k in leaves})
    r["base_tables"] = "|".join(tabs)
    r["base_columns"] = "|".join(sorted(leaves))
    r["columns_verified"] = "Y" if leaves and all(leaves.values()) else ("N" if leaves else "")
    r["filters"] = " || ".join(dict.fromkeys(filt))
    r["derivation"] = " | ".join(dict.fromkeys(chain))
    if unres:
        r["notes"] = ((r.get("notes") or "") + " ; unresolved: " + ", ".join(dict.fromkeys(unres))).strip(" ;")
    if not leaves:
        r["status"] = "unresolved"
    elif unres or not all(leaves.values()):
        r["status"] = "partial"
    else:
        r["status"] = "resolved"
    return r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config-dir", required=True)
    ap.add_argument("--client", default="TRD")
    ap.add_argument("--env", default="qa")
    ap.add_argument("--out", default=None, help="default customers/<CLIENT>/metrics/metric_map.csv")
    ap.add_argument("--conf", default="*.confdefn", help="confdefn glob (layout _LG variants skipped)")
    ap.add_argument("--refresh-schema", action="store_true")
    ap.add_argument("--pivot", help="debug: one pivot")
    ap.add_argument("--explain", help="debug: dataIndex to trace in --pivot")
    a = ap.parse_args()
    cfg = Path(a.config_dir).resolve()
    mdir = HUB / "customers" / a.client / "metrics"
    schema_path = mdir / "ch_schema.json"
    if a.pivot:
        schema = {t: set(c) for t, c in load_schema(schema_path).items() if c}
        res, out_id, pv, blocks, creators = pivot_resolver(cfg, a.pivot, a.client.lower(), schema, {})
        print(f"{len(blocks)} blocks, temps={len(creators)}, output block={out_id}, "
              f"real tables={sorted(real_tables(blocks, creators, a.client.lower() + '_'))}")
        if a.explain:
            f, l, ch, u, w = best_render(res, out_id, a.explain)[1]
            print("base_formula:", f); print("leaves:", l); print("unresolved:", u)
            print("filters:", *dict.fromkeys(w), sep="\n  "); print("chain:", *ch, sep="\n  ")
        return
    out = Path(a.out) if a.out else mdir / "metric_map.csv"
    rows = build(cfg, a.client, a.env, out, schema_path, a.refresh_schema, a.conf)
    from collections import Counter
    st = Counter(r.get("status") for r in rows)
    print(f"{len(rows)} metric rows -> {out}")
    print("status:", dict(st))
    print("distinct display names:", len({r['display_name'] for r in rows}),
          "| pivots:", len({r['pivot'] for r in rows if r.get('pivot')}))


if __name__ == "__main__":
    main()
