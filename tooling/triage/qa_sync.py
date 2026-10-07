#!/usr/bin/env python3
"""
QA config sync: pull a tenant's live QA config from OCI, 3-way diff it against
the ticket branch (edit clone), and — only after explicit approval — push the
merged files to QA's override_configuration/.

Layout (outside any git repo, next to the edit clone):
    <JIRAS>/<SUP-ID>/<repo-name>/          edit clone on branch <SUP-ID>
    <JIRAS>/<SUP-ID>/qa-live/<tenant>/     raw `oci os object sync` mirror
    <JIRAS>/<SUP-ID>/qa-live/<tenant>.manifest.json   name -> etag/md5
    <JIRAS>/<SUP-ID>/qa-sync/<tenant>/     plan.json, report.md, files/, conflicts/
    <JIRAS>/<SUP-ID>/qa-backup/<ts>-<tenant>/   pre-push copies + restore.json

QA effective file = override_configuration/<p> if present, else
configuration/<p>, unless tombstoned in <prefix>.delete.

Per file changed on the branch (working tree vs merge-base with the base branch):
    in-sync    QA already equals branch          -> skip
    clean      QA equals merge-base              -> upload branch file
    new        absent in QA                      -> upload branch file
    merged     QA drifted, no overlap            -> upload 3-way merge
    overlap    QA drifted, overlapping hunks     -> upload merge, --overlap side wins
    tombstoned / deleted-in-branch / binary-conflict -> reported, never pushed

Safety: QA bucket only; push needs --approve <plan_id>; etags re-checked and
uploads use --if-match / --no-overwrite; backups before any write; never deletes.

CLI:
    qa_sync.py targets
    qa_sync.py pull     SUP-4429 --client KW --tenant ann
    qa_sync.py diff     SUP-4429 --client KW --tenant ann [--overlap branch|qa|stop]
    qa_sync.py push     SUP-4429 --client KW --tenant ann --approve <plan_id> [--writeback]
    qa_sync.py rollback SUP-4429 --client KW --tenant ann --backup <dir> [--approve <id>]

--tenant all (pull/diff/push): every tenant of the client (e.g. AEO aeo/aer/tsn/uns
share one repo). diff writes one combined plan_id; push preflights ALL tenants
before uploading to any.
"""
import argparse, base64, difflib, hashlib, json, os, re, shutil, subprocess, sys, tempfile, time
from pathlib import Path

HUB = Path(__file__).resolve().parent.parent.parent
JIRAS = Path(os.environ.get("QA_SYNC_JIRAS_ROOT", "/Users/vigneshn/Desktop/JIRAs"))
QA_BUCKETS = {"internal-qa-config"}
PREFIX_RE = re.compile(r"^[a-z0-9]+/asst/$")
EXCLUDE = (".github/", "lineage/")
PUSHABLE = {"clean", "new", "behind", "merged", "overlap", "replace"}


class QaSyncError(RuntimeError):
    pass


# ---- hashing ----------------------------------------------------------------
def sha256(b):
    return hashlib.sha256(b).hexdigest()


def md5b64(b):
    return base64.b64encode(hashlib.md5(b).digest()).decode()


# ---- target resolution ------------------------------------------------------
def resolve(client, tenant=None):
    f = HUB / "customers" / client / "config_sources.json"
    if not f.exists():
        raise QaSyncError(f"no config_sources.json for {client}")
    cfg = json.loads(f.read_text())
    top_qa = cfg["envs"].get("qa")
    default = cfg.get("default_tenant") or (top_qa["prefix"].split("/")[0] if top_qa else None)
    tenant = tenant or default
    if tenant == default:
        qa, repo = top_qa, cfg.get("config_repo")
    else:
        t = cfg.get("tenants", {}).get(tenant)
        if not t:
            known = [default] + list(cfg.get("tenants", {}))
            raise QaSyncError(f"unknown tenant '{tenant}' for {client}; known: {known}")
        qa, repo = t["envs"].get("qa"), t.get("config_repo", cfg.get("config_repo"))
    if not qa:
        raise QaSyncError(f"no qa env for {client}/{tenant}")
    if qa["bucket"] not in QA_BUCKETS:
        raise QaSyncError(f"refusing non-QA bucket {qa['bucket']}")
    if not PREFIX_RE.match(qa["prefix"]) or not qa["prefix"].startswith(f"{tenant}/"):
        raise QaSyncError(f"bad prefix {qa['prefix']!r} for tenant {tenant}")
    repo_name = Path(repo["repo"]).name.removesuffix(".git") if repo else None
    return {"client": client, "tenant": tenant, "bucket": qa["bucket"], "region": qa["region"],
            "prefix": qa["prefix"], "repo_name": repo_name,
            "branch": repo["branch"] if repo else None,
            "branch_unconfirmed": bool(repo and repo.get("branch_unconfirmed"))}


def ws_paths(sup, t):
    if not re.match(r"^SUP-\d+$", sup):
        raise QaSyncError(f"bad ticket id {sup!r} (want SUP-1234)")
    ws = JIRAS / sup
    return {"ws": ws,
            "live": ws / "qa-live",
            "live_root": ws / "qa-live" / t["tenant"],   # oci sync strips --prefix
            "manifest": ws / "qa-live" / f"{t['tenant']}.manifest.json",
            "sync": ws / "qa-sync" / t["tenant"],
            "backup": ws / "qa-backup"}


# ---- OCI (list args only — never a shell string) ---------------------------
class Oci:
    def _run(self, args):
        r = subprocess.run(["oci", "os", "object", *args], capture_output=True, text=True)
        if r.returncode != 0:
            raise QaSyncError(f"oci {' '.join(args[:1])} failed: {r.stderr.strip()[-800:]}")
        return r.stdout

    def list(self, bucket, region, prefix):
        out = self._run(["list", "-bn", bucket, "--region", region, "--prefix", prefix,
                         "--all", "--fields", "name,etag,md5,size"])
        data = json.loads(out[out.index("{"):]) if "{" in out else {"data": []}
        return {o["name"]: {"etag": o["etag"], "md5": o["md5"], "size": o["size"]}
                for o in data.get("data", [])}

    def sync_down(self, bucket, region, prefix, dest):
        self._run(["sync", "-bn", bucket, "--region", region, "--prefix", prefix,
                   "--dest-dir", str(dest)])

    def put(self, bucket, region, name, file, if_match):
        args = ["put", "-bn", bucket, "--region", region, "--name", name, "--file", str(file)]
        args += ["--if-match", if_match, "--force"] if if_match else ["--no-overwrite"]
        self._run(args)


# ---- git --------------------------------------------------------------------
def git(clone, *args, binary=False):
    r = subprocess.run(["git", "-C", str(clone), *args], capture_output=True)
    if r.returncode != 0:
        raise QaSyncError(f"git {' '.join(args)}: {r.stderr.decode().strip()}")
    return r.stdout if binary else r.stdout.decode()


def branch_changes(clone, base_ref):
    """Working tree (incl. uncommitted + untracked) vs merge-base(HEAD, base_ref)."""
    git(clone, "rev-parse", "--verify", base_ref)
    mb = git(clone, "merge-base", "HEAD", base_ref).strip()
    parts = git(clone, "diff", "--name-status", "--no-renames", "-z", mb).split("\0")
    changes = {parts[i + 1]: parts[i][0] for i in range(0, len(parts) - 1, 2) if parts[i]}
    for p in git(clone, "ls-files", "--others", "--exclude-standard", "-z").split("\0"):
        if p:
            changes[p] = "A"
    return mb, {p: s for p, s in sorted(changes.items()) if not p.startswith(EXCLUDE)}


def merge3(ours, base, theirs, favor=None):
    """git merge-file: ours=branch, base=merge-base, theirs=QA. Returns (bytes, conflicts)."""
    with tempfile.TemporaryDirectory() as d:
        files = []
        for n, b in (("branch", ours), ("base", base or b""), ("qa", theirs)):
            p = Path(d) / n
            p.write_bytes(b)
            files.append(str(p))
        cmd = ["git", "merge-file", "-p", "-L", "branch", "-L", "base", "-L", "qa"]
        if favor:
            cmd.append({"branch": "--ours", "qa": "--theirs"}[favor])
        r = subprocess.run(cmd + files, capture_output=True)
        if r.returncode < 0:
            raise QaSyncError(f"merge-file failed: {r.stderr.decode()}")
        return r.stdout, r.returncode


def _norm(b):
    return [l.rstrip() for l in b.decode().replace("\r", "").rstrip().split("\n")]


def is_text(*blobs):
    try:
        for b in blobs:
            if b is not None:
                b.decode("utf-8")
        return True
    except UnicodeDecodeError:
        return False


# ---- QA view ----------------------------------------------------------------
def load_manifest(p):
    if not p["manifest"].exists():
        raise QaSyncError("no QA snapshot yet — run `pull` first")
    return json.loads(p["manifest"].read_text())


def _mirror_bytes(p, t, name, meta):
    f = p["live_root"] / name[len(t["prefix"]):]
    if not f.exists():
        raise QaSyncError(f"mirror missing {name} — re-run `pull`")
    b = f.read_bytes()
    if meta.get("md5") and "-" not in meta["md5"] and md5b64(b) != meta["md5"]:
        raise QaSyncError(f"mirror stale for {name} (md5 mismatch) — re-run `pull`")
    return b


def qa_view(p, t, man, path):
    """-> (source, object_name, bytes|None)"""
    objs = man["objects"]
    tomb_name = f"{t['prefix']}.delete"
    if tomb_name in objs:
        tomb = {l.strip() for l in _mirror_bytes(p, t, tomb_name, objs[tomb_name]).decode().splitlines()}
        if path in tomb:
            return "tombstoned", tomb_name, None
    for src in ("override_configuration", "configuration"):
        name = f"{t['prefix']}{src}/{path}"
        if name in objs:
            return src, name, _mirror_bytes(p, t, name, objs[name])
    return "absent", None, None


# ---- commands ---------------------------------------------------------------
def cmd_pull(sup, t, oci):
    p = ws_paths(sup, t)
    p["live_root"].mkdir(parents=True, exist_ok=True)
    oci.sync_down(t["bucket"], t["region"], t["prefix"], p["live_root"])
    objs = oci.list(t["bucket"], t["region"], t["prefix"])
    man = {"tenant": t["tenant"], "bucket": t["bucket"], "prefix": t["prefix"],
           "pulled_at": int(time.time()), "objects": objs}
    p["manifest"].write_text(json.dumps(man, indent=1))
    n_ov = sum(1 for k in objs if k.startswith(f"{t['prefix']}override_configuration/"))
    return {"live_root": str(p["live_root"]), "objects": len(objs), "overrides": n_ov}


def qa_origin(clone, path, Q, limit=300):
    """Commit whose version of `path` equals QA's (ignoring whitespace), or None.
    Means QA isn't drifted — it's just on an older git version."""
    nq = _norm(Q)
    for c in git(clone, "log", "--all", "--format=%h", f"-n{limit}", "--", path).split():
        r = subprocess.run(["git", "-C", str(clone), "show", f"{c}:{path}"], capture_output=True)
        if r.returncode == 0 and is_text(r.stdout) and _norm(r.stdout) == nq:
            return c
    return None


def classify(path, status, B, S, qsrc, Q, overlap, origin=None, upstream=None):
    """Pure decision. Returns (action, payload|None, conflict_view|None, note).
    origin = base-line commit QA's version equals (see qa_origin); upstream = the
    base ref's current version. Then QA is just following git (no hotfix), so the
    push is the branch change on top of upstream, not a merge with QA's stale copy."""
    if origin and Q is not None and S is not None:
        U = upstream if upstream is not None else B
        a, pay, cv, note = classify(path, status, B, S, qsrc, U, overlap)
        if pay is None and a == "in-sync":                      # upstream already has it; QA doesn't
            a, pay = "behind", U
        elif a in ("clean", "merged"):
            a = "behind"
        return a, pay, cv, (f"QA is on git commit {origin} (no hotfix) — pushing your change on top of "
                            f"latest base. {note}").strip()
    if status == "D":
        return "deleted-in-branch", None, None, "deleted on branch — remove from QA manually (.delete)"
    if qsrc == "tombstoned":
        return "tombstoned", None, None, "tombstoned in QA .delete — remove the tombstone first"
    if Q == S:
        return "in-sync", None, None, "QA already matches branch"
    if Q is None:
        return "new", S, None, ""
    if is_text(Q, S) and _norm(Q) == _norm(S):
        return "in-sync", None, None, "differs only in whitespace/line endings"
    if B is not None and (Q == B or (is_text(Q, B) and _norm(Q) == _norm(B))):
        return "clean", S, None, ""
    if not is_text(B, S, Q):
        return "binary-conflict", None, None, "binary file drifted in QA — resolve by hand"
    merged, conflicts = merge3(S, B, Q)
    if conflicts == 0:
        if merged == Q:
            return "in-sync", None, None, "QA already contains the branch change"
        if merged == S:
            return "merged", merged, None, "QA had an older version of your change; pushing branch file"
        return "merged", merged, None, "QA-only drift preserved — not in your PR"
    if overlap == "stop":
        return "overlap-stopped", None, merged, f"{conflicts} overlapping hunk(s); --overlap stop"
    resolved, _ = merge3(S, B, Q, favor=overlap)
    return "overlap", resolved, merged, f"{conflicts} overlapping hunk(s) auto-resolved, {overlap} wins"


def _udiff(a, b, path):
    if not is_text(a, b):
        return "(binary)\n"
    return "".join(difflib.unified_diff(
        (a or b"").decode().splitlines(True), (b or b"").decode().splitlines(True),
        f"qa/{path}", f"push/{path}", n=3))


def plan_id(plan):
    core = {k: plan[k] for k in ("tenant", "bucket", "prefix", "merge_base", "overlap", "ops")}
    if plan.get("replace"):
        core["replace"] = True
    return sha256(json.dumps(core, sort_keys=True).encode())[:12]


def cmd_diff(sup, t, clone=None, base=None, overlap="branch", replace=False):
    p = ws_paths(sup, t)
    man = load_manifest(p)
    clone = Path(clone) if clone else p["ws"] / (t["repo_name"] or "")
    if not (clone / ".git").exists():
        raise QaSyncError(f"edit clone not found: {clone} (use --clone)")
    base = base or (f"origin/{t['branch']}" if t["branch"] else None)
    if not base:
        raise QaSyncError("no base branch configured — pass --base")
    head = git(clone, "rev-parse", "--abbrev-ref", "HEAD").strip()
    mb, changes = branch_changes(clone, base)
    out = p["sync"]
    if out.exists():
        shutil.rmtree(out)
    (out / "files").mkdir(parents=True)
    ops, report = [], []
    for path, status in changes.items():
        B = git(clone, "show", f"{mb}:{path}", binary=True) if status != "A" else None
        S = (clone / path).read_bytes() if status != "D" else None
        qsrc, qname, Q = qa_view(p, t, man, path)
        origin = upstream = None
        if Q is not None and S is not None and Q != S and is_text(Q) and (B is None or _norm(Q) != _norm(B)):
            origin = qa_origin(clone, path, Q)
            # QA follows git only if that commit is on the base line; otherwise it's a real hotfix
            if origin and subprocess.run(["git", "-C", str(clone), "merge-base", "--is-ancestor",
                                          origin, base]).returncode != 0:
                origin = None
        elif Q is not None and B is not None and S is not None and is_text(Q, B) and _norm(Q) == _norm(B):
            origin = mb[:7]                                     # QA == branch point: on the base line
        if origin:
            r = subprocess.run(["git", "-C", str(clone), "show", f"{base}:{path}"], capture_output=True)
            upstream = r.stdout if r.returncode == 0 else None
            if origin == mb[:7] and (upstream is None or _norm(upstream) == _norm(B)):
                origin = upstream = None                        # base unchanged: plain clean
        action, payload, conflict_view, note = classify(path, status, B, S, qsrc, Q, overlap, origin, upstream)
        if replace and action in ("merged", "overlap", "overlap-stopped") and S is not None:
            action, payload, conflict_view, note = ("replace", S, conflict_view,
                                                    "QA edits dropped — branch file pushed as-is (--replace)")
        if upstream is not None and B is not None and _norm(upstream) != _norm(B):
            note += " Base changed since your branch point — rebase your PR."
        target = f"{t['prefix']}override_configuration/{path}"
        op = {"path": path, "git_status": status, "qa_source": qsrc, "action": action, "note": note,
              "branch_sha256": sha256(S) if S is not None else None,
              "qa_object": qname,
              "qa_etag": man["objects"].get(qname, {}).get("etag") if qname else None,
              "target": target,
              "if_match": man["objects"].get(target, {}).get("etag")}
        if payload is not None:
            f = out / "files" / path
            f.parent.mkdir(parents=True, exist_ok=True)
            f.write_bytes(payload)
            op.update(payload_sha256=sha256(payload), payload_md5=md5b64(payload))
            report.append(f"### {path} — {action}\n{note}\n```diff\n{_udiff(Q, payload, path)}```\n")
        if conflict_view is not None:
            c = out / "conflicts" / path
            c.parent.mkdir(parents=True, exist_ok=True)
            c.write_bytes(conflict_view)
            op["conflict_file"] = str(c)
        ops.append(op)
    plan = {"ticket": sup, "client": t["client"], "tenant": t["tenant"], "bucket": t["bucket"],
            "region": t["region"], "prefix": t["prefix"], "clone": str(clone), "head": head,
            "base": base, "merge_base": mb, "overlap": overlap, "replace": replace, "qa_pulled_at": man["pulled_at"],
            "created_at": int(time.time()), "ops": ops}
    plan["plan_id"] = plan_id(plan)
    (out / "plan.json").write_text(json.dumps(plan, indent=1))
    summary = _summary(plan)
    (out / "report.md").write_text(summary + "\n\n" + "\n".join(report))
    warn = []
    if head != sup:
        warn.append(f"clone is on branch '{head}', not '{sup}'")
    if t["branch_unconfirmed"]:
        warn.append(f"base branch {base} is unconfirmed for {t['client']}")
    if time.time() - man["pulled_at"] > 3600:
        warn.append("QA snapshot is over 1h old — consider re-running pull")
    return {"plan_id": plan["plan_id"], "report": str(out / "report.md"), "summary": summary, "warnings": warn,
            "to_push": sum(o["action"] in PUSHABLE for o in ops)}


def _summary(plan):
    rows = [f"QA sync plan {plan['plan_id']} — {plan['ticket']} {plan['client']}/{plan['tenant']} "
            f"(branch {plan['head']} vs {plan['base']}, overlap: {plan['overlap']})", "",
            "| file | QA source | action | note |", "|---|---|---|---|"]
    rows += [f"| {o['path']} | {o['qa_source']} | **{o['action']}** | {o['note']} |" for o in plan["ops"]]
    n = sum(o["action"] in PUSHABLE for o in plan["ops"])
    rows += ["", f"{n} file(s) to push -> {plan['bucket']}/{plan['prefix']}override_configuration/"]
    return "\n".join(rows)


def _load_plan(p, approve):
    f = p["sync"] / "plan.json"
    if not f.exists():
        raise QaSyncError("no plan — run `diff` first")
    plan = json.loads(f.read_text())
    if plan_id(plan) != plan["plan_id"]:
        raise QaSyncError("plan.json was modified after it was generated — re-run diff")
    if approve != plan["plan_id"]:
        raise QaSyncError(f"--approve {approve} does not match plan {plan['plan_id']}")
    return plan


def _log(p, sup, name, rec):
    p["sync"].joinpath(name).write_text(json.dumps(rec, indent=1))
    logs = HUB / "tickets" / sup / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    (logs / f"qa-sync-{name}").write_text(json.dumps(rec, indent=1))


def cmd_push(sup, t, oci, approve, writeback=False):
    pre = _preflight(sup, t, oci, approve)
    return _execute(sup, t, oci, *pre, writeback) if pre[2] else {"pushed": [], "msg": "nothing to push"}


def _preflight(sup, t, oci, approve):
    """All checks, no writes. -> (p, plan, ops)"""
    p = ws_paths(sup, t)
    plan = _load_plan(p, approve)
    ops = [o for o in plan["ops"] if o["action"] in PUSHABLE]
    if not ops:
        return p, plan, ops
    clone = Path(plan["clone"])
    # 1. branch unchanged since plan; payload files untouched
    for o in ops:
        if sha256((clone / o["path"]).read_bytes()) != o["branch_sha256"]:
            raise QaSyncError(f"{o['path']} changed on branch since plan — re-run diff")
        if sha256((p["sync"] / "files" / o["path"]).read_bytes()) != o["payload_sha256"]:
            raise QaSyncError(f"payload for {o['path']} changed since plan — re-run diff")
    # 2. QA unchanged since snapshot
    live = oci.list(t["bucket"], t["region"], t["prefix"])
    for o in ops:
        for name, etag in ((o["qa_object"], o["qa_etag"]), (o["target"], o["if_match"])):
            if name and live.get(name, {}).get("etag") != etag:
                raise QaSyncError(f"QA changed since pull: {name} — re-run pull + diff")
    return p, plan, ops


def _execute(sup, t, oci, p, plan, ops, writeback=False):
    clone = Path(plan["clone"])
    # 3. backup
    ts = time.strftime("%Y%m%d-%H%M%S")
    bdir = p["backup"] / f"{ts}-{t['tenant']}"
    restore = []
    man = load_manifest(p)
    for o in ops:
        rec = {"path": o["path"], "object": o["target"], "existed": bool(o["if_match"])}
        if o["if_match"]:
            dst = bdir / "files" / o["path"]
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes(_mirror_bytes(p, t, o["target"], man["objects"][o["target"]]))
            rec["file"] = str(dst)
        restore.append(rec)
    bdir.mkdir(parents=True, exist_ok=True)
    (bdir / "restore.json").write_text(json.dumps(
        {"ticket": sup, "tenant": t["tenant"], "bucket": t["bucket"], "region": t["region"],
         "plan_id": plan["plan_id"], "entries": restore}, indent=1))
    # 4. upload
    done, err = [], None
    for o in ops:
        try:
            oci.put(t["bucket"], t["region"], o["target"], p["sync"] / "files" / o["path"], o["if_match"])
            done.append(o["path"])
        except QaSyncError as e:
            err = f"{o['path']}: {e}"
            break
    # 5. verify
    after = oci.list(t["bucket"], t["region"], t["prefix"])
    verified = {o["path"]: after.get(o["target"], {}).get("md5") == o["payload_md5"]
                for o in ops if o["path"] in done}
    for o in ops:
        if o["path"] in done:
            o["pushed_etag"] = after.get(o["target"], {}).get("etag")
    if writeback:
        for o in ops:
            if o["path"] in done and o["action"] in ("merged", "overlap"):
                shutil.copy2(p["sync"] / "files" / o["path"], clone / o["path"])
    rec = {"ticket": sup, "plan_id": plan["plan_id"], "pushed_at": ts, "by": os.environ.get("USER"),
           "bucket": t["bucket"], "backup": str(bdir), "pushed": done, "verified": verified,
           "error": err, "writeback": writeback,
           "ops": [{k: o.get(k) for k in ("path", "action", "target", "if_match", "pushed_etag", "payload_md5")}
                   for o in ops]}
    (bdir / "restore.json").write_text(json.dumps(
        {**json.loads((bdir / "restore.json").read_text()),
         "pushed_etags": {o["target"]: o.get("pushed_etag") for o in ops}}, indent=1))
    _log(p, sup, f"push-{ts}.json", rec)
    if err:
        raise QaSyncError(f"push stopped at {err}. Pushed so far: {done}. Backup: {bdir}")
    return rec


def tenants_of(client, tenant):
    """'all' -> every tenant of the client (default first); else [tenant]."""
    if tenant != "all":
        return [resolve(client, tenant)]
    cfg = json.loads((HUB / "customers" / client / "config_sources.json").read_text())
    return [resolve(client, None)] + [resolve(client, n) for n in cfg.get("tenants", {})]


def _all_file(sup):
    return JIRAS / sup / "qa-sync" / "_all.json"


def _combined_id(ids):
    return sha256(json.dumps(ids, sort_keys=True).encode())[:12]


def cmd_diff_all(sup, ts, clone=None, base=None, overlap="branch", replace=False):
    res = {t["tenant"]: cmd_diff(sup, t, clone, base, overlap, replace) for t in ts}
    ids = {k: r["plan_id"] for k, r in res.items()}
    combined = {"ticket": sup, "plans": ids, "plan_id": _combined_id(ids)}
    _all_file(sup).write_text(json.dumps(combined, indent=1))
    return {"plan_id": combined["plan_id"], "tenants": res,
            "to_push": sum(r["to_push"] for r in res.values())}


def cmd_push_all(sup, ts, oci, approve):
    f = _all_file(sup)
    if not f.exists():
        raise QaSyncError("no combined plan — run `diff --tenant all` first")
    combined = json.loads(f.read_text())
    if _combined_id(combined["plans"]) != combined["plan_id"] or approve != combined["plan_id"]:
        raise QaSyncError(f"--approve {approve} does not match combined plan {combined['plan_id']}")
    if sorted(combined["plans"]) != sorted(t["tenant"] for t in ts):
        raise QaSyncError("tenant set changed since diff — re-run diff --tenant all")
    # preflight every tenant before writing anything
    pre = {t["tenant"]: _preflight(sup, t, oci, combined["plans"][t["tenant"]]) for t in ts}
    out = {}
    for t in ts:
        p, plan, ops = pre[t["tenant"]]
        try:
            out[t["tenant"]] = _execute(sup, t, oci, p, plan, ops) if ops else {"pushed": []}
        except QaSyncError as e:
            done = {k: v.get("pushed") for k, v in out.items()}
            raise QaSyncError(f"{t['tenant']}: {e}. Already pushed: {done}")
    return out


def cmd_rollback(sup, t, oci, backup, approve=None):
    p = ws_paths(sup, t)
    bdir = Path(backup) if Path(backup).is_absolute() else p["backup"] / backup
    r = json.loads((bdir / "restore.json").read_text())
    if r["bucket"] != t["bucket"] or r["tenant"] != t["tenant"]:
        raise QaSyncError("backup belongs to a different tenant/bucket")
    rid = sha256(json.dumps(r, sort_keys=True).encode())[:12]
    etags = r.get("pushed_etags", {})
    pushed = [e for e in r["entries"] if etags.get(e["object"])]
    restores = [e for e in pushed if e["existed"]]
    creates = [e for e in pushed if not e["existed"]]
    plan = {"rollback_id": rid, "restore": [e["object"] for e in restores],
            "delete_by_hand": [["oci", "os", "object", "delete", "-bn", t["bucket"], "--region", t["region"],
                                "--name", e["object"]] for e in creates]}
    if approve is None:
        return plan
    if approve != rid:
        raise QaSyncError(f"--approve {approve} does not match rollback {rid}")
    for e in restores:
        oci.put(t["bucket"], t["region"], e["object"], e["file"], etags.get(e["object"]))
    _log(p, sup, f"rollback-{time.strftime('%Y%m%d-%H%M%S')}.json", {**plan, "restored": plan["restore"]})
    return {**plan, "restored": plan["restore"]}


def cmd_targets():
    rows = []
    for f in sorted((HUB / "customers").glob("*/config_sources.json")):
        cfg = json.loads(f.read_text())
        tenants = [None] + list(cfg.get("tenants", {}))
        for tn in tenants:
            try:
                t = resolve(cfg["client"], tn)
                rows.append(f"{t['client']:5} {t['tenant']:7} {t['bucket']}/{t['prefix']:13} "
                            f"repo={t['repo_name'] or '-'}@{t['branch'] or '-'}")
            except QaSyncError as e:
                rows.append(f"{cfg['client']:5} {tn or '?':7} ERROR {e}")
    return "\n".join(rows)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["targets", "pull", "diff", "push", "rollback"])
    ap.add_argument("ticket", nargs="?")
    ap.add_argument("--client")
    ap.add_argument("--tenant")
    ap.add_argument("--clone")
    ap.add_argument("--base")
    ap.add_argument("--overlap", choices=["branch", "qa", "stop"], default="branch")
    ap.add_argument("--replace", action="store_true",
                    help="diff: push branch files as-is where QA has hand edits (use when those edits are captured in git)")
    ap.add_argument("--approve")
    ap.add_argument("--writeback", action="store_true")
    ap.add_argument("--backup")
    a = ap.parse_args()
    try:
        if a.cmd == "targets":
            print(cmd_targets()); return
        if not (a.ticket and a.client):
            ap.error("ticket and --client are required")
        is_all = a.tenant == "all"
        ts = tenants_of(a.client.upper(), a.tenant)
        t = ts[0]
        oci = Oci()
        if is_all and a.cmd == "rollback":
            ap.error("rollback is per tenant — pass --tenant <name>")
        if is_all and a.writeback:
            ap.error("--writeback with --tenant all is ambiguous (one clone, per-tenant merges)")
        if a.cmd == "pull":
            res = {x["tenant"]: cmd_pull(a.ticket, x, oci) for x in ts}
        elif a.cmd == "diff":
            if is_all:
                res = cmd_diff_all(a.ticket, ts, a.clone, a.base, a.overlap, a.replace)
                diffs = list(res["tenants"].values())
            else:
                res = cmd_diff(a.ticket, t, a.clone, a.base, a.overlap, a.replace)
                diffs = [res]
            for r in diffs:
                print(r["summary"])
                for w in r["warnings"]:
                    print("WARN:", w)
                print(f"Review: {r['report']}\n")
            if res["to_push"]:
                print(f"Approve: qa_sync.py push {a.ticket} --client {a.client} "
                      f"--tenant {a.tenant if is_all else t['tenant']} --approve {res['plan_id']}")
            return
        elif a.cmd == "push":
            if not a.approve:
                ap.error("push requires --approve <plan_id> from `diff`")
            res = (cmd_push_all(a.ticket, ts, oci, a.approve) if is_all
                   else cmd_push(a.ticket, t, oci, a.approve, a.writeback))
        else:
            if not a.backup:
                ap.error("rollback requires --backup <dir>")
            res = cmd_rollback(a.ticket, t, oci, a.backup, a.approve)
        print(json.dumps(res, indent=1))
    except QaSyncError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
