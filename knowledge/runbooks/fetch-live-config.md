# Runbook: fetch live configuration from OCI (lower environments)

**Why:** lower envs get manual config changes; the git repo cannot be
trusted for env-specific debugging. Always diff live vs repo before
concluding anything about QA/staging behavior.

## Commands (confirmed working, 2026-07)

The live config is served from an OCI Object Storage bucket per lower env.
Sync it down with `oci os object sync`, then diff against the git repo.

```bash
# from a fresh working dir (e.g. tickets/<SUP-ID>/live-config/)
# bucket = internal-<env>-config ; prefix = <tenant>/asst/override_configuration/
oci os object sync \
  -bn internal-qa-config \
  --prefix aeo/asst/override_configuration/ \
  --dest-dir .

# → downloads the tenant's live override configs into ./aeo/asst/override_configuration/
#   (includes a .delete marker file listing tombstoned objects)
```

Fill per case:
- `-bn internal-<env>-config` — env bucket (`internal-qa-config`,
  `internal-staging-config`, …). Confirm the exact bucket name per env.
- `--prefix <tenant>/asst/override_configuration/` — tenant = client
  prefix (aeo, trd, blk…). `override_configuration/` holds the env's
  live confdefn/viewdefn/modeldefn/pivotdefn OVERRIDES (only files that
  were changed in the env; unchanged files still come from the repo).
- Requires OCI CLI configured (`oci setup config` once) with access to
  the bucket; run from the VM/host that has that access.

```bash
# diff the live overrides against the same paths in the git repo
diff -rq ./aeo/asst/override_configuration/ <configs-repo>/ \
  --exclude .git --exclude lineage | head -50
```

## Interpretation

- Files only in live  → manual hotfix not in git (capture in the ticket!)
- Files that differ   → compare with `diff -u`; the delta is often the bug
- No differences      → repo is trustworthy for this env; debug from repo

## After the ticket

Any legitimate live-only change must be PR'd back to the repo. Note it in
the solution note under Gotchas.
