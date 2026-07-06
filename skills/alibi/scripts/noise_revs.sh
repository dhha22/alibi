#!/usr/bin/env bash
# noise_revs.sh <file> [max-commits]
# Prints candidate noise-commit SHAs (formatting/mechanical commits) for a file,
# one per line. Feed them to blame as: git blame $(sed 's/^/--ignore-rev /' <<<"$out")
set -euo pipefail

FILE="${1:?usage: noise_revs.sh <file> [max-commits]}"
MAX="${2:-200}"

PATTERN='prettier|reformat|format(ting)?|lint|eslint|spotless|whitespace|indent|code style|^style[(:]|^chore[(:].*(format|style|lint)|rename|move file'

ROOT="$(git rev-parse --show-toplevel)"

if [ -f "$ROOT/.git-blame-ignore-revs" ]; then
  grep -Eo '^[0-9a-f]{7,40}' "$ROOT/.git-blame-ignore-revs" || true
fi

git log --follow -n "$MAX" --format='%H%x09%s' -- "$FILE" | while IFS=$'\t' read -r sha subject; do
  if printf '%s' "$subject" | grep -qiE "$PATTERN"; then
    # confirm: whitespace-insensitive diff for this file is empty while normal diff is not
    normal=$(git diff "$sha^" "$sha" -- "$FILE" 2>/dev/null | wc -l)
    wsless=$(git diff -w "$sha^" "$sha" -- "$FILE" 2>/dev/null | wc -l)
    if [ "$normal" -gt 0 ] && [ "$wsless" -eq 0 ]; then
      echo "$sha"
    else
      # mass-touch reformat: huge file count is corroborating evidence even if -w diff is nonempty
      files=$(git show --stat --format='' "$sha" 2>/dev/null | tail -1 | grep -Eo '^ *[0-9]+' | tr -d ' ' || echo 0)
      [ "${files:-0}" -ge 50 ] && echo "$sha"
    fi
  fi
done | sort -u
