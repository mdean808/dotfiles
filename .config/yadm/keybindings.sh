#!/bin/sh
command -v gsettings >/dev/null || exit 0

wm=org.gnome.desktop.wm.keybindings
gsettings set $wm switch-windows "['<Control>Tab']"
gsettings set $wm switch-windows-backward "['<Shift><Control>Tab']"
gsettings set $wm switch-to-workspace-left "['<Alt><Super>Left', '<Shift><Control>h']"
gsettings set $wm switch-to-workspace-right "['<Alt><Super>Right', '<Shift><Control>l']"
gsettings set $wm switch-applications "[]"
gsettings set $wm switch-applications-backward "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>Tab']"
gsettings set $wm minimize "[]"
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"

ta=org.gnome.shell.extensions.tiling-assistant
if gsettings list-schemas | grep -qx $ta; then
  gsettings set $ta tile-left-half "['<Super>Left', '<Super>KP_4', '<Super>h']"
  gsettings set $ta tile-right-half "['<Super>Right', '<Super>KP_6', '<Super>l']"
  gsettings set $ta tile-maximize "['<Super>Up', '<Super>KP_5', '<Super>k']"
  gsettings set $ta restore-window "['<Super>Down', '<Super>j']"
else
  gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Super>Left', '<Super>h']"
  gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Super>Right', '<Super>l']"
  gsettings set $wm maximize "['<Super>Up', '<Super>k']"
  gsettings set $wm unmaximize "['<Super>Down', '<Alt>F5', '<Super>j']"
fi

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
