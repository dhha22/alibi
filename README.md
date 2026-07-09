# alibi

<p align="center">
  <img src="docs/assets/alibi-hero.jpg" alt="alibi — the detective at his evidence board" width="820">
</p>

<sub>🇰🇷 한국어 설명은 <a href="./README.ko.md">README.ko.md</a></sub>

> **git blame tells you *who*. This tells you *why*.**
>
> 🌐 **[Landing page (EN)](https://dhha22.github.io/alibi/)** · **[소개 페이지 (KO)](https://dhha22.github.io/alibi/ko.html)**

`alibi` is a Claude Code skill: a homicide detective with a 20-year career and an
arrest rate of zero. Point him at a suspicious line and he skips the prettier commits
blame keeps framing people with, digs down to the commit that actually authored the
line's meaning, chases it through PRs, issues, and review threads, and rules on its
alibi:

- ⚖️ **JUSTIFIED** — the reason still holds. Don't touch it.
- ⌛ **EXPIRED** — the reason died. Safe to remove, precautions attached.
- 🕳️ **COLD CASE** — no reason found. Maximum caution; here are the last witnesses.

*No code is guilty. It just has a past.*

## Requirements

- [Claude Code](https://claude.com/claude-code)
- A **git** repository with history (alibi reads `git blame`, `git log`, `git show`)
- The [`gh` CLI](https://cli.github.com/), authenticated — *recommended, not required*.
  It unlocks PR and review-thread evidence; without it alibi falls back to git-only.

## Install

Install as a Claude Code plugin (two prompts):

```
/plugin marketplace add dhha22/alibi
/plugin install alibi@alibi
```

Or, if you prefer to install the skill by hand, copy the folder into your skills directory:

```bash
git clone https://github.com/dhha22/alibi
cp -r alibi/skills/alibi ~/.claude/skills/alibi
```

### Connect the `gh` CLI (recommended)

alibi chases each line's story through PRs, issues, and review threads — the reasons that
live nowhere in git objects. To reach them it needs the [GitHub CLI](https://cli.github.com/)
installed and authenticated. Without it, alibi still works from git history alone and says
so in the verdict.

```bash
# install the gh CLI (macOS · Homebrew)
brew install gh

# authenticate your GitHub account — one browser prompt
gh auth login

# verify the connection
gh auth status
```

## Try asking

- "Why is this timeout 30 seconds? `src/auth/session.ts:47`"
- "Can I delete this `setTimeout(resolve, 0)`? It looks pointless."
- "who wrote this and why — and don't tell me it was the prettier commit"
- "Give me the full story of commit 4f2a91c — why did this change land?"

## How it works

`git blame` names whoever *last touched* a line — which is routinely a prettier run, a
lint sweep, or a mass rename, not the person who gave the line its meaning. alibi runs the
excavation a senior engineer would do by hand, the same way every time:

1. **Blame, properly armed** — `git blame -w`, honoring any `.git-blame-ignore-revs` the
   repo ships. Never the bare `git blame` that lies.
2. **The noise-judgment loop** — for the commit blame just named, judge whether it actually
   authored the line or merely reformatted it (message patterns like `prettier`/`lint`/
   `rename`, whitespace-only `-w` diffs, mass-touch commits). If it's noise, exclude it and
   blame again. Move/extract commits get chased across file boundaries with `git log -S`.
   The loop repeats until it reaches the commit that truly authored the line — **the origin
   commit**.
3. **Chase the story off-git** — from the origin commit, follow `#123` references, then (if
   the `gh` CLI is connected) the PR that carried it and the review threads around it. This
   is where the *reasons* live — the pushback, the alternatives tried and rejected, the
   "we'll remove this later" promises that exist nowhere in git objects.
4. **Rule on it** — check whether that reason still holds today, and return a verdict:
   **JUSTIFIED / EXPIRED / COLD CASE**.

Without `gh` or on a non-GitHub remote, alibi doesn't stall — it completes the case on git
evidence alone and says so in the verdict, rather than dying on a missing tool.

## What you get back

Every investigation closes with a structured case file — a verdict, the evidence it rests
on, and one concrete next step (the decision stays yours):

```
🗂️  CASE #a1b2c3d — "why is this connect timeout 30s?"
────────────────────────────────────────────────────

⚖️ Verdict: JUSTIFIED — the slow-broker bug it works around is still open.

📋 Case summary
   Introduced 2021-03 in PR #812 to survive a broker that takes ~25s to
   accept the first connection. Blame first framed a 2023 prettier commit;
   the real author is @maria in #812.

🧾 Exhibits
   E-1  commit 4f2a91c "raise connect timeout to 30s" (2021-03-11, @maria)
   E-2  PR #812 — broker cold-start can exceed 20s
   E-3  broker changelog: cold-start fix still unreleased

🗣️  Witness statements
   W-1  @lead (reviewer, 2021-03): "keep it until the broker fix ships"

∴  Deduction
   E-3 (fix unreleased)   ∴ the original hazard still exists
   ∴  Verdict: JUSTIFIED

⚖️  Disposition recommendation (the decision is yours)
   Keep it. Revisit when the broker cold-start fix lands.

🔗 Related
   SHA: 4f2a91c   PR: #812
```

## Investigation modes

| Mode | Question it answers | Output |
|---|---|---|
| **why-not-who** | "why does this *line* exist — can it go?" | case file with a verdict |
| **commit-to-story** | "why did this *commit/PR* land — what was the debate?" | dossier: problem → debate → decision → aftermath |
| **first-broken** | "this *used to work* — which commit broke it?" | validated-probe bisect → culprit interrogated, verdict on intent |
| **incident-trace** | "what *happened* with X — was it reverted, which releases had it?" | incident timeline + per-release exposure line |
| **design-rationale** | "why is this *designed* this way — was anything else tried?" | precedent record: eras + alternatives on file, verdict on today |
| **repo-tour** | "onboard me through this repo's *history* — where are the bodies buried?" | five-scene precinct tour + first-move disposition |

Real transcripts against facebook/react: [why-not-who](examples/transcripts/why-not-who-react.md) ·
[commit-to-story](examples/transcripts/commit-to-story-react.md)

---

Status: v4 — all six investigation modes shipped.
