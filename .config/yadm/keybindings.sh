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

mk=org.gnome.settings-daemon.plugins.media-keys
vicinae=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae/
clipboard=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae-clipboard/
ghostty=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty/
gsettings set $mk terminal "[]"
gsettings set $mk custom-keybindings "['$vicinae', '$clipboard', '$ghostty']"
gsettings set $mk.custom-keybinding:$vicinae name 'Vicinae'
gsettings set $mk.custom-keybinding:$vicinae command 'vicinae toggle'
gsettings set $mk.custom-keybinding:$vicinae binding '<Control>space'
gsettings set $mk.custom-keybinding:$clipboard name 'Vicinae clipboard history'
gsettings set $mk.custom-keybinding:$clipboard command 'vicinae cmd launch clipboard:history'
gsettings set $mk.custom-keybinding:$clipboard binding '<Super><Control>v'
gsettings set $mk.custom-keybinding:$ghostty name 'Ghostty'
gsettings set $mk.custom-keybinding:$ghostty command 'ghostty +new-window'
gsettings set $mk.custom-keybinding:$ghostty binding '<Control><Alt>t'
