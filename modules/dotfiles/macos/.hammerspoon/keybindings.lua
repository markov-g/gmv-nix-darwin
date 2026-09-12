-- Keybinding overlay: press ctrl+alt+/ to show a summary of active shortcuts.
-- No shell execution, no network access, no Accessibility beyond what
-- Hammerspoon already requires.

local bindings = {
  "-- AeroSpace (window management) --",
  -- @OMARCHY_HAMMERSPOON_BINDINGS@
  "",
  "-- tmux --",
  "Ctrl+A                tmux prefix",
  "Ctrl+A, h/j/k/l      Pane navigation",
  "Ctrl+A, -/|           Split pane",
  "Ctrl+A, c             New window",
  "Ctrl+A, Enter         Copy mode",
  "Ctrl+A, r             Reload config",
  "",
  "-- Herdr --",
  "Ctrl+B                Herdr prefix",
  "Ctrl+B, h/j/k/l      Pane focus",
  "Ctrl+B, c             New tab",
  "Ctrl+B, [             Copy mode",
  "Ctrl+B, b             Toggle sidebar",
  "Ctrl+B, z             Zoom pane",
  "",
  "-- Neovim --",
  "Space                 Leader key",
  "Alt+J/K               Move line down/up",
  "",
  "-- Hammerspoon --",
  "Ctrl+Alt+/            This overlay",
  "Ctrl+Alt+C            Toggle caffeine (keep-awake)",
}

hs.hotkey.bind({"ctrl", "alt"}, "/", function()
  local text = table.concat(bindings, "\n")
  hs.alert.show(text, 8)
end)
