#!/usr/bin/env python3
"""
Flashcards — turn the copilot's captured knowledge into active recall.

Every resolved ticket already writes techno-functional `knowledge_gained` +
a root cause. That IS study material; this drills you on it with spaced
repetition (SM-2-lite) so the understanding sticks in YOUR head, not just the
tool's. The point of the whole learning layer: the copilot solves the ticket
AND keeps you sharp.

Sources scanned:
  tickets/*/state.json        -> knowledge_gained{technical,functional}, root_cause
  knowledge/solutions/*.md    -> the "Knowledge gained" section

Commands:
  flashcards.py build                 # (re)generate the deck from sources
  flashcards.py due [--n 5]           # list cards due today (fronts only)
  flashcards.py show <card_id>        # reveal the back (the answer)
  flashcards.py grade <card_id> <0-5> # SM-2-lite: 0-2 = missed, 3-5 = recalled
  flashcards.py stats                 # deck size, due count, weakest cards

Deck: tooling/learning/deck.json  (portable; commit it or gitignore, your call)
"""
import argparse, datetime, hashlib, json, re, sys
from pathlib import Path

HUB = Path(__file__).resolve().parent.parent.parent
DECK = Path(__file__).resolve().parent / "deck.json"
TODAY = datetime.date.today


def _cid(front):
    return hashlib.sha1(front.encode()).hexdigest()[:8]


def _new_card(front, back, source, tag):
    return {"id": _cid(front), "front": front, "back": back, "source": source,
            "tag": tag, "ease": 2.5, "interval": 0, "reps": 0,
            "due": TODAY().isoformat(), "lapses": 0}


def _mine_states():
    cards = []
    for sj in sorted((HUB / "tickets").glob("*/state.json")):
        try:
            st = json.loads(sj.read_text())
        except Exception:
            continue
        tid = st.get("ticket", sj.parent.name)
        kg = st.get("knowledge_gained", {}) or {}
        if kg.get("technical"):
            cards.append(_new_card(
                f"[{tid}] Technical: what mechanism did this ticket teach?",
                kg["technical"], tid, "technical"))
        if kg.get("functional"):
            cards.append(_new_card(
                f"[{tid}] Functional: what does this mean to a retail planner?",
                kg["functional"], tid, "functional"))
        rc = (st.get("root_cause") or {}).get("statement")
        if rc:
            req = (st.get("requirement") or {}).get("statement", "")
            cards.append(_new_card(
                f"[{tid}] Root cause of: {req[:90]}",
                rc, tid, "root_cause"))
    return cards


def _mine_solutions():
    cards = []
    for md in sorted((HUB / "knowledge" / "solutions").glob("*.md")):
        text = md.read_text()
        tid = md.stem
        m = re.search(r"\*\*Technical:\*\*\s*(.+?)(?:\n\n|\Z)", text, re.S)
        if m:
            cards.append(_new_card(f"[{tid}] Technical mechanism?",
                                   m.group(1).strip(), tid, "technical"))
        m = re.search(r"\*\*Functional:\*\*\s*(.+?)(?:\n\n|\Z)", text, re.S)
        if m:
            cards.append(_new_card(f"[{tid}] Functional / business meaning?",
                                   m.group(1).strip(), tid, "functional"))
    return cards


def build():
    old = {c["id"]: c for c in _load().get("cards", [])}
    fresh = _mine_states() + _mine_solutions()
    merged = {}
    for c in fresh:
        if c["id"] in old:            # keep scheduling progress on existing cards
            merged[c["id"]] = old[c["id"]]
            merged[c["id"]]["back"] = c["back"]   # refresh answer text
        else:
            merged[c["id"]] = c
    deck = {"updated": TODAY().isoformat(), "cards": list(merged.values())}
    DECK.write_text(json.dumps(deck, indent=1))
    print(f"deck: {len(deck['cards'])} cards ({len(fresh)} mined, "
          f"{len(fresh)-len([c for c in fresh if c['id'] in old])} new) -> {DECK.name}")


def _load():
    if DECK.exists():
        return json.loads(DECK.read_text())
    return {"cards": []}


def _save(deck):
    deck["updated"] = TODAY().isoformat()
    DECK.write_text(json.dumps(deck, indent=1))


def _is_due(c):
    return c["due"] <= TODAY().isoformat()


def due(n):
    deck = _load()
    ds = [c for c in deck["cards"] if _is_due(c)]
    ds.sort(key=lambda c: (c["reps"], c["due"]))
    if not ds:
        print("nothing due — deck is warm. `build` to mine new tickets."); return
    print(f"{len(ds)} due (showing {min(n,len(ds))}). Recall the answer, then "
          f"`show <id>` and `grade <id> 0-5`:\n")
    for c in ds[:n]:
        print(f"  {c['id']}  [{c['tag']}]  {c['front']}")


def show(cid):
    deck = _load()
    c = next((x for x in deck["cards"] if x["id"] == cid), None)
    if not c:
        print(f"no card {cid}"); return
    print(f"[{c['tag']}] {c['front']}\n\nANSWER ({c['source']}):\n{c['back']}\n")
    print(f"grade it: flashcards.py grade {cid} <0-5>  (0-2 missed, 3-5 recalled)")


def grade(cid, q):
    """SM-2-lite: q in 0..5. <3 resets interval; >=3 grows it by ease."""
    deck = _load()
    c = next((x for x in deck["cards"] if x["id"] == cid), None)
    if not c:
        print(f"no card {cid}"); return
    q = max(0, min(5, q))
    if q < 3:
        c["interval"] = 1; c["reps"] = 0; c["lapses"] += 1
    else:
        c["reps"] += 1
        c["interval"] = 1 if c["reps"] == 1 else 6 if c["reps"] == 2 else round(c["interval"] * c["ease"])
        c["ease"] = max(1.3, c["ease"] + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
    c["due"] = (TODAY() + datetime.timedelta(days=c["interval"])).isoformat()
    _save(deck)
    print(f"{cid}: {'missed → see again tomorrow' if q<3 else 'got it'}; "
          f"next due {c['due']} (interval {c['interval']}d, ease {c['ease']:.2f})")


def stats():
    deck = _load()
    cards = deck["cards"]
    if not cards:
        print("empty deck — run `build`."); return
    dfmt = sum(1 for c in cards if _is_due(c))
    by_tag = {}
    for c in cards:
        by_tag[c["tag"]] = by_tag.get(c["tag"], 0) + 1
    weak = sorted(cards, key=lambda c: (-c["lapses"], c["reps"]))[:5]
    print(f"{len(cards)} cards | {dfmt} due | by tag: "
          + ", ".join(f"{k}={v}" for k, v in sorted(by_tag.items())))
    if any(c["lapses"] for c in weak):
        print("weakest (most lapses):")
        for c in weak:
            if c["lapses"]:
                print(f"  {c['id']} [{c['tag']}] lapses={c['lapses']} — {c['front']}")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("build")
    d = sub.add_parser("due"); d.add_argument("--n", type=int, default=5)
    s = sub.add_parser("show"); s.add_argument("card_id")
    g = sub.add_parser("grade"); g.add_argument("card_id"); g.add_argument("q", type=int)
    sub.add_parser("stats")
    a = ap.parse_args()
    {"build": lambda: build(),
     "due": lambda: due(a.n),
     "show": lambda: show(a.card_id),
     "grade": lambda: grade(a.card_id, a.q),
     "stats": lambda: stats()}[a.cmd]()


if __name__ == "__main__":
    main()
