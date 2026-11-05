"""
Layered formulas per pivot -> customers/<CLIENT>/metrics/formulas.csv

A pivot column is rebuilt in three layers (the same shape the pivot runs, minus the
temp tables):
  read     one base-table scan: verbatim FROM … WHERE … of the pivot block (session
           table names kept; the family CTEs provide them at compose time)
  measure  an aggregate evaluated inside a read at the requested grain
           (e.g. sum(shp_r), sumIf(eoh_u, time = (select max(ty_week_id) …)))
  column   a pivot output column over measures {m:<id>} and other columns
           (e.g. shp_r = sum({m:…shp_r_x}), net_sls_r = shp_r - ret_r)

formulas_override.csv (same columns) wins over the generated rows: add / edit /
remove (expr = '-') formulas without touching the pivot.
"""
import csv, re
from pathlib import Path

import metric_map as mm

COLS = ["pivot", "kind", "name", "expr", "read", "table", "from_sql", "status", "notes"]
_WRAP = re.compile(r"^\s*(sum|max|min|any|anyLast)\s*\(\s*([A-Za-z_][\w.]*)\s*\)\s*$", re.I)


def _reads_table(blocks, creators, bid, prefix, seen=None, schema=None):
    """True if block bid scans a real table (directly or through a SELECT * subquery)."""
    seen = seen or set()
    if bid in seen:
        return None
    seen.add(bid)
    b = blocks[bid]
    if not b.sources:
        return None
    s = b.sources[0]
    if s[0] == "table":
        t = s[1]
        if t in creators or "SESSION" in t or not t.startswith(prefix):
            return None
        if schema is not None and t not in schema:
            return None
        return t
    if s[0] == "blocks":
        for k in s[1]:
            t = _reads_table(blocks, creators, k, prefix, seen, schema)
            if t:
                return t
    return None


class Layering:
    def __init__(self, pivot, res, blocks, creators, prefix, outputs=()):
        self.pivot, self.res, self.blocks, self.creators, self.prefix = pivot, res, blocks, creators, prefix
        self.reads, self.measures, self.columns, self.problems = {}, {}, {}, []
        self.outputs, self.top = set(outputs), None

    def grand_total(self, bid):
        """block bid = ungrouped aggregate over a temp table, nested in a block reading the same table
        (CROSS JOIN (SELECT sum(x) … FROM FINAL)): a total over all the screen's rows."""
        b = self.blocks[bid]
        if b.group_sql or not b.sources or b.sources[0][0] != "table" or b.sources[0][1] not in self.creators:
            return False
        t = b.sources[0][1]
        return any(o.id != b.id and ("table", t) in o.sources and b.text in o.text for o in self.blocks)

    def _read_id(self, bid, table):
        b = self.blocks[bid]
        name = (b.stmt_creates or "inline").replace(self.prefix, "").replace("_SESSION", "")
        rid = f"{name}#{bid}"
        if rid not in self.reads:
            self.reads[rid] = {"table": table, "from_sql": b.from_sql}
        return rid

    def define(self, node):
        """-> (sql token, needs_agg). Registers measures / columns as it goes."""
        k = node["kind"]
        if k == "const":
            return "0", False
        if k in ("leaf", "unresolved"):
            self.problems.append(f"{node['name']}: {node.get('why') or 'raw column outside a read'}")
            return node["name"], True
        if k == "union":
            parts = [self.define(p) for p in node["parts"]]
            return "(" + " + ".join(t for t, _ in parts) + ")", any(n for _, n in parts)
        bid = node["bid"]
        table = _reads_table(self.blocks, self.creators, bid, self.prefix,
                             schema=getattr(self.res, "schema", None) or None)
        if table:
            rid = self._read_id(bid, table)
            mid = f"{rid}:{node['name']}"
            self.measures.setdefault(mid, {"expr": node["expr"], "read": rid, "table": table})
            return "{m:" + mid + "}", True
        subs = {i: self.define(kid) for i, kid in node["kids"].items()}
        w = _WRAP.match(node["masked"])
        if w and w.group(2) in subs and w.group(1).lower() == "sum" and self.grand_total(bid):
            tok, needs = subs[w.group(2)]
            value = f"total({tok})"                 # share-of-total denominators
        elif w and w.group(2) in subs:
            tok, needs = subs[w.group(2)]
            value = f"{w.group(1)}({tok})" if needs else tok
        else:
            if any(n for _, n in subs.values()):
                self.problems.append(f"{node['name']}: aggregate over un-aggregated measure in '{node['expr']}'")
            value = mm._IDENT.sub(lambda m: mm._wrap(subs[m.group(0)][0]) if m.group(0) in subs
                                  else m.group(0), node["masked"])
            for i, q in enumerate(node.get("subqs", [])):
                value = value.replace(f"__subq{i}__", q)
        name = node["name"]
        if value.strip() == name:
            return name, False
        if re.fullmatch(r"[A-Za-z_]\w*", value.strip()):
            return value.strip(), False             # pure rename: reuse the source column
        if name in self.outputs and node is not self.top:
            name = f"{name}__b{bid}"                # output columns own their names
        elif name in self.columns and self.columns[name] != value:
            # same alias, different block meaning (nested TY/LY/LLY levels): namespace it
            name = f"{name}__b{bid}"
        self.columns.setdefault(name, value)
        return name, False


def layer_pivot(cfg, pivot, tenant, schema, columns):
    res, outs, pv, blocks, creators = mm.pivot_resolver(cfg, pivot, tenant, schema, {})
    L = Layering(pivot, res, blocks, creators, tenant + "_", columns)
    status = {}
    for c in columns:
        (_, node), _r = mm.best_render(res, outs, c) if outs else ((None, None), None)
        if node is None or node["kind"] == "unresolved":
            status[c] = "unresolved"
            continue
        before = len(L.problems)
        L.top = node
        tok, needs = L.define(node)
        if needs:                                   # bare measure as output: pivot sums it
            L.columns.setdefault(c, f"sum({tok})")
        elif tok != c:
            L.columns.setdefault(c, tok)
        status[c] = "ok" if len(L.problems) == before else "partial"
    return L, status


def build(cfg, client, schema, rows, out):
    """rows: metric_map rows. Writes formulas.csv for every (pivot, column) the screens use."""
    tenant = client.lower()
    need = {}
    for r in rows:
        if r.get("pivot") and r.get("status") in ("resolved", "partial"):
            cols = need.setdefault(r["pivot"], set())
            cols.add(r["data_index"])
            if r.get("view_formula"):
                cols.update(mm._pivot_cols_in(r["view_formula"]))
    out_rows = []
    for pv in sorted(need):
        try:
            L, st = layer_pivot(cfg, pv, tenant, schema, sorted(need[pv]))
        except Exception as e:                       # one bad pivot must not sink the build
            out_rows.append({"pivot": pv, "kind": "error", "name": "", "notes": repr(e)[:300]})
            continue
        for rid, r in L.reads.items():
            out_rows.append({"pivot": pv, "kind": "read", "name": rid, "table": r["table"],
                             "from_sql": r["from_sql"], "status": "ok"})
        for mid, m in L.measures.items():
            out_rows.append({"pivot": pv, "kind": "measure", "name": mid, "expr": m["expr"],
                             "read": m["read"], "table": m["table"], "status": "ok"})
        for c, e in L.columns.items():
            out_rows.append({"pivot": pv, "kind": "column", "name": c, "expr": e,
                             "status": st.get(c, "ok")})
        if L.problems:
            out_rows.append({"pivot": pv, "kind": "problems", "name": "",
                             "notes": " ; ".join(dict.fromkeys(L.problems))[:2000]})
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLS)
        w.writeheader()
        for r in out_rows:
            w.writerow({k: r.get(k, "") for k in COLS})
    return out_rows


def load(mdir, pivot):
    """{'reads','measures','columns'} for one pivot, overrides applied."""
    out = {"reads": {}, "measures": {}, "columns": {}}
    for fn in ("formulas.csv", "formulas_override.csv"):
        p = Path(mdir) / fn
        if not p.exists():
            continue
        with open(p, newline="") as f:
            for r in csv.DictReader(f):
                if r["pivot"] != pivot or r["kind"] not in ("read", "measure", "column"):
                    continue
                bucket = out[r["kind"] + "s"]
                if r.get("expr", "").strip() == "-":
                    bucket.pop(r["name"], None)
                else:
                    bucket[r["name"]] = r
    return out
