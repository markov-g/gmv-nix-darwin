# gmv-nix-darwin

> Declarative macOS configuration using **nix-darwin** + **home-manager** + **nix-homebrew** + **sops-nix**

All system settings, packages, dotfiles, and secrets live in Nix expressions.
One command rebuilds everything reproducibly on any machine.

---

## Repository Layout

```
~/.config/nix-darwin/
├── flake.nix                        # entry point — machines + users
├── flake.lock                       # pinned input revisions
├── .sops.yaml                       # age public key for secret encryption
├── secrets/
│   ├── README.md                    # full sops-nix bootstrap guide
│   └── secrets.yaml                 # encrypted secrets (safe to commit)
└── modules/
    ├── system.nix                   # nix-darwin: packages, macOS defaults, firewall
    ├── homebrew.nix                 # nix-darwin: brew bundle (formulas + casks + MAS)
    ├── home.nix                     # home-manager: dotfiles, packages, activation
    ├── home-standard.nix            # home-manager: standard/secondary users (brews only)
    ├── homebrew/
    │   ├── brews.nix                # CLI formula list (shared by all users)
    │   └── casks.nix                # GUI app list (admin account only)
    └── dotfiles/macos/
        ├── .zshrc                   # interactive shell config
        ├── .zprofile                # login shell env + PATH
        ├── .zshenv.seed             # template — copy to ~/.zshenv on new machine
        ├── .gitconfig
        ├── .gitignore_global
        ├── .tmux.conf
        ├── .ssh/config
        ├── .config/nvim/            # LazyVim config
        └── bin/                     # personal scripts (bootstrap, proxy, etc.)
```

---

## Architecture

### Three layers, one command

```
darwin-rebuild switch --flake ~/.config/nix-darwin#<hostname>
```

This single command runs all three layers in sequence:

| Layer | Tool | Manages |
|---|---|---|
| System | nix-darwin | macOS settings, firewall, system packages, hostname |
| Packages | nix-homebrew | Homebrew install + brew bundle (formulas, casks, MAS apps) |
| User | home-manager | Dotfiles, user packages, secrets, shell, Neovim, tmux |

### Multi-machine design

`flake.nix` defines two helpers in its `let` block:

**`mkDarwin`** — for admin/primary accounts. Wires together nix-darwin + nix-homebrew + home-manager. Used via `darwin-rebuild`:
```
darwin-rebuild switch --flake ~/.config/nix-darwin#minidevbox
```

**`mkHomeUser`** — for standard/secondary accounts. Standalone home-manager only — no admin privileges needed. Used via:
```
home-manager switch --flake ~/.config/nix-darwin#devel@minidevbox
```

### Package strategy

| What | Where | Managed by |
|---|---|---|
| Core CLI (bat, eza, ripgrep, nvim, LSPs…) | `system.nix` → `environment.systemPackages` | Nix (system-wide, all users) |
| GUI apps (browsers, IDEs, security tools) | `homebrew/casks.nix` | Homebrew / nix-darwin (admin only) |
| CLI formulas (antigen, colima, awscli…) | `homebrew/brews.nix` | Homebrew / nix-darwin (admin) or activation script (standard user) |
| MAS apps (1Password, Xcode, Telegram…) | `homebrew.nix` → `masApps` | mas-cli / nix-darwin (admin only) |
| User packages (direnv, home-manager…) | `home.nix` → `home.packages` | Nix (per-user) |
| Secrets (SSH key, AWS creds, kubeconfig…) | `secrets/secrets.yaml` | sops-nix (decrypted to tmpfs at activation) |

### Homebrew prefix

Homebrew is installed at `~/PACKAGEMGMT/Homebrew` (not the standard `/opt/homebrew`).
This is intentional: it keeps each user's Homebrew completely isolated.
The trade-off is that most bottles must be compiled from source — `darwin-rebuild switch` takes longer on first run.

Homebrew binaries are **not** on `$PATH` by default. Activate them explicitly per shell session:
```zsh
source ~/.profile.homebrew   # adds ~/PACKAGEMGMT/Homebrew/bin to PATH
```

---

## Machines

| Flake key | Hostname | Primary user | Type |
|---|---|---|---|
| `r1pp3r` | r1pp3r | r1pp3r | Personal laptop |
| `SE1FXHLQH3MTP` | SE1FXHLQH3MTP | mch12700 | Work laptop |
| `minidevbox` | minidevbox | r1pp3r | Mac mini (dev server) |
| `minidevboxvm` | minidevboxvm | devel | VM running on mini |

Secondary (standard) users available on the mini:

| Flake key | User | Host | Purpose |
|---|---|---|---|
| `llmautomation@minidevbox` | llmautomation | minidevbox | AI / automation workloads |
| `devel@minidevbox` | devel | minidevbox | General dev work |
| `devel@minidevboxvm` | devel | minidevboxvm | VM dev environment |

Only one of `llmautomation` / `devel` should be created per machine in macOS System Settings.
The other entry in `homeConfigurations` is inert until explicitly activated.

---

## Fresh Machine Setup (Admin Account)

### Prerequisites

1. Install [Determinate Nix](https://determinate.systems/nix-installer/):
```bash
curl --proto '=https' --tlsv1.2 -sSf \
  https://install.determinate.systems/nix | sh -s -- install
```

2. Clone this repo:
```bash
git clone https://github.com/markov-g/gmv-nix-darwin.git \
  ~/.config/nix-darwin --branch mac-mini
```

3. Seed `~/.zshenv` (not managed by Nix — apps like ServBay write to it):
```bash
cp ~/.config/nix-darwin/modules/dotfiles/macos/.zshenv.seed ~/.zshenv
```

### Bootstrap (first-ever run, before `darwin-rebuild` is on `$PATH`)

```bash
sudo -i nix run github:LnL7/nix-darwin#darwin-rebuild -- \
  switch --flake /Users/$USER/.config/nix-darwin#$(hostname -s)
```

### All subsequent rebuilds

```bash
sudo darwin-rebuild switch --flake ~/.config/nix-darwin
# or use the alias:
darwin-re
```

### After first rebuild — configure p10k prompt

```bash
p10k configure
# commit the result:
cp ~/.p10k.zsh ~/.config/nix-darwin/modules/dotfiles/macos/.p10k.zsh
# add to home.nix: ".p10k.zsh".source = ./dotfiles/macos/.p10k.zsh;
```

---

## Fresh Machine Setup (Standard / Secondary User)

Standard users get: all dotfiles, all Nix system packages, their own Homebrew with formulas only (no casks — GUI apps are already in `/Applications` from the admin account).

1. Admin creates the macOS account in System Settings → Users & Groups (Standard type).

2. Log in as the new user, then:
```bash
# Clone the repo
git clone https://github.com/markov-g/gmv-nix-darwin.git \
  ~/.config/nix-darwin --branch mac-mini

# Seed .zshenv
cp ~/.config/nix-darwin/modules/dotfiles/macos/.zshenv.seed ~/.zshenv

# Activate — installs dotfiles, Homebrew, and all formulas
nix run nixpkgs#home-manager -- \
  switch --flake ~/.config/nix-darwin#devel@minidevbox -b hm-backup
```

3. All future updates:
```bash
home-manager switch --flake ~/.config/nix-darwin#devel@minidevbox
```

---

## Secrets (sops-nix)

Secrets are encrypted with [age](https://age-encryption.org) keys derived from your SSH key.
The encrypted `secrets/secrets.yaml` is safe to commit. Plaintext never touches disk —
sops-nix decrypts everything to a tmpfs path at `darwin-rebuild switch` time.

**Managed secrets:**

| Secret key | Decrypted path | Mode |
|---|---|---|
| `ssh_private_key` | `~/.ssh/id_ed25519` | 0600 |
| `ssh_public_key` | `~/.ssh/id_ed25519.pub` | 0644 |
| `aws_credentials` | `~/.aws/credentials` | 0600 |
| `docker_config` | `~/.docker/config.json` | 0600 |
| `kube_config` | `~/.kube/config` | 0600 |
| `netrc` | `~/.netrc` | 0600 |

See `secrets/README.md` for the full bootstrap guide (generate age key, encrypt, add new secrets).

---

## Day-to-Day Operations

### Rebuild after any change

```bash
darwin-re                  # alias for: darwin-rebuild switch --flake ~/.config/nix-darwin
```

### Add a CLI formula

Edit `modules/homebrew/brews.nix`, then `darwin-re`.

### Add a GUI app

Edit `modules/homebrew/casks.nix`, then `darwin-re`.

### Add a Mac App Store app

Edit the `masApps` block in `modules/homebrew.nix`:
```nix
"App Name" = 1234567890;  # app ID from the MAS URL
```
Then `darwin-re`.

### Add a Nix system package

Edit `environment.systemPackages` in `modules/system.nix`, then `darwin-re`.
System packages are available to all users immediately after rebuild.

### Add a user package

Edit `home.packages` in `modules/home.nix`, then `darwin-re`.

### Add a dotfile

Drop the file under `modules/dotfiles/macos/`, add a `home.file` entry in `modules/home.nix`:
```nix
".myconfig".source = ./dotfiles/macos/.myconfig;
```
Then `darwin-re`.

### Update all flake inputs

```bash
cd ~/.config/nix-darwin
nix flake update            # updates flake.lock
darwin-re                   # applies updates
```

### Garbage collect old Nix store paths

```bash
nix-collect-garbage -d
# alias:
nix-gc
```

### Edit an existing secret

```bash
sops ~/.config/nix-darwin/secrets/secrets.yaml
# opens $EDITOR (nvim) with decrypted content; saves re-encrypted
```

### Add a new machine

1. Add an entry in `darwinConfigurations` in `flake.nix`:
```nix
"newhostname" = mkDarwin {
  host   = "newhostname";
  user   = "yourusername";
  system = "aarch64-darwin";
};
```
2. On the new machine: follow the Fresh Machine Setup steps above.

### Add a secondary user to a new machine

1. Create the macOS account (Standard type) in System Settings.
2. Add an entry in `homeConfigurations` in `flake.nix`:
```nix
"devel@newhostname" = mkHomeUser {
  user = "devel";
  host = "newhostname";
};
```
3. Log in as that user and follow the Standard User Setup steps above.

---

## Shell Configuration

### Load order

```
Login shell:     .zprofile → .zshrc
Non-login shell: .zshrc only
                 └── .zshrc re-sources .zprofile for non-login shells (VSCode, tmux panes)
```

### .zprofile responsibilities

- Locale, system PATH via `/usr/libexec/path_helper`
- `BREW_PREFIX` variable (path reference only — Homebrew NOT on PATH by default)
- User identity exports (`DEVEL_*`)
- Tool PATH entries (cargo, pipx, JetBrains, Docker CLI, LM Studio)
- direnv hook, OrbStack init, kubectl completion
- fzf **env vars only** (`FZF_DEFAULT_COMMAND`, `FZF_DEFAULT_OPTS`, etc.)
- Machine-local overrides via `~/.zprofile.local` (not managed by Nix)

### .zshrc responsibilities

- `antigen` / oh-my-zsh plugins + powerlevel10k theme
- `antigen apply` (triggers `compinit`)
- **fzf shell integration** — `source <(fzf --zsh)` + `_fzf_compgen_*` + `_fzf_comprun` functions
  — **must be after `antigen apply`** — fzf's `completion.zsh` calls `compdef` which only exists post-`compinit`
- All aliases, functions, key bindings
- Tmux autostart (creates named session with pre-configured windows on first login)
- zoxide, atuin init
- p10k prompt config

### Why fzf `**<Tab>` requires post-compinit placement

`source <(fzf --zsh)` sources both `key-bindings.zsh` and `completion.zsh`.
The `completion.zsh` script calls `compdef` to register the `**` trigger widget.
`compdef` only exists after `compinit` has run. Antigen calls `compinit` inside
`antigen apply` — so anything calling `compdef` must come after line 37 (`antigen apply`).
Placing `source <(fzf --zsh)` in `.zprofile` (which runs before `.zshrc`) caused
`compdef: command not found` errors and broke `ls **<Tab>` completion.

### Activating Homebrew in a shell session

```zsh
source ~/.profile.homebrew    # adds ~/PACKAGEMGMT/Homebrew/bin to PATH
                              # also activates nvm, jenv, conda, SDKMAN
source ~/.profile.macports    # MacPorts
source ~/.profile.kubectl     # helm + eksctl completions
```

---

## Neovim

Config lives at `modules/dotfiles/macos/.config/nvim/` (LazyVim-based).
Home Manager symlinks it to `~/.config/nvim` as a read-only store path.
Plugins and data live in `~/.local/share/nvim` (writable, outside the store).

LSP servers that can't be built by Mason on aarch64 are installed via Nix in `system.nix`:
`gopls`, `nil` (Nix LSP), `nodejs` (pyright, vtsls), `go`, `statix`.

---

## Tmux

TPM (Tmux Plugin Manager) is bootstrapped automatically on first `home-manager` activation
via a `home.activation` script — no manual `Ctrl-a I` needed on new machines.

On existing machines, if plugins are missing: `~/.tmux/plugins/tpm/bin/install_plugins`

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `compdef: command not found` on shell start | `source <(fzf --zsh)` in `.zprofile` before `compinit` | Ensure it's in `.zshrc` after `antigen apply` |
| `ls **<Tab>` does nothing | Same as above | Same fix |
| `tee: .../oh-my-zsh/cache//completions/_docker: No such file` | `ZSH_CACHE_DIR` undefined before antigen loads docker plugin | Add `mkdir -p "${ZSH:-$HOME/.antigen/...}/cache/completions"` before `source antigen.zsh` |
| `darwin-rebuild` not found on brand-new machine | Not bootstrapped yet | Use the `nix run github:LnL7/nix-darwin...` bootstrap command above |
| `could not find a suitable key` (sops) | `~/.config/sops/age/keys.txt` missing | Re-derive: `ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt` |
| `mac verify failed` (sops) | Wrong SSH key used to derive age key | Check which SSH key you used on the original machine |
| Homebrew bottles all compiling from source | Non-standard prefix (`~/PACKAGEMGMT/Homebrew`) | Expected — bottles are prebuilt for `/opt/homebrew` only |
| p10k prompt is plain (no icons/glyphs) | Nerd Font not set in terminal | Set terminal font to `FiraCode Nerd Font` or `Hack Nerd Font` |
| tmux plugins not loaded | TPM not initialised | Run `~/.tmux/plugins/tpm/bin/install_plugins` |
| Home Manager backup files (`*.hm-backup`) accumulating | HM can't overwrite existing files | Safe to delete; set by `backupFileExtension = "hm-backup"` |
