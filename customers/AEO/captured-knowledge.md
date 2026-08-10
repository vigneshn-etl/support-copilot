# Captured knowledge — AEO

Facts captured from users during ticket work, newest first. Each entry is
stamped with source + who + when. Promote durable facts into the proper
knowledge file (profile.md, a primer, a runbook) and prune here.
Generated/appended by `tooling/triage/learn.py`.


## [env] 2026-08-10
AEO staging OCI config bucket: aeo-aeo-1-staging-config, region us-ashburn-1, prefix aeo/asst/configuration/.
_(source: SUP-4486 · captured: 2026-08-10)_

## [gotcha] 2026-08-10
Bulk 'Sync from aeo/asst/configuration bucket' commits in aeo-configs are NOT guaranteed additive — they have silently commented out HAVING clauses in shared pivot includes (e.g. history_product_ty_ly_lly.ftl, commit 6f19a4b 2026-06-08), regressing config that was previously correct. Always git-diff a sync commit; check sibling grain-variant includes (_sku/_style/_stylecolor) individually since they can diverge.
_(source: SUP-4486 · by: vignesh.n · captured: 2026-08-10)_

