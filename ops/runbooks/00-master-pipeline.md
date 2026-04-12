# Master Pipeline Runbook

You are the orchestrator for a background income pipeline. This runbook executes once per loop cycle. Follow it in order, stop at the first unrecoverable blocker, update state, exit.

## Cycle budget

~10 minutes of real work per cycle. If a step is taking longer, snapshot progress to `ops/active/<task>/notes.md` and exit — the next cycle continues.

## Step 0 — Orient

1. Read `ops/state.json` fully.
2. Read the last 20 lines of `ops/LOG.md`.
3. `ls ops/inbox/URGENT/ ops/inbox/submit/ ops/inbox/approve/ ops/inbox/decide/ ops/active/` — know what's in flight and what the user may have left for you.

Bump `cycle_count` in state immediately so subsequent steps see it.

## Step 1 — Process user responses

For each file in `ops/inbox/approve/` or `ops/inbox/decide/` whose filename ends in `.answered.md`:

1. Read the file. The user appended their decision under a `## Answer` header.
2. Apply the decision to the relevant task in `ops/active/`.
3. Move the file to `ops/shipped/inbox-answered/<timestamp>-<slug>.md`.
4. Log: `inbox-processed <slug> <outcome>`.

If `ops/inbox/URGENT/` is non-empty: halt all NEW work until the user clears it. Continuing existing work is OK. Write one new line to `ops/inbox/URGENT/STATUS.md` noting that the pipeline is in degraded mode.

## Step 2 — Continue active work

For each directory under `ops/active/`:

1. Read `ops/active/<task>/notes.md` to see where the previous cycle stopped.
2. If it's a bounty task → follow `ops/runbooks/01-bounty-workflow.md` from the `Resume` section.
3. If it's an audit task → follow `ops/runbooks/02-audit-workflow.md` from the `Resume` section.
4. Before exiting each task, append to `notes.md`: timestamp, what ran, what's next.

Hard rule: never have more than `defaults.max_concurrent_bounties` bounties or `defaults.max_concurrent_audits` audits active at once. If over quota, do NOT start new work.

## Step 3 — Start new work (if capacity)

If active bounty count < `max_concurrent_bounties` AND blockers permit:

1. Open `ops/queue/bounties.md`.
2. Pick the top-ranked unclaimed entry.
3. Before claiming: re-verify the issue is still open with 0–2 competing PRs (`gh issue view` + check linked PRs). If stale, mark entry `DROPPED` in the queue, log reason, try the next one.
4. Start a new `ops/active/bounty-<id>/` directory with an initial `notes.md`.
5. Follow `ops/runbooks/01-bounty-workflow.md` from `Phase 1`.

If active audit count < `max_concurrent_audits` AND `defaults.immunefi_enabled`:

1. Open `ops/queue/audit-targets.md`.
2. Pick the top-ranked program not currently in rotation.
3. Start `ops/active/audit-<program>/` with a fresh `notes.md`.
4. Follow `ops/runbooks/02-audit-workflow.md` from `Phase 1`.

## Step 4 — Housekeeping

1. Update `ops/state.json`:
   - `last_run_at` = now
   - `cycle_count` += 1
   - `bounties.in_progress`, `audits.in_progress` = current active dirs
   - `stats.*` recalculated from shipped/
2. Append a one-line summary to `ops/LOG.md`.
3. If any task has been active > 7 days with no merge/submission, move it to `ops/inbox/decide/` with a "kill or continue?" question.

## Step 5 — Exit

Print a 5-line status report:

```
cycle <N>  at <timestamp>
active bounties: <list>
active audits: <list>
inbox URGENT: <count>  submit: <count>  approve: <count>  decide: <count>
next cycle: <interval>
```

Do NOT post to GitHub, do NOT push commits, do NOT send messages unless a step explicitly required it. Exit clean.

## Hard rules — violate none

- Never push to `main` of any repo. Always a feature branch.
- Never force-push. Never skip hooks. Never `--amend` published commits.
- Never post exploratory comments on issues you haven't claimed.
- Never submit a bounty PR under a GitHub handle other than `defaults.github_handle` once set.
- Never submit an Immunefi report automatically — always draft to `ops/inbox/submit/` for user review.
- Never run security tooling against live targets. Local clones only.
- Never commit secrets, tokens, or `.env` files.
- Never fabricate a bounty, issue, or audit finding. Real links or abort.
- If a step fails twice, stop and write a `decide/` inbox item. Do not brute-force.

## Degraded modes

- **No GitHub auth**: skip bounty steps, do audit-only until URGENT is cleared.
- **No Immunefi KYC**: draft reports anyway, queue in `ops/inbox/submit/` awaiting user.
- **No payout method**: same as above — work proceeds, payouts queue.
- **Queue empty**: run `ops/runbooks/05-queue-refresh.md` (if it exists) to scout new targets. If not, log `queue-empty` and exit.

## Graceful degradation for zero-human days

If `ops/inbox/URGENT/STATUS.md` says user has been absent > 48h: reduce `max_concurrent_*` to 1, slow new-work starts, keep existing work alive by responding to review comments with conservative fixes. Do not let in-progress PRs go stale.
