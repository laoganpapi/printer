# Audit Targets Queue

Immunefi programs in rotation for continuous smart-contract review. Seeded 2026-04-12 from the security-prep research agent.

**Re-verification rule**: Before starting work on any program, open the Immunefi page and re-check scope, rewards, and safe-harbor clause. Programs change frequently.

**Format per entry:**
```
### <rank>. <program>  [status]
- url: <immunefi link>
- repo: <github source link if public>
- payout_tiers: <critical / high / medium / low>
- in_scope: <contract list>
- safe_harbor: <verified / unknown / rejected>
- last_audit: <date / url of most recent published audit>
- known_issues: <link to list>
- notes: <why it fits a code-reading specialist>
```

**Status values**: `unreviewed` · `IN_ROTATION` · `DRY` · `PAUSED` · `REJECTED`

---

### 1. Compound  [unreviewed]
- url: https://immunefi.com/bug-bounty/compound/
- repo: github.com/compound-finance/compound-protocol (v2) + github.com/compound-finance/comet (v3)
- payout_tiers: historically up to ~$1M critical
- in_scope: Compound v2 + v3 contracts — verify current list on program page
- safe_harbor: verified (Immunefi standard)
- last_audit: multiple public audits available in repo audits/ folders
- known_issues: check program page
- notes: Canonical DeFi lending protocol. Extensively documented. Rich hunting ground for accounting / share-math / liquidation-logic bugs. Best teaching codebase — start here.

### 2. MakerDAO / Sky  [unreviewed]
- url: https://immunefi.com/bug-bounty/makerdao/
- repo: github.com/makerdao/* (many repos)
- payout_tiers: historically up to ~$10M for crits on top tier
- in_scope: Maker/Sky protocol contracts — verify current list; multiple products
- safe_harbor: verified
- last_audit: extensive public audit history
- known_issues: large, check program page carefully
- notes: Huge codebase with heavy prior research. High ceiling but competitive. Only after shipping 1-2 reports elsewhere — needs pattern-matching against years of findings.

### 3. Chainlink  [unreviewed]
- url: https://immunefi.com/bug-bounty/chainlink/
- repo: github.com/smartcontractkit/ccip + github.com/smartcontractkit/chainlink
- payout_tiers: historically up to seven figures for crits
- in_scope: Chainlink contracts + CCIP — verify
- safe_harbor: verified
- last_audit: public audits on repo
- known_issues: check program page
- notes: Oracle logic is rich terrain for economic / logic bugs. Cross-chain (CCIP) adds surface. Good match for static-analysis edge.

### 4. Lido  [unreviewed]
- url: https://immunefi.com/bug-bounty/lido/
- repo: github.com/lidofinance/lido-dao
- payout_tiers: historically up to ~$2M
- in_scope: Lido staking contracts — verify
- safe_harbor: verified
- last_audit: multiple public audits
- known_issues: check program page
- notes: Liquid staking has subtle accounting bugs (share/pooled-ETH math, oracle reports, withdrawal queue). Classic "read carefully, find logic flaw" territory.

---

## Rotation strategy

**Month 1 — Pick one program** (recommendation: Compound).
- Read every public audit of the program first (prior art sweep is 20% of budget)
- Produce architecture map
- Work through top 10 review paths
- Draft any findings that break invariants

**Month 2 — Add a second program** (recommendation: Lido) once the first is fully mapped.

**Month 3+ — Maintain 2 active programs** with weekly rotation. Never more than 1 concurrent audit at a time per `state.json` → `defaults.max_concurrent_audits`.

## Discipline reminders

- Foundry PoC is mandatory for every submission. No PoC = no submission.
- Duplicate-check hard before drafting a report. Immunefi triagers downgrade padded severity.
- All work happens in local Foundry fork tests. Never touch mainnet.
- Reports draft to `ops/inbox/submit/` — user submits through the Immunefi UI, not automatically.
- KYC must be completed before any payout clears. Start the KYC process in `inbox/URGENT/` week 1.

## Programs considered but not seeded

- **Uniswap v3 / v4** — very competitive, high audit density; revisit after 2+ mediums landed elsewhere
- **Aave** — similar profile to Compound, add as rotation slot 3 once comfortable
- **Arbitrum / Optimism rollup contracts** — infra-level, high payouts, very competitive
