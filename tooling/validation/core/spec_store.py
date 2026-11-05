"""
Spec store: read / upsert / approve / retire rows in customers/<CLIENT>/spec/*.csv.

Every row carries status (draft | approved | retired), version, approved_by, approved_at.
Any content change bumps the version and returns the row to draft; approval is a separate
act. Every write appends to changelog.csv (who, when, before -> after). CSV keeps it
reviewable in git today; the same API can sit on a DB table later without UI changes.
"""
import csv, datetime, json
from pathlib import Path

KEYS = {"sources": ["source_id"], "measures": ["measure_id"], "metrics": ["metric_id"],
        "populations": ["population_id", "rule_id"], "screens": ["pivot"],
        "bindings": ["pivot", "viewdefn", "data_index"]}
META = ["status", "version", "approved_by", "approved_at"]
CONTENT_SKIP = set(META) | {"notes"}


class SpecStore:
    def __init__(self, spec_dir):
        self.dir = Path(spec_dir)

    def path(self, file):
        if file not in KEYS:
            raise ValueError(f"unknown spec file {file}")
        return self.dir / f"{file}.csv"

    def read(self, file):
        p = self.path(file)
        if not p.exists():
            return [], []
        with open(p, newline="") as f:
            r = csv.DictReader(f)
            return list(r.fieldnames or []), list(r)

    def _write(self, file, cols, rows):
        tmp = self.path(file).with_suffix(".csv.tmp")
        with open(tmp, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
            w.writeheader()
            w.writerows(rows)
        tmp.replace(self.path(file))

    def key(self, file, row):
        return "|".join(str(row.get(k, "")) for k in KEYS[file])

    def _log(self, user, file, key, action, version, before, after):
        p = self.dir / "changelog.csv"
        new = not p.exists()
        with open(p, "a", newline="") as f:
            w = csv.writer(f)
            if new:
                w.writerow(["ts", "user", "file", "key", "action", "version", "before", "after"])
            w.writerow([datetime.datetime.now().isoformat(timespec="seconds"), user, file, key, action,
                        version, json.dumps(before or {}, sort_keys=True), json.dumps(after or {}, sort_keys=True)])

    def upsert(self, file, row, user):
        """add or edit; content change -> version+1, status draft. -> saved row"""
        cols, rows = self.read(file)
        for c in list(row):
            if c not in cols:
                cols.append(c)
        for c in META:
            if c not in cols:
                cols.append(c)
        k = self.key(file, row)
        if any(not str(row.get(x, "")).strip() for x in KEYS[file]):
            raise ValueError(f"{file}: {', '.join(KEYS[file])} required")
        cur = next((r for r in rows if self.key(file, r) == k), None)
        new = {c: str(row.get(c, cur.get(c, "") if cur else "")) for c in cols}
        if cur is None:
            new.update(status="draft", version="1", approved_by="", approved_at="")
            rows.append(new)
            action = "add"
        else:
            changed = {c for c in cols if c not in CONTENT_SKIP and str(cur.get(c, "")) != new[c]}
            if not changed and cur.get("notes", "") == new.get("notes", ""):
                return cur
            if changed:
                new.update(status="draft", version=str(int(cur.get("version") or 0) + 1),
                           approved_by="", approved_at="")
            else:
                new.update({m: cur.get(m, "") for m in META})
            rows[rows.index(cur)] = new
            action = "edit"
        self._write(file, cols, rows)
        self._log(user, file, k, action, new["version"], cur, new)
        return new

    def set_status(self, file, keyvals, status, user):
        cols, rows = self.read(file)
        k = self.key(file, keyvals)
        cur = next((r for r in rows if self.key(file, r) == k), None)
        if cur is None:
            raise ValueError(f"{file}: {k} not found")
        before = dict(cur)
        cur["status"] = status
        if status == "approved":
            cur["approved_by"] = user
            cur["approved_at"] = datetime.date.today().isoformat()
        self._write(file, cols, rows)
        self._log(user, file, k, status, cur.get("version", ""), before, cur)
        return cur

    def changelog(self, limit=200):
        p = self.dir / "changelog.csv"
        if not p.exists():
            return []
        with open(p, newline="") as f:
            rows = list(csv.DictReader(f))
        return rows[-limit:][::-1]
