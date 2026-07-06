#!/usr/bin/env python3
"""
Diff two lineage graphs — the data-impact report for a PR.

Usage:
  python3 lineage/diff.py <old_graph.json> <new_graph.json> [--markdown]

Typical CI use (PR branch vs main):
  git show origin/main:lineage/graph.json > /tmp/main_graph.json
  python3 lineage/extract.py
  python3 lineage/diff.py /tmp/main_graph.json lineage/graph.json --markdown

Exit code: 0 = no lineage change, 2 = lineage changed (so CI can decide
to post a comment / require review).
"""
import json
import sys
from collections import defaultdict


def key(e):
    return (e["src"], e["dst"], e["type"])


def load(path):
    with open(path) as f:
        return json.load(f)


def main():
    md = "--markdown" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 2:
        sys.exit(__doc__)
    old, new = load(args[0]), load(args[1])

    old_nodes = {n["id"] for n in old["nodes"]}
    new_nodes = {n["id"] for n in new["nodes"]}
    old_edges = {key(e): e for e in old["edges"]}
    new_edges = {key(e): e for e in new["edges"]}

    added_n = sorted(new_nodes - old_nodes)
    removed_n = sorted(old_nodes - new_nodes)
    added_e = [new_edges[k] for k in sorted(new_edges.keys() - old_edges.keys())]
    removed_e = [old_edges[k] for k in sorted(old_edges.keys() - new_edges.keys())]

    changed = bool(added_n or removed_n or added_e or removed_e)

    def prov(e):
        p = (e.get("provenance") or [{}])[0]
        s = p.get("sql_file") or p.get("script") or ""
        return f"{s}:{p['line']}" if p.get("line") and s else s

    if md:
        print("## Lineage impact of this PR\n")
        if not changed:
            print("No table-level lineage changes.")
        if added_n:
            print(f"**New nodes ({len(added_n)}):** " +
                  ", ".join(f"`{n}`" for n in added_n[:30]))
        if removed_n:
            print(f"\n**Removed nodes ({len(removed_n)}):** " +
                  ", ".join(f"`{n}`" for n in removed_n[:30]))
        if added_e:
            print(f"\n**New edges ({len(added_e)}):**\n")
            for e in added_e[:40]:
                print(f"- `{e['src']}` → `{e['dst']}` ({e['type']}, {prov(e)})")
        if removed_e:
            print(f"\n**Removed edges ({len(removed_e)}):**\n")
            for e in removed_e[:40]:
                print(f"- `{e['src']}` → `{e['dst']}` ({e['type']}, {prov(e)})")
        if changed:
            # who is downstream of the touched nodes -> reviewers care
            touched = {e["dst"] for e in added_e} | {e["dst"] for e in removed_e}
            down = defaultdict(list)
            adj = defaultdict(list)
            for e in new["edges"]:
                adj[e["src"]].append(e["dst"])
            seen = set(touched)
            frontier = list(touched)
            while frontier:
                cur = frontier.pop()
                for nxt in adj[cur]:
                    if nxt not in seen:
                        seen.add(nxt)
                        frontier.append(nxt)
            indirect = sorted(seen - touched)
            if indirect:
                print(f"\n**Transitively affected ({len(indirect)}):** " +
                      ", ".join(f"`{n}`" for n in indirect[:30]) +
                      (" …" if len(indirect) > 30 else ""))
    else:
        print(f"nodes: +{len(added_n)} -{len(removed_n)}   "
              f"edges: +{len(added_e)} -{len(removed_e)}")
        for e in added_e[:40]:
            print(f"  + {e['src']} -> {e['dst']} ({e['type']}, {prov(e)})")
        for e in removed_e[:40]:
            print(f"  - {e['src']} -> {e['dst']} ({e['type']}, {prov(e)})")

    sys.exit(2 if changed else 0)


if __name__ == "__main__":
    main()
