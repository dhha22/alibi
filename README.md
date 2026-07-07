# code-archaeology

> **git blame tells you *who*. This tells you *why*.**

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
git clone https://github.com/YOU/code-archaeology ~/.claude/skills/code-archaeology
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

Real transcripts against facebook/react: [why-not-who](examples/transcripts/why-not-who-react.md) ·
[commit-to-story](examples/transcripts/commit-to-story-react.md)

---

Status: v3 (why-not-who, commit-to-story, first-broken, incident-trace modes).
Roadmap: design-rationale, repo-tour investigation modes.
