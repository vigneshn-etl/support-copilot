"""
Metrics Catalog in UCM (schema dvs), read and written as the dvs_app login.

Same interface as core.spec_store.SpecStore (read / key / upsert / set_status / changelog)
and the same row shape the engine and the Studio already use, so switching the store does
not touch the UI or the composer. Postgres limits dvs_app to the dvs schema; history is
written by trigger, attributed through set_config('dvs.user', ...).

Connection: DVS_DB_HOST / _PORT / _NAME / _USER / _PASSWORD from the environment, else
from ~/.config/dvs/.env (or the file named by DVS_ENV_FILE).
"""
import json, os
from pathlib import Path

ENV_FILE = Path(os.environ.get("DVS_ENV_FILE", Path.home() / ".config" / "dvs" / ".env"))
_ENV_KEYS = ("DVS_DB_HOST", "DVS_DB_PORT", "DVS_DB_NAME", "DVS_DB_USER", "DVS_DB_PASSWORD")

# file (engine/UI name) -> (db table, key columns in row shape)
TABLES = {
    "sources": ("sources", ["source_id"]),
    "measures": ("measures", ["measure_id"]),
    "metrics": ("metrics", ["metric_id"]),
    "populations": ("business_rules", ["population_id", "rule_id"]),
    "screens": ("screens", ["pivot"]),
    "bindings": ("bindings", ["pivot", "viewdefn", "data_index"]),
}
# row-shape name -> db column, where they differ
RENAMES = {
    "sources": {"table": "table_name"},
    "measures": {"agg": "agg_kind", "filter": "predicate"},
    "metrics": {"type": "metric_type", "round": "round_digits"},
}
META = ("status", "version", "approved_by", "approved_at")
SKIP_CONTENT = set(META) | {"notes", "origin", "ucm_ref", "qa_ref", "created_by", "created_at", "updated_by",
                            "updated_at"}
# row shape columns per file (what read() returns, in this order)
COLUMNS = {
    "sources": ["source_id", "table", "item_key", "location_key", "time_key", "level_filters", "description",
                "row_filter", "latest_by"],
    "measures": ["measure_id", "label", "source_id", "expr", "agg", "filter", "time_window",
                 "location_set", "rollup"],
    "metrics": ["metric_id", "label", "type", "expr", "denominator", "round", "requirement"],
    "populations": ["population_id", "step", "rule_id", "kind", "source_id", "time_window",
                    "condition", "row_filter", "applies_when", "group_level"],
    "screens": ["pivot", "population_id", "time_mode", "split_by_class", "row_periods", "row_filter", "item_grain"],
    "bindings": ["pivot", "viewdefn", "data_index", "label", "metric_id", "period", "rollup_formula"],
}
TAIL = ["status", "version", "approved_by", "approved_at", "origin", "notes"]


def settings():
    """connection settings, or None when the DVS database is not configured."""
    vals = {k: os.environ.get(k) for k in _ENV_KEYS}
    if not all(vals.values()) and ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                k, v = k.strip(), v.strip().strip('"').strip("'")
                if k in vals and not vals[k]:
                    vals[k] = v
    return vals if all(vals.values()) else None


def configured():
    return settings() is not None


def use_db():
    """DVS_STORE=db|csv forces a store; by default the DB when it is configured."""
    mode = os.environ.get("DVS_STORE", "").lower()
    return mode == "db" or (mode != "csv" and configured())


def tenant_for(spec_dir):
    """customers/<CLIENT>/spec -> client code as the tenant (trd)."""
    return Path(spec_dir).resolve().parent.name.lower()


def connect():
    import psycopg
    from psycopg.rows import dict_row
    s = settings()
    if not s:
        raise RuntimeError(f"DVS database not configured: set {', '.join(_ENV_KEYS)} or create {ENV_FILE}")
    return psycopg.connect(host=s["DVS_DB_HOST"], port=int(s["DVS_DB_PORT"]), dbname=s["DVS_DB_NAME"],
                           user=s["DVS_DB_USER"], password=s["DVS_DB_PASSWORD"], sslmode="require",
                           connect_timeout=10, row_factory=dict_row,
                           options="-c search_path=dvs -c statement_timeout=60000")


# ---------------------------------------------------------------- row shape <-> db
def to_row(file, rec):
    """db record -> the row shape the engine and UI use (all strings, like the CSV)."""
    ren = {v: k for k, v in RENAMES.get(file, {}).items()}
    out = {}
    for col, val in rec.items():
        name = ren.get(col, col)
        if val is None:
            out[name] = ""
        elif isinstance(val, bool):
            out[name] = "yes" if val else "no"
        elif isinstance(val, list):
            out[name] = ",".join(val)
        elif isinstance(val, dict):
            out[name] = json.dumps(val, sort_keys=True)
        elif hasattr(val, "isoformat"):
            out[name] = val.isoformat()
        else:
            out[name] = str(val)
    if file == "bindings" and rec.get("kind") == "attribute":
        out["status"] = "n/a"                           # display field, not a metric column
    return out


def to_db(file, row):
    """row shape -> db column values (only the content columns present in row)."""
    ren = RENAMES.get(file, {})
    out = {}
    for name in COLUMNS[file] + ["notes"]:
        if name not in row:
            continue
        v = row[name]
        v = v.strip() if isinstance(v, str) else v
        col = ren.get(name, name)
        if col == "level_filters":
            v = [x.strip() for x in (v or "").split(",") if x.strip()]
        elif col == "split_by_class":
            v = str(v).lower() in ("yes", "true", "1")
        elif col == "period":
            v = (v or "ty").lower()
        elif col in ("round_digits", "step"):
            v = int(v) if str(v).strip() else None
        elif v == "":
            v = None
        out[col] = v
    if file == "bindings":
        out["kind"] = "attribute" if row.get("status") == "n/a" else "metric"
    if row.get("qa_ref"):                               # provenance of a qa_import row (migration 003)
        from psycopg.types.json import Jsonb
        ref = row["qa_ref"]
        out["qa_ref"] = Jsonb(json.loads(ref) if isinstance(ref, str) else ref)
    return out


class CatalogDB:
    """drop-in for SpecStore, scoped to one client (tenant) and environment."""

    def __init__(self, tenant, environment="qa"):
        self.tenant, self.env = tenant.lower(), environment

    def key(self, file, row):
        return "|".join(str(row.get(k, "")) for k in TABLES[file][1])

    def _where_key(self, file, row):
        table, keys = TABLES[file]
        cols = [RENAMES.get(file, {}).get(k, k) for k in keys]
        return " AND ".join(f"{c} = %s" for c in cols), [row.get(k) for k in keys]

    def read(self, file):
        table, keys = TABLES[file]
        with connect() as c:
            recs = c.execute(f"SELECT * FROM {table} WHERE tenant = %s AND environment = %s "
                             f"ORDER BY {', '.join(RENAMES.get(file, {}).get(k, k) for k in keys)}",
                             (self.tenant, self.env)).fetchall()
        rows = [to_row(file, r) for r in recs]
        return COLUMNS[file] + TAIL, rows

    def upsert(self, file, row, user):
        """add or edit; a content change -> version + 1, back to draft. -> saved row"""
        table, keys = TABLES[file]
        if any(not str(row.get(k, "")).strip() for k in keys):
            raise ValueError(f"{file}: {', '.join(keys)} required")
        vals = to_db(file, row)
        where, params = self._where_key(file, row)
        with connect() as c:
            c.execute("SELECT set_config('dvs.user', %s, true)", (user or "unknown",))
            cur = c.execute(f"SELECT * FROM {table} WHERE tenant = %s AND environment = %s AND {where} "
                            "FOR UPDATE", [self.tenant, self.env] + params).fetchone()
            if cur is None:
                cols = ["tenant", "environment"] + list(vals) + ["status", "version", "origin"]
                args = [self.tenant, self.env] + list(vals.values()) + ["draft", 1, row.get("origin") or "dvs_ui"]
                rec = c.execute(f"INSERT INTO {table} ({', '.join(cols)}) VALUES "
                                f"({', '.join(['%s'] * len(cols))}) RETURNING *", args).fetchone()
                return to_row(file, rec)
            changed = [k for k, v in vals.items() if k not in SKIP_CONTENT and cur.get(k) != v]
            notes_changed = "notes" in vals and cur.get("notes") != vals["notes"]
            ref_changed = "qa_ref" in vals and cur.get("qa_ref") != vals["qa_ref"].obj
            if not changed and not notes_changed and not ref_changed:
                return to_row(file, cur)
            sets = {k: vals[k] for k in changed}
            if notes_changed:
                sets["notes"] = vals["notes"]
            if ref_changed:
                sets["qa_ref"] = vals["qa_ref"]
            if changed:
                sets.update(status="draft", version=cur["version"] + 1, approved_by=None, approved_at=None)
            if file == "bindings" and "kind" in vals:
                sets["kind"] = vals["kind"]
            rec = c.execute(f"UPDATE {table} SET {', '.join(f'{k} = %s' for k in sets)} "
                            f"WHERE tenant = %s AND environment = %s AND {where} RETURNING *",
                            list(sets.values()) + [self.tenant, self.env] + params).fetchone()
            return to_row(file, rec)

    def set_status(self, file, keyvals, status, user):
        table, _ = TABLES[file]
        where, params = self._where_key(file, keyvals)
        extra = ", approved_by = %s, approved_at = now()" if status == "approved" else ""
        with connect() as c:
            c.execute("SELECT set_config('dvs.user', %s, true)", (user or "unknown",))
            rec = c.execute(f"UPDATE {table} SET status = %s{extra} WHERE tenant = %s AND environment = %s "
                            f"AND {where} RETURNING *",
                            [status] + ([user] if extra else []) + [self.tenant, self.env] + params).fetchone()
        if rec is None:
            raise ValueError(f"{file}: {self.key(file, keyvals)} not found")
        return to_row(file, rec)

    def changelog(self, limit=200):
        back = {v[0]: k for k, v in TABLES.items()}
        with connect() as c:
            recs = c.execute("SELECT changed_at, changed_by, table_name, row_key, action, version, status "
                             "FROM row_history WHERE tenant = %s AND environment = %s "
                             "ORDER BY id DESC LIMIT %s", (self.tenant, self.env, limit)).fetchall()
        out = []
        for r in recs:
            action = r["action"]
            if action == "update" and r["status"] in ("approved", "retired"):
                action = r["status"]
            out.append({"ts": r["changed_at"].isoformat(timespec="seconds"), "user": r["changed_by"],
                        "file": back.get(r["table_name"], r["table_name"]),
                        "key": "|".join(str((r["row_key"] or {}).get(k, ""))
                                        for k in TABLES.get(back.get(r["table_name"], ""), ("", []))[1]),
                        "action": action, "version": str(r["version"] or "")})
        return out


def load_spec(tenant, environment="qa", include_drafts=True):
    """the same structure core.spec.load() returns, from the database."""
    db = CatalogDB(tenant, environment)
    keyed = {"sources": "source_id", "measures": "measure_id", "metrics": "metric_id", "screens": "pivot"}
    out = {}
    for file in TABLES:
        _, rows = db.read(file)
        rows = [r for r in rows if r.get("status") != "retired"
                and (include_drafts or r.get("status") in ("approved", "n/a"))]
        if file == "populations":
            rows.sort(key=lambda r: (r["population_id"], int(r["step"] or 0)))
        out[file] = {r[keyed[file]]: r for r in rows} if file in keyed else rows
    return out
