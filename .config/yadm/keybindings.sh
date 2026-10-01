#!/bin/sh
command -v gsettings >/dev/null || exit 0

wm=org.gnome.desktop.wm.keybindings
gsettings set $wm switch-windows "['<Control>Tab']"
gsettings set $wm switch-windows-backward "['<Shift><Control>Tab']"
gsettings set $wm switch-to-workspace-left "['<Alt><Super>Left']"
gsettings set $wm switch-to-workspace-right "['<Alt><Super>Right']"
gsettings set $wm switch-applications "[]"
gsettings set $wm switch-applications-backward "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>Tab']"
