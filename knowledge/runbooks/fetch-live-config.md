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

### TRD buckets (confirmed 2026-08)

| Env | Bucket | Region | Prefix |
|---|---|---|---|
| QA | `internal-qa-config` | us-chicago-1 (US Midwest Chicago) | `trd/asst/` |
| Staging/Upgrade | `trd-trd-1-staging-config` | us-ashburn-1 (US East Ashburn) | `trd/asst/` |
| Prod | `trd-trd-1-prod-config` | us-ashburn-1 (US East Ashburn) | `trd/asst/` |

Workflow for TRD: clone git branch `allocation-configs` (the base), THEN
sync the env bucket over it — the running config = base + OCI overlay.

```bash
oci os object sync -bn internal-qa-config --prefix trd/asst/ --dest-dir ./live-config/qa/
```

Fill per case:
- `-bn <bucket>` — from the table above (per env).
- `--prefix trd/asst/` — TRD's config path in the bucket.
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
