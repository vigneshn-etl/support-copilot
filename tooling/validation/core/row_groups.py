"""Row-group screens: rows are groups of items, not items (QA HistoryInfoGraph: Pareto Summary).

screens.row_groups = 'pareto:<metric>': per period, that period's items are ranked by <metric> (descending,
ties by item id; QA's order on ties is arbitrary) and cut by rank position into
  Total | Top 50 | Top 20% | Above Average | Average | Below Average | Bottom 20%
(rank <= 0.2 * n, 0.2 n < rank <= 0.4 n, ...). Measures are summed per group, then every metric is
recomputed on the group sums; total(x) = the Total group's x; __items counts the group's items.
"""
import re

from core import spec as SP

PARETO = [("Total", lambda k, n: True), ("Top 50", lambda k, n: k <= 0.5 * n),
          ("Top 20%", lambda k, n: k <= 0.2 * n), ("Above Average", lambda k, n: 0.2 * n < k <= 0.4 * n),
          ("Average", lambda k, n: 0.4 * n < k <= 0.6 * n), ("Below Average", lambda k, n: 0.6 * n < k <= 0.8 * n),
          ("Bottom 20%", lambda k, n: k > 0.8 * n)]
KINDS = {"pareto": PARETO}


def parse(spec_text):
    kind, _, metric = (spec_text or "").partition(":")
    if kind not in KINDS or not metric.strip():
        raise ValueError(f"row_groups '{spec_text}': expected one of {sorted(KINDS)} as '<kind>:<metric>'")
    return KINDS[kind], metric.strip()


def num(v):
    try:
        return float(v) if v not in (None, "", "\\N", "nan") else 0.0
    except (TypeError, ValueError):
        return 0.0


def group(rows, groups, rank_col, key, cols):
    """{group: {col: sum}} for one period's item rows, ranked by rank_col descending (ties by key)."""
    items = sorted(rows, key=lambda r: (-num(r.get(rank_col)), str(r.get(key))))
    n, out = len(items), {}
    for name, sel in groups:
        picked = [r for k, r in enumerate(items, 1) if sel(k, n)]
        out[name] = {c: sum(num(r.get(c)) for r in picked) for c in cols}
    return out


def evaluate(env_by_group, metric_exprs):
    """metrics on the group sums, in dependency order; total(x) = the Total group's x."""
    fn = {"_if": lambda c, a, b: a if c else b, "_round": lambda x, n=0: round(x, int(n)), "multiIf": SP._multi_if}
    for col, sql, _typ in metric_exprs:
        code = compile(SP._py(SP.TOTAL.sub(lambda t: f"__t_{t.group(1)}", sql)), col, "eval")
        tot = {f"__t_{c}": v for c, v in env_by_group["Total"].items()}
        for g, env in env_by_group.items():
            try:
                env[col] = eval(code, {"__builtins__": {}, **fn}, {**env, **tot})
            except ZeroDivisionError:
                env[col] = 0.0
        tot = {f"__t_{c}": v for c, v in env_by_group["Total"].items()}
    return env_by_group
