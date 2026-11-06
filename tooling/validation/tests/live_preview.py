"""Live preview of a QA import before applying it: catalog + import proposals (in memory) -> engine -> QA CH.

  python3 tests/live_preview.py req.json --pivot P [--pivot P2] [--screen '{"P": {"row_periods": "ty,ly"}}']
         [--populations rules.json] [--sources sources.json] [--out result.json]
Prints status, warnings and totals; --out keeps the full result (rows too). Nothing is written to the catalog.
"""
import argparse, json, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import validate as V
from core import spec as SP, qa_import as QI


def preview_spec(client, pivots, screens=None, populations=None, sources=None):
    base = SP.load(QI.HUB / "customers" / client.upper() / "spec")
    for r in sources or []:                                # draft sources (e.g. plan snapshots before they are applied)
        base["sources"][r["source_id"]] = {"status": "draft", "version": "1", "description": "", **r}
    for r in populations or []:                            # draft rules / screens first, so the translator sees them
        base["populations"] = [x for x in base["populations"]
                               if (x["population_id"], x["rule_id"]) != (r["population_id"], r["rule_id"])]
        base["populations"].append({"status": "draft", "version": "1", "notes": "", **r})
    late = {}
    for p, over in (screens or {}).items():
        if p not in base["screens"] and "population_id" not in over:
            late[p] = over                                 # settings on top of the import's proposed screen
            continue
        base["screens"][p] = {"pivot": p, "time_mode": "history", "split_by_class": "yes", "status": "draft",
                              "version": "1", **base["screens"].get(p, {}), **over}
    rep = QI.translate(client, pivots, base)
    spec = {k: (dict(v) if isinstance(v, dict) else list(v)) for k, v in base.items()}
    for m in rep["measures"]:
        if m["status"] == "new":
            spec["measures"][m["id"]] = {"measure_id": m["id"], "label": m["id"], "source_id": m["source_id"],
                                         "expr": m["expr"], "agg": m["agg"], "filter": m["filter"],
                                         "time_window": m["time_window"], "location_set": m["location_set"],
                                         "rollup": m["rollup"], "status": "draft", "version": "1"}
    for m in rep["metrics"]:
        if m["status"] == "new":
            spec["metrics"][m["id"]] = {"metric_id": m["id"], "label": m["id"], "type": m["type"], "expr": m["expr"],
                                        "denominator": m["denominator"], "round": m["round"], "status": "draft",
                                        "version": "1"}
    for s in rep["screens"]:
        if s["status"] == "new" and s.get("population") and \
                not any(r["population_id"] == s["population_id"] for r in spec["populations"]):
            spec["populations"] += [dict(r, status="draft", version="1") for r in s["population"]]
        if s["status"] == "new":
            spec["screens"][s["pivot"]] = {"pivot": s["pivot"], "population_id": s["population_id"],
                                           "time_mode": s["time_mode"], "split_by_class": s["split_by_class"], "item_grain": s.get("item_grain", "stylecolor"),
                                           "status": "draft", "version": "1"}
    for p, over in late.items():
        if p in spec["screens"]:
            spec["screens"][p] = {**spec["screens"][p], **over}
    binds = {(b["pivot"], b["viewdefn"], b["data_index"]): b for b in spec["bindings"]}
    for b in rep["bindings"]:
        if b["status"] in ("new", "unbound"):
            binds[(b["pivot"], b["viewdefn"], b["data_index"])] = {
                "pivot": b["pivot"], "viewdefn": b["viewdefn"], "data_index": b["data_index"], "label": b["label"],
                "metric_id": b["metric_id"], "period": b["period"],
                "rollup_formula": b["rollup_formula"] or (b.get("catalog") or {}).get("rollup_formula", ""),
                "status": "draft", "version": "1"}
    spec["bindings"] = list(binds.values())
    return spec, rep


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("request")
    ap.add_argument("--pivot", action="append", required=True)
    ap.add_argument("--screen", default="{}")
    ap.add_argument("--populations", help="json file: population rules to add (preview only)")
    ap.add_argument("--sources", help="json file: sources to add (preview only)")
    ap.add_argument("--out")
    a = ap.parse_args()
    raw = json.load(open(a.request))
    spec, _ = preview_spec(raw.get("client", "TRD"), a.pivot, json.loads(a.screen),
                           json.load(open(a.populations)) if a.populations else None,
                           json.load(open(a.sources)) if a.sources else None)
    SP.load = lambda *x, **k: spec
    res = V.validate(raw, V.context(raw.get("client", "TRD")), with_rows=bool(a.out))
    if a.out:
        json.dump(res, open(a.out, "w"), default=str)
    print(res["status"], res.get("error") or "", res.get("timing_ms"))
    print("warnings:", res["warnings"][:6])
    for k, v in sorted(res.get("totals", {}).items()):
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
