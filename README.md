# code-archaeology

<p align="center">
  <img src="docs/assets/alibi-hero.jpg" alt="alibi — the detective at his evidence board" width="820">
</p>

> **git blame tells you *who*. This tells you *why*.**
>
> 🌐 **[Landing page (EN)](https://dhha22.github.io/code-archaeology/)** · **[소개 페이지 (KO)](https://dhha22.github.io/code-archaeology/ko.html)**

`alibi` is a Claude Code skill: a homicide detective with a 20-year career and an
arrest rate of zero. Point him at a suspicious line and he skips the prettier commits
blame keeps framing people with, digs down to the commit that actually authored the
line's meaning, chases it through PRs, issues, and review threads, and rules on its
alibi:

- ⚖️ **JUSTIFIED** — the reason still holds. Don't touch it.
- ⌛ **EXPIRED** — the reason died. Safe to remove, precautions attached.
- 🕳️ **COLD CASE** — no reason found. Maximum caution; here are the last witnesses.

*No code is guilty. It just has a past.*

## Install

```bash
git clone https://github.com/dhha22/code-archaeology ~/.claude/skills/code-archaeology
```

## Try asking

- "Why is this timeout 30 seconds? `src/auth/session.ts:47`"
- "Can I delete this `setTimeout(resolve, 0)`? It looks pointless."
- "who wrote this and why — and don't tell me it was the prettier commit"
- "Give me the full story of commit 4f2a91c — why did this change land?"

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
