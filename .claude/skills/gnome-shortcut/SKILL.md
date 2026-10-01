---
name: gnome-shortcut
description: Add, change or remove a GNOME desktop keyboard shortcut and sync it
  to every machine through yadm. Use when the user wants to rebind a desktop key
  (Alt+Tab, Super+Tab, workspace or window keys), bind a key to run a command,
  or unbind one. Not for Claude Code's own keybindings.
---

# GNOME shortcuts

Shortcuts live in dconf, which yadm cannot track. The source of truth is
`~/.config/yadm/keybindings.sh`: one `gsettings set` per key. The yadm
`post_pull` hook and `step_keybindings` in `bootstrap.common` both run it, so
every machine converges on the script after `yadm pull`.

The machines are Ubuntu and Arch, both GNOME. Ubuntu ships different defaults
from stock GNOME, so a key the script leaves alone can behave differently on
each machine.

## Steps

1. **Find the key.** Search every keybinding schema for the action:

   ```sh
   gsettings list-recursively | grep -iE 'keybindings|media-keys' | grep -i <term>
   ```

   The schemas are `org.gnome.desktop.wm.keybindings`,
   `org.gnome.shell.keybindings`, `org.gnome.mutter.keybindings`,
   `org.gnome.mutter.wayland.keybindings` and
   `org.gnome.settings-daemon.plugins.media-keys`. A key that runs a command is
   a custom keybinding (see below). Done when you can name the schema and key
   for each action the user wants moved. If two keys fit, ask which one.

2. **Find every conflict.** List every key bound to the new accelerator on
   this machine, and on stock GNOME:

   ```sh
   gsettings list-recursively | grep -F '<Super>Tab'
   grep -B3 -F '<Super>Tab' /usr/share/glib-2.0/schemas/*.gschema.xml \
     | grep -E 'key name|default'
   ```

   GNOME treats `<Primary>` and `<Control>` as the same modifier, so search for
   both spellings. The `.xml` files hold stock GNOME defaults, which Arch uses.
   `/usr/share/glib-2.0/schemas/*.override` holds Ubuntu's changes to them.
   Done when every key holding the accelerator on either distro is listed.
   Each one goes into the script with the accelerator removed from its value.
   Tell the user which actions lose a shortcut.

3. **Edit `keybindings.sh`.** Add or update one line per key, writing the full
   list value: `"['<Control>Tab']"`, or `"[]"` to unbind. Match the existing
   style, with schemas in short variables like `wm=`. The script holds only the
   user's choices and the conflict fixes from step 2. A key that is back at its
   default on both distros comes out of the script and gets a
   `gsettings reset` on this machine.

4. **Apply and verify.** Run `~/.config/yadm/keybindings.sh`. Then check that
   `gsettings get <schema> <key>` returns the new value for each key, and that
   `dconf dump /org/gnome/` holds no keybinding changes missing from the
   script. Report the changes and any shortcuts the user lost. Leave committing
   to the user.

## Custom command shortcuts

The list `org.gnome.settings-daemon.plugins.media-keys custom-keybindings`
names a dconf path for each entry. Each path uses a relocatable schema:

```sh
mk=org.gnome.settings-daemon.plugins.media-keys
p=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/
gsettings set $mk custom-keybindings "['$p']"
gsettings set $mk.custom-keybinding:$p name 'Terminal'
gsettings set $mk.custom-keybinding:$p command 'ghostty'
gsettings set $mk.custom-keybinding:$p binding '<Super>Return'
```

Setting the list replaces it, so the script must list every custom entry the
user wants kept. Read the current list first and carry over its entries.

## Key-for-key remaps

If the user wants one key to send a different key everywhere, rather than
trigger a GNOME action, that belongs in keyd: `~/.config/keyd/default.conf`.
`step_keyd` copies it to `/etc/keyd` only during bootstrap, so a pull alone
does not apply it. Tell the user to rerun `yadm bootstrap` or that step.
