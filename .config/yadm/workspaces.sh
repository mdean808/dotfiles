#!/bin/sh
command -v gsettings >/dev/null || exit 0
gsettings list-schemas | grep -qx org.gnome.shell.extensions.auto-move-windows || exit 0

gsettings set org.gnome.shell.extensions.auto-move-windows application-list \
  "['slack_slack.desktop:1', 'app.zen_browser.zen.desktop:2', 'local.ghostty.startup.desktop:3']"

uuid=auto-move-windows@gnome-shell-extensions.gcampax.github.com
enabled=$(gsettings get org.gnome.shell enabled-extensions)
case "$enabled" in
  *"'$uuid'"*) ;;
  "@as []") gsettings set org.gnome.shell enabled-extensions "['$uuid']" ;;
  *) gsettings set org.gnome.shell enabled-extensions "${enabled%]}, '$uuid']" ;;
esac
