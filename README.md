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

---

Status: v1 (why-not-who mode). Roadmap: commit-to-story, first-broken, incident-trace,
design-rationale, repo-tour investigation modes.
