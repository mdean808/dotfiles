#!/bin/sh
find "${XDG_RUNTIME_DIR:-/tmp}" -type s -name 'nvim.*.0' 2>/dev/null | while read -r socket; do
	nvim --server "$socket" --remote-expr 'execute("colorscheme " . g:colors_name)' >/dev/null 2>&1 &
done
wait
