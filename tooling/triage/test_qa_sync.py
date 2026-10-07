#!/usr/bin/env python3
"""Tests for qa_sync.py — fake in-memory OCI bucket + real temp git repos.
Run: python3 tooling/triage/test_qa_sync.py"""
import json, shutil, subprocess, sys, tempfile, unittest, uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import qa_sync as q

SUP = "SUP-9001"          # gitignored smoke-test ticket id
P = "trd/asst/"
BASE10 = "".join(f"line{i}\n" for i in range(1, 11))


class FakeOci:
    def __init__(self):
        self.store = {}       # name -> (bytes, etag)
        self.puts = []

    def set(self, name, data):
        self.store[name] = (data.encode() if isinstance(data, str) else data, uuid.uuid4().hex)

    def list(self, bucket, region, prefix):
        return {n: {"etag": e, "md5": q.md5b64(b), "size": len(b)}
                for n, (b, e) in self.store.items() if n.startswith(prefix)}

    def sync_down(self, bucket, region, prefix, dest):
        for n, (b, _) in self.store.items():
            if n.startswith(prefix):
                f = Path(dest) / n[len(prefix):]
                f.parent.mkdir(parents=True, exist_ok=True)
                f.write_bytes(b)

    def put(self, bucket, region, name, file, if_match):
        assert bucket in q.QA_BUCKETS
        cur = self.store.get(name)
        if if_match and (not cur or cur[1] != if_match):
            raise q.QaSyncError("412 precondition failed")
        if not if_match and cur:
            raise q.QaSyncError("409 object exists (--no-overwrite)")
        self.puts.append(name)
        self.set(name, Path(file).read_bytes())


def sh(cwd, *args):
    subprocess.run(args, cwd=cwd, check=True, capture_output=True)


class QaSyncTest(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        q.JIRAS = self.tmp / "JIRAs"
        self.t = q.resolve("TRD")
        self.oci = FakeOci()
        # origin + edit clone on base branch
        origin = self.tmp / "origin.git"
        sh(self.tmp, "git", "init", "-q", "--bare", str(origin))
        self.clone = q.JIRAS / SUP / "trd-configs"
        self.clone.mkdir(parents=True)
        c = self.clone
        sh(c, "git", "init", "-q", "-b", "allocation-configs")
        sh(c, "git", "config", "user.email", "t@t"); sh(c, "git", "config", "user.name", "t")
        base = {"pivot/clean.pivotdefn": "a\nb\nc\n", "pivot/insync.pivotdefn": "x\n",
                "pivot/merged.pivotdefn": BASE10, "pivot/overlap.pivotdefn": BASE10,
                "pivot/tomb.pivotdefn": "t\n", "pivot/gone.pivotdefn": "g\n", ".github/ci.yml": "ci\n"}
        for k, v in base.items():
            (c / k).parent.mkdir(parents=True, exist_ok=True); (c / k).write_text(v)
            self.oci.set(f"{P}configuration/{k}", v)        # QA configuration/ == base
        sh(c, "git", "add", "-A"); sh(c, "git", "commit", "-qm", "base")
        sh(c, "git", "remote", "add", "origin", str(origin))
        sh(c, "git", "push", "-q", "origin", "allocation-configs")
        sh(c, "git", "checkout", "-qb", SUP)
        # QA drift (override_configuration/ + tombstone)
        self.oci.set(f"{P}override_configuration/pivot/insync.pivotdefn", "x2\n")
        self.oci.set(f"{P}override_configuration/pivot/merged.pivotdefn", BASE10.replace("line1\n", "QA1\n"))
        self.oci.set(f"{P}override_configuration/pivot/overlap.pivotdefn", BASE10.replace("line2\n", "QA2\n"))
        self.oci.set(f"{P}.delete", "pivot/tomb.pivotdefn\n")
        # branch edits (left uncommitted, like a real ticket)
        (c / "pivot/clean.pivotdefn").write_text("a\nB\nc\n")
        (c / "pivot/insync.pivotdefn").write_text("x2\n")
        (c / "pivot/new.pivotdefn").write_text("new\n")
        (c / "pivot/merged.pivotdefn").write_text(BASE10.replace("line9\n", "BR9\n"))
        (c / "pivot/overlap.pivotdefn").write_text(BASE10.replace("line2\n", "BR2\n"))
        (c / "pivot/tomb.pivotdefn").write_text("t2\n")
        (c / "pivot/gone.pivotdefn").unlink()
        (c / ".github/ci.yml").write_text("changed\n")

    def tearDown(self):
        shutil.rmtree(self.tmp)
        shutil.rmtree(q.HUB / "tickets" / SUP, ignore_errors=True)

    def plan(self, overlap="branch"):
        q.cmd_pull(SUP, self.t, self.oci)
        res = q.cmd_diff(SUP, self.t, overlap=overlap)
        plan = json.loads((q.JIRAS / SUP / "qa-sync/trd/plan.json").read_text())
        return res, {o["path"]: o for o in plan["ops"]}

    def obj(self, path):
        return self.oci.store[f"{P}override_configuration/{path}"][0].decode()

    def test_layout_outside_clone(self):
        self.plan()
        ws = q.JIRAS / SUP
        self.assertTrue((ws / "qa-live/trd/configuration/pivot/clean.pivotdefn").exists())
        self.assertTrue((ws / "qa-sync/trd/report.md").exists())
        self.assertEqual(subprocess.run(["git", "-C", str(self.clone), "status", "--porcelain", "--ignored"],
                                        capture_output=True, text=True).stdout.count("qa-"), 0)

    def test_classification(self):
        _, ops = self.plan()
        got = {p: o["action"] for p, o in ops.items()}
        self.assertEqual(got, {"pivot/clean.pivotdefn": "clean", "pivot/insync.pivotdefn": "in-sync",
                               "pivot/new.pivotdefn": "new", "pivot/merged.pivotdefn": "merged",
                               "pivot/overlap.pivotdefn": "overlap", "pivot/tomb.pivotdefn": "tombstoned",
                               "pivot/gone.pivotdefn": "deleted-in-branch"})
        self.assertNotIn(".github/ci.yml", got)
        self.assertEqual(ops["pivot/clean.pivotdefn"]["qa_source"], "configuration")
        self.assertEqual(ops["pivot/merged.pivotdefn"]["qa_source"], "override_configuration")

    def test_push_merges_and_backs_up(self):
        res, _ = self.plan()
        out = q.cmd_push(SUP, self.t, self.oci, res["plan_id"])
        self.assertEqual(sorted(out["pushed"]), ["pivot/clean.pivotdefn", "pivot/merged.pivotdefn",
                                                 "pivot/new.pivotdefn", "pivot/overlap.pivotdefn"])
        self.assertTrue(all(out["verified"].values()))
        self.assertEqual(self.obj("pivot/clean.pivotdefn"), "a\nB\nc\n")
        merged = self.obj("pivot/merged.pivotdefn")
        self.assertIn("QA1", merged); self.assertIn("BR9", merged)          # both sides kept
        ov = self.obj("pivot/overlap.pivotdefn")
        self.assertIn("BR2", ov); self.assertNotIn("QA2", ov); self.assertNotIn("<<<<", ov)
        # configuration/ never written; tombstoned/deleted untouched
        self.assertTrue(all("/override_configuration/" in n for n in self.oci.puts))
        self.assertEqual(self.oci.store[f"{P}configuration/pivot/gone.pivotdefn"][0], b"g\n")
        backup = Path(out["backup"])
        self.assertEqual((backup / "files/pivot/merged.pivotdefn").read_text(),
                         BASE10.replace("line1\n", "QA1\n"))
        self.assertTrue((q.HUB / "tickets" / SUP / "logs").exists())
        # branch working tree unchanged without --writeback
        self.assertNotIn("QA1", (self.clone / "pivot/merged.pivotdefn").read_text())

    def test_overlap_qa_wins_and_stop(self):
        _, ops = self.plan(overlap="qa")
        payload = (q.JIRAS / SUP / "qa-sync/trd/files/pivot/overlap.pivotdefn").read_text()
        self.assertIn("QA2", payload); self.assertNotIn("BR2", payload)
        _, ops = self.plan(overlap="stop")
        self.assertEqual(ops["pivot/overlap.pivotdefn"]["action"], "overlap-stopped")
        self.assertIn("<<<<<<< branch",
                      Path(ops["pivot/overlap.pivotdefn"]["conflict_file"]).read_text())

    def test_replace_drops_qa_edits(self):
        q.cmd_pull(SUP, self.t, self.oci)
        res = q.cmd_diff(SUP, self.t, replace=True)
        ops = {o["path"]: o for o in json.loads((q.JIRAS / SUP / "qa-sync/trd/plan.json").read_text())["ops"]}
        self.assertEqual(ops["pivot/merged.pivotdefn"]["action"], "replace")
        self.assertEqual(ops["pivot/overlap.pivotdefn"]["action"], "replace")
        self.assertEqual(ops["pivot/clean.pivotdefn"]["action"], "clean")
        q.cmd_push(SUP, self.t, self.oci, res["plan_id"])
        self.assertEqual(self.obj("pivot/merged.pivotdefn"), BASE10.replace("line9\n", "BR9\n"))   # QA1 dropped

    def test_wrong_approve_refused(self):
        self.plan()
        with self.assertRaisesRegex(q.QaSyncError, "does not match"):
            q.cmd_push(SUP, self.t, self.oci, "deadbeef0000")
        self.assertEqual(self.oci.puts, [])

    def test_tampered_plan_refused(self):
        res, _ = self.plan()
        f = q.JIRAS / SUP / "qa-sync/trd/plan.json"
        plan = json.loads(f.read_text()); plan["ops"][0]["target"] = "trd/asst/configuration/x"
        f.write_text(json.dumps(plan))
        with self.assertRaisesRegex(q.QaSyncError, "modified"):
            q.cmd_push(SUP, self.t, self.oci, res["plan_id"])

    def test_qa_changed_after_pull_refused(self):
        res, _ = self.plan()
        self.oci.set(f"{P}override_configuration/pivot/merged.pivotdefn", "someone else\n")
        with self.assertRaisesRegex(q.QaSyncError, "QA changed since pull"):
            q.cmd_push(SUP, self.t, self.oci, res["plan_id"])
        self.assertEqual(self.oci.puts, [])

    def test_branch_edited_after_plan_refused(self):
        res, _ = self.plan()
        (self.clone / "pivot/clean.pivotdefn").write_text("edited later\n")
        with self.assertRaisesRegex(q.QaSyncError, "changed on branch"):
            q.cmd_push(SUP, self.t, self.oci, res["plan_id"])

    def test_writeback(self):
        res, _ = self.plan()
        q.cmd_push(SUP, self.t, self.oci, res["plan_id"], writeback=True)
        self.assertIn("QA1", (self.clone / "pivot/merged.pivotdefn").read_text())

    def test_rollback(self):
        res, _ = self.plan()
        out = q.cmd_push(SUP, self.t, self.oci, res["plan_id"])
        name = Path(out["backup"]).name
        rb = q.cmd_rollback(SUP, self.t, self.oci, name)                 # preview only
        self.assertIn(f"{P}override_configuration/pivot/merged.pivotdefn", rb["restore"])
        self.assertEqual(len(rb["delete_by_hand"]), 2)                     # clean + new were created
        before = len(self.oci.puts)
        with self.assertRaises(q.QaSyncError):
            q.cmd_rollback(SUP, self.t, self.oci, name, approve="nope")
        self.assertEqual(len(self.oci.puts), before)
        q.cmd_rollback(SUP, self.t, self.oci, name, approve=rb["rollback_id"])
        self.assertEqual(self.obj("pivot/merged.pivotdefn"), BASE10.replace("line1\n", "QA1\n"))

    def test_stale_mirror_detected(self):
        q.cmd_pull(SUP, self.t, self.oci)
        (q.JIRAS / SUP / "qa-live/trd/override_configuration/pivot/merged.pivotdefn").write_text("tampered")
        with self.assertRaisesRegex(q.QaSyncError, "stale"):
            q.cmd_diff(SUP, self.t)


class AllTenantsTest(unittest.TestCase):
    """AEO: aeo/aer/tsn/uns share aeo-configs; one fix -> all four QA prefixes."""
    BRANDS = ("aeo", "aer", "tsn", "uns")

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        q.JIRAS = self.tmp / "JIRAs"
        self.oci = FakeOci()
        origin = self.tmp / "origin.git"
        sh(self.tmp, "git", "init", "-q", "--bare", str(origin))
        c = self.clone = q.JIRAS / SUP / "aeo-configs"
        c.mkdir(parents=True)
        sh(c, "git", "init", "-q", "-b", "hindsighting")
        sh(c, "git", "config", "user.email", "t@t"); sh(c, "git", "config", "user.name", "t")
        (c / "pivot").mkdir(); (c / "pivot/fix.pivotdefn").write_text(BASE10)
        sh(c, "git", "add", "-A"); sh(c, "git", "commit", "-qm", "base")
        sh(c, "git", "remote", "add", "origin", str(origin))
        sh(c, "git", "push", "-q", "origin", "hindsighting")
        sh(c, "git", "checkout", "-qb", SUP)
        for b in self.BRANDS:
            self.oci.set(f"{b}/asst/configuration/pivot/fix.pivotdefn", BASE10)
        self.oci.set("uns/asst/override_configuration/pivot/fix.pivotdefn",
                     BASE10.replace("line1\n", "UNS1\n"))           # uns-only drift
        (c / "pivot/fix.pivotdefn").write_text(BASE10.replace("line9\n", "FIX9\n"))
        self.ts = q.tenants_of("AEO", "all")

    def tearDown(self):
        shutil.rmtree(self.tmp)
        shutil.rmtree(q.HUB / "tickets" / SUP, ignore_errors=True)

    def diff_all(self):
        for t in self.ts:
            q.cmd_pull(SUP, t, self.oci)
        return q.cmd_diff_all(SUP, self.ts)

    def test_expands_to_four_brands(self):
        self.assertEqual([t["tenant"] for t in self.ts], list(self.BRANDS))
        self.assertEqual({t["repo_name"] for t in self.ts}, {"aeo-configs"})

    def test_push_all(self):
        res = self.diff_all()
        self.assertEqual({k: r["to_push"] for k, r in res["tenants"].items()},
                         {b: 1 for b in self.BRANDS})
        q.cmd_push_all(SUP, self.ts, self.oci, res["plan_id"])
        for b in self.BRANDS:
            got = self.oci.store[f"{b}/asst/override_configuration/pivot/fix.pivotdefn"][0].decode()
            self.assertIn("FIX9", got)
            self.assertEqual("UNS1" in got, b == "uns")              # per-brand merge, no cross-bleed

    def test_per_tenant_id_rejected(self):
        res = self.diff_all()
        with self.assertRaisesRegex(q.QaSyncError, "combined plan"):
            q.cmd_push_all(SUP, self.ts, self.oci, res["tenants"]["aeo"]["plan_id"])

    def test_one_stale_brand_blocks_all(self):
        res = self.diff_all()
        self.oci.set("tsn/asst/configuration/pivot/fix.pivotdefn", "changed\n")
        with self.assertRaisesRegex(q.QaSyncError, "QA changed since pull"):
            q.cmd_push_all(SUP, self.ts, self.oci, res["plan_id"])
        self.assertEqual(self.oci.puts, [])                         # nothing pushed anywhere


class StaleQaTest(unittest.TestCase):
    """SUP-4678 regression: QA configuration/ is an OLDER git version of the file.
    A plain 3-way merge would keep the old lines and revert later git fixes."""
    OLD = BASE10.replace("line1\n", "old1\n").replace("line10\n", "old10\n")

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        q.JIRAS = self.tmp / "JIRAs"
        self.t = q.resolve("TRD")
        self.oci = FakeOci()
        origin = self.tmp / "origin.git"
        sh(self.tmp, "git", "init", "-q", "--bare", str(origin))
        c = self.clone = q.JIRAS / SUP / "trd-configs"
        (c / "pivot").mkdir(parents=True)
        sh(c, "git", "init", "-q", "-b", "allocation-configs")
        sh(c, "git", "config", "user.email", "t@t"); sh(c, "git", "config", "user.name", "t")
        f = c / "pivot/stale.pivotdefn"
        f.write_text(self.OLD); sh(c, "git", "add", "-A"); sh(c, "git", "commit", "-qm", "old (what QA has)")
        f.write_text(BASE10); sh(c, "git", "commit", "-qam", "later git fix (QA never got it)")
        sh(c, "git", "remote", "add", "origin", str(origin))
        sh(c, "git", "push", "-q", "origin", "allocation-configs")
        sh(c, "git", "checkout", "-qb", SUP)
        self.oci.set(f"{P}configuration/pivot/stale.pivotdefn", self.OLD.replace("\n", "\r\n"))
        f.write_text(BASE10.replace("line5\n", "FIX5\n"))

    def tearDown(self):
        shutil.rmtree(self.tmp)
        shutil.rmtree(q.HUB / "tickets" / SUP, ignore_errors=True)

    def test_behind_pushes_branch_file_not_stale_merge(self):
        q.cmd_pull(SUP, self.t, self.oci)
        res = q.cmd_diff(SUP, self.t)
        op = json.loads((q.JIRAS / SUP / "qa-sync/trd/plan.json").read_text())["ops"][0]
        self.assertEqual(op["action"], "behind")
        payload = (q.JIRAS / SUP / "qa-sync/trd/files/pivot/stale.pivotdefn").read_text()
        self.assertEqual(payload, (self.clone / "pivot/stale.pivotdefn").read_text())
        self.assertNotIn("old1", payload)                            # later git fix not reverted
        q.cmd_push(SUP, self.t, self.oci, res["plan_id"])
        self.assertIn("FIX5", self.oci.store[f"{P}override_configuration/pivot/stale.pivotdefn"][0].decode())

    def test_qa_on_regressed_upstream_deploy_gets_latest_base(self):
        """SUP-4678 tsn/uns: deploy commit regressed the file, a later commit fixed it,
        QA is stuck on the regressed deploy. Push = branch change on latest base."""
        c = self.clone
        sh(c, "git", "checkout", "-q", "allocation-configs")
        deploy = BASE10.replace("line9\n", "BAD9\n")
        (c / "pivot/stale.pivotdefn").write_text(deploy)
        sh(c, "git", "commit", "-qam", "deploy (regression)")
        (c / "pivot/stale.pivotdefn").write_text(BASE10.replace("line10\n", "UP10\n"))
        sh(c, "git", "commit", "-qam", "fix pivots")
        sh(c, "git", "push", "-q", "origin", "allocation-configs")
        sh(c, "git", "checkout", "-q", SUP)
        (c / "pivot/stale.pivotdefn").write_text(BASE10.replace("line5\n", "FIX5\n"))
        self.oci.set(f"{P}configuration/pivot/stale.pivotdefn", deploy)
        q.cmd_pull(SUP, self.t, self.oci)
        q.cmd_diff(SUP, self.t)
        op = json.loads((q.JIRAS / SUP / "qa-sync/trd/plan.json").read_text())["ops"][0]
        self.assertEqual(op["action"], "behind")
        self.assertIn("rebase your PR", op["note"])
        payload = (q.JIRAS / SUP / "qa-sync/trd/files/pivot/stale.pivotdefn").read_text()
        self.assertIn("FIX5", payload); self.assertIn("UP10", payload)
        self.assertNotIn("BAD9", payload)                            # regression not re-pushed

    def test_qa_at_branch_point_gets_change_on_latest_base(self):
        c = self.clone
        sh(c, "git", "checkout", "-q", "allocation-configs")
        (c / "pivot/stale.pivotdefn").write_text(BASE10.replace("line10\n", "UP10\n"))
        sh(c, "git", "commit", "-qam", "upstream after branch point")
        sh(c, "git", "push", "-q", "origin", "allocation-configs")
        sh(c, "git", "checkout", "-q", SUP)
        (c / "pivot/stale.pivotdefn").write_text(BASE10.replace("line5\n", "FIX5\n"))
        self.oci.set(f"{P}configuration/pivot/stale.pivotdefn", BASE10)   # QA == branch point
        q.cmd_pull(SUP, self.t, self.oci)
        q.cmd_diff(SUP, self.t)
        op = json.loads((q.JIRAS / SUP / "qa-sync/trd/plan.json").read_text())["ops"][0]
        self.assertEqual(op["action"], "behind")
        payload = (q.JIRAS / SUP / "qa-sync/trd/files/pivot/stale.pivotdefn").read_text()
        self.assertIn("FIX5", payload); self.assertIn("UP10", payload)

    def test_real_hotfix_still_preserved(self):
        """QA content matching NO git commit is a genuine hotfix -> 3-way keeps it."""
        self.oci.set(f"{P}configuration/pivot/stale.pivotdefn", BASE10.replace("line1\n", "HOT1\n"))
        q.cmd_pull(SUP, self.t, self.oci)
        q.cmd_diff(SUP, self.t)
        op = json.loads((q.JIRAS / SUP / "qa-sync/trd/plan.json").read_text())["ops"][0]
        self.assertEqual(op["action"], "merged")
        payload = (q.JIRAS / SUP / "qa-sync/trd/files/pivot/stale.pivotdefn").read_text()
        self.assertIn("HOT1", payload); self.assertIn("FIX5", payload)


class ResolveTest(unittest.TestCase):
    def test_all_targets_resolve(self):
        out = q.cmd_targets()
        self.assertNotIn("ERROR", out)
        for tenant in ("trd", "aeo", "aer", "bd", "eve", "loft", "ann", "atfs", "los",
                       "belk", "exp", "lp", "tb", "gap"):
            self.assertRegex(out, rf"\b{tenant}\s+internal-qa-config/{tenant}/asst/")

    def test_kw_brand_repo(self):
        t = q.resolve("KW", "ann")
        self.assertEqual((t["repo_name"], t["branch"], t["prefix"]), ("ann-configs", "planning_strategy", "ann/asst/"))

    def test_rejects(self):
        with self.assertRaisesRegex(q.QaSyncError, "unknown tenant"):
            q.resolve("KW", "--dry-run")
        with self.assertRaisesRegex(q.QaSyncError, "bad ticket"):
            q.ws_paths("../etc", q.resolve("TRD"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
