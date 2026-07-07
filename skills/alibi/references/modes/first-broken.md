# first-broken — the stakeout mode

> "You don't know who did it. Fine. We sit here all night until someone walks past the camera."

Read this file when the user reports that something **used to work and now doesn't**,
and wants the commit where it broke — "this worked last week", "when did X break?",
"find the commit that broke this", "bisect this". why-not-who starts from a suspicious
line; this mode starts from a **symptom** and has no line to blame yet.

All SKILL.md rules stay in force: voice rules, evidence taxonomy, the three verdicts,
the case file structure. This file adds the stakeout routine.

## The stakeout routine

### Step 1 — Take the statement (before touching anything)

A bisect is expensive; a bisect on a bad premise is worthless. Establish three facts,
asking the user only for what you cannot determine yourself:

1. **A probe** — a command that exits 0 when the behavior is good and non-zero when
   bad. If the user gave only a symptom ("`parseDuration('1h30m')` returns the wrong
   value"), build the probe yourself: a one-liner (`node -e`, `python -c`, a test
   filter, a `curl | grep`) is usually enough. Write it to a script file outside the
   repo (a temp/scratch dir) so checkouts don't sweep it away.
2. **A known-good ref** — a tag, SHA, or date the user believes worked
   (`git rev-list -1 --before=<date> HEAD` turns "last month" into a SHA).
3. **The bad ref** — usually HEAD.

**Validate the probe before the stakeout**: it must fail on the bad ref and pass on
the good ref. If it fails on both, the good ref is wrong (widen backwards); if it
passes on both, the symptom isn't what the user thinks — stop and report that finding,
it's a case-changing fact.

**Try the cheap lead first.** If the symptom names a distinctive string, config key, or
function, `git log -S'<fragment>' --oneline -- <path>` may hand you the culprit in one
command. Bisect is for behavioral breaks with no textual lead.

**Safety**: the probe will execute code from old commits. Don't put anything in the
probe you wouldn't run by hand, surface the probe command to the user before running
the bisect, and refuse probes that mutate state outside the repo (deploys, DB writes).
If the worktree is dirty, stop and ask — `git bisect` will refuse or, worse, mix
uncommitted changes into every checkout. Suggest `git stash` or running the stakeout
in a separate `git worktree add`.

### Step 2 — Run the stakeout

```bash
git bisect start <bad> <good>
git bisect run <probe-script>
```

`git bisect run` interprets the probe's exit codes: 0 = good, 1–124/126–127 = bad,
**125 = cannot test this commit** (build broken, deps missing) — bake 125 into the
probe for setup failures so an untestable commit is skipped instead of misjudged:

```bash
npm ci --silent 2>/dev/null || exit 125
node probe.js
```

Record the bisect log (`git bisect log`) — the stakeout log is an exhibit. **Always
`git bisect reset` afterwards, even when the run fails halfway.** And reset is not
enough on its own: it returns to wherever the bisect *started*, so if you validated
the probe by checking out the good ref first, you end up detached there. Finish by
confirming `git branch --show-current` prints the original branch — if it's empty,
check the branch out explicitly. The scene must be exactly as you found it; leaving
the repo detached is how the next investigator finds a crime scene you created.
(Validating the probe via `git worktree add` or `git show <ref>:<file>` avoids
touching the user's checkout at all.)

### Step 3 — Interrogate the culprit commit

The first-bad commit is where the stakeout ends and ordinary detective work resumes:

- `git show <sha>` — which hunk plausibly causes the symptom? Name the mechanism, not
  just the commit ("the anchored regex no longer matches combined forms"), and verify
  it: does reverting just that hunk (or reasoning through it) explain the probe flip?
- Judge **intent**: did this commit *mean* to change the behavior (message/PR/tests
  updated to the new behavior = deliberate) or is the break **collateral** (a refactor
  or cleanup whose stated purpose didn't require it)?
- Chase the paper trail for the culprit exactly as in Step 4 of the main routine
  (PR, issue, `gh` if available — same degradation rule).

### Step 4 — Verdict

The verdict rules on the breaking change's alibi:

- ⚖️ **JUSTIFIED** — the behavior change was deliberate and its reason still holds.
  The old behavior isn't coming back; disposition: adapt the caller / migrate.
- ⌛ **EXPIRED** — the break is collateral damage (the commit's real purpose didn't
  need it) or its reason has since lapsed. Disposition: fix or partially revert the
  breaking hunk *while preserving the commit's actual intent* — never a blind
  `git revert` of a commit that also did legitimate work.
- 🕳️ **COLD CASE** — the culprit is found but intent can't be established (thin
  message, no trail). Disposition: the probe now exists — add it as a regression test
  either way, and name the last witnesses.

Case file: standard SKILL.md structure. Include the stakeout as exhibits — the probe
command, good/bad refs, and the bisect log (steps count: a 200-commit range is ~8
probes). If the user's report itself narrowed the range ("worked at v0.1"), credit it
as a witness statement. Close with the 🔗 Related footer; offer — one line, never
automatically — a commit-to-story dossier on the culprit.
