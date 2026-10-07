# Runbook: push a ticket's config fix to QA (OCI) — `qa_sync.py`

**Why:** replaces hand-comparing the ticket branch with QA and pasting files into
the bucket. The tool pulls QA, does a 3-way diff against your branch, and pushes
only after you approve a specific plan. **Config repos only, QA only.**

## How QA config is laid out (all tenants, verified 2026-10-07)

Bucket `internal-qa-config` (us-chicago-1), one prefix per tenant: `<tenant>/asst/`

| Object | Meaning |
|---|---|
| `configuration/<path>` | base copy of the config repo (`git_hash` = commit it came from) |
| `override_configuration/<path>` | per-env hotfixes; **wins over** `configuration/` |
| `.delete` | tombstones: one repo-relative path per line, hidden in QA |

QA's effective file = override if present, else configuration, unless tombstoned.
**Pushes go to `override_configuration/` only.** The script never writes
`configuration/` and never deletes anything.

## Tenants (from `customers/<CLIENT>/config_sources.json`)

Run `python3 tooling/triage/qa_sync.py targets` to see the current map.

| Client | Tenant(s) | Config repo @ base branch |
|---|---|---|
| TRD | trd | trd-configs @ allocation-configs |
| AEO | aeo, aer, tsn, uns | aeo-configs @ hindsighting (4 brands, same branch + code; fix once, push to each) |
| BELK | belk | belk-configs @ assortment-planning |
| BOD | bd | boden-configs @ main |
| EE | eve | evereve-configs @ assortment-planning |
| EXP | exp | express-configs @ release/2025.10 |
| GAP | gap | gap-configs @ assortment_planning |
| KW | loft (default), ann, atfs, los | `<brand>-configs` @ planning_strategy |
| LP | lp | lp-configs @ main |
| TB | tb | tb-configs-v2 @ main |

Ignored bucket prefixes: `bc/`, `on/` (unmapped), `belkap/` (stale since 2025-04-24).

## Folder layout (outside every git repo)

```
JIRAs/<SUP-ID>/
  <repo-name>/                 edit clone, branch <SUP-ID> (edits may be uncommitted)
  qa-live/<tenant>/            QA mirror (oci sync strips the prefix)
  qa-live/<tenant>.manifest.json   object -> etag/md5 at pull time
  qa-sync/<tenant>/            plan.json, report.md, files/ (payloads), conflicts/
  qa-backup/<ts>-<tenant>/     pre-push copies + restore.json
```

Push and rollback logs are also copied to the hub at `tickets/<SUP-ID>/logs/qa-sync-*.json`
(gitignored), which serves as the validation-gate evidence.

## Steps

```bash
T=tooling/triage/qa_sync.py
python3 $T pull SUP-4449 --client TRD                  # ~2 min first time, incremental after
python3 $T diff SUP-4449 --client TRD                  # writes the plan + report and prints plan_id
#   review qa-sync/<tenant>/report.md: one diff per file, QA -> what will be pushed
python3 $T push SUP-4449 --client TRD --approve <plan_id>
```

**All brands at once (AEO: aeo/aer/tsn/uns share one repo):**

```bash
python3 $T pull SUP-XXXX --client AEO --tenant all     # 4 pulls
python3 $T diff SUP-XXXX --client AEO --tenant all     # 4 reports + ONE combined plan_id
python3 $T push SUP-XXXX --client AEO --tenant all --approve <combined plan_id>
```

- Each brand gets its own 3-way merge, so one brand's QA drift never spreads to the others.
- Push checks **every** brand before uploading to any. If one brand is stale, nothing is pushed.
- A single brand's plan_id is rejected here; use the combined id.
- `--writeback` and `rollback` stay per tenant.

Options:
- `--tenant ann`: a non-default tenant, for KW brands and AEO brands. `--tenant all` = every tenant of the client.
- `--clone PATH`: the edit clone, when it isn't at `JIRAs/<SUP-ID>/<repo-name>`.
- `--base REF`: the base ref, when it isn't `origin/<branch>`.
- `--overlap branch|qa|stop`: who wins overlapping hunks. The default is `branch`.
- `--writeback` (on `push`): also writes merged files into the edit clone, so the PR carries QA's drift.

## What `diff` decides per changed file

The changed set is the working tree vs `merge-base(HEAD, base)`, so it includes uncommitted and untracked files.

| Action | When | Pushed? |
|---|---|---|
| in-sync | QA already has the branch change | no |
| clean | QA == merge-base | yes, the branch file |
| new | not in QA | yes (`--no-overwrite`) |
| behind | QA's file equals some commit on the base branch (older, or a broken deploy): no hotfix. The push is your change on the **latest** base, never a merge with the stale copy (SUP-4678) | yes |
| merged | QA has hand edits matching no git commit and no overlap: 3-way merge keeps both | yes; note: QA drift isn't in your PR |
| replace | `diff --replace`: QA hand edits dropped and the branch file pushed. Use only when those edits are already in git (e.g. a teammate's PR in a combined worktree) | yes |
| overlap | overlapping hunks; the `--overlap` side wins (marker version saved in `conflicts/`) | yes |
| overlap-stopped / tombstoned / deleted-in-branch / binary-conflict | needs a human | no |

## Safety checks on `push`

Each check refuses the push if it fails:
- `--approve` doesn't equal the plan id, or `plan.json` was edited.
- A branch file or payload changed since `diff`.
- Any QA object's etag changed since `pull`. The uploads also use `--if-match`, so a race fails safe.
- A non-QA bucket, or a prefix that isn't `<tenant>/asst/`.

The push then backs up, uploads, re-lists, and verifies the md5 of each object. It stops at the first failure and reports what was pushed.

## Rollback

```bash
python3 $T rollback SUP-4449 --client TRD --backup <ts>-trd                   # preview + rollback_id
python3 $T rollback SUP-4449 --client TRD --backup <ts>-trd --approve <id>
```

Rollback restores overwritten overrides (`--if-match` on the etag we pushed). Overrides
that the push *created* are listed as `oci os object delete` commands for a human to run.

## Gotcha found while building this

The bucket has junk top-level prefixes `--dry-run/` and `--yes/`, and an
`eve/asst/192.168.86.21/` prefix. A script took a flag as the tenant name. That's why the
tool validates the tenant and prefix and passes args as a list, never a shell string.
