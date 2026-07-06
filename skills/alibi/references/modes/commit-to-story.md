# commit-to-story — the dossier mode

> "A SHA is a fingerprint. I want the whole night reconstructed."

Read this file when the case target is **a commit or PR itself** and the question is its
*story* — "why did this change land?", "what was the debate on this PR?", "give me the
dossier on 4f2a91c" — rather than a line's origin (that's the default why-not-who
routine in SKILL.md). why-not-who ends at the origin commit; this mode begins there.

All SKILL.md rules stay in force: voice rules, evidence taxonomy (E-n / W-n), the three
verdicts, the case file structure, gh graceful degradation. This file only adds the
dossier routine and one extra section to the case file.

## The dossier routine

### Step 1 — Book the subject

Resolve the input to one commit:

- **SHA** — verify it exists: `git show -s --format='%h %s (%an, %ad)' <sha>`. If
  unknown, try `git fetch origin <sha>` before giving up (partial clones).
- **PR number** — `gh pr view <n> --json mergeCommit,title` gives the commit; without
  `gh`, search `git log --oneline --grep '(#<n>)'`.
- **Vague description** ("the commit that added retries") — locate with
  `git log -S` / `--grep`, confirm the pick with the user if more than one candidate.

### Step 2 — Physical evidence (git-only, always available)

- `git show <sha>` — message, author, date, the diff itself (E-1). Read the full
  message body, not just the subject: trailers (`Fixes:`, `Refs:`, `Reviewed-by:`,
  ticket IDs, URLs) are leads.
- **Shape of the change** — `git show <sha> --stat`: one surgical file or a sweep?
  Test files included? Docs updated in the same commit? Each tells part of the story.
- **Context commits** — `git log --oneline <sha>~3..<sha>` and the few commits after:
  was this part of a series? Look for follow-ups and reverts that name this commit or
  its subject: `git log --all --oneline --grep '<distinctive subject fragment>'` and
  `git log --all --oneline --grep 'revert' -i --grep '<subject fragment>'`.

### Step 3 — Chase the paper trail (gh)

Only if `gh auth status` succeeds and the remote is GitHub. Use
`scripts/resolve_pr.sh <sha>` to find the carrying PR (falls back to `(#n)` in the
subject when the API has no answer).

Then, in order of evidence value:

1. `gh pr view <n> --json title,body,author,mergedAt,url` — the stated rationale (E-n).
2. `gh api "repos/{owner}/{repo}/pulls/<n>/reviews"` and
   `gh api "repos/{owner}/{repo}/pulls/<n>/comments"` — review pushback. This is where
   the real story lives: **alternatives proposed and rejected, objections raised and
   answered, promises made** ("we can remove this once X ships"). Quote these as
   witness statements (W-n), verbatim, with author and date.
3. `gh api "repos/{owner}/{repo}/issues/<n>/comments"` — discussion on the PR thread
   itself and any linked issues from the body (`#123`, `Fixes ...`).

**Rate-limit discipline**: a dossier should cost at most ~20 `gh api` calls. Batch
fields into single `--json` queries, don't paginate past page 2 of comments unless a
specific quote is missing, and if the API rate-limits or errors mid-chase, stop calling
and write the dossier on the evidence already in hand, declaring the gap. Never let the
paper chase stall the verdict.

**No `gh` / not GitHub / no remote**: same rule as SKILL.md — complete the dossier on
physical evidence and state: *"Witness statements (PR/review/issue records) unreachable
from this environment — dossier rests on physical evidence only."*

### Step 4 — The aftermath

A story doesn't end at merge. Check what happened to the change since:

- Do the touched lines survive today? (`git log --oneline -- <file>` since the commit;
  a later rewrite or revert is part of the story.)
- Were the promises kept? If a reviewer said "remove after X" or "follow-up coming",
  search for that follow-up. A kept promise strengthens JUSTIFIED; a broken one is
  evidence for EXPIRED or at least belongs in the disposition.
- Did the change's premise hold? If it fixed a bug, is the bug's cause still around?
  If it optimized something, does the hot path still exist?

### Step 5 — Verdict

Same three verdicts, applied to the change's rationale:

- ⚖️ **JUSTIFIED** — the reason it landed was real and still governs the code today.
- ⌛ **EXPIRED** — the reason was real, but the world moved (premise gone, promised
  removal condition met, superseded by a later change).
- 🕳️ **COLD CASE** — the change landed but its reason is unrecoverable (empty message,
  no PR trail, witnesses unreachable). List the last witnesses.

## Dossier format

Use the standard case file from SKILL.md, with one addition: a **📖 Case chronicle**
section between the case summary and the exhibits. The chronicle is the point of this
mode — a chronological narrative, 2–4 short paragraphs, dry and factual, every sentence
traceable to an exhibit or witness:

1. **The problem** — what was broken/missing, who reported it, how it surfaced.
2. **The debate** — what was proposed, what alternatives were considered and rejected
   (and *why* rejected), who pushed back and on what grounds. If the record shows no
   debate, say so — a change that landed without discussion is itself a fact.
3. **The decision and its terms** — what merged, and any conditions attached
   (soak periods, promised follow-ups, "temporary until X").
4. **The aftermath** — what happened since: follow-ups landed or broken, premise
   still alive or dead.

```
🗂️  CASE #<short-sha> — "<one-line question the dossier answers>"
────────────────────────────────────────────────────────

<⚖️|⌛|🕳️> Verdict: <JUSTIFIED|EXPIRED|COLD CASE> — <one-line ruling>

📋 Case summary
   <2-4 lines>

📖 Case chronicle
   <the narrative above>

🧾 Exhibits
   E-1 ...

🗣️  Witness statements
   W-1 ...

∴  Deduction
   ...

⚖️  Disposition recommendation (the decision is yours)
   ...

🔗 Related
   SHA: <sha>   PR: #<n>   Issues: #<n>   Follow-ups: <sha/PR if any>
```

## Chaining back

If the dossier surfaces a *line* whose presence now looks suspicious (a workaround the
chronicle says should have been removed, a constant the debate never settled), offer —
one line, never automatically — to open a why-not-who case on it.
