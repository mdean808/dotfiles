#!/bin/sh

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE

. "$HOME/.config/yadm/lib.sh"

store="$HOME/.scratch"
remote=git@gitlab.com:modean/scratch.git
link="$HOME/.local/bin/scratch-sync"
action=${1:?usage: scratch.sh pull|push}

step_clone() {
  if [ -d "$store/.git" ]; then already '~/.scratch exists'; fi
  git clone --quiet "$remote" "$store" ||
    fail "could not clone $remote, check SSH access with: ssh -T git@gitlab.com"
}

step_tools() {
  if [ -x "$store/bin/scratch-sync" ]; then already 'scratch-sync is in ~/.scratch'; fi
  git -C "$store" pull --quiet --rebase --autostash
  if [ ! -x "$store/bin/scratch-sync" ]; then fail 'scratch-sync is still missing after the pull'; fi
}

step_link() {
  if [ "$(readlink "$link")" = "$store/bin/scratch-sync" ]; then already 'already linked'; fi
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$store/bin/scratch-sync" "$link"
}

step_sync() { "$store/bin/scratch-sync" "$action"; }

title "scratch $action"
run clone 'clone the scratch notes into ~/.scratch'
run tools 'pull scratch-sync if it is missing' clone
run link 'link scratch-sync into ~/.local/bin' tools
run sync "$action the scratch notes with scratch-sync" link
finish
