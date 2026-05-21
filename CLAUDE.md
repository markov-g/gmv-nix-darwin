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
| `SE1FXHLQH3MTP` | SE1FXHLQH3MTP | mch12700 | Work laptop (older SIE MBP) |
| `SE1L649RJQC4F` | SE1L649RJQC4F | mch12700 | Work laptop (new SIE MacBook Pro M5) |
| `minidevbox` | minidevbox | r1pp3r | Mac mini dev server |
| `minidevboxvm` | minidevboxvm | devel | VM on the mini |
| `openclaw` | openclaw | r1pp3r | No Apple ID (`enableMas = false`) |

### Module layout

- `modules/system.nix` — nix-darwin system layer: hostname, system packages, macOS defaults (Dock, Finder, keyboard, screensaver, etc.), Touch ID sudo, firewall. Sets `nix.enable = false` to defer to Determinate Nix daemon.
- `modules/homebrew.nix` — thin wiring; imports the three homebrew sub-modules; sets `onActivation.cleanup = "zap"`.
- `modules/homebrew/brews.nix` — shared CLI formula list.
- `modules/homebrew/casks.nix` — takes `{ host }`; returns shared + per-host GUI apps.
- `modules/homebrew/mas.nix` — takes `{ host, enableMas }`; returns per-host + shared app attrset; returns `{}` when `enableMas = false`. Declaration only -- no installation logic.
- `modules/homebrew/mas-install.nix` — custom activation module; forces `homebrew.masApps = lib.mkForce {}` to bypass brew bundle, then installs/upgrades MAS apps via `mas` in `postActivation` using `SUDO_UID/SUDO_GID/SUDO_USER` env shim.
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

`system.nix` (Nix store, all users): vim, neovim, tmux, bat, eza, fzf, fd, ripgrep, delta, jq, lazygit, gitui, atuin, zoxide, bottom, htop, ncdu, yazi, difftastic, dust, tokei, xh, jless, hyperfine, procs, k9s, tealdeer, glow, gnupg, age, ssh-to-age, gopls, nil (Nix LSP), nodejs, go, statix, fh.

`homebrew/brews.nix` (Homebrew, primary user): antigen, awscli, azure-cli, colima, eksctl, helm, kubernetes-cli, k8sgpt, lazydocker, lume, mise, nvm, ollama, rustup, uv, pixi, sleepwatcher, and others that require Homebrew-specific installation.

## Mac App Store (MAS) app management

### Architecture

MAS apps are declared in `modules/homebrew/mas.nix` (per-host attrset, merged with a shared list). Installation and upgrade are handled by `modules/homebrew/mas-install.nix`, **not** by nix-darwin's built-in `homebrew.masApps` brew-bundle path.

### Why a custom module

nix-darwin's standard `homebrew.masApps` mechanism delegates to brew bundle, which calls `mas install <id>` as root during activation. This is broken on modern macOS:

1. macOS (26.1, 15.7.2, 14.8.2 and later) revoked the entitlement that let non-Apple binaries connect to `installd` directly.
2. mas 4.0+ works around this by shelling out to `/usr/sbin/installer`, which requires root.
3. App Store auth lives in the user's launchd session, not root's. Per-user XPC services (`storeaccountd`, `commerced`) are registered in the user's launchd bootstrap domain.
4. mas-as-root cannot reach those services, so authentication fails on every `mas install` call.

Tracked upstream as [nix-darwin#1694](https://github.com/nix-darwin/nix-darwin/issues/1694) and [Homebrew/brew#21559](https://github.com/Homebrew/brew/issues/21559). Both open.

### How the custom module works

`modules/homebrew/mas-install.nix`:

1. Forces `homebrew.masApps = lib.mkForce {};` so brew bundle has nothing to fail on.
2. Imports `./mas.nix` directly to get the app list (single source of truth preserved).
3. Sets `SUDO_UID` / `SUDO_GID` / `SUDO_USER` in the activation environment so mas's zsh wrapper sees the env it expects from a `sudo mas` invocation.
4. Calls `mas install <id>` for missing apps (idempotent via `mas list` pre-check).
5. Calls `mas upgrade` to bring outdated apps current.

The activation runs in `system.activationScripts.postActivation.text` with `lib.mkAfter`, after brew bundle and home-manager have completed.

### What it does NOT do

- **Deletion**: mas has no uninstall command. To remove an app, delete `/Applications/<Name>.app` manually and remove the entry from `mas.nix`. nix-darwin will not clean up `/Applications` for you.
- **Acquisition**: `mas install` only re-downloads apps already in the Apple ID's purchase history. Fresh apps must be "Get"ed once via the App Store GUI; after that, future rebuilds install them automatically.
- **Sign-in**: mas cannot sign in to the App Store. User must sign in via App Store GUI once per machine.

### Per-host opt-out

`mkDarwin` accepts an `enableMas` parameter (default true). Setting `enableMas = false` (as on `openclaw`) skips the module entirely: no override, no activation script. Use this for machines without an Apple ID or where MAS is intentionally unmanaged.

### Why apps end up owned by root:wheel

Apple's installer runs as root, so MAS apps land at `/Applications/<Name>.app` with `root:wheel` ownership. This is expected and correct. macOS doesn't enforce uniform ownership in `/Applications`; the mix of `root:wheel`, `root:admin`, and `<user>:staff` you'll see across apps reflects different install methods (MAS, pkg, DMG drag, brew cask). Don't normalize it.

### Homebrew version pinning

`flake.lock` pins `nix-homebrew/brew-src` to Homebrew **5.1.10 or later**. Required because current casks (notably `codex`) use the `generate_completions_from_executable` DSL method, added in Homebrew 5.1.0. Older brew errors with:

```
Error: Unexpected method 'generate_completions_from_executable' called on Cask codex
```

When bumping inputs, do not downgrade `brew-src` below 5.1.0.

### New machine setup

1. `darwin-rebuild switch --flake .` once (mas-install will fail silently on uninstalled apps).
2. Sign into App Store GUI with your Apple ID.
3. For each app in `mas.nix` not yet in your purchase history, click "Get" in App Store. This adds it to your purchases without necessarily installing it.
4. `darwin-rebuild switch --flake .` again; mas-install picks them up and installs each.

End-of-life apps (e.g. 1Password 7) may show "no longer available" in the store. Remove from `mas.nix` and use a cask alternative (e.g., `1password` cask for v8).

### Modifying mas-install.nix

If touching this module:

- Keep `homebrew.masApps = lib.mkForce {};`. Without it, brew bundle re-enters the broken root-mas path.
- Keep the `export SUDO_UID/SUDO_GID/SUDO_USER` lines before any mas invocation. Without them, mas 4.0+ exits with `Failed to get sudo uid`.
- The script runs as root from `darwin-rebuild`'s outer sudo. mas internally drops to the user's UID via `SUDO_UID` for App Store ops and re-elevates to root for `/usr/sbin/installer`. This is the same flow as running `sudo mas install <id>` interactively.
- `mas upgrade` can run long when the App Store has updates pending. If activation hangs become a problem, wrap with `${pkgs.coreutils}/bin/timeout 1800 ...` for a 30-minute ceiling.

### Logs

mas activation output is prefixed with `[mas-install]` and visible in `darwin-rebuild switch` output. Look for:

- `[mas-install]   <id>: already installed` -- idempotent skip
- `[mas-install]   <id>: installing...` -- fresh install attempt
- `[mas-install]   <id>: install failed (may need 'Get' from App Store GUI first)` -- not in purchase history; click "Get" once in the store
- `==> Updated <App>` -- successful upgrade from the upgrade pass
- `Warning: Found a likely App Store app that is not indexed in Spotlight` -- informational; suppress with `export MAS_NO_AUTO_INDEX=1` in the activation script if noisy.
