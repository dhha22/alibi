# incident-trace — the scene forensics mode

> "One commit is a fingerprint. A revert chain is a whole crime scene."

Read this file when the user asks what **happened around an incident or a
revert/reland chain** — "reconstruct what happened with X", "was this ever reverted?",
"which releases had this bug?", "why does this feature appear twice in the log?".
why-not-who explains a line, commit-to-story explains one commit; this mode explains
an **episode**: land → incident → revert → (cherry-picks) → fix/reland, mapped onto
releases.

All SKILL.md rules stay in force: voice rules, evidence taxonomy, the three verdicts,
gh graceful degradation. This file adds the forensics routine and the timeline section.

## The forensics routine

### Step 1 — Mark out the scene

Resolve the subject to a searchable identity: a feature name, a commit subject
fragment, an incident ID, a file. Then collect every commit in the episode:

```bash
git log --all --oneline --grep '<subject fragment>' -i
git log --all --oneline --grep 'revert' -i --grep '<fragment>' -i --all-match
git log --oneline --follow -- <file>          # when the subject is a file's behavior
```

`--all` matters: revert chains routinely span release branches that never merged back.

### Step 2 — Read the chain metadata (git makes this forensic, not guesswork)

Each commit in the episode carries machine-readable links — extract them instead of
inferring:

- **Revert bodies** — `This reverts commit <sha>.` names the exact victim. The rest of
  the revert message is often the best incident summary in the repo (E-n).
- **Cherry-pick trailers** — `(cherry picked from commit <sha>)` ties a release-branch
  commit back to its mainline original. Find them with
  `git log --all --grep 'cherry picked from'`.
- **Reland markers** — "reland of #n", "retry", same subject landing twice
  (`git log --all --oneline --grep '<exact subject>'` shows the reincarnations).
- **Release mapping** — for every commit in the chain: `git tag --contains <sha>`
  (and `git branch -a --contains <sha>`). The difference set is the exposure window:
  *tags that contain the bug commit but not the revert/fix shipped broken.*

### Step 3 — Pull the records

- In-repo first: postmortems, `docs/INCIDENTS*`, CHANGELOG, runbooks — search for the
  incident ID and the feature name. A postmortem's **action items are the terms of the
  episode**: they define what a legitimate reland must satisfy.
- `gh` if available: PRs for each chain commit (`scripts/resolve_pr.sh`), issue
  threads for the incident. Same rules as always — call cap, and without `gh` complete
  the trace on physical evidence and declare the gap.

### Step 4 — Verify the ending

An episode isn't over because the log stops. Check the current state:

- Is the fix/reland actually in HEAD, and does the code satisfy the postmortem's
  action items? (Read the relevant lines — a reland that says "with fsync barrier"
  should contain one.)
- Did any release line miss the fix? A release branch that got the revert but died
  before the reland is fine; one still shipping the bug commit is a live finding.
- Any *later* commits weakening the fix?

### Step 5 — Verdict

The verdict rules on whether the incident is actually closed:

- ⚖️ **JUSTIFIED** — the current implementation is legitimate: root cause addressed,
  postmortem terms met, every live release line clean. Case closed.
- ⌛ **EXPIRED** — the episode left residue that no longer serves: a mitigation or
  feature-flag guard still in place though the fix landed, a release branch kept alive
  past its purpose. Disposition: name the removable residue.
- 🕳️ **COLD CASE** — the chain doesn't close: the revert's reason is unrecorded, the
  reland's compliance can't be verified, or exposure can't be established. Say exactly
  which link is missing and who the last witnesses are.

## Case file: add the timeline

Standard SKILL.md structure, with a **🕒 Incident timeline** section between the case
summary and the exhibits — one dated line per event, each pinned to an exhibit:

```
🕒 Incident timeline
   2023-03-01  #88 async flush lands (E-1) ── ships in v1.1
   2023-03-07  INC-2023-042: data loss in production (E-3)
   2023-03-08  revert #91 (E-2) ── ships in v1.1.1; cherry-picked to release-1.1 (v1.1.2)
   2023-05-20  reland #95 with fsync barrier (E-4) ── ships in v1.2

   Exposure: v1.1 only. v1.1.1/v1.1.2 reverted; v1.2+ carries the fixed reland.
```

The `Exposure:` line is mandatory when the user asked "which releases were affected" —
it is the single line an on-call engineer actually needs. Close with the 🔗 Related
footer listing the whole chain (land / revert / reland SHAs and PRs); offer — one
line — a commit-to-story dossier on whichever chain commit still looks underexplained.
