# Called as: import ./homebrew/brews.nix { inherit lib omarchy4mac; }
# Returns the merged formula list: shared ++ omarchy4mac conditional
{ lib, omarchy4mac }:

# Plain Nix list -- CLI formulas
# NOTE: the following are managed by Nix (system.nix) -- do NOT add here:
#   bat, eza, fzf, fd, git-delta, ripgrep, tmux, autojump  (original)
#   neovim, lazygit, gitui, atuin, zoxide, bottom, htop, ncdu, yazi,
#   difftastic, dust, tokei, xh, jless, k9s, tealdeer, glow,
#   hyperfine, procs, jq
[
  "antigen" # zsh plugin manager (sourced from BREW_PREFIX in .zshrc)
  # "aws-shell"
  "awscli"
  "azure-cli"
  "blueutil" # Bluetooth control (used in ~/.sleep / ~/.wakeup)
  "libxcb"
  #  "code-server"
  "colima"
  "cloudflared"
  #  "container"           # Apple container runtime (macOS 26+)
  "cpulimit"
  "eksctl"
  "exercism"
  "fail2ban"
  # "fish"
  "gambit"
  # "gemini-cli"
  "git"
  "git-lfs"
  # "glow"               # -> Nix (system.nix)
  "gnu-tar"
  "go"
  "pkgconf"
  "icu4c@76"
  ###  "gradle"
  "helm"
  "herdr" # AI-aware terminal multiplexer (tmux replacement candidate)
  # "hermes-agent"
  # "htop"               # -> Nix (system.nix)
  "huggingface-cli"
  "iproute2mac"
  "jenv" # Java version manager
  "k8sgpt"
  ###  "kotlin"
  ###  "kotlin-language-server"
  "kubernetes-cli"
  "kubeshark"
  "lazydocker"
  "lima"
  "lua"
  "lume"
  "m-cli" # macOS CLI utilities
  "mas" # Mac App Store CLI
  "mise" # polyglot version manager (Node, Python, Ruby, Go...)
  "minikube"
  "mole"
  # "ncdu"               # -> Nix (system.nix)
  ###  "neo4j"
  # "neovim"             # -> Nix (system.nix)
  "nvm" # Node version manager (alternative to mise for Node)
  "ollama"
  # "opencode"
  "opensc"
  "pipx"
  "pixi"
  "podman"
  "podman-compose"
  # "qemu"
  "quartz-wm" # X11 window manager (XQuartz companion)
  "rsync"
  "rustup" # Rust toolchain manager
  "sleepwatcher" # Triggers ~/.sleep and ~/.wakeup on power events
  "starship"
  # "subversion"
  "uv" # Fast Python package manager
  "vapor" # Swift web framework CLI
  "whalebrew"
  # "yazi"               # -> Nix (system.nix)

  # tap-qualified formulas
  "kylef/formulae/swiftenv"
  "sdkman/tap/sdkman-cli"
  "swiftbrew/tap/swiftbrew"
  # "mas-cli/tap/mas"
]
# ── Omarchy4Mac conditional formulas ─────────────────────────────────────────
++ lib.optionals (omarchy4mac.enable && omarchy4mac.apps.bun)         [ "bun" ]
++ lib.optionals (omarchy4mac.enable && omarchy4mac.apps.fastfetch)   [ "fastfetch" ]
++ lib.optionals (omarchy4mac.enable && omarchy4mac.desktop.sketchybar) [ "sketchybar" ]
++ lib.optionals (omarchy4mac.enable && omarchy4mac.desktop.borders)  [ "borders" ]
