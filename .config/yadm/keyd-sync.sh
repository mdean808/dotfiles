#!/bin/sh
command -v keyd >/dev/null || exit 0

src="$HOME/.config/keyd/default.conf"
dst=/etc/keyd/default.conf
cmp -s "$src" "$dst" && exit 0
sudo install -D -m 644 "$src" "$dst"
sudo keyd reload
