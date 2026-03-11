# Testing the Bootstrap with lume

This guide walks through a complete end-to-end test of the `bootstrap-macos.sh`
flow using **lume** — a macOS VM tool for Apple Silicon that uses Apple's native
Virtualization.framework.

> **Why lume over tart?**
> `lume` is already installed via `brews.nix`. Both use the same framework
> under the hood. This guide assumes lume is available at:
> `~/PACKAGEMGMT/Homebrew/bin/lume`

---

## Prerequisites (on your real machine)

Before starting:

1. `lume` is installed and working:
   ```bash
   lume --version
   ```

2. Your nix-darwin repo is committed and pushed to GitHub:
   ```bash
   cd ~/.config/nix-darwin
   git status        # should be clean (or at least committed)
   git push origin mac-mini
   ```

3. You know your GitHub SSH key is working:
   ```bash
   ssh -T git@github.com
   # Expected: "Hi r1pp3r! You've successfully authenticated..."
   ```

---

## Part 1 — Create and Boot the VM

### 1.1 Pull a macOS image

lume uses OCI images. Pull the latest vanilla Sequoia image (~10–15 GB):

```bash
lume pull ghcr.io/trycombined/macos-sequoia-vanilla:latest
```

> This can take 15–30 min depending on your connection. Run it once and reuse
> the image for multiple test runs.

### 1.2 Create a VM instance

```bash
lume create test-bootstrap \
  --os macos \
  # --image ghcr.io/trycombined/macos-sequoia-vanilla:latest \
  --disk 80    \
  --memory 8
```

| Flag | Value | Notes |
|------|-------|-------|
| `--disk` | 80 GB | nix store + Homebrew need ~30 GB minimum |
| `--memory` | 8 GB | 4 GB works but 8 GB is smoother |

### 1.3 Start the VM

```bash
lume run test-bootstrap
```

A macOS window appears. Complete the one-time macOS Setup Assistant (language,
region, Apple ID skip — do NOT sign in with Apple ID for a throwaway VM).

---

## Part 2 — Prepare the VM

### 2.1 Enable SSH into the VM

In the VM's Terminal (open via Spotlight → Terminal):

```bash
# Enable Remote Login (SSH)
# Note: systemsetup -setremotelogin requires Full Disk Access which VMs lack (System Settings → Privacy & Security → Full Disk Access)
# Use launchctl instead:
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist

# Note the VM's IP address
ipconfig getifaddr en0
```

From your real Mac you can now SSH in:

```bash
ssh <vm-user>@<vm-ip>
# Default lume user is often 'admin' or whatever macOS Setup created
```

> All subsequent commands in Part 2+ can be run over SSH from your terminal
> (better clipboard, scrollback) instead of inside the VM window.

### 2.2 Install Xcode Command Line Tools in the VM

The bootstrap script checks for CLT first. Trigger the install:

```bash
xcode-select --install
```

A dialog appears in the VM window — click **Install**. Wait ~3 min.

Verify:
```bash
xcode-select -p
# Expected: /Library/Developer/CommandLineTools
```

### 2.3 Copy your SSH private key into the VM

The bootstrap needs to clone the repo via SSH. Copy your GitHub key:

```bash
# On your real Mac:
scp ~/.ssh/id_ed25519 <vm-user>@<vm-ip>:~/.ssh/id_ed25519
scp ~/.ssh/id_ed25519.pub <vm-user>@<vm-ip>:~/.ssh/id_ed25519.pub

# In the VM:
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
```

Verify SSH access to GitHub from the VM:
```bash
ssh -T git@github.com
# Expected: "Hi r1pp3r! You've successfully authenticated..."
```

---

## Part 3 — Run the Bootstrap

### 3.1 Set the hostname

The flake targets `minidevbox` by hostname. Either:

**Option A** — Set the VM hostname to match:
```bash
sudo scutil --set LocalHostName minidevbox
sudo scutil --set ComputerName  minidevbox
sudo scutil --set HostName      minidevbox
```

**Option B** — Add a new host entry to `flake.nix` for testing (e.g. `testvm`)
and push it before running. Then the bootstrap will look for `testvm`.

> Option A is simpler for a quick test. Use Option B if you want to test a
> clean multi-machine config without touching `minidevbox`.

### 3.2 Download and run the bootstrap script

```bash
# If SSH key is set up and repo is public:
bash <(curl -fsSL \
  https://raw.githubusercontent.com/r1pp3r/nix-darwin/main/modules/dotfiles/macos/bin/bootstrap-macos.sh)
```

Or clone manually first:
```bash
mkdir -p ~/.config
git clone git@github.com:markov-g/nixfiles.git ~/.config/nix-darwin
bash ~/.config/nix-darwin/modules/dotfiles/macos/bin/bootstrap-macos.sh
```

### 3.3 Expected bootstrap flow

The script runs 5 phases. Watch for each:

```
[bootstrap] Xcode CLT already installed: /Library/Developer/CommandLineTools
[bootstrap] Repo already present at /Users/<vm-user>/.config/nix-darwin
[bootstrap] Nix not found — launching Determinate Nix installer...
```

**Phase 4 (Nix install):** The DMG is downloaded and opened. A GUI installer
appears. Click through it. When done, **open a new Terminal** (or re-source):
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Then re-run the bootstrap:
```bash
bash ~/.config/nix-darwin/modules/dotfiles/macos/bin/bootstrap-macos.sh
```

**Phase 5 (nix-darwin first bootstrap):** This takes 10–20 min the first time:
```
[bootstrap] First-time bootstrap: using nix run to install nix-darwin...
```

It downloads nixpkgs, builds system closure, installs all Nix packages, runs
Home Manager, and sets up Homebrew. Expect a lot of output.

When done, you'll see the **POST-BOOTSTRAP CHECKLIST**.

---

## Part 4 — Verify Everything Works

Open a **new terminal** in the VM after the bootstrap completes.

### 4.1 Shell and prompt

```bash
echo $SHELL            # should be /bin/zsh
echo $0                # zsh
zsh --version

# Antigen and p10k load:
antigen list           # should show bundles including powerlevel10k

# zoxide and atuin:
z --version
atuin --version
```

### 4.2 Nix packages (from system.nix)

```bash
which nvim && nvim --version
which bat  && bat --version
which eza  && eza --version
which tmux && tmux -V
which btm  && btm --version    # bottom
which yazi && yazi --version
which lazygit && lazygit --version
which atuin && atuin --version
which zoxide && zoxide --version
which difft && difft --version
which tokei && tokei --version
which k9s  && k9s version
which jq   && jq --version
which glow && glow --version
which gpg  && gpg --version
which age  && age --version
which ssh-to-age && ssh-to-age --version
```

### 4.3 Homebrew packages (from brews.nix)

```bash
export PATH="$HOME/PACKAGEMGMT/Homebrew/bin:$PATH"   # or source .profile.homebrew

brew list              # should show all formulas
brew list --cask       # should show all casks

which antigen
which awscli && aws --version
which helm && helm version
which kubectl && kubectl version --client
which mise && mise --version
which ollama && ollama --version
```

### 4.4 Dotfiles (from home.nix)

```bash
ls -la ~ | grep -E '^\l'    # symlinks from home.nix home.file

# Verify specific dotfiles are symlinked:
ls -la ~/.zshrc             # → nix store path
ls -la ~/.tmux.conf         # → nix store path
ls -la ~/.gitconfig         # → nix store path (or .gitconfig.r1pp3r)
ls -la ~/.config/nvim       # → nix store path

# ~/bin scripts are present:
ls ~/bin/
~/bin/nix-update-all.sh --help 2>/dev/null || echo "script exists"
```

### 4.5 tmux

```bash
tmux new-session -s test
```

Inside tmux:
- Header cheat sheet should appear at the top
- Catppuccin Mocha theme should render (purple/pink status bar)
- `Ctrl-a ?`  →  tmux help
- `Ctrl-a I`  →  TPM install plugins (first time, auto-bootstrapped)
- After TPM install: `Ctrl-a r` to reload config

Verify TPM plugins installed:
```bash
ls ~/.tmux/plugins/
# Should list: tpm, tmux-sensible, catppuccin, tmux-resurrect,
#              tmux-continuum, tmux-sessionx, vim-tmux-navigator
```

### 4.6 Neovim / LazyVim

```bash
nvim
```

First launch:
- LazyVim installs all plugins automatically (~2–5 min, shows progress)
- After install completes, close with `:qa`

Re-open to verify:
```bash
nvim somefile.py
```

Check in Neovim:
```
:Lazy          → plugin manager (all plugins should be installed/healthy)
:Mason         → LSP tool installer (check tools are installing)
:LazyHealth    → health check (should show mostly green)
:checkhealth   → Neovim built-in health (check for warnings)
```

Verify LSP is working:
```
:LspInfo       → shows active LSPs for current filetype
```

Test a few filetypes:
```bash
nvim test.py      # Python — check :LspInfo shows pyright
nvim test.go      # Go — gopls
nvim test.rs      # Rust — rust-analyzer
nvim test.ts      # TypeScript — tsserver
nvim test.sh      # Bash — bashls
nvim test.nix     # Nix — nil
```

### 4.7 Avante (AI) — optional if ANTHROPIC_API_KEY is set

```bash
# In VM, set the key:
export ANTHROPIC_API_KEY="sk-ant-..."

nvim somefile.py
# Then: <leader>aa  →  opens Avante AI panel
# Type a question and check it responds
```

### 4.8 Security tools (casks)

```bash
# Check casks installed:
brew list --cask | grep -E 'blockblock|oversight|knockknock|reikey|gpg-suite|signal|protonvpn|malwarebytes'
```

Note: blockblock, oversight, knockknock, and reikey require system extensions
and will prompt for approval on first launch — this is expected in a VM too.

### 4.9 ALF firewall settings

```bash
# Check firewall state (should be 1 = on):
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Check stealth mode (should be enabled):
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode
```

### 4.10 sops / secrets (if secrets.yaml exists)

On a fresh VM with no secrets yet, the `mkIf` guard in `home.nix` means sops
is simply inactive — this is correct. Test that build still works without
`secrets/secrets.yaml`:

```bash
darwin-rebuild build --flake ~/.config/nix-darwin#minidevbox
# Should complete with no errors about missing secrets file
```

---

## Part 5 — Test the Update Script

Run the full update cycle:
```bash
~/bin/nix-update-all.sh --no-gc
```

Expected output:
```
[nix-update-all] Upgrading Determinate Nix daemon...
[nix-update-all] Updating flake inputs in /Users/.../nix-darwin...
[nix-update-all] Applying configuration: darwin-rebuild switch --flake '...'
[nix-update-all] All updates complete. Open a new terminal to pick up any shell changes.
```

Verify it does NOT run `brew upgrade` separately (Homebrew is managed
declaratively — `darwin-rebuild switch` already calls `brew upgrade` via
`onActivation.upgrade = true` in `homebrew.nix`).

---

## Part 6 — Teardown and Retry

### Destroy the VM

```bash
# On your real Mac:
lume stop test-bootstrap
lume delete test-bootstrap
```

### Start a fresh test run

```bash
lume create test-bootstrap \
  --os macos \
  --image ghcr.io/trycombined/macos-sequoia-vanilla:latest \
  --disk 80 \
  --memory 8

lume run test-bootstrap
```

The image is cached locally after the first pull — fresh VMs take ~1 min to
create, not 30 min.

---

## Checklist Summary

Use this checklist to track your test run:

```
Bootstrap
[ ] Xcode CLT detected / installed
[ ] Repo cloned via SSH
[ ] Determinate Nix DMG downloaded and installed
[ ] nix-darwin first-time bootstrap via nix run succeeded
[ ] darwin-rebuild switch completed without errors
[ ] POST-BOOTSTRAP CHECKLIST printed

Shell
[ ] zsh is default shell
[ ] antigen loads (p10k, zsh-syntax-highlighting, zsh-autosuggestions)
[ ] zoxide init in shell
[ ] atuin init in shell (Ctrl-R works)
[ ] Aliases work: ll, la, tree, lg, gu, vi

Nix packages
[ ] nvim, bat, eza, tmux, yazi, btm, k9s, lazygit, atuin, zoxide
[ ] jq, glow, difft, tokei, dust, procs, xh, jless
[ ] gpg, age, ssh-to-age

Homebrew
[ ] brew list shows all formulas from brews.nix
[ ] brew list --cask shows all casks from casks.nix
[ ] No duplicate packages between Nix and Homebrew

Dotfiles
[ ] ~/.zshrc, ~/.tmux.conf, ~/.gitconfig are symlinks
[ ] ~/.config/nvim is a symlink → nix store
[ ] ~/bin/ scripts are present

tmux
[ ] Catppuccin Mocha theme renders
[ ] Cheat-sheet header visible
[ ] TPM plugins installed
[ ] Prefix Ctrl-a works
[ ] Pane splits: Ctrl-a | and Ctrl-a -

Neovim / LazyVim
[ ] First launch installs all plugins without errors
[ ] :Lazy shows all plugins healthy
[ ] :Mason installs LSP tools
[ ] LSP works in .py, .go, .rs, .ts, .sh, .nix files
[ ] Catppuccin Mocha colorscheme active
[ ] vim-tmux-navigator: Ctrl-h/j/k/l works across splits+panes

Security
[ ] ALF firewall is on (globalstate = 1)
[ ] Stealth mode enabled
[ ] Security casks installed: blockblock, oversight, knockknock, reikey, gpg-suite

Update
[ ] nix-update-all.sh --no-gc runs without errors
[ ] Does NOT run brew upgrade manually
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `nix: command not found` after DMG install | Nix profile not sourced | `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` then re-run |
| `error: flake 'path:...' does not provide attribute 'minidevbox'` | VM hostname doesn't match | `sudo scutil --set LocalHostName minidevbox` |
| `warning: Git tree '...' is dirty` | Uncommitted files in repo | Commit and push before running in VM |
| Homebrew install fails | Disk too small | Recreate VM with `--disk 80` or larger |
| LazyVim plugins fail to download | No internet in VM | Check VM network (lume uses shared NAT by default — should work) |
| `brew list` empty after bootstrap | Homebrew activation ran but PATH not updated | Open new terminal or `source ~/.profile.homebrew` |
| sops errors on darwin-rebuild | Missing age key file | Expected on fresh machine — `mkIf` guard prevents build failure |
| Security casks need approval | SIP / system extensions | Normal macOS behaviour — approve in System Settings → Privacy & Security |
