#!/usr/bin/env python3
"""
Parse a pivot3 listData request into a structured SCOPE.

The UI loads pivot data via:
  GET /asst/api/pivot3/listData?aggBy=<levels>&appName=Assortment
      &defnId=<pivot>&flowStatus=<v>&topMembers=<member,...>

The request IS the scope spec. We copy these INPUTS (grain, filters) so the
composed validation query matches the UI exactly — while computing the metric
logic independently (that keeps it a real test, not a replay).

Usage:
  python3 listdata_parse.py "<full URL or query string>"
  python3 listdata_parse.py --file <url.txt>
  # or pipe a log line containing a listData URL:
  grep listData log.txt | python3 listdata_parse.py --stdin
"""
import argparse, json, re, sys
from urllib.parse import urlparse, parse_qs, unquote


def parse_aggby(raw):
    """aggBy tokens -> ordered grain. Tokens look like:
       level:stylecolor | level:class:name | attribute:class_name:name
    Returns list of {kind, name, qualifier}."""
    grain = []
    for tok in raw.split(","):
        tok = tok.strip()
        if not tok:
            continue
        parts = tok.split(":")
        kind = parts[0]                      # level | attribute
        name = parts[1] if len(parts) > 1 else None
        qual = parts[2] if len(parts) > 2 else None   # e.g. 'name'
        grain.append({"kind": kind, "name": name, "qualifier": qual, "raw": tok})
    return grain


def parse(url_or_qs):
    # accept a full URL, a bare query string, or a log line containing one
    m = re.search(r"listData\?([^\s\"'<>]+)", url_or_qs)
    qs = m.group(1) if m else (urlparse(url_or_qs).query or url_or_qs)
    q = parse_qs(qs, keep_blank_values=True)

    def one(k, default=None):
        v = q.get(k, [default])
        return v[0] if v else default

    agg_raw = unquote(one("aggBy", "") or "")
    scope = {
        "defnId": one("defnId"),
        "appName": one("appName"),
        "grain": parse_aggby(agg_raw),
        "grain_raw": agg_raw,
        "flowStatus": one("flowStatus"),          # '' = all, '0' = specific status
        "topMembers": [m for m in (unquote(one("topMembers", "") or "")).split(",") if m],
        "other": {k: v for k, v in q.items()
                  if k not in ("aggBy", "defnId", "appName", "flowStatus", "topMembers")},
    }
    return scope


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("url", nargs="?", default="")
    ap.add_argument("--file")
    ap.add_argument("--stdin", action="store_true")
    a = ap.parse_args()
    src = a.url
    if a.file:
        src = open(a.file).read()
    elif a.stdin:
        src = sys.stdin.read()
    if not src.strip():
        ap.error("give a URL, --file, or --stdin")
    print(json.dumps(parse(src), indent=1))


if __name__ == "__main__":
    main()
