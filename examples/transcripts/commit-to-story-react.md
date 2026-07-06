> Real run against facebook/react (blob:none partial clone, 2026-07-07).
> This dossier continues the case in [why-not-who-react.md](why-not-who-react.md):
> that investigation ended at origin commit `19476aa5f` and offered the full dossier.
> Question: *"Give me the full story of commit 19476aa5f in this repo — why did this
> change land, and what was the debate around it?"*

🗂️  CASE #19476aa5f — "Why does the React Compiler bail out when it sees a `$FlowFixMe[react-rule-*]` suppression?"
────────────────────────────────────────────────────────

⚖️ Verdict: JUSTIFIED — the reason was real, still governs the code today, and the feature was later promoted from opt-in to default. (One caveat, declared below: the *review debate* for this specific commit happened in Meta's pre-open-source repo and is unreachable — the "why" is reconstructed entirely from physical evidence, which here is unusually rich.)

📋 Case summary
   `19476aa5f` — "Option to bail on Flow react-rule suppressions", authored by witness
   Mike Vitousek (@mvitousek, mvitousek@fb.com) on 2024-02-09, during the compiler's
   pre-open-source era when it was still called **React Forget**. It teaches the
   compiler to treat a Flow suppression of a React-rule error (`$FlowFixMe[react-rule-…]`,
   `$FlowExpectedError[react-rule-…]`, `$FlowIssue[react-rule-…]`) the same way it
   already treated a disabled `react-hooks` ESLint rule: as an admission that the
   component knowingly violates the Rules of React, and therefore must not be
   optimized. The commit reached facebook/react inside the bulk import PR #29061
   ("Open-source React Compiler", merged 2024-05-15).

📖 Case chronicle
   **The problem.** The compiler's entire safety model assumes components follow the
   Rules of React; compiling a component that knowingly breaks them risks silent
   miscompilation. Eleven days before this commit, witness Joe Savona had landed the
   ESLint half of that defense (E-2, `bc145f6f1`, 2024-01-29: bail out when
   `eslint-disable react-hooks/…` is in scope). But inside Meta, the Rules of React
   are enforced by a second checker — **Flow**, whose `react-rule-*` error codes flag
   hook misuse and ref violations. A developer who silences one of those errors with
   `$FlowFixMe[react-rule-hook]` has left the exact same confession as an
   eslint-disable, and the compiler was blind to it.

   **The change.** `19476aa5f` generalizes `EslintSuppression.ts` into
   `Suppression.ts`, adds a `SuppressionSource` (`'Eslint' | 'Flow'`) to each detected
   suppression range, and matches Flow comments against
   `\$(FlowFixMe\w*|FlowExpectedError|FlowIssue)\[react\-rule` (E-1). It is precise on
   purpose: the fixture pair added in the same commit (E-3) proves that a *react-rule*
   suppression triggers a bailout while an unrelated Flow suppression
   (`$FlowFixMe[incompatible-type]`) does not. The error text authored in the diff
   states the rationale in plain words: *"React Forget has bailed out of optimizing
   this component as one or more React rule violations were reported by Flow …
   Remove the Flow suppression and address the React error."* The behavior shipped
   behind a new plugin option, `flowSuppressions`, defaulting to **false** — opt-in
   first, consistent with a Meta-internal rollout.

   **The debate.** Off the record. The commit's message body is a single line with no
   PR number or reviewer trailers, and the pre-OSS repo (facebook/react-forget)
   returns 404 today (E-7). If reviewers pushed back on the regex, the default, or
   the scope, that conversation lived in the private repo and cannot be recovered.
   What *is* on record is that no revert or dispute ever surfaced in public history.

   **The aftermath — every signal says the premise held.** The error strings were
   renamed with the product (E-5: `7748ce8f3`, 2024-03-28, Forget → React Compiler;
   `87993f333`, 2024-04-17, dx pass). Then on 2024-08-06 the same author flipped the
   default to **true** in PR #30622 ("[compiler][ez] Default to using flow
   suppressions"), approved by witness Joe Savona (E-6, W-1) — the opt-in graduated
   to standard behavior. Notably, that PR carved out one deliberate exception, with
   an in-code justification: the ESLint plugin keeps `flowSuppressions: false`
   because *"Flow already gave a signal"* (W-2) — don't double-report to the
   developer, but do refuse to compile. The mechanism survives verbatim in today's
   `Suppression.ts` (same regex, same Eslint/Flow source split) and has even been
   specified into the Rust port of the compiler with `flowSuppressions ?? true`
   (E-8).

🧾 Exhibits
   E-1  commit 19476aa5f "Option to bail on Flow react-rule suppressions"
        (2024-02-09, @mvitousek) — 9 files: Options.ts (+`flowSuppressions: false`),
        EslintSuppression.ts → Suppression.ts rename/generalization, Program.ts
        hookup, 2 fixtures, test utils
   E-2  commit bc145f6f1 "Support customizable eslint suppressions"
        (2024-01-29, @josephsavona) — the ESLint-suppression bailout framework this
        commit extends
   E-3  fixtures `error.bailout-on-flow-suppression.js` (bails on
        `$FlowFixMe[react-rule-hook]`) and `no-flow-bailout-unrelated.js` (does NOT
        bail on `$FlowFixMe[incompatible-type]`) — the intended scope, encoded as tests
   E-4  PR #29061 "Open-source React Compiler" (merged 2024-05-15) — the import that
        carried this commit into facebook/react; body says only "React Compiler is
        open source!"
   E-5  commits 7748ce8f3 (2024-03-28) and 87993f333 (2024-04-17) — error-message
        renames/polish; mechanism untouched
   E-6  commit 9eb288e65 / PR #30622 "[compiler][ez] Default to using flow
        suppressions" (merged 2024-08-07, @mvitousek) — flips the default to `true`,
        keeps `false` in eslint-plugin-react-compiler
   E-7  `gh api repos/facebook/react-forget` → HTTP 404 — the pre-OSS review record
        is unreachable from this environment
   E-8  current tree: `compiler/packages/babel-plugin-react-compiler/src/Entrypoint/Options.ts`
        (`flowSuppressions: true` in defaults) and `.../Entrypoint/Suppression.ts`
        (regex intact); `compiler/docs/rust-port/rust-port-0005-babel-plugin.md`
        (`flowSuppressions: rawOpts.flowSuppressions ?? true`)

🗣️  Witness statements
   W-1  @josephsavona (reviewer, 2024-08-07): APPROVED PR #30622 — no comment left;
        a silent approval of making the bailout the default.
   W-2  @mvitousek (author, in-code comment shipped in E-6):
        "Don't emit errors on Flow suppressions--Flow already gave a signal"
        — the one recorded trace of design reasoning: bail in the compiler, stay
        quiet in the linter.
   (The review thread for the subject commit itself is unreachable — pre-OSS private
   repo. The chronicle above rests on physical evidence only.)

∴  Deduction
   E-2 (ESLint bailout landed 11 days prior)      ∴ this commit is the second half of
                                                    one defense: both checkers that
                                                    enforce Rules of React at Meta
                                                    must gate compilation
   E-1 + E-3 (regex scoped to `react-rule`,        ∴ intent was surgical — only
   negative fixture included)                        *confessed React-rule violations*
                                                    block compilation, not Flow noise
   E-6 (default flipped to true, Aug 2024)         ∴ the opt-in survived contact with
                                                    Meta's codebase and was promoted —
                                                    the premise was validated, not
                                                    abandoned
   E-8 (mechanism live today; carried into the     ∴ the reason still governs the code
   Rust port spec)
   E-7 (pre-OSS review thread 404)                 ∴ the *debate* is unrecoverable, but
                                                    the *rationale* is fully evidenced
   ∴  Verdict: ⚖️ JUSTIFIED

⚖️  Disposition recommendation (the decision is yours)
   Keep — this is a load-bearing safety fence, now default-on and being replicated in
   the Rust port. If you need the internal review discussion (e.g., why exactly those
   three Flow suppression forms, or the rollout data behind the Aug 2024 default
   flip), the last witnesses are @mvitousek (author of both the feature and the
   default flip) and @josephsavona (framework author and approving reviewer).

🔗 Related
   SHA: 19476aa5f   PR: #29061 (import), #30622 (default flip)   Issues: none found
   Follow-ups: bc145f6f1 (precursor) · 7748ce8f3 · 87993f333 · 9eb288e65

*"The commit walked in without a lawyer and without a transcript — but its story checks out at every door I knocked on. Case closed."*
