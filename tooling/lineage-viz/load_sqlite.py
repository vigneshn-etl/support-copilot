#!/usr/bin/env python3
"""
Phase 0 — SQLite loader for the ETL Lineage Visualization Tool.

Reads the existing static-extractor output (`graph.json`) and materializes it
into a queryable SQLite graph (`lineage.db`) following the schema in
ETL-Lineage-Viz-Tool-Proposal.md (§3.1). Idempotent: safe to re-run.

Usage:
    python3 load_sqlite.py --graph <path/to/graph.json> \
                           --repo  <path/to/etl-trd-batch> \
                           --out   <path/to/lineage.db>

`--repo` is optional; when given, script content hashes are computed for
staleness detection (§6). Load-mode (full/incremental) is left NULL here — it is
populated in Phase 3.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sqlite3
import time
from functools import lru_cache
from pathlib import Path

SCHEMA = """
-- WAL is preferable on real local disk (concurrent reads); it is omitted here
-- because WAL needs shared memory that some network/FUSE mounts don't support.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS node (
  id      TEXT PRIMARY KEY,
  name    TEXT NOT NULL,
  engine  TEXT NOT NULL,
  kind    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS edge (
  id         INTEGER PRIMARY KEY,
  src_id     TEXT NOT NULL REFERENCES node(id),
  dst_id     TEXT NOT NULL REFERENCES node(id),
  type       TEXT NOT NULL,
  load_mode  TEXT,
  UNIQUE (src_id, dst_id, type)
);

CREATE TABLE IF NOT EXISTS provenance (
  edge_id   INTEGER NOT NULL REFERENCES edge(id),
  script    TEXT,
  sql_file  TEXT,
  line      INTEGER
);

CREATE TABLE IF NOT EXISTS edge_batch (
  edge_id  INTEGER NOT NULL REFERENCES edge(id),
  batch    TEXT NOT NULL,
  PRIMARY KEY (edge_id, batch)
);

CREATE TABLE IF NOT EXISTS script (
  path          TEXT PRIMARY KEY,
  kind          TEXT NOT NULL,
  engine        TEXT,
  content_hash  TEXT
);

CREATE TABLE IF NOT EXISTS script_call (
  caller      TEXT NOT NULL,
  callee      TEXT NOT NULL,
  call_order  INTEGER,
  PRIMARY KEY (caller, callee)
);

CREATE TABLE IF NOT EXISTS graph_build (
  id            INTEGER PRIMARY KEY CHECK (id = 1),
  built_at      TEXT,
  coverage_pct  REAL,
  repo_commit   TEXT,
  source_graph  TEXT
);

CREATE INDEX IF NOT EXISTS idx_edge_dst  ON edge(dst_id);
CREATE INDEX IF NOT EXISTS idx_edge_src  ON edge(src_id);
CREATE INDEX IF NOT EXISTS idx_prov_edge ON provenance(edge_id);
CREATE INDEX IF NOT EXISTS idx_ebatch    ON edge_batch(batch);
"""

# engine folder -> sql dialect prefix (for script.engine tagging)
ENGINE_BY_DIR = {"vsql": "vertica", "pgsql": "postgres", "ch": "clickhouse"}


def sql_engine_for(path: str) -> str | None:
    parts = path.split("/")
    return next((ENGINE_BY_DIR[p] for p in parts if p in ENGINE_BY_DIR), None)


def file_hash(repo: Path | None, rel: str) -> str | None:
    if not repo or not rel:
        return None
    f = repo / rel
    if not f.exists() or not f.is_file():
        return None
    return hashlib.sha256(f.read_bytes()).hexdigest()[:16]


@lru_cache(maxsize=4096)
def _read_lines(repo_str: str, rel: str):
    f = Path(repo_str) / rel
    try:
        return f.read_text(errors="ignore").splitlines() if f.exists() else None
    except OSError:
        return None


def resolve_line(repo_str: str, sql_file: str, dst: str, etype: str):
    """Find the real line where `dst` is written in `sql_file`. The upstream
    extractor stores segment-start lines (mostly 1); this recovers the true
    statement line so provenance points at the actual edit site."""
    lines = _read_lines(repo_str, sql_file)
    if not lines:
        return None
    d = re.escape(dst.lower())
    q = r'["`\']?'                      # optional quoting around the identifier
    if etype in ("insert", "inbound_load", "regex_dml"):
        pats = [rf"insert\s+into\s+{q}{d}\b"]
    elif etype == "create_table_as":
        pats = [rf"create\s+(?:local\s+temp(?:orary)?\s+)?table\s+(?:if\s+not\s+exists\s+)?{q}{d}\b"]
    elif etype == "create_view":
        pats = [rf"create\s+(?:or\s+replace\s+)?view\s+{q}{d}\b"]
    elif etype == "update":
        pats = [rf"update\s+{q}{d}\b"]
    elif etype == "merge":
        pats = [rf"merge\s+into\s+{q}{d}\b"]
    else:                                # exports / file targets: match the name
        pats = [rf"\b{d}\b"]
    rx = [re.compile(p, re.I) for p in pats]
    for i, ln in enumerate(lines, 1):
        if any(r.search(ln) for r in rx):
            return i
    # fallback: first mention of the table anywhere
    rd = re.compile(rf"\b{d}\b", re.I)
    for i, ln in enumerate(lines, 1):
        if rd.search(ln):
            return i
    return None


def resolve_provenance_lines(con, repo: Path):
    """Overwrite bogus line=1 provenance with the real write-site line.
    Sets line to NULL when the site can't be located (honest 'unknown')."""
    repo_str = str(repo)
    rows = con.execute(
        """SELECT pr.rowid, pr.sql_file, e.type, n.name
           FROM provenance pr JOIN edge e ON e.id = pr.edge_id
           JOIN node n ON n.id = e.dst_id
           WHERE pr.sql_file IS NOT NULL"""
    ).fetchall()
    fixed = 0
    for rowid, sql_file, etype, dst in rows:
        ln = resolve_line(repo_str, sql_file, dst, etype)
        con.execute("UPDATE provenance SET line=? WHERE rowid=?", (ln, rowid))
        if ln:
            fixed += 1
    return fixed, len(rows)


def load(graph_path: Path, out_path: Path, repo: Path | None):
    g = json.loads(graph_path.read_text())
    con = sqlite3.connect(out_path)
    con.executescript(SCHEMA)
    cur = con.cursor()

    # --- nodes ------------------------------------------------------------
    cur.executemany(
        "INSERT INTO node(id,name,engine,kind) VALUES(?,?,?,?) "
        "ON CONFLICT(id) DO UPDATE SET name=excluded.name, "
        "engine=excluded.engine, kind=excluded.kind",
        [(n["id"], n["name"], n["engine"], n["kind"]) for n in g["nodes"]],
    )

    # --- edges + provenance + batches ------------------------------------
    scripts: dict[str, tuple[str, str | None]] = {}  # path -> (kind, engine)
    for e in g["edges"]:
        cur.execute(
            "INSERT INTO edge(src_id,dst_id,type) VALUES(?,?,?) "
            "ON CONFLICT(src_id,dst_id,type) DO NOTHING",
            (e["src"], e["dst"], e["type"]),
        )
        cur.execute(
            "SELECT id FROM edge WHERE src_id=? AND dst_id=? AND type=?",
            (e["src"], e["dst"], e["type"]),
        )
        edge_id = cur.fetchone()[0]

        # refresh provenance/batches for this edge (idempotent re-run)
        cur.execute("DELETE FROM provenance WHERE edge_id=?", (edge_id,))
        cur.execute("DELETE FROM edge_batch WHERE edge_id=?", (edge_id,))
        for p in e.get("provenance", []):
            cur.execute(
                "INSERT INTO provenance(edge_id,script,sql_file,line) VALUES(?,?,?,?)",
                (edge_id, p.get("script"), p.get("sql_file"), p.get("line")),
            )
            if p.get("sql_file"):
                scripts[p["sql_file"]] = ("sql", sql_engine_for(p["sql_file"]))
            if p.get("script"):
                scripts.setdefault(p["script"], ("shell", None))
        for b in e.get("flows", []):
            cur.execute(
                "INSERT OR IGNORE INTO edge_batch(edge_id,batch) VALUES(?,?)",
                (edge_id, b),
            )

    # --- script_calls (orchestration) ------------------------------------
    for i, c in enumerate(g.get("script_calls", [])):
        cur.execute(
            "INSERT INTO script_call(caller,callee,call_order) VALUES(?,?,?) "
            "ON CONFLICT(caller,callee) DO UPDATE SET call_order=excluded.call_order",
            (c["src"], c["dst"], c.get("line", i)),
        )
        scripts.setdefault(c["src"], ("shell", None))
        scripts.setdefault(c["dst"], ("shell", None))

    # --- scripts (+ content hashes for staleness) ------------------------
    cur.executemany(
        "INSERT INTO script(path,kind,engine,content_hash) VALUES(?,?,?,?) "
        "ON CONFLICT(path) DO UPDATE SET kind=excluded.kind, "
        "engine=excluded.engine, content_hash=excluded.content_hash",
        [(p, k, eng, file_hash(repo, p)) for p, (k, eng) in scripts.items()],
    )

    # --- resolve real provenance line numbers (fix the bogus line=1) ------
    line_fixed = line_total = 0
    if repo:
        line_fixed, line_total = resolve_provenance_lines(cur, repo)

    # --- build metadata ---------------------------------------------------
    meta = g.get("meta", {})
    cur.execute(
        "INSERT INTO graph_build(id,built_at,coverage_pct,repo_commit,source_graph) "
        "VALUES(1,?,?,?,?) ON CONFLICT(id) DO UPDATE SET "
        "built_at=excluded.built_at, coverage_pct=excluded.coverage_pct, "
        "repo_commit=excluded.repo_commit, source_graph=excluded.source_graph",
        (
            time.strftime("%Y-%m-%d %H:%M:%S"),
            None,
            meta.get("repo"),
            str(graph_path),
        ),
    )
    con.commit()

    stats = {
        "nodes": cur.execute("SELECT COUNT(*) FROM node").fetchone()[0],
        "edges": cur.execute("SELECT COUNT(*) FROM edge").fetchone()[0],
        "provenance": cur.execute("SELECT COUNT(*) FROM provenance").fetchone()[0],
        "edge_batch": cur.execute("SELECT COUNT(*) FROM edge_batch").fetchone()[0],
        "scripts": cur.execute("SELECT COUNT(*) FROM script").fetchone()[0],
        "script_calls": cur.execute("SELECT COUNT(*) FROM script_call").fetchone()[0],
        "hashed_scripts": cur.execute(
            "SELECT COUNT(*) FROM script WHERE content_hash IS NOT NULL"
        ).fetchone()[0],
        "lines_resolved": f"{line_fixed}/{line_total}",
    }
    con.close()
    return stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--graph", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--repo", type=Path, default=None)
    args = ap.parse_args()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    stats = load(args.graph, args.out, args.repo)
    print(f"Loaded {args.out}")
    for k, v in stats.items():
        print(f"  {k:14}: {v}")


if __name__ == "__main__":
    main()
