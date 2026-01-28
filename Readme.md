# GMv’s macOS Nix Setup

# 

> Declarative macOS configuration using **nix-darwin**, **home-manager** & **nix-homebrew**

---

## 🚀 Overview

# 

This repository configures your macOS machine in a fully-declarative way:

1. **nix-darwin** — manages system-wide settings, services & global packages
2. **home-manager** — manages per-user dotfiles, shell config & user packages
3. **nix-homebrew** — bootstraps one or more Homebrew prefixes (including a custom `~/PACKAGEMGMT/Homebrew`), taps, formulas, casks and Mac-App-Store apps

Every change lives in Nix expressions — no imperative “brew install …” or manual edits.

---

## 📁 Repository Layout

# 

```
~/.config/nix-darwin/
├── flake.nix                # top-level flake definition
├── flake.lock
└── modules/
    ├── system.nix           # nix-darwin system config
    ├── homebrew.nix         # nix-darwin Homebrew bundle
    ├── home.nix             # home-manager per-user config
    ├── homebrew/
    │   ├── brews.nix        # list of brew CLI formulas
    │   └── casks.nix        # list of brew GUI casks
    └── dotfiles/
        └── macos/
            └── .zshrc.${USER}  # your Z-shell config

```

---

## 🔧 flake.nix

# 

Located at `~/.config/nix-darwin/flake.nix`.

### Inputs

# 

* **nixpkgs**: core package set (`nixpkgs-unstable`)
* **nix-darwin**: system manager
* **home-manager**: user-level manager
* **nix-homebrew**: Homebrew integration
* **homebrew-core**, **homebrew-cask**, **kylef-formulae**, **mas-cli-tap**, **swiftbrew-tap**, **sdkman-tap**: pinned taps

### Outputs

# 

Defines `darwinConfigurations.${HOSTNAME}` via:

```
nix-darwin.lib.darwinSystem {
  inherit system;                # e.g. "aarch64-darwin"
  specialArgs = { user inputs; } # makes $user & taps available

  modules = [
    ./modules/system.nix
    ({ … }: { users.users.${user}.home = "/Users/${user}"; })
    nix-homebrew.darwinModules.nix-homebrew { … }
    ./modules/homebrew.nix
    home-manager.darwinModules.home-manager { … }
  ];
}

```

---

## ⚙️ modules/system.nix

# 

Global macOS & Nix settings:

```
{ pkgs, user, … }:

{
  nix.enable = false;                     # nix-darwin takes over
  system.primaryUser = user;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;             # add /run/current-system/sw/bin to $PATH

  environment.systemPackages = with pkgs; [
    vim bat eza tmux
  ];

  system.stateVersion = 6;                # macOS compatibility
}

```

---

## 🍺 modules/homebrew.nix

# 

Declarative Homebrew bundle:

```
{ inputs, user, … }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
in {
  homebrew.enable     = true;
  homebrew.brewPrefix = "/Users/${user}/PACKAGEMGMT/Homebrew/bin";
  homebrew.brews      = brews;
  homebrew.casks      = casks;
  homebrew.masApps    = {
    "Kagi for Safari" = 1622835804;
    "Microsoft To Do" = 1274495053;
    "Quiver"          = 866773894;
    "Termius"         = 117607088;
    "UTM"             = 1538878817;
    "Windows App"     = 1295203466;
    "Workspaces"      = 1540284555;
    "Xcode"           = 497799835;
  };
  homebrew.onActivation = {
    autoUpdate = true;
    upgrade    = true;
    cleanup    = "uninstall";
  };
}

```

* **brews.nix**: plain list of formula names
* **casks.nix**: plain list of GUI apps
* **masApps**: `{ "App Name" = appId; … }`

---

## 🏠 modules/home.nix

# 

User-level (Home-Manager) config:

```
{ config, pkgs, inputs, user, … }:

{
  programs.home-manager.enable = true;
  home.username      = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion  = "25.11";

  home.packages = with pkgs; [
    (inputs.home-manager.packages.${pkgs.system}.home-manager)
    direnv nix-direnv autojump
  ];

  home.file.".zshrc".source = ./dotfiles/macos/.zshrc.${user};
}

```

* Symlinks your custom `modules/dotfiles/macos/.zshrc.${USER}` into `~/.zshrc`
* Installs `home-manager` CLI, `direnv`, `autojump`, etc.

---

## 📦 modules/homebrew/{brews.nix,casks.nix}

### brews.nix

# 

```
[
  "antigen"
  "autojump"
  "awscli"
  "bat"
  "eza"
  "fd"
  "fzf"
  "git"
  # …plus tap-qualified…
  "kylef/formulae/swiftenv"
  "mas-cli/tap/mas"
]

```

### casks.nix

# 

```
[
  "iterm2"
  "jetbrains-toolbox"
  "temurin"
  "xquartz"
  # …
]

```

Add or remove lines to manage all your Homebrew packages declaratively.

---

## 📝 Dotfiles

# 

Place any per-machine or per-user dotfiles under:

```
modules/dotfiles/macos/.zshrc.${USER}
modules/dotfiles/macos/.gitconfig
…

```

Home-Manager will create symlinks into your home directory.

---

## 🔄 Workflow

# 

1. **Edit** any Nix file (`flake.nix`, `modules/*.nix`, `modules/homebrew/*.nix`, dotfiles).
2. **Rebuild & activate**:

```
sudo darwin-rebuild switch --flake ~/.config/nix-darwin

```

  This runs:

  * Nix-darwin system build & activation
  * `brew bundle` (install/upgrade/cleanup)
  * Home-Manager activation
3. **Enjoy** your updated, reproducible Mac!

Note!
Initially, since darwin-rebuild doesn't exist yet, use nix run to execute it directly from the nix-darwin flake to bootstrap:
```
sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake /Users/$USER/.config/nix-darwin#$(hostname -s)
```

---

## 🌱 Updating

# 

* **Flake inputs**:

```
nix flake update

```
* **Rebuild**:

```
sudo darwin-rebuild switch --flake ~/.config/nix-darwin

```
* **Clean old Nix store paths**:

```
nix-collect-garbage -d

```

---

## ✨ Extending

# 

* **Add a new formula** → append `"newtool"` to `modules/homebrew/brews.nix`
* **Add a new cask** → append `"newapp"` to `modules/homebrew/casks.nix`
* **Add a new Mac App Store app** → add `"Name" = appId;` in `masApps`
* **Add a system package** → update `environment.systemPackages` in `system.nix`
* **Add a Home-Manager package** → update `home.packages` in `home.nix`
* **Add a dotfile** → drop it under `modules/dotfiles/macos/` and reference in `home.nix`

---

## 🛠 Troubleshooting

# 

* **Missing `hm-session-vars.sh`** → ensure `programs.home-manager.enable = true;` and re-switch
* **Z-shell completion errors** → set `programs.zsh.enableCompletion = true;` in `system.nix`
* **`fzf` keybindings** → after adding `"fzf"` to `brews.nix`, run:

```
$(brew --prefix)/opt/fzf/install

```
* **Homebrew tap failures** → check `inputs` in `flake.nix` and the `taps = { … }` block under `nix-homebrew`

---

Keep your Mac fully reproducible, share your configuration across machines, and never install software manually again!
