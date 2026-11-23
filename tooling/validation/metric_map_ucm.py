# /// script
# requires-python = ">=3.9"
# dependencies = ["psycopg[binary]>=3.2", "python-dotenv>=1.0", "openpyxl>=3.1"]
# ///
"""
Metric map from the UCM database instead of the config git clone.

Same trace as metric_map.py (screen -> view column -> pivot -> CH base
table.column), and it reuses that file's SQL parser / resolver / renderer
unchanged. Only the inputs differ, all read from UCM Postgres for one
tenant + environment:

    app_ui_config.config_ui_navigation   top nav > left nav > screen -> view_name
    app_view.view_definition / _def_item  view columns (label, dataIndex, formula, renderer)
    app_public.model_templates            model -> pivotdefn
    app_pivot.view_model_pivot_mapping    screen -> models/pivots (fallback binding)
    app_pivot.patterns.raw_json           pivot SQL sections, FTL includes already inlined

UCM reflects what's loaded for the env (qa = deployed), so it can differ from
git; `git_*` columns show the git-based metric_map.csv row for comparison.

Needs a UCM login with read access to the app_* schemas, in the .env named by
UCM_ENV_FILE (DB_NAME/DB_USER/DB_PASSWORD). The ssh tunnel opens itself (core/tunnel.py).

Usage:
  uv run --script metric_map_ucm.py --client TRD --env qa
  uv run --script metric_map_ucm.py --client TRD --pivot HistoryFit --explain net_sls_r
"""
import argparse, csv, json, os, re, sys
from collections import Counter, defaultdict
from pathlib import Path

import psycopg
from dotenv import load_dotenv

HERE = Path(__file__).resolve().parent
HUB = HERE.parent.parent
sys.path.insert(0, str(HERE))
import metric_map as mm  # noqa: E402

UCM_ENV = os.environ.get("UCM_ENV_FILE", "")
NO_CFG = Path("/nonexistent-ucm-config")   # includes are pre-inlined; nothing to read from disk
_FTL_COMMENT = re.compile(r"<#--.*?-->", re.S)

COLS = ["metric_key", "display_name", "column_group", "data_index", "view_formula", "renderer",
        "visible", "top_nav", "left_nav", "screen_view", "modules", "viewdefn", "view_section",
        "app", "unique_id", "model", "pivot", "binding", "pivot_expr", "base_formula",
        "base_tables", "base_columns", "columns_verified", "filters", "derivation", "variants",
        "status", "notes", "git_base_formula", "git_base_columns", "git_match"]


# ---------------------------------------------------------------- DB
def connect():
    if not UCM_ENV:
        sys.exit("set UCM_ENV_FILE to a .env with DB_NAME / DB_USER / DB_PASSWORD for UCM")
    load_dotenv(UCM_ENV)
    from core import tunnel
    err = tunnel.ensure({"DVS_DB_HOST": os.environ.get("DB_HOST", "localhost"),
                         "DVS_DB_PORT": os.environ.get("DB_PORT", "15432")})
    if err:
        sys.exit(err)
    c = psycopg.connect(host=os.environ.get("DB_HOST", "localhost"),
                        port=int(os.environ.get("DB_PORT", "15432")),
                        dbname=os.environ["DB_NAME"], user=os.environ["DB_USER"],
                        password=os.environ["DB_PASSWORD"], sslmode="require",
                        connect_timeout=15)
    c.read_only = True
    return c


def fetch(c, sql, params):
    cur = c.execute(sql, params)
    names = [d.name for d in cur.description]
    return [dict(zip(names, r)) for r in cur.fetchall()]


class DbPivot(mm.Pivot):
    """mm.Pivot built from UCM pattern sections instead of a .pivotdefn file."""

    def __init__(self, name, sections, tenant):
        self.path, self.name, self.cfg, self.tenant = None, name, NO_CFG, tenant
        self.params, self.fields, self.missing_vars = {}, defaultdict(list), set()
        for s in sorted(sections, key=lambda s: (s["position"] or 0)):
            # UCM marks inlined includes with <#-- @@AP_FTL_START:x.ftl@@ -->. Drop FTL
            # comments first: mm's SQL-comment pass would eat the "--" and leave a bare
            # "<#" that the FTL-tag pass then extends to the next ">" in the SQL.
            body = _FTL_COMMENT.sub(" ", s["content"] or "")
            if s["section"] == "params":
                self.params[s["name"]] = body
            elif s["section"] in ("prologueSQL", "prologueSQLs", "aggregationSQLs",
                                  "reverseAggSQLs", "epilogueSQL"):
                self.fields[s["section"]].append(body)
        self.fields = dict(self.fields)


def load_ucm(c, tenant, env):
    p = (tenant, env)
    nav = fetch(c, """select top_nav, left_nav, view, view_name, unique_id, config, top_down, bottom_up
                      from app_ui_config.config_ui_navigation
                      where tenant=%s and environment=%s
                      order by top_nav, left_nav, view, view_name""", p)
    vdefs = {r["view_name"]: r for r in fetch(c, """
        select view_name, view_type, root_props->>'model' as model
        from app_view.view_definition where tenant=%s and environment=%s""", p)}
    items = defaultdict(list)
    for r in fetch(c, """select item_id, parent_item_id, view_name, seq_no, role, data_index,
                                label_text, renderer, formula, extra_props
                         from app_view.view_def_item where tenant=%s and environment=%s
                         order by view_name, seq_no""", p):
        items[r["view_name"]].append(r)
    models = {r["id"]: r["pivotdefn"] for r in fetch(c, """
        select id, pivotdefn from app_public.model_templates
        where tenant=%s and environment=%s""", p)}
    mapping = {r["unique_id"]: r for r in fetch(c, """
        select unique_id, model_names, pivot_names from app_pivot.view_model_pivot_mapping
        where tenant=%s and environment=%s""", p)}
    secs = defaultdict(list)
    for r in fetch(c, """
        select p.pattern_key, v->>'section' as section, v->>'name' as name,
               (v->>'position')::int as position, v->>'content' as content
        from app_pivot.patterns p, jsonb_each(p.raw_json::jsonb->'patterns') e(k, v)
        where p.tenant=%s and p.environment=%s
          and v->>'section' in ('params','prologueSQL','prologueSQLs','aggregationSQLs',
                                'reverseAggSQLs','epilogueSQL')""", p):
        secs[r["pattern_key"]].append(r)
    defs = defaultdict(set)
    for r in fetch(c, """select distinct pivot_name, data_index from app_pivot.pivot_dataindex_defs
                         where tenant=%s and environment=%s""", p):
        defs[r["pivot_name"]].add(r["data_index"])
    return nav, vdefs, items, models, mapping, secs, defs


# ---------------------------------------------------------------- view columns
def view_columns(view_items):
    """viewdefn leaf columns, mirroring mm.view_columns' filter."""
    by_id = {i["item_id"]: i for i in view_items}
    out = []
    for i in view_items:
        di = i["data_index"]
        if not (isinstance(di, str) and di and ":" not in di and di not in ("&", "_")):
            continue
        if not (i["label_text"] or i["formula"]):
            continue
        groups, p, guard = [], i["parent_item_id"], 0
        while p in by_id and guard < 20:
            lbl = by_id[p]["label_text"]
            if lbl:
                groups.insert(0, lbl)
            p, guard = by_id[p]["parent_item_id"], guard + 1
        ep = i["extra_props"] or {}
        if isinstance(ep, str):
            try:
                ep = json.loads(ep)
            except Exception:
                ep = {}
        hidden = ep.get("visible") is False or ep.get("hidden") is True
        out.append({"dataIndex": di, "text": i["label_text"] or "", "formula": i["formula"] or "",
                    "renderer": i["renderer"] or "", "visible": "N" if hidden else "Y",
                    "group": " › ".join(groups), "section": " › ".join(groups) or "view"})
    return out


# ---------------------------------------------------------------- binding
def bind(nav_row, vdefs, models, mapping, secs, defs, data_indexes):
    """-> (model, pivot, how, alternates). Prefer the view's own model (as git
    metric_map does), else the screen's model/pivot list, picking the pivot that
    defines the most of this view's dataIndexes. `alternates` are the screen's
    other (model, pivot) pairs, tried per column when the chosen pivot doesn't
    define that column."""
    vm = (vdefs.get(nav_row["view_name"]) or {}).get("model")
    m = mapping.get(nav_row["unique_id"])
    pairs = []
    if m and m["pivot_names"]:
        pairs = list(zip(m["model_names"] or [None] * len(m["pivot_names"]), m["pivot_names"]))
        pairs = [(mo, pv) for mo, pv in pairs if pv in secs]
    if vm and models.get(vm) in secs:
        return vm, models[vm], "view.model", [p for p in pairs if p[1] != models[vm]]
    if pairs:
        best = max(pairs, key=lambda mp: len(defs.get(mp[1], set()) & data_indexes))
        how = "screen.mapping" if len(pairs) == 1 else f"screen.mapping (best of {len(pairs)})"
        return best[0], best[1], how, [p for p in pairs if p != best]
    if vm:
        return vm, None, "view.model (pivot not in UCM)", []
    return None, None, "none", []


def column_binding(col, model, pv, how, alts, defs):
    """Per column: keep the view's pivot if it defines the dataIndex (or the
    pivot cols a view formula reads), else the first screen pivot that does."""
    want = [col["dataIndex"]]
    f = col["formula"]
    if f and f.strip() != f"sum({col['dataIndex']})":
        want = mm._pivot_cols_in(f) or want
    def covers(p):
        return p and all(w in defs.get(p, ()) for w in want)
    if covers(pv) or not alts:
        return model, pv, how
    for mo, p in alts:
        if covers(p):
            return mo, p, "screen.mapping (column defined here)"
    return model, pv, how


_CREATE = re.compile(r"^CREATE (?:TABLE|MATERIALIZED VIEW|VIEW) \w+\.(\w+) \((.*?)\) ENGINE", re.M)


def _dump_schema(path):
    """{table: [columns]} from a db/clickhouse_schema.sql dump (one CREATE per line)."""
    if not path.exists():
        return {}
    out = {}
    for m in _CREATE.finditer(path.read_text(errors="replace")):
        out[m.group(1)] = re.findall(r"`([^`]+)` ", m.group(2))
    return out


def resolver(name, secs, tenant, schema, cache):
    if name in cache:
        return cache[name]
    pv = DbPivot(name, secs[name], tenant)
    pro, outs = pv.sql_sets()
    blocks, creators = mm.parse_blocks("\n;\n".join(pro + outs))
    out_id, n = [], len(blocks)
    for o in reversed(outs):
        k = len(mm.parse_blocks(o)[0])
        n -= k
        if k:
            out_id.insert(0, n)
    out_id = [(i, f"{pv.out_field}[{j}]") for j, i in enumerate(out_id)] or None
    r = mm.Resolver(blocks, creators, schema)
    r.prefix = tenant + "_"
    cache[name] = (r, out_id, pv, blocks, creators)
    return cache[name]


# ---------------------------------------------------------------- build
def build(client, env, out_dir, schema_path, describe_missing):
    tenant = client.lower()
    c = connect()
    print(f"reading UCM {tenant}/{env}…", file=sys.stderr)
    nav, vdefs, items, models, mapping, secs, defs = load_ucm(c, tenant, env)
    print(f"  {len(nav)} nav rows, {len(items)} views, {len(secs)} pivots", file=sys.stderr)

    schema = mm.load_schema(schema_path)
    dumped = _dump_schema(HUB / "customers" / client / "db" / "clickhouse_schema.sql")
    for t, cs in dumped.items():                         # ch_schema.json (fresher) wins
        if not schema.get(t):
            schema[t] = cs
    plan, pivots = [], set()
    for n in nav:
        cols = view_columns(items.get(n["view_name"], []))
        model, pv, how, alts = bind(n, vdefs, models, mapping, secs, defs, {x["dataIndex"] for x in cols})
        bound = [(col, *column_binding(col, model, pv, how, alts, defs)) for col in cols]
        plan.append((n, bound))
        pivots |= {b[2] for b in bound if b[2]}
    tables = set()
    for p in sorted(pivots):
        _, _, _, blocks, creators = resolver(p, secs, tenant, {}, {})
        tables |= mm.real_tables(blocks, creators, tenant + "_")
    missing = sorted(t for t in tables if t not in schema)
    if missing and describe_missing:
        print(f"describing {len(missing)} CH tables on {client} {env}…", file=sys.stderr)
        schema = mm.fetch_schema(set(missing), client, env, schema)
        Path(schema_path).write_text(json.dumps(dict(sorted(schema.items())), indent=0))
    elif missing:
        print(f"  {len(missing)} base tables not in {schema_path.name}; their columns stay "
              f"unverified (use --describe-missing)", file=sys.stderr)
    schema_sets = {t: set(cs) for t, cs in schema.items() if cs}

    rows, seen, pcache = [], set(), {}
    for n, bound in plan:
        for col, model, pv, how in bound:
            key = (n["unique_id"], n["view_name"], col["section"], col["dataIndex"], col["text"])
            if key in seen:
                continue
            seen.add(key)
            res = out_id = None
            if pv:
                try:
                    res, out_id, _, _, _ = resolver(pv, secs, tenant, schema_sets, pcache)
                except Exception as e:                   # one bad pivot shouldn't stop the map
                    print(f"  pivot {pv}: {e}", file=sys.stderr)
            s = {"app": n["config"] or "", "top_nav": n["top_nav"], "top_nav_id": "",
                 "screen_id": n["unique_id"], "path": [n["left_nav"], n["view"]],
                 "modules": [m for m, on in (("top-down", n["top_down"]), ("bottom-up", n["bottom_up"])) if on],
                 "model": model}
            try:
                r = mm.row_for(s, n["view_name"], col, pv, res, out_id)
            except Exception as e:
                r = mm.row_for(s, n["view_name"], col, None, None, None)
                r.update(status="error", notes=f"trace failed: {e}"[:300])
            r.update(column_group=col["group"], unique_id=n["unique_id"], binding=how,
                     left_nav=n["left_nav"], screen_view=n["view"])
            if not pv and how.startswith("view.model"):
                r["notes"] = f"model {model} has no pivot loaded in UCM"
            rows.append(r)

    _variants(rows)
    _git_compare(rows, HUB / "customers" / client / "metrics" / "metric_map.csv")
    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "metric_map_ucm.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLS)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in COLS})
    return rows


def _variants(rows):
    forms = defaultdict(Counter)
    for r in rows:
        if r.get("base_formula"):
            forms[r["display_name"]][r["base_formula"]] += 1
    for r in rows:
        fs = forms.get(r["display_name"])
        if fs and r.get("base_formula"):
            rank = [k for k, _ in fs.most_common()].index(r["base_formula"]) + 1
            r["variants"] = f"{rank} of {len(fs)}" + (" (majority)" if rank == 1 and len(fs) > 1 else "")


def _git_compare(rows, git_csv):
    """Same pivot + dataIndex in the git-built map: does the base trace agree?"""
    if not git_csv.exists():
        return
    # the view formula is part of the key: the same pivot.dataIndex traces differently
    # on a screen whose column formula recombines other pivot columns
    git = {}
    for g in csv.DictReader(open(git_csv)):
        if g.get("base_columns"):
            git.setdefault((g["pivot"], g["data_index"], g["view_formula"]), g)
    for r in rows:
        g = git.get((r.get("pivot"), r.get("data_index"), r.get("view_formula") or ""))
        if not g:
            r["git_match"] = "not in git map" if r.get("pivot") else ""
            continue
        r["git_base_formula"], r["git_base_columns"] = g["base_formula"], g["base_columns"]
        if not r.get("base_columns"):
            r["git_match"] = "git only"
        elif r["base_columns"] == g["base_columns"]:
            r["git_match"] = "same" if r.get("base_formula") == g["base_formula"] else "same columns"
        else:
            r["git_match"] = "DIFFERENT"


# ---------------------------------------------------------------- workbook
def write_xlsx(rows, path, client, env):
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Font, PatternFill
    from openpyxl.utils import get_column_letter

    wb = Workbook()
    head_fill, head_font = PatternFill("solid", fgColor="1F3864"), Font(bold=True, color="FFFFFF")

    def sheet(ws, header, data, widths):
        ws.append(header)
        for r in data:
            ws.append([("" if v is None else str(v))[:32000] for v in r])
        for i, w in enumerate(widths, 1):
            ws.column_dimensions[get_column_letter(i)].width = w
        for cell in ws[1]:
            cell.fill, cell.font = head_fill, head_font
            cell.alignment = Alignment(vertical="center", wrap_text=True)
        ws.freeze_panes = "A2"
        ws.auto_filter.ref = ws.dimensions

    # 1. summary
    ws = wb.active
    ws.title = "Summary"
    st = Counter(r.get("status") for r in rows)
    gm = Counter(r.get("git_match") for r in rows if r.get("git_match"))
    metrics = {(r["data_index"]) for r in rows}
    resolved_di = {r["data_index"] for r in rows if r.get("status") == "resolved"}
    lines = [
        ("Metric → base column map", f"{client} / {env}, built from the UCM database"),
        ("", ""),
        ("Screen-metric rows", len(rows)),
        ("Distinct metrics (dataIndex)", len(metrics)),
        ("Distinct display names", len({r['display_name'] for r in rows})),
        ("Pivots used", len({r['pivot'] for r in rows if r.get('pivot')})),
        ("Base tables reached", len({t for r in rows for t in (r.get('base_tables') or '').split('|') if t})),
        ("", ""),
        ("Status: resolved", st.get("resolved", 0)),
        ("Status: partial", st.get("partial", 0)),
        ("Status: unresolved", st.get("unresolved", 0)),
        ("Status: no_pivot", st.get("no_pivot", 0)),
        ("Status: no_sql / error", st.get("no_sql", 0) + st.get("error", 0)),
        ("Metrics fully resolved on ≥1 screen", f"{len(resolved_di)} of {len(metrics)}"),
        ("", ""),
        ("vs git map: same base trace", gm.get("same", 0) + gm.get("same columns", 0)),
        ("vs git map: DIFFERENT base columns", gm.get("DIFFERENT", 0)),
        ("vs git map: git resolves, UCM doesn't", gm.get("git only", 0)),
        ("vs git map: pivot+metric not in git map", gm.get("not in git map", 0)),
        ("", ""),
        ("Tabs", ""),
        ("Metrics", "One row per metric (dataIndex): its base formula(s), base tables/columns, and where it shows"),
        ("Screen detail", "One row per metric per screen column, with the full derivation chain"),
        ("Base columns", "One row per ClickHouse table.column, with the metrics that read it"),
        ("Needs review", "Unresolved/partial rows and rows whose base trace differs from git"),
        ("", ""),
        ("Status meanings", "resolved = every leaf reached a real CH table.column; partial = some leaves "
                            "did; unresolved = none did; no_pivot = screen has no pivot bound in UCM"),
        ("columns_verified", "Y = every leaf column exists in the cached QA CH schema (ch_schema.json); "
                             "N = some tables not in the cache, so not checked"),
    ]
    for a, b in lines:
        ws.append([a, b])
    ws.column_dimensions["A"].width, ws.column_dimensions["B"].width = 42, 110
    ws["A1"].font = Font(bold=True, size=14)
    for row in ws.iter_rows(min_row=3):
        row[0].font = Font(bold=bool(row[0].value) and not row[1].value == "")

    # 2. metrics (one row per dataIndex)
    agg = defaultdict(lambda: {"names": Counter(), "forms": Counter(), "tables": set(), "cols": set(),
                               "screens": set(), "pivots": set(), "status": Counter(), "renderers": Counter()})
    for r in rows:
        a = agg[r["data_index"]]
        a["names"][r["display_name"] if not r.get("column_group") else f"{r['column_group']} › {r['display_name']}"] += 1
        if r.get("base_formula"):
            a["forms"][r["base_formula"]] += 1
        a["tables"] |= {t for t in (r.get("base_tables") or "").split("|") if t}
        a["cols"] |= {t for t in (r.get("base_columns") or "").split("|") if t}
        a["screens"].add(f"{r['top_nav']} › {r['left_nav']} › {r['screen_view']}")
        if r.get("pivot"):
            a["pivots"].add(r["pivot"])
        a["status"][r.get("status")] += 1
        if r.get("renderer"):
            a["renderers"][r["renderer"]] += 1
    data = []
    for di, a in sorted(agg.items()):
        best = "resolved" if a["status"].get("resolved") else (
            "partial" if a["status"].get("partial") else a["status"].most_common(1)[0][0])
        forms = [f for f, _ in a["forms"].most_common()]
        data.append([di, " | ".join(n for n, _ in a["names"].most_common(3)),
                     a["renderers"].most_common(1)[0][0] if a["renderers"] else "",
                     forms[0] if forms else "", len(forms),
                     "\n".join(forms[1:4]) + (" …" if len(forms) > 4 else ""),
                     "\n".join(sorted(a["tables"])), "\n".join(sorted(a["cols"])),
                     len(a["screens"]), "\n".join(sorted(a["screens"])[:15]) + (" …" if len(a["screens"]) > 15 else ""),
                     ", ".join(sorted(a["pivots"])), best])
    sheet(wb.create_sheet("Metrics"),
          ["data_index", "display names (top 3)", "renderer", "base formula (most common)",
           "# formula variants", "other variants", "base tables", "base columns",
           "# screens", "screens", "pivots", "best status"],
          data, [26, 34, 14, 60, 10, 50, 34, 44, 9, 50, 34, 12])

    # 3. screen detail
    det = [c for c in COLS if c not in ("app", "metric_key")]
    sheet(wb.create_sheet("Screen detail"), det, [[r.get(k, "") for k in det] for r in rows],
          [24, 18, 22, 30, 14, 7, 20, 22, 22, 12, 30, 22, 12, 26, 26, 18, 30, 50, 32, 44, 8, 40, 60, 12, 11, 40, 40, 40, 14])

    # 4. base columns
    bc = defaultdict(lambda: {"metrics": set(), "pivots": set(), "n": 0, "verified": set()})
    for r in rows:
        for col in (r.get("base_columns") or "").split("|"):
            if col:
                b = bc[col]
                b["metrics"].add(r["data_index"]); b["n"] += 1
                if r.get("pivot"):
                    b["pivots"].add(r["pivot"])
                b["verified"].add(r.get("columns_verified"))
    sheet(wb.create_sheet("Base columns"),
          ["base table", "column", "# metrics", "metrics (dataIndex)", "# screen columns", "pivots"],
          [[k.rsplit(".", 1)[0], k.rsplit(".", 1)[1], len(v["metrics"]),
            ", ".join(sorted(v["metrics"]))[:5000], v["n"], ", ".join(sorted(v["pivots"]))]
           for k, v in sorted(bc.items())],
          [38, 28, 10, 80, 12, 50])

    # 5. needs review
    rev = [r for r in rows if r.get("status") in ("unresolved", "partial", "error", "no_sql")
           or r.get("git_match") == "DIFFERENT"]
    rc = ["status", "git_match", "display_name", "data_index", "top_nav", "left_nav", "screen_view",
          "pivot", "base_formula", "base_columns", "git_base_formula", "git_base_columns", "notes"]
    sheet(wb.create_sheet("Needs review"), rc, [[r.get(k, "") for k in rc] for r in rev],
          [11, 13, 22, 24, 18, 22, 22, 28, 50, 44, 50, 44, 60])
    wb.save(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--client", default="TRD")
    ap.add_argument("--env", default="qa", help="UCM environment: qa (deployed) or repo")
    ap.add_argument("--describe-missing", action="store_true",
                    help="DESCRIBE base tables missing from ch_schema.json on QA CH (db MCP)")
    ap.add_argument("--pivot", help="debug: one pivot")
    ap.add_argument("--explain", help="debug: dataIndex to trace in --pivot")
    a = ap.parse_args()
    mdir = HUB / "customers" / a.client / "metrics"
    schema_path = mdir / "ch_schema.json"
    if a.pivot:
        c = connect()
        *_, secs, _ = load_ucm(c, a.client.lower(), a.env)
        schema = {t: set(cs) for t, cs in mm.load_schema(schema_path).items() if cs}
        res, out_id, pv, blocks, creators = resolver(a.pivot, secs, a.client.lower(), schema, {})
        print(f"{len(blocks)} blocks, temps={len(creators)}, output block={out_id}, real tables="
              f"{sorted(mm.real_tables(blocks, creators, a.client.lower() + '_'))}")
        if a.explain:
            f, l, ch, u, w = mm.best_render(res, out_id, a.explain)[1]
            print("base_formula:", f); print("leaves:", l); print("unresolved:", u)
            print("filters:", *dict.fromkeys(w), sep="\n  "); print("chain:", *ch, sep="\n  ")
        return
    rows = build(a.client, a.env, mdir, schema_path, a.describe_missing)
    xlsx = mdir / f"{a.client}_metric_base_column_map_{a.env}.xlsx"
    write_xlsx(rows, xlsx, a.client, a.env)
    st = Counter(r.get("status") for r in rows)
    print(f"{len(rows)} rows -> {mdir / 'metric_map_ucm.csv'}\n          -> {xlsx}")
    print("status:", dict(st))
    print("git compare:", dict(Counter(r.get("git_match") for r in rows if r.get("git_match"))))


if __name__ == "__main__":
    main()
