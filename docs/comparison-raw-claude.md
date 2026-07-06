# Raw Claude vs alibi — same question, same repo

Real run against facebook/react (2026-07-06). Question: *"Suppression.ts:102 has this
scary regex — why does it exist, who wrote it? blame just shows a prettier commit."*
Full outputs: [alibi](../examples/transcripts/why-not-who-react.md) · baseline in
`skills/alibi-workspace/react-transcript/baseline-answer.md` (not shipped).

Both agents ran on the same strong model. The difference is not raw capability — it is
what you can rely on getting, every time:

| | Raw Claude | alibi |
|---|---|---|
| True origin (Vitousek `19476aa5f`) | ✅ found | ✅ found |
| Second noise layer on the exact line (`48024b76b` "Fix lints") | ➖ bypassed via adjacent-line heuristic, not identified as a peeled layer | ✅ identified and evidenced (`-w` diff = quote churn only) |
| Verdict on "is it safe to touch?" | ❌ none — history essay only | ✅ **JUSTIFIED** + disposition (what to do if it fires on you) |
| Still-valid-today check | ➖ partial | ✅ defaults-on today (`Options.ts:322`) + freshly ported to Rust — reason actively maintained |
| Evidence trail you can audit | prose | numbered exhibits E-1…E-8 + deduction chain |
| Repo hygiene tip | — | `git config blame.ignoreRevsFile` so it stops happening |
| Cost | 174s / 43k tokens | 396s / 53k tokens |

**The honest pitch**: a top-tier model digging freestyle can find the story — this run
did. What it doesn't give you is a ruling, an auditable evidence chain, or the same
routine on the day it's tired and you're in a hurry. alibi is the difference between
a good detective having a good day and a precinct with a case-file standard.

## Round 2 — commit-to-story mode (same repo, 2026-07-07)

Question: *"Give me the full story of commit 19476aa5f — why did this change land,
and what was the debate around it?"* Full output:
[commit-to-story-react.md](../examples/transcripts/commit-to-story-react.md).

| | Raw Claude | alibi (dossier mode) |
|---|---|---|
| Import vehicle PR #29061, default-flip PR #30622 | ✅ found | ✅ found |
| Declares the pre-open-sourcing debate unreachable (no invented quotes) | ✅ | ✅ + probes and exhibits the 404 (E-7) |
| Verdict on "does the rationale still hold?" | ❌ prose conclusion only | ✅ **JUSTIFIED** + disposition + last witnesses to ask |
| Machine-consumable `🔗 Related` footer (feeds the next investigation) | ❌ | ✅ |
| Rich extras | same-day fixup commits, 2025 diagnostics refactor | negative test fixture as scope evidence, Rust port carrying the option forward |
| Cost | 418s / 55k tokens | 280s / 48k tokens |

Same lesson, one new data point: on this round the skill was *cheaper* — the routine
(resolve PR → chase thread → check aftermath → rule) spends fewer tokens than
freestyle exploration, because it knows when to stop digging.

One more finding worth reporting: with alibi installed, the "baseline" first had to be
re-run — the plain question "give me the full story of commit X" **auto-triggered the
skill**. The trigger working that well is the point of shipping it as a skill.
