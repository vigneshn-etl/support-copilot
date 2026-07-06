# Runbook: fetch live configuration from OCI (lower environments)

**Why:** lower envs get manual config changes; the git repo cannot be
trusted for env-specific debugging. Always diff live vs repo before
concluding anything about QA/staging behavior.

## Commands

> TODO(Vignesh): paste the working OCI CLI commands here (from prior
> download session). Template:

```bash
# auth (once per session)
oci session authenticate --profile <PROFILE>

# download the config bundle for an env
oci os object bulk-download \
  --bucket-name <CONFIG_BUCKET> \
  --prefix <env>/<tenant>/ \
  --download-dir ./live-config/<env>/

# diff against repo
diff -rq ./live-config/<env>/ <trd-configs-repo>/ \
  --exclude .git --exclude lineage | head -50
```

## Interpretation

- Files only in live  → manual hotfix not in git (capture in the ticket!)
- Files that differ   → compare with `diff -u`; the delta is often the bug
- No differences      → repo is trustworthy for this env; debug from repo

## After the ticket

Any legitimate live-only change must be PR'd back to the repo. Note it in
the solution note under Gotchas.
