# printer

A background income pipeline that runs on `/loop` inside Claude Code.

The goal: beat a passive DeFi vault by stacking two engines that run continuously with a ~10 min/day human checkpoint.

## Engines

1. **OSS bounty farming** — scan Algora/Polar/repo-native bounty queues, pick winnable issues, clone, fix, test, open PR, respond to review, collect. Steady cashflow floor.
2. **Immunefi audit hunting** — read top-funded smart contract programs, find invariant violations, build Foundry PoCs, draft reports. Variance-heavy, power-law tail.

Optional tertiary engines (Gumroad products, Chrome extensions) can be added later once the two above are producing.

## Operation

A single `/loop` invocation runs the master pipeline on an interval (default every 2 hours). Each cycle:

1. Reads `ops/state.json` and recent `ops/LOG.md` for context
2. Processes anything the user left in `ops/inbox/` as a response
3. Continues in-progress work in `ops/active/`
4. If capacity (< 2 concurrent items), picks the next target from `ops/queue/`
5. Writes any user-action items to `ops/inbox/`
6. Updates state and log, exits cleanly

## Daily ritual (target: 10 min)

Open `ops/inbox/` and process in this order:

1. `URGENT/` — must action today (one-time setup, broken auth, blocked decisions)
2. `submit/` — paste-and-click: copy a drafted report into the platform UI and submit
3. `approve/` — skim a PR diff, give thumbs up / down
4. `decide/` — answer judgment calls I can't make alone

Close laptop. The pipeline handles the rest.

## Directory layout

```
ops/
├── README.md             # You are here (this file is repo root README)
├── state.json            # Pipeline state: what's in flight, what's done
├── LOG.md                # Rolling activity log, append-only
├── runbooks/             # Step-by-step playbooks the pipeline executes
├── queue/                # Ranked work queues (bounties, audits)
├── inbox/                # User-facing action items
├── active/               # In-progress work (clones, notes, drafts)
├── drafts/               # Finished drafts awaiting approval
└── shipped/              # Archive of everything that earned
```

## How to override defaults

Edit `ops/state.json` → `defaults`. The next loop cycle will read the new values and adjust.

## Kicking off the loop

```
/loop 2h Execute ops/runbooks/00-master-pipeline.md
```

Run that once. It will invoke itself on the interval. Check back daily for the inbox ritual.
