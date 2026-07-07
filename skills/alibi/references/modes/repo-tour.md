# repo-tour — the precinct tour mode

> "Welcome to the precinct. Before you touch anything, let me show you where the bodies are buried."

Read this file when a newcomer asks to be **onboarded to a repo through its history**
— "give me the tour", "what should I know before touching this codebase?", "where are
the bodies buried?", "walk me through this repo's history". This mode is not a code
explainer (what the modules do) — it is a *history* briefing: where the scars are,
which files churn, what got reverted, and what has quietly held the roof up for years.

All SKILL.md rules stay in force: voice, evidence IDs, honest gaps. The output is a
**tour of scenes**, not a single case — but every scene is pinned to evidence, and
the tour still ends with a disposition and a 🔗 Related footer.

## The tour routine

Collect the precinct facts first — all cheap, all git-only:

```bash
git log --format= --name-only | sort | uniq -c | sort -rn | head -15   # churn ranking
git log --oneline --all --grep 'revert' -i                              # the scars
git log --oneline --diff-filter=A --format='%ad %h %s' --date=short | tail -5  # the founders
git shortlog -sn --no-merges | head -10                                 # the witnesses
ls .git-blame-ignore-revs 2>/dev/null && cat .git-blame-ignore-revs     # blame hygiene
git log --oneline -5 -- <top-churn file>                                # what churns it NOW
```

Scope churn to a recent window too (`git log --since='1 year ago' ...`) — a file that
churned in 2021 and froze is a different story from one still hot today. If `gh` is
available, `gh pr list --state merged --limit 30 --json title,comments` finds the
most-argued PRs; without it, revert chains and message archaeology carry the tour.

## The five scenes

Pick the five most load-bearing stories the data supports. The canonical lineup —
adapt to what the repo actually shows, and drop a scene honestly if the repo doesn't
support it (a young repo may have no scars yet):

1. **The hotspot** — the highest-churn file(s), with the count, *why* it churns
   (read its recent commits: is it feature growth, config sprawl, or a design that
   makes every change land there?), and what that means for the newcomer's first PR.
   **Verify the commits' claims against the current code before repeating them** —
   a commit titled "add retry on 503" may have only added a constant nobody ever
   wired in. History says what was *intended*; only the code says what's *true*,
   and a dead constant that promises behavior is exactly the landmine a newcomer
   needs told about.
2. **The scar** — the most instructive revert/incident saga: what was tried, why it
   came back out, where the rule it taught is written down (ADR, postmortem). This
   scene teaches the repo's hardest-won constraint.
3. **The old guard** — the load-bearing file(s) nearly untouched since the founding
   commits. Old and stable means *encodes assumptions everyone forgot* — touch it
   with a case file, not a drive-by refactor.
4. **The noise layer** — repo-wide reformats/renames and whether
   `.git-blame-ignore-revs` exists. This is practical survival: it decides whether
   the newcomer's `git blame` will lie to them on day one, and it's your one
   configuration tip (`git config blame.ignoreRevsFile .git-blame-ignore-revs`).
5. **The live case** — what the recent log says the team is working on now, so the
   newcomer knows which floor of the precinct is currently busy.

Each scene: 3-6 lines, one verdict-flavored tag where it fits naturally (the scar is
usually a closed case; the old guard is standing evidence), every claim pinned to an
exhibit (E-n: a SHA, a churn count, a file). People are witnesses — the shortlog top
authors are "the veterans on this floor", never "who to blame".

## Tour format

```
🗂️  PRECINCT TOUR — <repo name>
────────────────────────────────────────────────────────
   <one-line character read of the repo: age, size, tempo>

🎬 Scene 1 — The hotspot: <file> (E-1: N commits, M in the last year)
   ...
🎬 Scene 2 — The scar: <the revert saga> (E-2, E-3)
   ...
(3 · 4 · 5 likewise)

🧾 Exhibits
   E-1 ...

⚖️  Disposition (the decision is yours)
   Start here: <concrete first move>. Don't touch <X> without opening a case
   first. Set `git config blame.ignoreRevsFile ...` before your first blame.

🔗 Related
   SHA: <founding> · <scar chain> · <reformat>   Docs: <ADR/postmortem paths>
```

The tour has no single verdict — it is five small rulings. But it must still end
with a concrete disposition (the newcomer's first move and the one thing not to
touch), and the 🔗 Related footer so any scene can be reopened as a full case:
offer — one line — to open a why-not-who or commit-to-story case on whichever
scene made the newcomer's eyebrows go up.
