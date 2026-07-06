#!/usr/bin/env bash
set -u
# usage: resolve_pr.sh <sha> [repo-dir]
# Prints one line per PR associated with the commit: <number>\t<title>\t<url>
# Falls back to "(#n)" markers in the commit subject when gh is unavailable.
# Always exits 0 with possibly-empty output — absence of a PR is evidence, not an error.

sha="${1:?usage: resolve_pr.sh <sha> [repo-dir]}"
dir="${2:-.}"
cd "$dir" || exit 0

subject=$(git log -1 --format=%s "$sha" 2>/dev/null) || exit 0

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  remote=$(git remote get-url origin 2>/dev/null || true)
  slug=$(printf '%s' "$remote" | sed -E 's#^(git@|ssh://git@|https?://)([^/:]+)[:/]##; s#\.git$##')
  if [ -n "$slug" ]; then
    out=$(gh api "repos/$slug/commits/$sha/pulls" \
      --jq '.[] | [(.number|tostring), .title, .html_url] | @tsv' 2>/dev/null || true)
    if [ -n "$out" ]; then
      printf '%s\n' "$out"
      exit 0
    fi
  fi
fi

printf '%s\n' "$subject" | grep -oE '#[0-9]+' | tr -d '#' | while read -r n; do
  printf '%s\tfrom commit subject\t\n' "$n"
done

exit 0
