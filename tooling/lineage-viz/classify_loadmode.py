#!/usr/bin/env python3
"""
Phase 3 — load-mode classification (full vs incremental).

Enriches each edge in lineage.db with `load_mode`, using idioms calibrated to
the TRD batch (see proposal §5 / Appendix A). This is a heuristic pass; a
Phase-3 spot-check on marquee tables is recommended.

    python3 classify_loadmode.py --db <lineage.db> --repo <etl-trd-batch>

Verdicts:
  full        truncate/drop+recreate of the target, or CREATE TABLE AS
  incremental ALTER … DELETE mutation, ReplacingMergeTree target, MERGE/UPDATE,
              or plain append INSERT
  view        CREATE VIEW (a definition, not a load)
  file_move   export / \\copy / inbound file load (cross-DB hop, not a table load)
  unknown     no provenance SQL resolved (e.g. dynamic SQL, §5.1)
"""
from __future__ import annotations

import argparse
import re
import sqlite3
from functools import lru_cache
from pathlib import Path

FILE_TYPES = {"export", "load", "inbound_load", "copy_from", "copy_to", "into_outfile"}


@lru_cache(maxsize=4096)
def read_sql(repo_str: str, rel: str) -> str:
    f = Path(repo_str) / rel
    try:
        return f.read_text(errors="ignore").lower() if f.exists() else ""
    except OSError:
        return ""


def build_engine_map(repo: Path) -> dict:
    """table name -> engine string, scanned from CREATE TABLE ... ENGINE=X."""
    eng = {}
    rx = re.compile(
        r"create\s+table\s+(?:if\s+not\s+exists\s+)?[\"`]?([\w.]+)[\"`]?.*?engine\s*=\s*([a-z]+)",
        re.I | re.S,
    )
    for p in repo.rglob("*.sql"):
        if "deprecated" in str(p).lower():
            continue
        try:
            txt = p.read_text(errors="ignore")
        except OSError:
            continue
        for m in rx.finditer(txt):
            tbl = m.group(1).split(".")[-1].lower()
            eng.setdefault(tbl, m.group(2).lower())
    return eng


def classify(edge_type, dst_name, prov_files, repo_str, engine_map) -> str:
    if edge_type in FILE_TYPES:
        return "file_move"
    if edge_type == "create_view":
        return "view"
    if edge_type == "create_table_as":
        return "full"
    if edge_type in ("update", "merge"):
        return "incremental"

    # insert / regex_dml — inspect the producing SQL around the target
    dst = dst_name.lower()
    blob = " ".join(read_sql(repo_str, f) for f in prov_files if f)
    if blob:
        if re.search(rf"truncate\s+table\s+[\"`]?{re.escape(dst)}\b", blob) or \
           re.search(rf"drop\s+table\s+(?:if\s+exists\s+)?[\"`]?{re.escape(dst)}\b", blob):
            return "full"
        if re.search(rf"alter\s+table\s+[\"`]?{re.escape(dst)}[\"`]?\s+delete", blob):
            return "incremental"
    if "replacing" in engine_map.get(dst, ""):   # ReplacingMergeTree = upsert/dedup
        return "incremental"
    if blob:
        return "incremental"                     # append insert, no full-reload signal
    return "unknown"                             # no SQL resolved (dynamic, §5.1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True, type=Path)
    ap.add_argument("--repo", required=True, type=Path)
    a = ap.parse_args()

    engine_map = build_engine_map(a.repo)
    con = sqlite3.connect(a.db)
    con.row_factory = sqlite3.Row
    repo_str = str(a.repo)

    rows = con.execute(
        "SELECT e.id, e.type, n.name AS dst_name FROM edge e JOIN node n ON n.id = e.dst_id"
    ).fetchall()
    counts = {}
    for r in rows:
        prov = [p[0] for p in con.execute(
            "SELECT sql_file FROM provenance WHERE edge_id=? AND sql_file IS NOT NULL",
            (r["id"],)).fetchall()]
        mode = classify(r["type"], r["dst_name"], prov, repo_str, engine_map)
        con.execute("UPDATE edge SET load_mode=? WHERE id=?", (mode, r["id"]))
        counts[mode] = counts.get(mode, 0) + 1
    con.commit()
    con.close()
    print(f"Classified {len(rows)} edges (engines mapped: {len(engine_map)} tables)")
    for k in sorted(counts):
        print(f"  {k:11}: {counts[k]}")


if __name__ == "__main__":
    main()
