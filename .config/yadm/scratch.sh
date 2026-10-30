#!/bin/sh

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE

store="$HOME/.scratch"
remote=git@gitlab.com:modean/scratch.git
link="$HOME/.local/bin/scratch-sync"

if [ ! -d "$store/.git" ]; then
  printf 'Cloning %s into ~/.scratch\n' "$remote"
  if ! git clone --quiet "$remote" "$store"; then
    printf 'Could not clone %s. Check SSH access with: ssh -T git@gitlab.com\n' "$remote" >&2
    exit 1
  fi
fi

if [ ! -x "$store/bin/scratch-sync" ]; then
  printf 'scratch-sync is missing from ~/.scratch, pulling\n'
  git -C "$store" pull --quiet --rebase --autostash || exit 1
fi

if [ "$(readlink "$link")" != "$store/bin/scratch-sync" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$store/bin/scratch-sync" "$link"
  printf 'Linked ~/.local/bin/scratch-sync\n'
fi

exec "$store/bin/scratch-sync" "$@"
