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

read -r bg surface purple green yellow red <<< "$(tmux display-message -p '#{@thm_bg} #{@thm_surface} #{@thm_purple} #{@thm_green} #{@thm_yellow} #{@thm_red}')"

out="$branch"
((staged)) && out+=" #[fg=$green]+$staged"
((modified)) && out+=" #[fg=$yellow]~$modified"
((untracked)) && out+=" #[fg=$red]?$untracked"

printf "#[fg=$surface,bg=$bg]#[fg=$purple,bg=$surface] %s#[fg=$surface,bg=$bg] " "$out"
