# 001 — One-Time Setup (BLOCKING)

**Status**: open
**Created**: 2026-04-12
**Blocks**: all new pipeline work until at least items 1–3 are complete
**Estimated user time**: ~60 minutes total, spread across multiple sittings

The pipeline cannot earn money without a payout path, a GitHub identity, and at least one platform account. Everything below is one-time friction — after this week you should never see it again.

Work top to bottom. Mark each item `[x]` when done. When all items are `[x]` OR items 1–3 are `[x]`, move this file to `ops/shipped/inbox-answered/001-one-time-setup.done.md` so the pipeline unblocks.

---

## Items

### [ ] 1. Git identity + GitHub handle (5 min)

The pipeline opens PRs as *you*. It needs your GitHub identity configured in this environment.

- [ ] Confirm your GitHub username. Write it in `ops/state.json` → `defaults.github_handle`.
- [ ] Run:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "<the email on your GitHub account>"
  ```
- [ ] Confirm `gh auth status` shows you logged in. If not: `gh auth login` and pick HTTPS + browser.
- [ ] Confirm you can push to a test repo under your account.

**Why blocking**: without this, I can't open PRs. No PRs, no income.

---

### [ ] 2. Algora account + Stripe Connect KYC (15 min, then 7–14 day wait)

Algora is the primary OSS bounty platform. Stripe Connect onboarding has a 7–14 day first-payout delay — the clock starts the day you submit, so **start this today even if you do nothing else**.

- [ ] Sign up at https://algora.io using GitHub OAuth
- [ ] Begin Stripe Connect onboarding from your Algora profile settings
- [ ] Complete the KYC form (legal name, DOB, address, tax ID or equivalent)
- [ ] Link your bank account for payouts
- [ ] Submit. Note the date in `state.json` → `defaults.payout_methods_ready.algora_stripe = "submitted:<YYYY-MM-DD>"`. When approved, change to `"approved:<date>"`.

**Why blocking**: merged bounty payouts sit in escrow until Stripe is approved. Start the clock.

---

### [ ] 3. Decide: accept XTM tokens? (2 min)

Most bounties on the seeded queue are from the Tari project, paid in XTM tokens (~$0.0007 each as of seed date). A medium bounty (60k XTM) is worth ~$42 USD if converted.

- [ ] Decide yes or no. Write the answer in `state.json` → `defaults.accept_xtm_tokens` (true / false).

If **yes**: the pipeline will pick Tari bounties as cheap shakedown runs while the Stripe Connect clock is ticking.

If **no**: the pipeline skips all Tari bounties and waits for Stripe approval before earning anything. Slower start but cleaner cash flow.

**Recommendation**: **yes** unless you're ideologically opposed to holding illiquid tokens. Tari is the only way to ship merges in the first 2 weeks while Stripe is pending.

If you pick yes: add a Tari wallet. Follow https://tari.com/downloads → set up a wallet → copy your receiving address into `state.json` → `defaults.payout_methods_ready.tari_wallet = "<address>"`.

---

### [ ] 4. Immunefi account + KYC (30 min, then variable wait)

Immunefi is the fat-tail engine. KYC is mandatory for payout on any finding; without it, drafted reports pile up indefinitely.

- [ ] Sign up at https://immunefi.com
- [ ] Complete researcher profile
- [ ] Submit KYC (government ID + proof of address; varies by jurisdiction)
- [ ] Mark in `state.json` → `defaults.payout_methods_ready.immunefi_kyc = "submitted:<YYYY-MM-DD>"`, update to `"approved"` when cleared

**Why not strictly blocking**: audit work can proceed without KYC. Drafts queue to `inbox/submit/` and wait. But no payout clears until this is done, so don't delay.

**Opt out**: if you want to turn Immunefi OFF entirely, edit `state.json` → `defaults.immunefi_enabled = false` and mark this item `[x] SKIPPED`.

---

### [ ] 5. Confirm allowed languages (1 min)

Defaults in `state.json`:
```
["typescript", "javascript", "python", "rust", "go", "solidity"]
```

- [ ] Delete any language you don't want me shipping PRs in under your handle.
- [ ] Save.

No action needed if the defaults are fine.

---

### [ ] 6. Confirm quality bar (1 min)

Defaults in `state.json`:
```
quality_bar: "gold-plated"
```

Options:
- `"gold-plated"` — every PR is self-reviewed, routed through `inbox/approve/` before Ready-for-Review. Slower, better reputation.
- `"normal"` — self-review only, straight to Ready. Faster, some noise.
- `"volume"` — minimum viable PR, faster iteration, more risk.

- [ ] Keep `"gold-plated"` (recommended for first 10 merges) or change and save.

---

### [ ] 7. (Optional) Polar.sh backup account (5 min)

Polar's bounty feature is in reduced-maintenance mode as of seed date, but some repos still use it. Having an account costs nothing.

- [ ] Sign up at https://polar.sh with GitHub OAuth
- [ ] Start Stripe Express onboarding
- [ ] Mark `state.json` → `defaults.payout_methods_ready.polar_stripe = "submitted:<date>"`

Skippable. Not blocking.

---

## When you're done

After items 1–3 are complete:

1. Move this file: `mv ops/inbox/URGENT/001-one-time-setup.md ops/shipped/inbox-answered/001-one-time-setup.done.md`
2. Remove the `user_has_not_completed_one_time_setup` blocker from `state.json` → `blockers`
3. Kick off the loop:
   ```
   /loop 2h Execute ops/runbooks/00-master-pipeline.md
   ```

The next cycle will see the cleared blocker and start picking bounty #1 from the queue.

## Questions or stuck?

If any step is broken or you need me to do something different, leave a note at the bottom of this file under `## Answer` and the next loop cycle will read it and respond.

## Answer

<!-- Leave any questions or adjustments here. Next cycle will read and act. -->
