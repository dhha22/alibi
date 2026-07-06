> Real run against facebook/react (blob:none partial clone, 2026-07-06).
> Question: *"In compiler/.../Entrypoint/Suppression.ts:102 there's this scary regex
> `'\\$(FlowFixMe\\w*|FlowExpectedError|FlowIssue)\\[react\\-rule'` — why does this
> exist, who actually wrote it, and what's the story? git blame just shows me some
> prettier config commit."*

🗂️  CASE #19476aa5f — "Why does the compiler refuse to compile when it sees `$FlowFixMe[react-rule...]`?"
────────────────────────────────────────────────────────

⚖️ Verdict: JUSTIFIED — the regex is a live safety valve, not cruft. Don't touch it.

📋 Case summary
   Your blame framed the wrong witness twice over. Bare blame names Jan Kassens'
   2024-07-18 "Compiler: unfork prettier config (#30205)" — a quote-style sweep that is
   literally listed in the repo's own `.git-blame-ignore-revs` (E-5). Peel that and you
   hit "Fix lints" (48024b76b), another quote-swap on the same line (E-4). The true
   origin is **19476aa5f, "Option to bail on Flow react-rule suppressions" — Mike
   Vitousek (@mvitousek), 2024-02-09** (E-1), which created `Suppression.ts` by
   extending the pre-existing `EslintSuppression.ts` to also understand Flow. The commit
   predates the compiler's open-sourcing; it reached GitHub inside PR #29061
   "Open-source React Compiler" (May 2024), so the original code review happened on
   Meta-internal tooling — those witness statements are unreachable from here.

   The why: React Compiler's entire correctness model assumes your components follow
   the Rules of React — it memoizes aggressively on that assumption. At Meta, Flow (not
   just ESLint) enforces those rules at type-check time, emitting error codes like
   `react-rule-hook`, `react-rule-unsafe-ref`, `react-rule-hook-conditional` (E-6).
   Flow's standardized suppression syntax is `$FlowFixMe[error-code]` /
   `$FlowExpectedError[error-code]` / `$FlowIssue[error-code]`. So a comment matching
   this regex is a developer's signed confession: *"this component knowingly violates a
   Rule of React, and I silenced the checker."* Compiling such a component could bake
   the violation into memoized output (e.g. a ref read during render that the compiler
   assumes is stable) and produce silently wrong behavior. Hence: same treatment as an
   `eslint-disable` of a React rule — skip the component and tell the user. The
   compiler already did this for ESLint suppressions (Lauren Tan's 6d101435d,
   2023-11-17; made configurable by Joe Savona's bc145f6f1, 2024-01-29); Vitousek's
   commit added Flow as a second suppression source, gated behind the
   `flowSuppressions` option.

🧾 Exhibits
   E-1  commit 19476aa5f "Option to bail on Flow react-rule suppressions"
        (2024-02-09, Mike Vitousek <mvitousek@fb.com>) — creates Suppression.ts from
        EslintSuppression.ts, adds the regex, `flowSuppressions` option, and fixture
        `error.bailout-on-flow-suppression.js` (`// $FlowFixMe[react-rule-hook]`)
   E-2  PR #29061 "Open-source React Compiler" (@josephsavona, merged 2024-05-15) —
        the import vehicle; body says only "React Compiler is open source!"
   E-3  commits 6d101435d (2023-11-17, Lauren Tan) and bc145f6f1 (2024-01-29,
        Joe Savona) — the ESLint-suppression bailout this pattern generalizes
   E-4  commit 48024b76b "Fix lints" (2024-02-09, same author, 29 min later) — noise:
        `-w` diff shows only quote-style churn on line 102
   E-5  commit fd2b3e13d "Compiler: unfork prettier config (#30205)" (2024-07-18,
        Jan Kassens) — noise; listed in `.git-blame-ignore-revs`; this is the
        "prettier config commit" your blame showed
   E-6  Flow public docs — `react-rule-*` error codes and the `$FlowFixMe[code]`
        suppression syntax the regex targets:
        https://flow.org/en/docs/react/hook-syntax/ · https://flow.org/en/docs/errors/
   E-7  current code — `Options.ts:322` defaults `flowSuppressions: true`; the error
        text in `Suppression.ts` (`suppressionsToCompilerError`) states the rationale:
        "React Compiler only works when your components follow all the rules of React,
        disabling them may result in unexpected or incorrect behavior."
   E-8  the logic was freshly ported to the Rust compiler
        (`compiler/crates/react_compiler/src/entrypoint/suppression.rs:88-114`), and
        `eslint-plugin-react-compiler/src/rules/ReactCompilerRule.ts:189-190` also
        checks `react-rule-hook`/`react-rule-unsafe-ref` Flow suppressions to avoid
        double-reporting

🗣️  Witness statements
   Original review comments unreachable — the commit predates open-sourcing and was
   reviewed on Meta-internal tooling; PR #29061 carries no per-commit discussion.
   Verdict rests on physical evidence plus the authors' own error-message text (E-7).

∴  Deduction
   E-1 (dedicated commit + test fixture)        ∴ deliberate feature, not an accident
   E-3 (ESLint bailout predates it)             ∴ regex extends an established safety
                                                  policy to Meta's Flow-checked code
   E-6 (Flow emits react-rule-* codes)          ∴ the regex precisely targets
                                                  suppressions of Rules-of-React errors
   E-7 (defaults on today) + E-8 (Rust port)    ∴ reason still holds and is actively
                                                  maintained
   ∴  Verdict: JUSTIFIED

⚖️  Disposition recommendation (the decision is yours)
   Keep it. This fence guards the compiler's core soundness assumption. If it's firing
   on your code, the fix is at the call site: remove the `$FlowFixMe[react-rule-*]`
   suppression and fix the underlying rule violation — or, if you must, set
   `flowSuppressions: false` in compiler options (per-file opt-outs beat disabling the
   check globally). Also: add `.git-blame-ignore-revs` to your blame config
   (`git config blame.ignoreRevsFile .git-blame-ignore-revs`) so prettier commits stop
   framing innocent lines.

🔗 Related
   SHA: 19476aa5f6f448a97733dc95739b4873a8f8ab12   PR: #29061   Issues: —
   Noise layers: fd2b3e13d (#30205), 48024b76b

Sources: [Flow — Hook Syntax](https://flow.org/en/docs/react/hook-syntax/), [Flow — Error Suppressions](https://flow.org/en/docs/errors/)

*The line had an alibi all along — blame just kept pointing at the guy who repainted the wall.*
