# Immunefi Audit Workflow Runbook

Invoked by the master pipeline when a new audit is picked or an active one is resumed.

**Safety preamble**: this workflow is strictly defensive research on authorized, in-scope programs. All analysis happens on local clones. Never run any tool against a live target, a mainnet contract, or a deployed asset. Never attempt dynamic exploitation outside a local Foundry fork test. If a program's scope is unclear or missing safe-harbor language, abort and pick another target.

## Phase 1 — Scope & setup (new audit)

1. Read the queue entry. Note: program URL, in-scope contracts, payout tiers, source repo link.
2. Open the program page and extract:
   - Exact in-scope contracts (names, addresses, chain)
   - Out-of-scope assets (write these down explicitly — you will not touch them)
   - Severity classification and payout table
   - Safe-harbor clause (must reference good-faith security research; if absent, ABORT)
   - Known-issues list (do not waste time rediscovering these)
   - KYC requirement status
3. Write `ops/active/audit-<program>/scope.md` with all of the above.
4. Clone the in-scope repo to `ops/active/audit-<program>/src/`. Check out the exact commit/tag the program page references.
5. Set up a Foundry project in `ops/active/audit-<program>/poc/`:
   - `forge init --no-git`
   - Add the target repo as a `lib/` dep or copy the relevant contracts
   - Configure an RPC endpoint for forking (env-var only, never commit URLs)
6. Write initial `notes.md`:
   ```
   # audit-<program>
   program: <url>
   in_scope: <list>
   out_of_scope: <list>
   commit: <sha>
   safe_harbor: verified
   phase: 1-scoped
   next: read threat model and past audits
   ```

## Phase 2 — Prior art sweep

1. Read the project's published audits (linked from program page or repo's `audits/` folder). Summarize the findings that were already fixed. Add to `notes.md` → `## prior-art`.
2. Read hacktivity / disclosed reports for the same program if any exist on Immunefi.
3. Read any public post-mortems for similar protocols.
4. This phase is 20% of total time. Do not skip. Most duplicates get caught here.

## Phase 3 — Architecture map

Produce `ops/active/audit-<program>/architecture.md`:

- Contract inventory (name, LOC, role, external dependencies)
- Trust boundaries: who can call what, which functions are admin / timelocked / permissionless
- State transitions: how does value flow in and out
- External integrations: oracles, other protocols, token standards
- Upgrade pattern: proxy type, admin, upgrade delay
- Key invariants the protocol assumes (e.g. "total shares always = sum of individual balances")

Stop and write this before touching code-level analysis. It's the lens for everything that follows.

## Phase 4 — Prioritized review paths

Produce a ranked list of 10 code paths to review by hand, written to `ops/active/audit-<program>/review-paths.md`. For each:

- File(s) and line ranges
- One-sentence hypothesis (what could go wrong)
- Bug class (access control / accounting / reentrancy / oracle / signature / upgrade / other)
- Why it's worth the time (specific code smell, recent change, past incident pattern)
- Effort estimate (S/M/L)
- Expected value = (impact × likelihood) / effort

Bias toward classes that reward static analysis: access control, accounting/share math, oracle manipulation, signature replay, upgrade hooks, cross-function reentrancy, fee math, reward distribution, slippage / sandwich surfaces.

Skip classes needing infra you don't have: gas-griefing, MEV-only attacks, cross-chain relayer timing.

## Phase 5 — Deep dive on top 3 paths

For each of the top 3 paths, one at a time:

1. Read the code. Read it again. Read callers. Read callees.
2. State the invariant the code is trying to preserve.
3. Construct 3 attempts to break the invariant. Each is a short story: "attacker deploys X, calls Y, then Z."
4. Write a Foundry test that encodes the attempt.
5. Run it. If it reverts as expected: invariant holds on this path, write `NULL` and move on.
6. If it passes (invariant broken): **stop everything**. You have a candidate finding. Proceed to Phase 6.

Cap this phase at ~6 hours per path. If no candidate after 6 hours, move to the next path.

## Phase 6 — Candidate finding workup

When a Foundry test breaks an invariant:

1. Minimize the PoC. Shortest possible exploit sequence.
2. Classify severity per the program's published rubric (not your gut).
3. Quantify impact:
   - Critical: direct theft of a material fraction of TVL / permanent freezing of funds
   - High: significant theft under specific conditions, or governance subversion
   - Medium: conditional theft, griefing with economic damage, unauthorized state changes
   - Low: minor griefing, gas waste, non-critical state drift
4. Research duplicates harder than you want to:
   - Re-check the known-issues list
   - Search the program's Hacktivity for similar roots
   - Search public audits for the same invariant
   - Check the project's issue tracker and recent commits
5. If any duplicate signal exists: drop to the next severity or abandon. Do not submit obvious duplicates.
6. Draft the report using `ops/runbooks/06-audit-report-template.md` (Solidity variant).
7. Save the draft as `ops/drafts/audit-<program>-<finding-slug>.md`.
8. Write an `ops/inbox/submit/audit-<program>-<finding-slug>.md` item with:
   - The report (inline or linked)
   - Program submission URL
   - Checklist for the user (KYC status, Immunefi login, paste instructions)
   - A "what I'm uncertain about" section so the user can decide to submit, revise, or shelve
9. Update `notes.md` → `phase: 6-drafted`.

## Phase 7 — Continue reviewing other paths

After drafting a finding, do NOT stop the audit. Continue to path #4, #5, etc. One program can yield multiple findings. Each additional finding follows Phase 5 → Phase 6.

Exit the audit when either:
- All 10 paths reviewed
- Total time on program > 30 hours with zero candidates (move on, log as `DRY`)
- User responds to a submitted finding with a decision

## Resume (for active audits)

On resume, read `notes.md` → `phase:` and jump to the right section. Also:

- Check if the user responded to any `submit/` inbox items for this program. If submitted → record submission_id, move draft to `shipped/`. If rejected → log reason, learn.
- If the program updated scope or paused, abort the audit and write a `decide/` item.

## Hard rules — audit specific

- Never run contract analyzers against mainnet. Local fork only.
- Never send real transactions. Ever.
- Never submit a finding without a Foundry PoC. No PoC = no submission.
- Never submit a finding that duplicates a known-issue or published audit finding.
- Never submit a finding under the user's handle without an `approve/` or `submit/` inbox checkpoint.
- Never pad severity. Triagers downgrade padded reports and it hurts reputation.
- Never touch out-of-scope assets during research, even accidentally. If you find something out of scope, stop, note it, move on.
- Never exfiltrate private keys, RPC URLs, or secrets from test configs even if present.

## Abort conditions

- Program goes down / scope changes / contracts paused
- Safe-harbor clause removed
- User explicitly drops the program via a `decide/` response
- 30+ hours with zero signal

Log every abort in `ops/LOG.md` with a reason. Retros learn from these.
