#!/usr/bin/env python3
"""
Shared read-only graph access over lineage.db — used by server.py and
export_static.py. Opens SQLite immutable/read-only so it works on read-only or
network/FUSE mounts (no locking, no journal).
"""
from __future__ import annotations

import hashlib
import sqlite3
from pathlib import Path

MAXDEPTH_FULL = 100

_UP = """
WITH RECURSIVE up(id, depth, path) AS (
    SELECT :t, 0, '|' || :t || '|'
    UNION ALL
    SELECT e.src_id, up.depth+1, up.path || e.src_id || '|'
    FROM edge e JOIN up ON e.dst_id = up.id
    WHERE up.depth < :maxd AND instr(up.path, '|' || e.src_id || '|') = 0
)
SELECT DISTINCT id FROM up;
"""
_DN = """
WITH RECURSIVE dn(id, depth, path) AS (
    SELECT :t, 0, '|' || :t || '|'
    UNION ALL
    SELECT e.dst_id, dn.depth+1, dn.path || e.dst_id || '|'
    FROM edge e JOIN dn ON e.src_id = dn.id
    WHERE dn.depth < :maxd AND instr(dn.path, '|' || e.dst_id || '|') = 0
)
SELECT DISTINCT id FROM dn;
"""


def connect_ro(db_path: str) -> sqlite3.Connection:
    uri = f"file:{Path(db_path).resolve()}?mode=ro&immutable=1"
    con = sqlite3.connect(uri, uri=True)
    con.row_factory = sqlite3.Row
    return con


def list_batches(con) -> list[dict]:
    rows = con.execute(
        "SELECT batch, COUNT(*) c FROM edge_batch GROUP BY batch ORDER BY batch"
    ).fetchall()
    return [{"batch": r["batch"], "edges": r["c"]} for r in rows]


def list_tables(con, batch: str | None) -> list[dict]:
    if batch:
        sql = """SELECT DISTINCT n.id, n.name, n.engine
                 FROM node n JOIN edge e ON e.dst_id = n.id
                 JOIN edge_batch b ON b.edge_id = e.id
                 WHERE n.kind='table' AND b.batch = ?
                 ORDER BY n.engine, n.name"""
        rows = con.execute(sql, (batch,)).fetchall()
    else:
        rows = con.execute(
            "SELECT id, name, engine FROM node WHERE kind='table' ORDER BY engine, name"
        ).fetchall()
    return [{"id": r["id"], "name": r["name"], "engine": r["engine"],
             "label": f"{r['engine']}.{r['name']}"} for r in rows]


def _node_set(con, target, direction, maxd):
    sql = _UP if direction == "upstream" else _DN
    return {r["id"] for r in con.execute(sql, {"t": target, "maxd": maxd})}


def subgraph(con, target, direction="upstream", depth=1, batch=None) -> dict:
    """Return {nodes, edges, meta} for the lineage view."""
    if not con.execute("SELECT 1 FROM node WHERE id=?", (target,)).fetchone():
        return {"error": f"table not found: {target}"}
    maxd = MAXDEPTH_FULL if depth == "full" else int(depth)
    ids = _node_set(con, target, direction, maxd)
    ids.add(target)
    ph = ",".join("?" * len(ids))
    ids_l = list(ids)

    # edges among the node set, on the traversal side of the target
    if direction == "upstream":
        edge_sql = f"SELECT * FROM edge WHERE dst_id IN ({ph}) AND src_id IN ({ph})"
    else:
        edge_sql = f"SELECT * FROM edge WHERE src_id IN ({ph}) AND dst_id IN ({ph})"
    edges = con.execute(edge_sql, ids_l + ids_l).fetchall()

    # optional batch filter
    if batch:
        keep = {r["edge_id"] for r in con.execute(
            "SELECT edge_id FROM edge_batch WHERE batch=?", (batch,))}
        edges = [e for e in edges if e["id"] in keep]

    used = set()
    out_edges = []
    for e in edges:
        prov = con.execute(
            "SELECT script, sql_file, line FROM provenance WHERE edge_id=?",
            (e["id"],)).fetchall()
        batches = [b["batch"] for b in con.execute(
            "SELECT batch FROM edge_batch WHERE edge_id=?", (e["id"],))]
        out_edges.append({
            "src": e["src_id"], "dst": e["dst_id"], "type": e["type"],
            "load_mode": e["load_mode"] or "unknown",
            "provenance": [{"loc": (p["sql_file"] or p["script"] or "?"),
                            "line": p["line"]} for p in prov],
            "batches": batches,
        })
        used.add(e["src_id"]); used.add(e["dst_id"])
    used.add(target)

    nrows = con.execute(
        f"SELECT id,name,engine,kind FROM node WHERE id IN ({','.join('?'*len(used))})",
        list(used)).fetchall()
    nodes = [{"id": r["id"], "name": r["name"], "engine": r["engine"],
              "kind": r["kind"], "is_target": r["id"] == target} for r in nrows]
    return {"nodes": nodes, "edges": out_edges,
            "meta": {"target": target, "direction": direction, "depth": depth,
                     "batch": batch, "node_count": len(nodes),
                     "edge_count": len(out_edges)}}


def batch_list_scripts(con) -> list[dict]:
    """Batches that have an execution DAG (from batch_scope)."""
    rows = con.execute(
        "SELECT batch, COUNT(DISTINCT caller)+COUNT(DISTINCT callee) FROM exec_edge "
        "GROUP BY batch ORDER BY batch").fetchall()
    return [{"batch": r[0]} for r in rows]


def batch_scripts(con, batch: str) -> dict:
    """Execution DAG for one batch: script/sql nodes, calls/runs_sql edges, and
    the tables each SQL writes/reads (joined via provenance)."""
    edges = con.execute(
        "SELECT caller, callee, kind, ord FROM exec_edge WHERE batch=? ORDER BY ord",
        (batch,)).fetchall()
    if not edges:
        return {"error": f"no execution DAG for batch {batch}"}
    paths = set()
    for e in edges:
        paths.add(e["caller"]); paths.add(e["callee"])
    nrows = con.execute(
        f"SELECT path, kind, engine FROM exec_node WHERE path IN ({','.join('?'*len(paths))})",
        list(paths)).fetchall()
    kind_of = {r["path"]: (r["kind"], r["engine"]) for r in nrows}

    # tables each SQL touches, via provenance.sql_file -> edge -> node
    sql_tables = {}
    for p in [x for x in paths if x.endswith(".sql")]:
        writes, reads = [], []
        for r in con.execute(
            """SELECT DISTINCT e.type, COALESCE(e.load_mode,'unknown') lm,
                      s.name src, d.name dst
               FROM provenance pr JOIN edge e ON e.id = pr.edge_id
               JOIN node s ON s.id = e.src_id JOIN node d ON d.id = e.dst_id
               WHERE pr.sql_file = ?""", (p,)):
            writes.append({"table": r["dst"], "type": r["type"], "load_mode": r["lm"]})
            reads.append(r["src"])
        sql_tables[p] = {"writes": _dedup(writes, "table"), "reads": sorted(set(reads))}

    nodes = [{"id": p, "label": p.split("/")[-1], "path": p,
              "kind": kind_of.get(p, ("shell", None))[0],
              "engine": kind_of.get(p, ("shell", None))[1]} for p in paths]
    out_edges = [{"src": e["caller"], "dst": e["callee"], "kind": e["kind"],
                  "ord": e["ord"]} for e in edges]

    # execution-order ("flow") edges: chain each parent's non-source children
    # (real calls + sql runs) in call order -> "runs before" relationships
    children = {}
    for e in edges:
        if e["kind"] in ("calls", "runs_sql"):
            children.setdefault(e["caller"], []).append((e["ord"], e["callee"]))
    seq = []
    for caller, kids in children.items():
        ordered = [c for _, c in sorted(kids)]
        # de-dup consecutive repeats while preserving order
        dedup = [c for i, c in enumerate(ordered) if i == 0 or c != ordered[i - 1]]
        for i in range(len(dedup) - 1):
            seq.append({"src": dedup[i], "dst": dedup[i + 1], "kind": "seq",
                        "parent": caller, "step": i + 1})

    return {"nodes": nodes, "edges": out_edges, "seq": seq, "sql_tables": sql_tables,
            "meta": {"batch": batch,
                     "script_count": sum(1 for p in paths if p.endswith(".sh")),
                     "sql_count": sum(1 for p in paths if p.endswith(".sql")),
                     "edge_count": len(out_edges), "seq_count": len(seq)}}


def _dedup(rows, key):
    seen, out = set(), []
    for r in rows:
        if r[key] not in seen:
            seen.add(r[key]); out.append(r)
    return out


def staleness(con, repo: Path) -> dict:
    """Compare stored script hashes against current on-disk files."""
    changed = []
    for r in con.execute("SELECT path, content_hash FROM script"):
        f = repo / r["path"]
        if not f.exists():
            if r["content_hash"] is not None:
                changed.append({"path": r["path"], "reason": "deleted"})
            continue
        h = hashlib.sha256(f.read_bytes()).hexdigest()[:16]
        if h != r["content_hash"]:
            changed.append({"path": r["path"], "reason": "modified"})
    return {"stale": bool(changed), "changed_scripts": changed}
