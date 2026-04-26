# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Declarative macOS configuration for multiple Apple Silicon machines using nix-darwin + nix-homebrew + home-manager + sops-nix. One `flake.nix` defines all machines and users.

## Key commands

### Apply config (admin/primary user)
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
# or use the shell alias:
darwin-re
```

### Apply config for a specific host
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin#minidevbox
```

### Build only (no activation — safe for testing)
```bash
darwin-rebuild build --flake ~/.config/nix-darwin#minidevbox
```

### Apply config (secondary/standard user, no sudo)
```bash
home-manager switch --flake ~/.config/nix-darwin#devel@minidevbox
```

### Full update (Nix daemon upgrade + flake update + rebuild + GC)
```bash
~/bin/nix-update-all.sh
~/bin/nix-update-all.sh --no-gc   # skip garbage collection
```

### Update flake inputs only
```bash
nix flake update
```

### Edit encrypted secrets
```bash
sops ~/.config/nix-darwin/secrets/secrets.yaml
```

### First bootstrap on a new machine (before darwin-rebuild is on PATH)
```bash
sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- \
  switch --flake /Users/$USER/.config/nix-darwin#$(hostname -s)
```

## Architecture

### Three layers composed per machine

| Layer | Tool | Manages |
|---|---|---|
| System | nix-darwin | macOS defaults, firewall, hostname, system packages (all users), Touch ID sudo |
| Packages | nix-homebrew | Homebrew at `~/PACKAGEMGMT/Homebrew`, brew bundle (formulas + casks + MAS) |
| User | home-manager | Dotfiles symlinked to nix store, user packages, secrets decryption, activation scripts |

### flake.nix — two machine helpers

**`mkDarwin`** — admin accounts. Composes all three layers. Each machine passes `host`, `user`, `system`, and `enableMas` as `specialArgs` injected into every module.

**`mkHomeUser`** — secondary/standard users. Standalone home-manager only (no root needed). Activated with `home-manager switch`.

### Machines

| Flake key | Hostname | User | Note |
|---|---|---|---|
| `r1pp3r` | r1pp3r | r1pp3r | Personal laptop |
| `SE1FXHLQH3MTP` | SE1FXHLQH3MTP | mch12700 | Work laptop |
| `minidevbox` | minidevbox | r1pp3r | Mac mini dev server |
| `minidevboxvm` | minidevboxvm | devel | VM on the mini |
| `openclaw` | openclaw | r1pp3r | No Apple ID (`enableMas = false`) |

### Module layout

- `modules/system.nix` — nix-darwin system layer: hostname, system packages, macOS defaults (Dock, Finder, keyboard, screensaver, etc.), Touch ID sudo, firewall. Sets `nix.enable = false` to defer to Determinate Nix daemon.
- `modules/homebrew.nix` — thin wiring; imports the three homebrew sub-modules; sets `onActivation.cleanup = "zap"`.
- `modules/homebrew/brews.nix` — shared CLI formula list.
- `modules/homebrew/casks.nix` — takes `{ host }`; returns shared + per-host GUI apps.
- `modules/homebrew/mas.nix` — takes `{ host, enableMas }`; returns `{}` when `enableMas = false`.
- `modules/home.nix` — home-manager for the primary user: dotfile symlinks, activation scripts (TPM bootstrap, SSH key generation, compinit fix), sleepwatcher launchd agent, sops secrets decryption.
- `modules/home-standard.nix` — secondary users: `imports = [ ./home.nix ]` plus activation scripts to bootstrap Homebrew and run `brew bundle` (formulas only, no casks/MAS).
- `modules/dotfiles/macos/` — all managed dotfiles (zsh chain, git, tmux, Neovim/LazyVim, p10k, `bin/` scripts).

### Secrets (sops-nix)

SSH key → `ssh-to-age` → age private key at `~/.config/sops/age/keys.txt` → decrypts `secrets/secrets.yaml` at activation → plaintext files at runtime. The entire `sops` block in `home.nix` is guarded with `lib.mkIf (builtins.pathExists ../secrets/secrets.yaml)` so the config builds cleanly before secrets exist. `.sops.yaml` contains a placeholder age public key that must be replaced on each new machine.

### tmux persistence

Sessions survive reboots via tmux-resurrect + tmux-continuum (configured in `.tmux.conf`). TPM and plugins are auto-bootstrapped on first tmux start via `home.activation.bootstrapTpm` in `home.nix`.

`.zshrc` autostart logic: starts a bare `${USER}-tmux` session and attaches. If `~/.tmux/resurrect/last` exists, continuum restores the saved layout into it. If not (fresh machine), default windows are created instead. All terminals including VSCode attach to the same session.

Before rebooting: `Ctrl-a Ctrl-s` to force-save. Continuum auto-saves every 15 min otherwise. To close the terminal normally, just `Cmd+Q` — the tmux server keeps running independently.

### Shell PATH note

Homebrew binaries are deliberately NOT on `$PATH` by default. Activate them per-session with `source ~/.profile.homebrew`. This keeps each user's Homebrew isolated.

### Nix packages vs Homebrew

`system.nix` (Nix store, all users): neovim, tmux, bat, eza, fzf, fd, ripgrep, delta, jq, lazygit, gitui, atuin, zoxide, bottom, htop, ncdu, yazi, difftastic, k9s, tealdeer, glow, gpg, age, ssh-to-age, gopls, nil (Nix LSP), nodejs, go, statix, fh.

`homebrew/brews.nix` (Homebrew, primary user): antigen, awscli, azure-cli, colima, eksctl, helm, kubernetes-cli, k8sgpt, lazydocker, lume, mise, nvm, ollama, rustup, uv, pixi, sleepwatcher, and others that require Homebrew-specific installation.
