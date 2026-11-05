#!/usr/bin/env python3
"""build_effective: repo, then bucket configuration/, then override_configuration/, then .delete."""
import json, sys, tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import config_sync as CS


def main():
    with tempfile.TemporaryDirectory() as d:
        root = Path(d)
        (root / "customers" / "ZZ").mkdir(parents=True)
        (root / "customers" / "ZZ" / "config_sources.json").write_text(json.dumps(
            {"client": "ZZ", "root": "config", "config_repo": {"repo": "x", "branch": "b", "local": "repo"},
             "envs": {"qa": {"bucket": "internal-qa-config", "region": "r", "prefix": "zz/asst/"}}}))
        base = root / "customers" / "ZZ" / "config"
        def w(path, text):
            f = base / path
            f.parent.mkdir(parents=True, exist_ok=True)
            f.write_text(text)
        w("repo/pivot/A.pivotdefn", "git")
        w("repo/pivot/B.pivotdefn", "git")
        w("repo/pivot/C.pivotdefn", "git")
        w("repo/pivot/D.pivotdefn", "git")
        w("overlay/qa/configuration/pivot/B.pivotdefn", "bucket")
        w("overlay/qa/configuration/pivot/C.pivotdefn", "bucket")
        w("overlay/qa/override_configuration/pivot/C.pivotdefn", "override")
        w("overlay/qa/.delete", "pivot/D.pivotdefn\n")
        CS.HUB = root
        CS.build_effective("ZZ", "qa")
        eff = base / "effective" / "qa"
        got = {n: (eff / "pivot" / n).read_text() if (eff / "pivot" / n).exists() else None
               for n in ("A.pivotdefn", "B.pivotdefn", "C.pivotdefn", "D.pivotdefn")}
        want = {"A.pivotdefn": "git", "B.pivotdefn": "bucket", "C.pivotdefn": "override", "D.pivotdefn": None}
        bad = [n for n in want if got[n] != want[n]]
        stray = [x for x in ("configuration", "override_configuration") if (eff / x).exists()]
        for n in bad:
            print(f"FAIL {n}: expected {want[n]!r}, got {got[n]!r}")
        if stray:
            print(f"FAIL layer folders copied in as subfolders: {stray}")
        print("PASS build_effective layering" if not (bad or stray) else "")
        sys.exit(1 if bad or stray else 0)


if __name__ == "__main__":
    main()
