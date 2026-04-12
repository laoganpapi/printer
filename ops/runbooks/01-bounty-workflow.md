# OSS Bounty Workflow Runbook

Invoked by the master pipeline when a new bounty is picked or an active one is resumed.

## Phase 1 — Claim & setup (new bounty)

1. Read the queue entry. Note: issue URL, repo URL, est. payout, est. hours, competing PRs.
2. Re-verify live:
   - `gh issue view <URL> --comments` — confirm open, unassigned to others, not locked
   - List linked PRs. If > 2 open and recent (< 7 days), abort. Mark queue entry `DROPPED (too-competitive)`.
3. Read repo's `README.md`, `CONTRIBUTING.md`, `.github/pull_request_template.md`, and any `AGENTS.md` / `CLAUDE.md`. Extract the 5 most binding rules into `ops/active/bounty-<id>/rules.md`.
4. Post a brief claim comment on the issue (ONLY if the repo's process requires it — many Algora repos use `/attempt` or similar). Template:
   > Claiming this. Plan: <one-sentence approach>. PR up within <N> days.
5. Clone to `ops/active/bounty-<id>/work/`. Check out a new branch `fix/<issue-number>-<slug>` or `feat/...`.
6. Install deps using the exact command the README prescribes. Log the command.
7. Establish a green baseline: run the full test suite. Record exit code and pass count.
8. Write initial `notes.md`:
   ```
   # bounty-<id>
   issue: <url>
   repo: <url>
   claimed: <timestamp>
   payout_est: <amount>
   phase: 1-claimed
   baseline_tests: <N passed>
   next: reproduce the bug / understand the feature
   ```

## Phase 2 — Reproduce / design surface

For a **bug**:
- Write a failing test that captures the bug. Commit nothing yet. Save repro command in `notes.md`.

For a **feature**:
- Re-read the issue's acceptance criteria. Map each bullet to a file/module in the codebase. Write the design as `notes.md` → `## design`.
- If ambiguous: write a `decide/` inbox item with the 2-3 interpretations and exit. Do NOT guess and implement the wrong thing.

## Phase 3 — Localize root cause (bugs only)

1. Trace from the failing test into source. Use ripgrep, LSP, git blame.
2. Write a 5-bullet `cause & fix` note to `notes.md`.
3. If the root cause is clear and low-risk: proceed to Phase 4.
4. If the root cause is ambiguous or the fix touches sensitive code: write a `decide/` inbox item with the hypothesis and exit.

## Phase 4 — Minimum-diff fix

- Smallest diff that satisfies every acceptance criterion.
- Match the repo's style exactly: naming, error handling, logging, comments.
- No speculative refactors. No unrelated file touches. No new dependencies unless the issue explicitly permits.
- If a new dep is needed: write a `decide/` inbox item first.

## Phase 5 — Regression test

- A test that fails on the pre-fix code and passes on the post-fix code.
- Use the repo's existing test framework and location. Mirror an adjacent test's structure.

## Phase 6 — Verify (must be green before PR)

Run in order, fix before proceeding:

1. Full test suite.
2. Lint (eslint / ruff / cargo clippy -D warnings / golangci-lint / scalafmt).
3. Format (prettier / black / cargo fmt / gofmt).
4. Type-check (tsc --noEmit / mypy / --).
5. Any repo-specific pre-pr command (`pnpm check`, `cargo xtask ci`, `make lint`, etc).

If any step fails after 2 fix attempts, snapshot and escalate via `decide/`.

## Phase 7 — Commit & push

- 1-2 commits max. Subject lines match the repo's convention (conventional commits if used).
- Author = user's configured git identity. NO `Co-authored-by: Claude`. NO AI watermarks anywhere in code or commit messages.
- Push the feature branch.

## Phase 8 — Draft PR

Use `gh pr create --draft`. Title matches repo convention.

Body must include:
- `Closes #<issue-number>`
- One-paragraph problem statement
- One-paragraph solution approach
- A checklist mirroring the issue's acceptance criteria, each checked `[x]`
- `## How to test` with exact copy-pasteable commands
- `## Risk / scope` section noting what this PR does NOT touch
- If the repo is on Algora/Polar and the bounty platform uses a claim string (e.g. `/claim #<n>`), include it on its own line at the end

## Phase 9 — Self-review

1. `git diff origin/<default>...HEAD` — read every hunk.
2. Check against `rules.md` line by line.
3. Confirm no debug prints, no unrelated formatting, no new TODOs.
4. If clean: flip PR from Draft → Ready for Review. Add a link to `ops/active/bounty-<id>/notes.md` → `phase: 9-review`.
5. Write an `approve/` inbox item: "PR #N open, checks pending, self-review passed — any concerns before human sign-off?" (Only if `defaults.quality_bar == "gold-plated"`; otherwise skip and go straight to Ready.)

## Resume (for active bounties)

When the master pipeline resumes an active bounty, read `notes.md` → `phase:` and jump to that phase. Additional resume actions:

- Check PR status: `gh pr view <N> --json state,reviews,comments`.
- If new review comments: read each, address actionable ones with new commits, leave a reply on non-actionable ones.
- If checks went red post-push: read failure, fix, push. Log attempt count.
- If PR merged: move `ops/active/bounty-<id>/` → `ops/shipped/bounty-<id>/`, update `state.json` → `bounties.completed`, log payout-pending status.
- If PR closed without merge: move to `ops/shipped/bounty-<id>-closed/`, write a retro note.

## Abort conditions

Abandon the bounty and mark `DROPPED` in the queue if:
- A competing PR is merged first.
- The maintainer comments "we're going a different direction" or similar.
- Acceptance criteria change significantly mid-work.
- Three consecutive review rounds on the same concern with no convergence.
- Tests or CI are fundamentally broken on the repo's main branch (not your fault).

Always log the abort reason. Retrospectives in `ops/LOG.md` use these signals.
