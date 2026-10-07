---
name: qa-sync
description: >
  Push a ticket's CONFIG fix from the edit clone to the client's QA OCI bucket
  (override_configuration/) safely: pull live QA, 3-way diff vs the SUP branch,
  human review + approval, push, verify. Use when config edits for a ticket are
  done in JIRAs/<SUP-ID>/<repo>/ (workflow stage 6 → before 7), or when the user
  says "push to QA", "sync QA", "apply to QA", "deploy config to QA", "copy to
  OCI", "QA bucket". Config repos only; QA only.
---

# QA sync (workflow stage 6 → 7)

Tool: `tooling/triage/qa_sync.py`. Runbook: `knowledge/runbooks/qa-config-sync.md`.
Tenant map: `python3 tooling/triage/qa_sync.py targets`.

## When to offer it (proactive)

At the end of stage 6, as soon as **config** files changed in the edit clone
(`git -C JIRAs/<SUP-ID>/<repo> status` shows pivot/, uidefn/, conf/, mfp/…),
ask once:

> Config changes are ready in `<repo>` (N files). Sync them to <CLIENT> QA OCI
> now? I'll pull QA, show you a diff per file, and push only after you approve.

Don't offer it for ETL/frontend/backend-only changes. Never push without a
fresh "push"/"go" from the user for **that** plan_id (approval doesn't carry
over between plans, brands or tickets).

## Steps

1. **Resolve target.** Client from the ticket; tenant(s) from `config_sources.json`.
   Multi-brand clients (AEO: aeo/aer/tsn/uns; KW: loft/ann/atfs/los) → ask
   which brands; `--tenant all` covers every brand with one combined plan.
2. **Pull** (read-only): `qa_sync.py pull <SUP> --client <C> [--tenant X|all]`.
   ~2 min per tenant first time; run in background for `all`.
3. **Diff**: `qa_sync.py diff <SUP> --client <C> [--tenant …]`. Read the table.
4. **Review before showing the approve line** — check every non-trivial row:

   | action | what to verify |
   |---|---|
   | clean / new | nothing — QA had the base version / didn't have the file |
   | in-sync | nothing to push (incl. whitespace/CRLF-only diffs) |
   | behind | QA was on an older or broken git commit; payload = your change on latest base. Note any upstream commits it brings along |
   | merged | **QA has hand edits that match no git commit.** Show them (`diff branch payload`). Are they intentional? Is QA built on a broken deploy? |
   | overlap | open `qa-sync/<tenant>/conflicts/<path>`; confirm the winning side |
   | tombstoned / deleted-in-branch / binary-conflict | human action, never pushed |

   Also check: **who else is editing QA right now?** List recent override
   mtimes (`oci os object list … --fields name,timeModified`). A same-day edit
   means someone's live test, so stop and ask before overwriting.
5. **Present** a per-brand summary: files to push, anything dropped or
   overwritten, upstream commits brought in, warnings. Give the exact push
   command with the plan_id and wait for the user.
6. **Push**: `qa_sync.py push <SUP> --client <C> --tenant <X|all> --approve <plan_id>`.
   It re-checks etags and branch content, backs up, uploads, and verifies md5.
7. **Record**: the push log lands in `tickets/<SUP>/logs/qa-sync-push-*.json`.
   Add it to state.json evidence; it's the "applied to QA" proof for stage 7.
   The pre-state = `JIRAs/<SUP>/qa-backup/<ts>-<tenant>/`.
8. **Hand off** to `validate-fix` (UI and data checks on QA), and give the
   rollback command.

## Special cases

- **QA hand edit already captured in another PR** (e.g. a teammate's hotfix +
  PR): build a combined tree in a throwaway worktree and use `--replace`:
  ```bash
  git -C JIRAs/<SUP>/<repo> fetch origin refs/pull/<N>/head:refs/remotes/origin/pr/<N>
  git -C JIRAs/<SUP>/<repo> worktree add --detach ../<repo>-<tenant>-qa origin/pr/<N>
  # apply the SUP changes onto it per file: git merge-file <wt>/<f> <base f> <clone>/<f>
  qa_sync.py diff <SUP> --client <C> --tenant <X> --clone <wt> --base origin/<branch> --replace
  ```
  Verify the payload = (single-brand payload) + (that PR's lines) and nothing else.
- **Stale branch** (base moved): the tool already pushes your change on the
  latest base and notes "rebase your PR". Tell the user.
- **Rollback**: `qa_sync.py rollback <SUP> --client <C> --tenant <X> --backup <ts>-<X>`
  previews; `--approve <id>` restores. Objects that were *created* get
  printed delete commands for the human to run.

## Never

- Push to a non-QA bucket, or to `configuration/` (the tool refuses).
- Delete objects, or edit `.delete` tombstones (manual only).
- Commit or push git as part of this, or run `--writeback` without asking.
