# Powerlevel10k Setup Guide

Powerlevel10k (p10k) is the shell prompt theme, loaded via antigen in `.zshrc.r1pp3r`.
It reads its configuration **exclusively** from `~/.p10k.zsh` — this file is **not**
managed by Nix so you can tweak it freely without a rebuild.

---

## How it works

```
antigen theme romkatv/powerlevel10k   ← installed by antigen in .zshrc
        │
        │  at shell start
        ▼
~/.p10k.zsh   ← your personal theme config (prompt style, segments, colours)
        │
        │  managed copy in the dotfiles repo
        ▼
modules/dotfiles/macos/.p10k.zsh  →  home.nix home.file  →  ~/.p10k.zsh (symlink)
```

Once `~/.p10k.zsh` is in the repo and wired in `home.nix`, every new machine gets
your exact prompt after `darwin-rebuild switch`.

---

## First-time setup

### Step 1 — Run the interactive configurator

Open a terminal. If antigen has installed p10k, run:

```bash
p10k configure
```

This launches a wizard that asks:
- Does the font render correctly? (pick `y` if you're using Fira Code Nerd Font / Hack Nerd Font — both installed via `casks.nix`)
- Prompt style: Classic / Rainbow / Lean / Pure
- Show on one or two lines
- Which segments (git, kubernetes, time, battery…)
- Prompt character style

**Recommended choices for a hacker terminal:**
- Font: `y` (Nerd Fonts installed)
- Style: `Rainbow` or `Lean`
- Separators: `Slanted` (rainbow) or `None` (lean)
- Heads: `Blurred` or `Sharp`
- Tails: `Blurred` or `Flat`
- Lines: `2` (two-line prompt keeps the command line clean)
- Sparse: `No`
- Transient prompt: `Yes` (collapses old prompts — very clean)
- Instant prompt: `Verbose` (first time), then set to `Quiet` after

The wizard writes `~/.p10k.zsh` when you finish.

### Step 2 — Test it

```bash
source ~/.p10k.zsh
exec zsh   # restart shell to see full effect
```

### Step 3 — Commit it to the repo

```bash
cp ~/.p10k.zsh ~/.config/nix-darwin/modules/dotfiles/macos/.p10k.zsh
```

Then add it to `home.nix` — in the `home.file` block:

```nix
".p10k.zsh".source = ./dotfiles/macos/.p10k.zsh;
```

Then rebuild:

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

After this, `~/.p10k.zsh` is a Nix-managed symlink pointing into the store.
Future edits must go through the repo file → rebuild.

---

## Editing later

Since `~/.p10k.zsh` becomes a read-only Nix symlink after wiring it in, to tweak it:

```bash
# Option A — re-run the wizard (easiest)
p10k configure
cp ~/.p10k.zsh.bak ~/.config/nix-darwin/modules/dotfiles/macos/.p10k.zsh  # wizard backs it up
darwin-rebuild switch --flake ~/.config/nix-darwin

# Option B — edit the repo file directly
nvim ~/.config/nix-darwin/modules/dotfiles/macos/.p10k.zsh
darwin-rebuild switch --flake ~/.config/nix-darwin
exec zsh
```

---

## Instant prompt

p10k's **instant prompt** makes the shell appear instantaneously even when `.zshrc`
takes 500ms+ to load (antigen, nvm, sdkman etc.). It is enabled by default from
the wizard.

If you see warnings like:
```
[WARNING] You're loading zsh dotfiles after instant prompt...
```

The solution is to ensure any shell initialization that produces output runs
**before** the p10k instant prompt block at the top of `.zshrc`. If needed,
silence a specific warning:
```bash
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet   # add near top of .p10k.zsh
```

---

## Useful segments to enable

Edit `~/.config/nix-darwin/modules/dotfiles/macos/.p10k.zsh` and add to
`POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` or `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS`:

| Segment | What it shows |
|---------|--------------|
| `kubecontext` | Current kubectl context + namespace |
| `aws` | Active AWS profile (when `$AWS_PROFILE` set) |
| `nix_shell` | Active nix-shell / nix develop environment |
| `virtualenv` | Active Python venv |
| `rust_version` | Rust toolchain version |
| `go_version` | Go version (in Go projects) |
| `node_version` | Node version (in JS projects) |
| `battery` | Battery % (useful on laptop) |
| `time` | Current time (right side) |
