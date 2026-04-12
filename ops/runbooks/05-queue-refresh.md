# Queue Refresh Runbook

Invoked when the bounty queue is running low (< 5 unstarted entries) or on a scheduled weekly cycle. Scouts new targets, scores them, appends to the queues.

## Bounty scouting

1. Check Algora's public bounty feed: https://algora.io/bounties
   - Extract all bounties opened in the last 14 days
   - Note: title, repo, amount, claim status, open competing PRs
2. Check Polar.sh if it's still actively funding bounties: https://polar.sh/
3. Scan the "individual repos paying bounties" list from previous runs:
   - coollabsio/coolify
   - CapSoftware/Cap
   - databuddy-analytics/Databuddy
   - CortexFlow-AI/dokploy
   - zio/zio-blocks
   - tscircuit/*
   - mangdangroboticsclub/mini_pupper_ros
   - tari-project/* (tari, tari-ootle, universe, minotari-cli)
   - Any new ones flagged by weekly retro
4. For each candidate:
   - Verify issue is open and unassigned
   - Count linked open PRs; skip if > 2
   - Score using the rubric in `ops/runbooks/06-bounty-rubric.md` (if exists) or the inline rubric below
   - Discard entries with total score < 18/25 or any axis = 1

## Inline bounty rubric

Score 1–5 on each axis. Proceed if total ≥ 18/25 AND no axis ≤ 2.

- **Payout/effort**: USD per estimated hour. 1 = <$20/hr, 3 = $20–50, 5 = >$50
- **Reproducibility**: can I trigger it locally in < 30 min? 1 = needs special infra, 5 = one command
- **Scope clarity**: 1 = "improve X somehow", 5 = file paths + checklist + test names
- **Maintainer responsiveness**: last issue activity / PR merge cadence. 1 = >14d, 5 = <48h with recent merges
- **Stack familiarity**: 1 = cold language, 3 = warm, 5 = TS/Python/Rust/Go/Solidity

**Hard disqualifiers:**
- Already assigned to another user
- ≥ 3 open PRs on the issue
- CONTRIBUTING.md forbids AI-generated PRs
- Token-only payout with illiquid token (< $1M 24h volume)
- Out of `state.json` → `defaults.allowed_languages`

## Append to `ops/queue/bounties.md`

Use the existing entry format. Append at the position matching the rank. Never remove entries; only mark them `DROPPED` or `CLAIMED` with a reason.

## Audit target refresh

Immunefi program rotations are lower-frequency but still need monitoring:

1. Check each program in `ops/queue/audit-targets.md` for:
   - Scope changes
   - Reward tier changes
   - Pause status
   - New in-scope contracts from recent upgrades
2. Remove any program that paused, shrunk rewards below threshold, or lost safe-harbor clarity
3. Scout 1-2 new programs per month from Immunefi's public feed, prioritizing:
   - TVL > $100M (skin in the game)
   - Open-source contracts
   - Published prior audits (helps duplicate-check)
   - Responsive triage history

## Output

After refresh, log:

```
queue-refresh  bounties_added=N  bounties_dropped=N  audits_added=N  audits_dropped=N
```

Exit. Do not start new work in this cycle — save that for the next normal cycle.
