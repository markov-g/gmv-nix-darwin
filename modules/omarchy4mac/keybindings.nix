{ lib }:

let
  # AeroSpace remains the only executor for these bindings. Hammerspoon uses
  # the same records for its display-only shortcut overlay.
  bindings = [
    { mode = "main"; key = "ctrl-alt-left"; action = "focus left"; label = "Ctrl+Alt+Left"; description = "Focus window left"; }
    { mode = "main"; key = "ctrl-alt-down"; action = "focus down"; label = "Ctrl+Alt+Down"; description = "Focus window down"; }
    { mode = "main"; key = "ctrl-alt-up"; action = "focus up"; label = "Ctrl+Alt+Up"; description = "Focus window up"; }
    { mode = "main"; key = "ctrl-alt-right"; action = "focus right"; label = "Ctrl+Alt+Right"; description = "Focus window right"; }

    { mode = "main"; key = "ctrl-alt-shift-left"; action = "move left"; label = "Ctrl+Alt+Shift+Left"; description = "Move window left"; }
    { mode = "main"; key = "ctrl-alt-shift-down"; action = "move down"; label = "Ctrl+Alt+Shift+Down"; description = "Move window down"; }
    { mode = "main"; key = "ctrl-alt-shift-up"; action = "move up"; label = "Ctrl+Alt+Shift+Up"; description = "Move window up"; }
    { mode = "main"; key = "ctrl-alt-shift-right"; action = "move right"; label = "Ctrl+Alt+Shift+Right"; description = "Move window right"; }

    { mode = "main"; key = "ctrl-alt-1"; action = "workspace 1"; label = "Ctrl+Alt+1"; description = "Switch to workspace 1"; }
    { mode = "main"; key = "ctrl-alt-2"; action = "workspace 2"; label = "Ctrl+Alt+2"; description = "Switch to workspace 2"; }
    { mode = "main"; key = "ctrl-alt-3"; action = "workspace 3"; label = "Ctrl+Alt+3"; description = "Switch to workspace 3"; }
    { mode = "main"; key = "ctrl-alt-4"; action = "workspace 4"; label = "Ctrl+Alt+4"; description = "Switch to workspace 4"; }
    { mode = "main"; key = "ctrl-alt-5"; action = "workspace 5"; label = "Ctrl+Alt+5"; description = "Switch to workspace 5"; }

    { mode = "main"; key = "ctrl-alt-shift-1"; action = "move-node-to-workspace 1"; label = "Ctrl+Alt+Shift+1"; description = "Move window to workspace 1"; }
    { mode = "main"; key = "ctrl-alt-shift-2"; action = "move-node-to-workspace 2"; label = "Ctrl+Alt+Shift+2"; description = "Move window to workspace 2"; }
    { mode = "main"; key = "ctrl-alt-shift-3"; action = "move-node-to-workspace 3"; label = "Ctrl+Alt+Shift+3"; description = "Move window to workspace 3"; }
    { mode = "main"; key = "ctrl-alt-shift-4"; action = "move-node-to-workspace 4"; label = "Ctrl+Alt+Shift+4"; description = "Move window to workspace 4"; }
    { mode = "main"; key = "ctrl-alt-shift-5"; action = "move-node-to-workspace 5"; label = "Ctrl+Alt+Shift+5"; description = "Move window to workspace 5"; }

    { mode = "main"; key = "ctrl-alt-f"; action = "layout floating tiling"; label = "Ctrl+Alt+F"; description = "Toggle floating layout"; }
    { mode = "main"; key = "ctrl-alt-enter"; action = "fullscreen"; label = "Ctrl+Alt+Enter"; description = "Toggle AeroSpace fullscreen"; }
    { mode = "main"; key = "ctrl-alt-r"; action = "mode resize"; label = "Ctrl+Alt+R"; description = "Enter resize mode"; }

    { mode = "resize"; key = "left"; action = "resize width -50"; label = "Left"; description = "Resize width -50"; }
    { mode = "resize"; key = "down"; action = "resize height +50"; label = "Down"; description = "Resize height +50"; }
    { mode = "resize"; key = "up"; action = "resize height -50"; label = "Up"; description = "Resize height -50"; }
    { mode = "resize"; key = "right"; action = "resize width +50"; label = "Right"; description = "Resize width +50"; }
    { mode = "resize"; key = "escape"; action = "mode main"; label = "Escape"; description = "Return to main mode"; }
    { mode = "resize"; key = "enter"; action = "mode main"; label = "Enter"; description = "Return to main mode"; }
    { mode = "resize"; key = "ctrl-alt-tab"; action = "focus-monitor next"; label = "Ctrl+Alt+Tab"; description = "Focus next monitor"; }
    { mode = "resize"; key = "ctrl-alt-shift-tab"; action = "focus-monitor prev"; label = "Ctrl+Alt+Shift+Tab"; description = "Focus previous monitor"; }
    { mode = "resize"; key = "ctrl-alt-backspace"; action = "workspace-back-and-forth"; label = "Ctrl+Alt+Backspace"; description = "Workspace back-and-forth"; }
    { mode = "resize"; key = "ctrl-alt-slash"; action = "layout tiles horizontal vertical"; label = "Ctrl+Alt+/"; description = "Tile layout orientation"; }
    { mode = "resize"; key = "ctrl-alt-comma"; action = "layout accordion horizontal vertical"; label = "Ctrl+Alt+,"; description = "Accordion layout orientation"; }
  ];

  renderMode = mode:
    let
      modeBindings = lib.filter (binding: binding.mode == mode) bindings;
    in
    "[mode.${mode}.binding]\n"
    + lib.concatMapStringsSep "\n" (binding:
      "${binding.key} = '${binding.action}'") modeBindings;

in
{
  aerospace = lib.concatMapStringsSep "\n\n" renderMode [ "main" "resize" ];

  hammerspoon = lib.concatMapStringsSep "\n" (binding:
    "  \"${binding.label}  ${binding.description}\",") bindings;
}
