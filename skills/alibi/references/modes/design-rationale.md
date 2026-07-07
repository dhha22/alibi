# design-rationale — the case-law mode

> "A design isn't a fact. It's a ruling — and rulings have dissents on file."

Read this file when the question is about a **design or structural decision**, not a
single line or commit — "why is this module structured this way?", "why a queue and
not Promise.all?", "why is X a separate package?", "was anything else tried?". The
subject is an architecture-shaped *decision*; the evidence is spread across eras of
commits, ADRs, and rejected attempts.

All SKILL.md rules stay in force: voice rules, evidence taxonomy, the three verdicts,
gh graceful degradation. This file adds the case-law routine.

## The case-law routine

### Step 1 — Name the ruling under review

Pin the design decision to concrete artifacts: which files/directory embody it, and
what one sentence states the decision ("uploads go through a bounded queue,
concurrency N"). If the user's question is vaguer than that, sharpen it with them
first — precedent research on a fuzzy question returns fuzzy precedent.

### Step 2 — Establish the eras

A design's rationale lives in its *transitions*. Reconstruct the formation history:

```bash
git log --oneline --follow -- <files/dir>          # the full life of the artifact
git log --diff-filter=A --oneline -- <files/dir>   # birth certificates
git log --all --oneline --grep '<design keyword>' -i
```

Read the log as **eras**: the shape the code was born with, and each commit that
changed the *approach* (not the details). Era-defining commits are usually easy to
spot — introductions, rewrites, reverts, "switch X to Y" subjects. Small tweaks
within an era (constant bumps, added endpoints) are not era boundaries, but note
them: a recently-tuned design is evidence the rationale is still alive.

### Step 3 — Find the dissents (this is the point of the mode)

For each era transition, hunt for **alternatives considered and rejected**:

- **Reverted eras are rejected alternatives with a body of evidence.** A revert
  commit's message states exactly why the alternative failed in production — quote it.
- **ADRs / design docs in-repo** — `docs/adr/`, `docs/design/`, `DESIGN.md`,
  RFC files. An ADR's "options considered" section is the dissent record; cite each
  rejected option and its stated reason. Check the ADR's status and any "revisit
  when X" conditions — those are live tripwires.
- **`gh` if available**: the PR that landed each era-defining commit, review threads
  arguing for other approaches. Same rules as always — call cap, declare gaps.
- Absence is also evidence: a design with no recorded alternatives is a decision
  made without (recorded) debate — say so rather than inventing a deliberation.

### Step 4 — Test the precedent against today

Each rejected alternative was rejected *under conditions*. Check whether they still
hold: the rate limit that killed option B — still that low? The team capacity that
deferred option D — did the dependency ship since? Search the log and docs for
later commits touching those conditions. A design can be simultaneously well-founded
in 2021 and wrong today; the verdict must be about **today**.

### Step 5 — Verdict

- ⚖️ **JUSTIFIED** — the ruling stands: the chosen design's reasons hold and the
  rejected alternatives' failure conditions are still in force.
- ⌛ **EXPIRED** — the precedent has lapsed: a rejected alternative's blocker is gone
  (the batch endpoint shipped, the rate limit was raised, the platform died) or the
  chosen design's premise no longer exists. Disposition: name the specific
  re-evaluation, not just "reconsider".
- 🕳️ **COLD CASE** — the design is real but its deliberation is unrecoverable: no
  ADR, no revert trail, no PR record. List the last witnesses (era authors).

## Case file: add the precedent record

Standard SKILL.md structure, with a **📜 Precedent record** section between the case
summary and the exhibits — one block per era, then the dissents:

```
📜 Precedent record
   Era 1 (2021-03, E-1)  sync per-file upload — worked, too slow at scale
   Era 2 (2021-05, E-2)  unbounded Promise.all (#12) — REVERTED (#19): 429 storms
   Era 3 (2021-07, E-4)  bounded queue, concurrency 3 — current, tuned 3→5 in 2024 (E-6)

   Alternatives on file (ADR-0003, E-5):
   A. keep sync        — rejected: minutes-long uploads
   B. Promise.all      — rejected: rate limits (proven in production, E-2→E-3)
   D. server-side batch — deferred: API capacity; REVISIT when /upload/batch ships
```

Close with the standard verdict, deduction, disposition, and 🔗 Related footer
(era-defining SHAs + ADR paths). When one era-defining commit deserves its own
investigation, offer — one line — a commit-to-story dossier on it.
