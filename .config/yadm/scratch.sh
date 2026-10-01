#!/bin/sh

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE

store="$HOME/.scratch"

if [ ! -d "$store/.git" ]; then
  git clone --quiet git@gitlab.com:modean/scratch.git "$store" || exit 1
fi

if [ ! -x "$store/bin/scratch-sync" ]; then
  git -C "$store" pull --quiet --rebase --autostash || exit 1
fi

mkdir -p "$HOME/.local/bin"
ln -sfn "$store/bin/scratch-sync" "$HOME/.local/bin/scratch-sync"

exec "$store/bin/scratch-sync" "$@"
