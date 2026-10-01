#!/usr/bin/env bash
status=$(git -C "$1" status --porcelain=v1 --branch 2>/dev/null) || exit 0

header=${status%%$'\n'*}
branch=${header#\#\# }
branch=${branch#No commits yet on }
branch=${branch%%...*}
if [[ $branch == "HEAD (no branch)" ]]; then
  branch=$(git -C "$1" rev-parse --short HEAD)
fi

staged=0 modified=0 untracked=0
while IFS= read -r line; do
  [[ $line == "## "* || -z $line ]] && continue
  x=${line:0:1} y=${line:1:1}
  if [[ $x$y == "??" ]]; then
    ((untracked++))
    continue
  fi
  [[ $x != " " ]] && ((staged++))
  [[ $y != " " ]] && ((modified++))
done <<< "$status"

out="$branch"
((staged)) && out+=" #[fg=#c3e88d]+$staged"
((modified)) && out+=" #[fg=#ffc777]~$modified"
((untracked)) && out+=" #[fg=#ff757f]?$untracked"

printf '#[fg=#2f334d,bg=#1e2030]#[fg=#c099ff,bg=#2f334d] %s#[fg=#2f334d,bg=#1e2030] ' "$out"
