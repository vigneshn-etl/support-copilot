"""
darwin-equivalent pivot params + rendering (PivotParamGenerator / PivotMemberIds /
PivotTemplatizerImpl in s5-stratos/darwin, assortment module).

render_pivot(...) -> {'prologue': [stmt…], 'agg': [stmt…], 'params': {...}} with every
${…}/<#…> resolved the way the server resolves it for this scope, filters and aggBy.
Session temp tables are named <tenant>_<NAME>_S.
"""
import re
from pathlib import Path

import metric_map as mm
from core.ftl import Renderer

DARWIN_MASON = Path(__file__).resolve().parents[4] / "darwin" / "assortment" / "src" / "main" / \
    "resources" / "com" / "darwin" / "mason"
SESSION = "S"
LONG_MAX = 9223372036854775807


def _q(v):
    return "'" + str(v).replace("'", "''") + "'"


def pivot_fields(cfg, pivot):
    """raw pivotdefn -> (params{}, parts{field: [templates]}, flags{})."""
    pv = mm.Pivot(Path(cfg) / "pivot" / f"{pivot}.pivotdefn", cfg, "")
    flags = {}
    t = (Path(cfg) / "pivot" / f"{pivot}.pivotdefn").read_text(errors="replace")
    m = re.search(r"^bottomLevels\s*=\s*\[(.*?)\]", t, re.S | re.M)
    flags["bottomLevels"] = re.findall(r'"([^"]+)"', m.group(1)) if m else []
    return pv.params, pv.fields, flags


def weeks_list(run_query, dims, start, end):
    t = dims["time"]
    _, rows, _ = run_query(f"SELECT {t['week']} FROM {t['table']} WHERE {t['week']} >= {_q(start)} "
                           f"AND {t['week']} <= {_q(end)} ORDER BY {t['week']}")
    return [r[0] for r in rows]


def build_params(req, dims, pivot, pivot_params, history, weeks_hist, weeks_asst, grain_levels):
    """Mirror PivotParamGenerator.generatePivotParams for one aggregation level."""
    tenant = dims["tenant"]
    sc = req["scope"]
    roots = {"product": "ProductRoot", "location": "LocationRoot", "time": "TimeRoot",
             "prodlife": "ProdLifeRoot", "cluster": "ClusterRoot"}
    all_dims = list(roots)
    # groupings: level ids -> dimension
    def dim_of(level):
        if level in dims["product"]["levels"]:
            return "product"
        if level in dims["location"]["levels"]:
            return "location"
        if level in dims["time"]["levels"]:
            return "time"
        if level in ("merchcat",):
            return "prodlife"
        if level in ("grade",):
            return "cluster"
        return None
    required = list(dict.fromkeys(dim_of(l) for l in grain_levels if dim_of(l)))
    agg_groups = ",".join(grain_levels)
    p = {}
    p["PIVOT_USER_ID"] = req.get("userId", "")
    # scopeModel.getScopeParams(): $<level> = member, $HistoryStart/End
    p[f"${sc['productLevel']}"] = sc["productMember"]
    p[f"${sc['locationLevel']}"] = sc["locationMember"]
    p["$HistoryStart"], p["$HistoryEnd"] = sc.get("historyStart"), sc.get("historyEnd")
    p.update(pivot_params)
    # getAggLevels
    p.update({"AGG_PRODUCT_LEVEL": "", "AGG_PRODUCT_LEVEL_COMMA": "",
              "AGG_LOCATION_LEVEL": "", "AGG_LOCATION_LEVEL_COMMA": ""})
    for i, lvl in enumerate(grain_levels, 1):
        p[f"AGG_LEVEL_{i}"] = lvl
        p[f"AGG_LEVEL_{i}_COMMA"] = lvl + ", "
        p[f"AGG_LEVEL_{i}_LEADING_COMMA"] = ", " + lvl
    by_dim = {}
    for lvl in grain_levels:
        d = dim_of(lvl)
        if d and "rootlevel" not in lvl:
            by_dim.setdefault(d, []).append(lvl)
    for d, ls in by_dim.items():
        p[f"AGG_{d.upper()}_LEVEL"] = ", ".join(ls)
        p[f"AGG_{d.upper()}_LEVEL_COMMA"] = ", ".join(ls) + ", "
    non_root = [l for l in grain_levels if "rootlevel" not in l]
    p["AGG_LEVEL_GROUP_TRAILING_COMMA"] = ", ".join(non_root) + ","
    p["AGG_LEVEL_GROUP_NO_TRAILING_COMMA"] = ", ".join(non_root)
    # getAggDimensions
    for d in all_dims:
        g = ",".join(l for l in grain_levels if dim_of(l) == d)
        p[f"AGGREGATION_{d.upper()}S"] = g or d
        p[f"AGGREGATION_{d.upper()}S_COMMA"] = (g + ",") if g else d
    # PivotMemberIds: LEAF_PRODLIFE / LEAF_CLUSTER from conditions (else every leaf)
    cbd = req["conditions_by_dimension"]
    for d, lvl, fid in (("prodlife", "merchcat", "merchcat"), ("cluster", "grade", "grade")):
        vals = (cbd.get(d) or {}).get(lvl) or dims["filters"][fid].get("all") or []
        p[f"LEAF_{d.upper()}"] = ", ".join(_q(v) for v in vals)
    p["SCOPED_HISTORY_WEEKS"] = ",".join(_q(w) for w in weeks_hist)
    p["SCOPED_ASSORTMENT_WEEKS"] = ",".join(_q(w) for w in weeks_asst)
    p["RAW"] = {}
    fs = req.get("flowStatus") or dims["flow_status"]["default"]
    p["FLOW_STATUS"] = ",".join(str(int(x)) for x in fs)
    p["SCOPED_PRODUCT"] = _q(sc["productMember"])
    p["SCOPED_PRODUCT_LEVEL"] = sc["productLevel"]
    p["SCOPED_LOCATION"] = _q(sc["locationMember"])
    p["SCOPED_LOCATION_LEVEL"] = sc["locationLevel"]
    p["TENANT_ID"] = tenant
    p["SESSION_ID"] = SESSION
    p["isNested"] = "false"
    p["PRODUCT_TABLENAME"] = f"{tenant}_{pivot}_product_{SESSION}"
    p["PRODUCT_TABLENAME_FILTERED"] = p["PRODUCT_TABLENAME"] + "_channel"
    p["LOCATION_TABLENAME"] = f"{tenant}_{pivot}_location_{SESSION}"
    p["MAYBE_LIMIT_TO"] = f"LIMIT {LONG_MAX}"
    p["MAYBE_ORDER_BY"] = ""
    p["LEAF_ORDERING_GROUPS"] = ""
    p["SORT_BY_ORDER"] = ""
    p["J_SESSION_ID"] = p["SERVICE_NAME"] = ""
    p["APP_NAME"] = req.get("appName", "Assortment")
    p["MAYBE_GROUP_BY"] = "GROUP BY" if required else ""
    p["LEAF_DIMENSION_GROUPS"] = ",".join(required)
    p["LEAF_DIMENSION_GROUPS_COMMA"] = (",".join(required) + ",") if required else ""
    p["AGGREGATION_GROUPS"] = agg_groups
    p["AGGREGATION_GROUPS_COMMA"] = (agg_groups + ",") if agg_groups else ""
    p["NULL_AS_SELECT_COMMA"] = "".join(f"'{roots[d]}' as {d}, \n" for d in all_dims if d not in required)
    p["AGGREGATION_CUSTOM"] = ""
    p["CONDITIONS_BY_DIMENSION"] = cbd
    p["GENERAL_CONDITIONS"] = req["general"]
    p["PRODUCT_WORKLIST_TABLENAME"] = "WORKLIST_" + SESSION
    weeks = weeks_hist if (history and weeks_hist) else weeks_asst
    if weeks:
        p["LEAF_TIME_START"], p["LEAF_TIME_END"] = _q(weeks[0]), _q(weeks[-1])
        p["LEAF_TIME"] = ", ".join(_q(w) for w in weeks)
    p["LEAF_FLOW_STATUS"] = p["FLOW_STATUS"]
    p["TOP_MEMBERS"] = ",".join(_q(m) for m in (sc["productMember"], sc["locationMember"]))
    p["PRODUCT_LEVEL"] = sc["productLevel"]
    p["LOCATION_LEVEL"] = sc["locationLevel"]
    p["WORKLIST_ITEMS"] = req.get("worklistItems") or []
    return p


def render_pivot(cfg, pivot, params, n_groupings=1, level_index=0):
    """-> {'prologue': [sql…], 'agg': sql, 'agg_field': str}"""
    pparams, fields, _ = pivot_fields(cfg, pivot)
    preserved = {}
    loaders = [Path(cfg) / "pivot" / "include", Path(cfg) / "pivot", DARWIN_MASON]
    r = Renderer(loaders, params, preserved)
    pro = []
    for f in ("prologueSQL", "prologueSQLs"):
        for t in fields.get(f, []):
            if t.strip():
                pro.append(r.render(t))
    rev, agg = fields.get("reverseAggSQLs", []), fields.get("aggregationSQLs", [])
    if rev:
        idx = min(len(rev) - 1, n_groupings - 1 - level_index)
        tpl, field = rev[idx], f"reverseAggSQLs[{idx}]"
    elif agg:
        idx = min(level_index, len(agg) - 1)
        tpl, field = agg[idx], f"aggregationSQLs[{idx}]"
    else:
        raise ValueError(f"{pivot}: neither aggregationSQLs nor reverseAggSQLs")
    return {"prologue": pro, "agg": r.render(tpl), "agg_field": field}
