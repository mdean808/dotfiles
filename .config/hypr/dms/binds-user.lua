-- Your keybinds. dms setup never overwrites this file.
-- Loaded after binds.lua: binding a stock key here replaces it, hl.unbind("SUPER + X") frees it.
-- Saving in the DMS keybind editor rewrites this file and keeps only hl.bind/hl.unbind lines.

hl.unbind("CTRL + space")
hl.bind("CTRL + space", hl.dsp.exec_cmd("dms ipc call spotlight-bar toggle"), { description = "dms ipc call spotlight-bar toggle" })
hl.unbind("ALT + space")
hl.unbind("CTRL + Q")
hl.bind("CTRL + Q", hl.dsp.window.close(), { description = "Close window" })
hl.unbind("SUPER + Q")
hl.bind("SUPER + CTRL + V", hl.dsp.exec_cmd("dms ipc call spotlight openQuery 'cb '"), { description = "Clipboard history" })
