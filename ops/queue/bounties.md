# Bounty Queue

Ranked list of OSS bounties the pipeline will work through in order. Seeded 2026-04-12 from live verification by the bounty-prep research agent.

**Format per entry:**
```
### <rank>. <title>  [status]
- url: <issue link>
- repo: <repo>
- language: <lang>
- payout: <amount + currency + USD estimate>
- score: P·R·S·M·F / total
- est_hours: <range>
- competing_prs: <count + links>
- notes: <anything relevant>
```

**Status values**: `unclaimed` · `CLAIMED` · `IN_PROGRESS` · `SHIPPED` · `DROPPED`

**Re-verification rule**: Before the pipeline starts work on any entry, re-run the live check. Bounty landscapes move daily.

---

### 1. Fix claim burn ownership proof in cucumber tests  [unclaimed]
- url: https://github.com/tari-project/tari-ootle/issues/1974
- repo: tari-project/tari-ootle
- language: rust
- payout: 60k XTM (~$42 USD at $0.0007/XTM as of seed date)
- score: 3·4·5·5·4 / 21
- est_hours: 4–8
- competing_prs: 2 (#1981, #1992 — check if stale before starting)
- notes: Crystal-clear bug, file:line given, AI-encouraged repo, fresh (Apr 8). Best first pick for pipeline velocity despite low USD value. Use as payout-pipeline shakedown.

### 2. Fix VN registration detection timeout in state sync test  [unclaimed]
- url: https://github.com/tari-project/tari-ootle/issues/1978
- repo: tari-project/tari-ootle
- language: rust
- payout: 60k XTM (~$42 USD)
- score: 3·4·5·5·4 / 21
- est_hours: 6–10
- competing_prs: 1 (#1994 by 0xPepeSilvia — strong competitor with diagnosis posted)
- notes: Solid backup. Only attempt if #1 is taken or #1994 on this issue gets closed/stalled.

### 3. Cap — Deeplinks + Raycast extension  [unclaimed]
- url: https://github.com/CapSoftware/Cap/issues/1540
- repo: CapSoftware/Cap
- language: rust + tauri + typescript
- payout: $200 USD (Algora)
- score: 4·3·4·5·5 / 21
- est_hours: 8–14
- competing_prs: ~10 PRs with sub-rewards distributed
- notes: Highest cash-USD pick on the list. Bounty is split into sub-rewards so even late entrants can claim part (mic/camera switching often unclaimed). Check sub-reward board before committing.

### 4. Create offline signing cucumber test  [unclaimed]
- url: https://github.com/tari-project/tari/issues/7736
- repo: tari-project/tari
- language: rust
- payout: 60k XTM (~$42 USD)
- score: 3·3·5·5·4 / 20
- est_hours: 6–10
- competing_prs: 0 at seed time
- notes: New test creation (not bug fix). Lowest competition on the list. Ramp cost: understand wallet gRPC and cucumber harness first.

### 5. Sparse scanned-header storage for wallet  [unclaimed]
- url: https://github.com/tari-project/tari/issues/7738
- repo: tari-project/tari
- language: rust
- payout: 60k XTM (~$42 USD)
- score: 3·3·5·5·4 / 20
- est_hours: 8–12
- competing_prs: 2 (#7744, #7748)
- notes: Nice algorithmic bounty. Only take if you can ship in <3 days and both competing PRs look stalled.

### 6. dokploy — rclone multi-destination backups  [unclaimed]
- url: https://github.com/CortexFlow-AI/dokploy/issues/168
- repo: CortexFlow-AI/dokploy
- language: typescript
- payout: $50 USD (Algora)
- score: 3·4·4·4·5 / 20
- est_hours: 4–8
- competing_prs: 4 (#1454, #1455, #1459, #1462)
- notes: USD payout, hot TS stack, but 4 competitors is a lot. Only go if one of the 4 is clearly stale (check dates).

### 7. minotari-cli — Payref reorg tracking  [unclaimed]
- url: https://github.com/tari-project/minotari-cli/issues/113
- repo: tari-project/minotari-cli
- language: rust
- payout: 60k XTM (~$42 USD)
- score: 3·3·5·4·4 / 19
- est_hours: 6–10
- competing_prs: 3 (#114, #115, #117)
- notes: Borderline. Only if you have a materially better approach than the 3 existing PRs.

### 8. Databuddy — Feature flag folders  [unclaimed]
- url: https://github.com/databuddy-analytics/Databuddy/issues/271
- repo: databuddy-analytics/Databuddy
- language: typescript + react + drizzle
- payout: $15 USD (Algora)
- score: 2·5·4·4·5 / 20
- est_hours: 3–5
- competing_prs: multiple, unclear exact count
- notes: Tiny payout but fastest path to a merged Algora bounty for Stripe Connect onboarding purposes. Consider as payout-pipeline warmup.

---

## Rejected at seed time (for reference, do not re-pick without re-verification)

### zio/zio-blocks #519 — Schema migration system
- url: https://github.com/zio/zio-blocks/issues/519
- payout: $4,000 USD
- reason: 10 open competing PRs, Scala (cold stack), 80–200 est hours — fails 14-day window. Revisit only if you've shipped 5+ bounties and want a big swing.

### coollabsio/coolify #8042 — OAuth-only self-registration
- url: https://github.com/coollabsio/coolify/issues/8042
- payout: $50 USD
- reason: 10+ closed PRs already, issue lingering. Graveyard — suggests scope or maintainer mismatch.

---

## Pipeline entry order rationale

The pipeline should start with **#1 (tari-ootle #1974)** as the shakedown run: low USD value but highest merge probability and fastest feedback. Parallel-track: begin Algora Stripe Connect KYC immediately (7–14 day clock).

After the first merge, shift focus to **#3 (Cap #1540)** for real USD flow, then **#4** for a competition-free Rust win.

Do not touch #6, #7, #8 until after 2 merges establish a baseline — their EV is marginal and they'll eat time without reputation gain.
