# Operations Discipline Runbook

Non-negotiable rules that apply to every cycle regardless of workflow. Read this before every risky action.

## Never

- Never push to `main` / `master` / default branch of any external repo
- Never force-push to a branch that has been reviewed by a human
- Never `--amend` a commit that has been pushed
- Never skip hooks (`--no-verify`, `--no-gpg-sign`)
- Never commit secrets, tokens, API keys, `.env`, private keys, RPC URLs
- Never run any security tool against a live production target — local clones only
- Never submit an Immunefi report automatically — always route through `inbox/submit/`
- Never open a PR under a handle other than `state.json` → `defaults.github_handle`
- Never post exploratory or speculative comments on issues you haven't claimed
- Never claim a bounty you don't intend to finish within the estimated window
- Never touch out-of-scope assets in any program, even during research
- Never fabricate data: no fake bounty links, no invented CVE numbers, no hallucinated issue IDs
- Never suppress a failing test to make CI green — fix the root cause or abort
- Never add an AI watermark to code or commits
- Never disclose a finding publicly before the program permits it
- Never mass-bump dependencies as a "fix"
- Never ship a PR with TODOs introduced by this work
- Never delete `ops/shipped/` or `ops/LOG.md` — they are audit trail

## Always

- Always read `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, and `.github/pull_request_template.md` before touching code
- Always establish a green baseline before writing any fix
- Always write a regression test that fails on pre-fix code and passes on post-fix code
- Always run the full lint/format/type-check/test suite locally before pushing
- Always self-review the diff line by line before marking a PR ready
- Always route judgment calls through `inbox/decide/` rather than guessing
- Always log every action in `ops/LOG.md` with timestamp and cycle number
- Always update `state.json` at the end of every cycle
- Always use feature branches with descriptive names
- Always close unused clones in `ops/active/` when a task ships
- Always record the reason when abandoning or dropping a queue item
- Always re-verify an issue is still unclaimed and low-competition immediately before starting work
- Always check for duplicate-finding signals before drafting an Immunefi report
- Always include a Foundry (or equivalent) PoC with smart-contract findings
- Always respect program scope down to the exact contract address
- Always wait for explicit user decision on `URGENT` inbox items before resuming blocked work

## Blast radius & reversibility discipline

Before any irreversible action — push, comment, submit, delete, rm, force — stop and ask:

1. What does this do?
2. Who sees it?
3. Can I undo it?
4. If it's wrong, what's the cost?

If the blast radius exceeds your local clone AND the action is not explicitly in a runbook, stop and write an `inbox/decide/` item.

## Escalation

If a step fails twice, do NOT retry a third time. Stop, snapshot, write an `inbox/decide/` item describing:

- What was attempted
- What errors occurred
- What the current hypothesis is
- What decisions the user can make to unblock

Then exit the cycle. The next cycle picks up after the user answers.

## Reputation protection

Your GitHub handle is the most valuable asset in this pipeline. Every action compounds or corrupts it. If a choice is between "ship faster" and "ship cleaner," always choose cleaner. A single bad PR on a high-visibility repo can close doors that took months to open.

Apply the same logic to Immunefi: one padded-severity report sours triagers for every future submission. Be the researcher whose reports are always worth reading.
