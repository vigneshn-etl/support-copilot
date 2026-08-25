# Runbook: EXP cyclic — recover partner SFTP delivery failures

**Why:** EXP's `cyclic.sh` pushes outbound files in two hops — our relay
box, then the relay pushes on to Express's partner SFTP. The second hop
is outside our infra and fails periodically (partner-side network/
firewall issues). This is how to confirm it's that failure, get the
partner to fix their end, and safely re-deliver the queued files without
re-running the whole batch.

## How the delivery actually works (confirmed from `run_cyclic.sh`)

`cyclic.sh` → `run_cyclic.sh`, in order:

1. **Export** — Vertica/PG queries write `S5Outbound*` files to a temp
   workdir, timestamped `_<NOW>` (format `YYYYMMDDHHMMSS`, e.g.
   `20260811104501`).
2. **`gsutil cp`** — backs the files up to
   `gs://s5-ex-prod-asst-backups/outbound/<DATE>/<NOW>/`.
3. **`scp_files`** (internal hop, retried 5x/30s) — `scp`'s the files to
   our relay box, `etlservice@35.227.70.15`, into
   `/home/express/prod/to_express/<NOW>/`, then `chmod ugo+r`.
4. **`send_files`** (retried 5x/30s) — SSHes into the relay and runs
   `postExpressOut.sh <NOW>` **on that box**. That remote script does the
   actual external delivery: `sshpass scp` of the same files to
   `exp_s5@sftp.inside-express.com` (partner SFTP, IP `199.71.217.62`).

**In every incident seen so far, step 3 (internal hop) succeeds and step
4's external push is what fails.** That means by the time you're looking
at this, the files are already sitting on the relay box, staged and
ready — you don't need to re-export or re-run steps 1-3.

## How to recognize this failure

Slack: `@here failed cyclic`. In the log, `scp_files` completes (`+
break`), then `send_files` repeats and fails identically each of the 5
attempts. Two signatures seen so far, both pointing to a problem on the
partner's end / the network path to them — not our script:

- `ssh_exchange_identification: read: Connection reset by peer` — TCP
  connected, then something reset the connection during the SSH banner
  exchange (2026-07-18 incident).
- `connect to address 199.71.217.62 port 22: Connection timed out` — TCP
  never completed the handshake at all (2026-08-11 incident).

Both hit the same remote script, same host, same port. Don't spend time
debugging `run_cyclic.sh` for this pattern — it's an external
connectivity problem to `sftp.inside-express.com`.

*(Cosmetic, unrelated noise you'll also see every run: `/home/etlservice/
trace.log: No such file or directory` — a leftover debug line in
`run_cyclic.sh` writing to a path that doesn't exist locally. Harmless,
ignore it.)*

## Fix steps (confirmed working)

1. **Pause the cyclic cron** for EXP so it stops retrying/alerting every
   15 minutes while this is being investigated.
2. **Email the customer/partner** (Express IT) to check their SFTP
   endpoint. Sample subject: *"File transfers to sftp.inside-express.com
   failing — connection timeout"*. Include the error signature from the
   log, the target `199.71.217.62:22`, and the timestamps of the failed
   attempts.
3. **Wait for their confirmation** that the issue is resolved on their
   end before retrying — retrying blind just reproduces the same
   timeout/reset.
4. **Find the failed batch's folder timestamp** — either from the Slack
   failure thread, or from the log itself (the `_<NOW>` suffix on the
   workdir / filenames, e.g. `20260811104501`). The files for that run
   are already staged on the relay at
   `/home/express/prod/to_express/<NOW>/`.
5. **Re-run only the external push** — from a box with access to the
   relay, run the exact command `send_files` already uses (swap in the
   real timestamp from step 4):

   ```bash
   ssh -i ~/.ssh/google_compute_engine_copied_gcp \
     -o CheckHostIP=no -o HashKnownHosts=no \
     -o HostKeyAlias=compute.943920637205184814 \
     -o IdentitiesOnly=yes -o StrictHostKeyChecking=no \
     etlservice@35.227.70.15 \
     /home/express/prod/to_express/postExpressOut.sh <NOW>
   ```

   This is non-destructive and safe to re-run as many times as needed —
   it just re-attempts the same `sshpass scp` to the partner.
6. **Verify** (see below), then **re-enable the cyclic cron**.
7. **Reply on the same customer email thread** to close the loop.

> Don't redo steps 1-3 of the pipeline (export/backup/internal scp)
> unless the log shows those actually failed too — only step 4 (external
> push) needs a manual retry in the incidents seen so far.

## Verification

- The manual `postExpressOut.sh <NOW>` run completes without `Connection
  reset by peer` / `Connection timed out`.
- Confirm with the partner (or via their SFTP if we have visibility) that
  the 6 files for `<NOW>` landed: `S5OutboundOrderFlows`,
  `S5OutboundProductHierarchy`, `S5OutboundProductMemberMaster`,
  `S5OutboundStyleAttributes`, `S5OutboundStyleColorSizeAttributes`,
  `S5RdyFiles`.
- Once the cron is back on, confirm the next scheduled cyclic run
  completes clean end-to-end.

## Gotchas

- Same partner IP (`199.71.217.62`) has failed twice with two *different*
  low-level signatures three and a half weeks apart (2026-07-18 reset,
  2026-08-11 timeout). Treat a third occurrence as a systemic
  partner-side reliability issue worth escalating, not another isolated
  blip.
- Use the direct `ssh`/`scp` form documented above (matches exactly what
  `run_cyclic.sh` uses) rather than `gcloud compute ssh`/`gcloud compute
  scp` — the relay box is reached directly over its key + host alias, not
  via `gcloud compute` tooling.
