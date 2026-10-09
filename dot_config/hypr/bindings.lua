-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Hyper key (Caps Lock) shortcuts. Caps Lock is configured as Mod3 in
-- input.lua, so bind with MOD3.
o.bind("MOD3 + V", "VSCode", { focus = "code", launch = "code" })
o.bind("MOD3 + G", "Ghostty", { focus = "ghostty", launch = "ghostty" })
o.bind("MOD3 + B", "Browser", { focus = "helium-browser", launch = "helium-browser" })

-- Dictation (voxtype): press Ctrl+Space to toggle listening on/off. voxtype's
-- own evdev hotkey only accepts a single KEY_*, so this modifier combo lives in
-- Hyprland. (F9 stays push-to-talk from Omarchy's defaults.)
o.bind("CTRL + SPACE", "Toggle dictation", "voxtype record toggle")

-- While recording, voxtype's pre_recording_command switches Hyprland into the
-- voxtype_recording submap, so Escape cancels the dictation without hijacking
-- Escape globally, and Ctrl+Space still stops it. voxtype_suppress swallows
-- modifier presses while the transcription is being typed, so they don't
-- disturb wtype.
local function voxtype_cancel()
  hl.dispatch(hl.dsp.exec_cmd("voxtype record cancel"))
  hl.dispatch(hl.dsp.submap("reset"))
end

hl.define_submap("voxtype_recording", function()
  hl.bind("ESCAPE", voxtype_cancel)
  hl.bind("F12", voxtype_cancel)
  hl.bind("CTRL + SPACE", hl.dsp.exec_cmd("voxtype record toggle"))
end)

hl.define_submap("voxtype_suppress", function()
  for _, key in ipairs({ "SUPER_L", "SUPER_R", "CONTROL_L", "CONTROL_R", "ALT_L", "ALT_R", "SHIFT_L", "SHIFT_R" }) do
    hl.bind(key, hl.dsp.no_op())
  end
  hl.bind("F12", hl.dsp.submap("reset"))
end)

-- Workspace assignments.
-- Verify class names with `hyprctl clients` if a rule doesn't apply.
o.window("(?i)(chromium|helium)", { workspace = "4" })
o.window("(code|Code)", { workspace = "2" })
o.window("com.mitchellh.ghostty", { workspace = "1" })

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
