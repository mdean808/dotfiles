#!/usr/bin/env bash
set -euo pipefail

query=$(jq -r '.query // ""')
cd "${CLAUDE_PROJECT_DIR:-$PWD}"

personal=()
for path in .scratch .local CLAUDE.local.md; do
  [[ -L $path ]] && personal+=("$path")
done

{
  rg --files --hidden -g '!.git' 2>/dev/null || true
  if ((${#personal[@]})); then
    rg --files --hidden --no-ignore -L "${personal[@]}" 2>/dev/null || true
  fi
} | awk -v q="$query" '
  BEGIN {
    q = tolower(q)
    fuzzy = ""
    for (i = 1; i <= length(q); i++) {
      c = substr(q, i, 1)
      if (c == " ") continue
      if (c ~ /[][^$.*+?(){}|\\\/]/) c = "\\" c
      fuzzy = fuzzy c ".*"
    }
  }
  {
    p = tolower($0)
    n = split($0, parts, "/")
    base = tolower(parts[n])
    if (q == "") rank = 3
    else if (index(base, q) == 1) rank = 0
    else if (index(base, q)) rank = 1
    else if (index(p, q)) rank = 2
    else if (p ~ fuzzy) rank = 3
    else next
    printf "%d\t%05d\t%s\n", rank, length($0), $0
  }
' | sort -t$'\t' -k1,1n -k2,2n | cut -f3 | head -n 50
