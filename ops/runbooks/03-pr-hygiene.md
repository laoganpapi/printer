# PR Hygiene Runbook

Checklists the bounty workflow invokes before pushing a PR. Gold-plated quality bar is the default. Every box must be checked or the PR waits.

## Universal checks

- [ ] Branch name follows `fix/<issue>-<slug>` or `feat/<issue>-<slug>` convention
- [ ] No commits to `main` / `master` / default branch
- [ ] No force-pushes
- [ ] No skipped hooks (`--no-verify`)
- [ ] No unrelated file changes in the diff
- [ ] No debug prints, `console.log`, `dbg!`, `fmt.Println` left in
- [ ] No `TODO` / `FIXME` / `XXX` comments introduced
- [ ] No secrets, tokens, API keys, `.env` files committed
- [ ] No AI watermarks anywhere (no "Claude", "Co-authored-by: Claude", no emoji in code/commits unless the repo already uses them)
- [ ] Commit messages match the repo's convention (conventional commits if used)
- [ ] Author identity matches `state.json` → `defaults.github_handle`

## Python checklist

- [ ] `ruff check --fix .` clean (or `flake8` if the repo uses that)
- [ ] `ruff format .` / `black .` clean — use whichever the repo uses
- [ ] `mypy` on touched modules clean; no new `# type: ignore`
- [ ] `pytest -q` green; new tests use existing fixtures
- [ ] Docstrings in repo's chosen style (Google / NumPy / reST)
- [ ] Imports sorted per repo convention (isort profile / ruff's `I` rule)
- [ ] Python version floor respected (check `python_requires` / `pyproject.toml`)
- [ ] New deps added to `pyproject.toml` + lockfile regenerated via the repo's tool (poetry / uv / pip-tools)

## TypeScript / JavaScript checklist

- [ ] `eslint .` clean, zero new warnings
- [ ] `tsc --noEmit` clean, no new `any`, no `@ts-ignore`
- [ ] `prettier --write` clean
- [ ] `pnpm test` / `npm test` / `bun test` green (whichever the repo uses)
- [ ] Package manager matches repo (never mix lockfiles)
- [ ] No new default exports if repo prefers named
- [ ] New deps added via the repo's CLI, not by manual `package.json` edit
- [ ] Public APIs have JSDoc if adjacent files do; internal code doesn't if they don't
- [ ] `workspace:*` protocol respected in monorepos

## Rust checklist

- [ ] `cargo fmt --all -- --check` clean
- [ ] `cargo clippy --all-targets --all-features -- -D warnings` clean
- [ ] `cargo test --all-features` green
- [ ] `cargo doc --no-deps` builds without warnings
- [ ] MSRV respected (check `rust-toolchain.toml` and `Cargo.toml` `rust-version`)
- [ ] No new `unsafe` unless adjacent code uses it
- [ ] No new `unwrap()` / `expect()` on non-test paths unless adjacent code does
- [ ] Error types use the repo's existing error enum or `thiserror`/`anyhow` — match pattern
- [ ] Feature flags gated correctly
- [ ] `cargo-deny` clean if `deny.toml` exists

## Go checklist

- [ ] `gofmt -s -d .` clean
- [ ] `go vet ./...` clean
- [ ] `golangci-lint run` clean with repo's `.golangci.yml`
- [ ] `go test ./...` green
- [ ] New files have the repo's license header if existing files do
- [ ] Exported symbols have doc comments
- [ ] Errors wrapped with `fmt.Errorf("...: %w", err)` per repo convention
- [ ] `context.Context` passed explicitly; no `context.TODO()` in new code
- [ ] `go mod tidy` run; `go.sum` committed

## Solidity checklist (for any contract PR, not audit reports)

- [ ] `forge fmt --check` clean
- [ ] `forge build` clean with the repo's solc version
- [ ] `forge test -vvv` green, including new tests
- [ ] `slither .` produces no new findings (acceptable noise = noted in PR body)
- [ ] No new `unchecked` blocks without justification
- [ ] No loosened visibility on existing functions
- [ ] Events emitted for every state change that matches existing patterns
- [ ] Gas snapshot updated if repo tracks `.gas-snapshot`

## PR body template (reusable)

```markdown
## Summary
<One paragraph: what this PR does and why.>

Closes #<ISSUE_NUMBER>

## Approach
<One paragraph: the core idea of the fix/feature.>

## Acceptance criteria
<Copy the checklist verbatim from the issue, check each satisfied:>
- [x] <criterion 1>
- [x] <criterion 2>

## How to test
​```bash
<exact commands a reviewer runs to verify>
​```
Expected result: <one line>.

## Scope / risk
- **Touched:** <files or subsystems>
- **Not touched:** <adjacent code I deliberately left alone>
- **Migration / breaking:** <none | details>

## Checklist
- [x] Full test suite passes locally
- [x] Lint / format / type-check passes locally
- [x] New regression test added
- [x] CONTRIBUTING.md guidelines followed
- [x] No unrelated changes
```

If the bounty platform is Algora, append `/claim #<N>` on its own line at the very end of the body.
