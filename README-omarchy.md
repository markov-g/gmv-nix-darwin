# Omarchy4Mac Adoption Strategy

Status: approved and implemented

This document defines how to selectively adopt useful ideas from
[dividendsolo/omarchy4mac](https://github.com/dividendsolo/omarchy4mac) in this
nix-darwin repository.

No upstream installer should be run. No upstream configuration file should be
copied into the deployed setup. The upstream project is a behavioral reference;
the implementation belongs in this repository and must follow its existing Nix,
Home Manager, Homebrew, launchd, and security conventions.

## Intent

The goal is to make selected parts of the Omarchy desktop experience available
as an opt-in profile for selected hosts while preserving the current setup for
all other hosts.

The adoption must:

- Keep the current configuration as the default.
- Preserve existing packages and configuration ownership.
- Make only new Omarchy-derived additions conditional.
- Avoid paid software by default.
- Allow selected optional applications such as Raycast, FluidVoice, Bun, and
  Fastfetch.
- Exclude `ttfx` unless separately approved later.
- Avoid the upstream theme system initially.
- Never write runtime-generated files into Nix-managed paths.
- Avoid mutable runtime downloads and `curl | bash` installation paths.
- Require source review and security scanning before local code is enabled.
- Support progressive adoption and feature-by-feature rollback.

## Source Review

The primary reference is the upstream repository at a pinned revision. The
initial review used the repository state represented by commit
`c84c43bcb9809f43b25a497c81eacbab9be15605`.

Relevant upstream areas reviewed:

- `README.md`: feature mapping, prerequisites, optional applications, and
  macOS portability claims.
- `Brewfile`: upstream package and cask suggestions.
- `install.sh`: filesystem writes, backups, package installation, launchd
  loading, compilation, and service startup.
- `aerospace/aerospace.toml`: window management and global keybindings.
- `hammerspoon/init.lua`: menus, global shortcuts, process execution, and
  appearance helpers.
- `herdr/config.toml`: Herdr layout, keybindings, and terminal behavior.
- `launchd/*.plist`: persistence and restart behavior.
- `sketchybar/`: status bar configuration and plugin scripts.
- `bin/*`: helper commands, screensaver, theme, gaming, and agent launchers.
- `docs/parity-v4.md` and `AUDIT.md`: portability boundaries and upstream
  roadmap.

The upstream repository is useful for identifying behavior. It is not a trusted
runtime dependency. Every selected behavior must be recreated locally and
reviewed in the context of this repository.

## Current-State Boundary

The repository already provides many dependencies that the upstream project
also lists. These remain unconditional and must not be moved behind Omarchy
flags merely because they appear in the upstream project.

Already managed in the current setup include:

- `eza`, `bat`, `fzf`, `zoxide`, and Starship.
- Neovim and LazyVim.
- btop and the existing terminal tooling.
- Herdr.
- Nerd fonts, including Hack Nerd Font.
- Brave Browser.
- Home Manager-managed shell, tmux, Neovim, Herdr, Claude, Codex, and
  OpenCode configuration.

The implementation must add only the delta:

- Existing shared packages stay in their current lists.
- Existing shared casks stay in their current lists.
- Existing configuration files stay owned by their current modules.
- Only new packages, casks, configs, launch agents, and keybindings are
  conditional.

## Proposed Profile Shape

The opt-in profile is accepted by both `mkDarwin` (admin) and `mkHomeUser`
(secondary/standard user) as an optional `omarchy4mac ? {}` parameter. Both
paths normalize the profile through `modules/omarchy4mac/defaults.nix` and pass
it through `specialArgs` or `extraSpecialArgs`.

Each user declares their own independent profile. A secondary user can opt in
even if the admin on the same host has not. The two profiles do not need to
match.

### Admin path (`mkDarwin`)

Casks are installed system-wide to `/Applications` through nix-homebrew and
brew bundle. Formulas are installed through the system Homebrew prefix.
Dotfiles are deployed through Home Manager.

### Secondary user path (`mkHomeUser`)

Casks are installed to `~/Applications` through the user's own Homebrew
instance. The activation checks `/Applications` first; if the admin already
installed the app, the user install is skipped. Formulas are installed through
the user's own `~/PACKAGEMGMT/Homebrew`. Dotfiles are deployed through Home
Manager.

### Current test configuration

```nix
"devel@minidevbox" = mkHomeUser {
  user = "devel";
  host = "minidevbox";
  omarchy4mac = omarchy4macDisabled;
};

"minidevbox" = mkDarwin {
  user = "r1pp3r";
  host = "minidevbox";
  omarchy4mac = omarchy4macDisabled;
};
```

The test profiles are explicitly populated with every option set to false. The
default profile is also disabled and normalizes every omitted option to false.
The profile is passed to:

- The Homebrew module for conditional package deltas (admin path).
- `home-standard.nix` for conditional formulas and cask installs (user path).
- Home Manager for conditional dotfile deployment (both paths).

Herdr is deliberately excluded from the profile. The current Herdr configuration
is already tuned for this repository and remains unchanged during Omarchy
adoption. Any future Herdr experiment should be proposed separately.

## Package Ownership

The existing package modules remain the single source of truth.

### Formulas

`modules/homebrew/brews.nix` remains the source for Homebrew formulas. It should
accept the normalized profile and append only new conditional formulas.

Candidate conditional formulas:

| Formula | Flag | Reason |
|---|---|---|
| `bun` | `apps.bun` | Required only for selected JavaScript-based widgets or tools |
| `fastfetch` | `apps.fastfetch` | Optional About/system information action |
| `sketchybar` | `desktop.sketchybar` | Optional status bar |
| `borders` | `desktop.borders` | Optional focused-window borders |

Existing formulas such as Starship and the current CLI tools remain unchanged.

### Casks

`modules/homebrew/casks.nix` remains the source for Homebrew casks. It should
append only new conditional casks.

Candidate conditional casks:

| Cask | Flag | Reason |
|---|---|---|
| `raycast` | `apps.raycast` | Optional launcher and clipboard history |
| `fluidvoice` | `apps.fluidvoice` | Optional voice input tool; license and cask provenance reviewed, privacy gate remains |
| `aerospace` | `desktop.aerospace` | Optional tiling window manager |
| `hammerspoon` | `desktop.hammerspoon` | Optional macOS automation layer |
| `ghostty` | `apps.ghostty` | Optional terminal; only if explicitly selected |

`font-hack-nerd-font` and `brave-browser` are already present and remain
unconditional. They must not be duplicated in the optional delta.

### FluidVoice License and Provenance Review

FluidVoice is acceptable as an optional unmodified application under the current
license review:

- The official repository states that current versions are licensed under GPLv3
  from 2026-02-23 onward.
- The official Homebrew cask points to the official `altic-dev/FluidVoice`
  GitHub release.
- The current cask includes a version and SHA-256 checksum.
- The cask installs `FluidVoice.app` and has no postflight installation script.
- The cask does not copy FluidVoice source code into this repository.

Installing and running the unmodified GPLv3 application does not impose GPL
licensing obligations on this Nix repository. Those obligations would require a
separate review only if FluidVoice code were copied, modified, or redistributed
as part of this repository.

The license review does not constitute privacy or security approval. Before
enabling the cask, explicitly accept these behaviors:

- Anonymous activity analytics are enabled by default and are uploaded in a
  weekly batch according to the upstream privacy documentation.
- Microphone and Accessibility permissions are required.
- Command Mode can launch applications, run shortcuts, and trigger system
  actions through voice input.
- Optional cloud AI providers can receive dictated content if configured.
- The optional Fluid Intelligence runtime is privately maintained and is not
  covered by the public GPLv3 source license in the same way as the app.
- The app supports self-updates, which can move the installed app independently
  of a Nix/Homebrew activation.

The initial policy is therefore: the conditional cask may be implemented, but
`apps.fluidvoice` remains false on the first test activation. Enabling it later
requires explicit acceptance of analytics, permissions, optional cloud-provider
behavior, and the separate Fluid Intelligence component.

### Cleanup Behavior

The current Homebrew activation uses `cleanup = "zap"`. Under that policy,
turning an optional package flag from true to false may remove the package on
the next activation because it is no longer declared.

For the admin path there are three possible policies:

1. Disabling an optional feature also removes its managed packages.
2. Disabling an optional feature stops managing its configuration but retains
   installed packages.
3. Package installation and feature enablement use separate settings.

The recommended policy for this repository is option 1. It preserves the
existing declarative ownership model and the current `zap` policy: a package
declared by an enabled profile is managed by Nix/Homebrew, and disabling that
profile removes it on the next activation. This is predictable, but the
activation output must clearly identify optional packages that will be removed.

Option 2 would require changing the repository-wide cleanup behavior or moving
optional packages outside the normal Homebrew declaration. That would weaken
the current invariant that undeclared Homebrew software is cleaned up.

Option 3 would add a second state dimension such as `enable` versus `retain`.
That can preserve packages but makes ownership less obvious and risks declaring
packages that the user did not intend to install. It should be considered only
if the first test host demonstrates a real need for package retention.

Therefore the admin path uses option 1. The secondary-user cask activation is a
separate install path and currently retains user-scoped casks when their flags
are disabled; it does not claim ownership of pre-existing applications. A
future cleanup change needs an ownership marker before it can safely remove
only casks installed by this profile.

## Feature Ownership

### AeroSpace

Recreate a minimal local configuration from the upstream behavior:

- Directional focus and window movement.
- Five workspaces.
- Workspace switching and back-and-forth navigation.
- Tiling, accordion, floating, and fullscreen controls.
- Monitor-aware workspace movement.
- Only explicitly enabled application rules.

Do not copy personal monitor names, application assumptions, or Raycast and web
app bindings without review.

AeroSpace requires Accessibility permission, which cannot be granted by Nix.
The module must report the manual permission step. Its launch-at-login behavior
and crash watchdog must be separate options.

### JankyBorders

This is the smallest desktop feature and can be adopted independently. It
should have a local Nix-managed configuration and a user-level service or
launchd integration. It should not require AeroSpace to be enabled.

### Hammerspoon

Recreate small modules, not the upstream monolithic `init.lua`:

- Keybinding overlay.
- Optional searchable application menu.
- Optional reminders and notifications.
- Optional keep-awake toggle.
- Optional appearance listener.
- Optional Ghostty reload helper.

Every module that uses `hs.execute`, `hs.task`, `osascript`, AppleScript, or
Accessibility must be separately enabled and reviewed.

### SketchyBar

Start with a minimal local bar:

- Workspace state.
- Focused application.
- Clock.
- Battery.
- Basic network state.

Defer weather, agent-usage, Spotify, and other external integrations. In
particular, do not adopt the upstream `bunx ccusage` widget without a pinned,
reviewed package strategy. `bunx` can resolve and execute mutable package code
at runtime and the widget reads Claude session data.

### Herdr

Herdr is not part of the Omarchy adoption. The existing configuration remains
the authority and is not changed by any Omarchy profile stage. In particular,
the following remain unchanged:

- `ctrl+b` prefix behavior.
- Sidebar and agent rows.
- Catppuccin theme configuration.
- Git branch, hostname, and date status elements.
- `lazygit` and `lazydocker` popup commands.
- Existing tmux interoperability.

The upstream Herdr configuration remains a reference only. Any compact-layout
or direct-arrow experiment requires a separate proposal and rollback plan.

### Themes

Theme integration is disabled in the initial profile.

The upstream theme script writes to Nix-managed or otherwise sensitive paths,
including Neovim, Ghostty, btop, Claude, Obsidian, and SketchyBar configuration.
That ownership model is incompatible with the current setup.

If themes are revisited later:

- Pin the upstream Omarchy theme source to an exact revision.
- Generate selected theme files locally.
- Keep generated mutable state under a dedicated unmanaged directory, or make
  the selected theme fully declarative.
- Never let a runtime script modify `~/.config/nvim` or other Nix-managed paths.
- Avoid runtime GitHub API and raw-file downloads during normal operation.
- Keep the existing Catppuccin setup unchanged unless explicitly replaced.

### Screensaver

`ttfx` is excluded from the initial and default design. It requires a Rust Git
installation and adds a separate fullscreen terminal and idle-management path.

It is not planned for the first adoption cycle.

## Keybinding Review

The upstream AeroSpace bindings must not be copied verbatim. Several of them
conflict with existing editor, shell, terminal, or macOS behavior.

### Existing Reservations

The following bindings are already owned by the current setup:

| Binding | Owner | Source | Decision |
|---|---|---|---|
| `ctrl+a` prefix | tmux | `.tmux.conf:117-119` | Preserve |
| `ctrl+b` prefix | Herdr | `.config/herdr/config.toml:18-20` | Preserve |
| Bare `ctrl+h/j/k/l` | tmux and vim-tmux-navigator | `.tmux.conf:142-150` | Preserve |
| Prefixed `ctrl+b h/j/k/l` | Herdr pane focus | `.config/herdr/config.toml:31-35` | Preserve |
| `alt+j/k` in Neovim | Neovim line movement | `.config/nvim/lua/config/keymaps.lua:11-13` | Do not intercept globally |
| `space` leader | LazyVim | `.config/nvim/lua/config/keymaps.lua` and LazyVim defaults | Preserve |
| `ctrl+b alt+g/l` | Herdr popups | `.config/herdr/config.toml:49-63` | Preserve |

The tmux and Herdr prefixes are intentionally different because tmux unbinds
`ctrl+b` and allows it to reach Herdr. An AeroSpace or Hammerspoon layer must
not change either prefix.

### High-Risk Upstream Bindings

These upstream bindings should be rejected or remapped:

| Upstream binding | Conflict | Recommendation |
|---|---|---|
| `cmd+left/right/up/down` | Standard macOS text navigation and terminal/editor movement | Do not use |
| `cmd+shift+left/right/up/down` | Text selection and application movement conventions | Do not use |
| `alt+j/k` | Existing Neovim line movement | Do not use |
| `alt+f` | Shell Meta-f word movement and application shortcuts | Do not use |
| `alt+a` | Shell Meta-a and application shortcuts | Do not use |
| `alt+s` | Shell/editor/application shortcuts | Do not use |
| `alt+t` | Shell Meta-t and future terminal bindings | Do not use |
| `alt+w` | Common application and terminal behavior | Do not use |
| `cmd+backtick` | macOS window cycling within an application | Do not use |
| `cmd+shift+n` | Finder new-folder behavior and application shortcuts | Do not use globally |
| `cmd+shift+c` | Finder copy-path behavior and application shortcuts | Do not use globally |
| `cmd+shift+g` | Finder Go to Folder behavior | Do not use globally |
| `cmd+space` | macOS Spotlight | Preserve for Spotlight |
| `cmd+alt+space` | New optional Raycast launcher binding | Use only when Raycast is enabled |

The fact that AeroSpace is a global window manager makes these conflicts more
serious than ordinary application-level collisions. A shortcut that works in a
terminal may still break text editing or Finder behavior elsewhere.

### Proposed Safe Binding Scheme

The first AeroSpace profile should use a conservative `ctrl+alt` family rather
than the upstream `cmd+arrow` and `alt+letter` family:

| Function | Proposed binding family | Rationale |
|---|---|---|
| Focus window | `ctrl+alt+arrow` | Does not overlap current tmux, Herdr, or Neovim bindings |
| Move/swap window | `ctrl+alt+shift+arrow` | Distinct from focus and normal text movement |
| Focus monitor | `ctrl+alt+tab` / `ctrl+alt+shift+tab` | Matches the upstream intent with a low-collision family |
| Switch workspace | `ctrl+alt+1..5` | Avoids terminal Meta-number behavior |
| Move window to workspace | `ctrl+alt+shift+1..5` | Keeps movement separate from switching |
| Toggle floating | `ctrl+alt+f` | Only after checking the terminal and macOS shortcut tables |
| Toggle fullscreen | `ctrl+alt+enter` | Only if it does not conflict with the chosen terminal |
| Open terminal | `cmd+alt+enter` | Retain only if tested against the terminal and macOS |
| Open Herdr | `cmd+ctrl+enter` | Retain only if tested against the terminal and macOS |
| Open Raycast | `cmd+alt+space` | Add only when `apps.raycast` is enabled; preserve Spotlight |

The `ctrl+alt` recommendation is a starting point, not a claim that every
terminal or macOS version leaves these chords free. Verification must happen on
the test host before activation.

### Ownership Rules

Every global shortcut must have exactly one owner:

- AeroSpace owns window focus, movement, workspace, and layout actions.
- Hammerspoon owns menus, reminders, notifications, and macOS automation.
- tmux owns terminal multiplexer actions inside tmux.
- Herdr owns Herdr actions inside Herdr.
- Neovim owns editor actions inside Neovim.
- macOS owns system shortcuts unless the profile explicitly replaces them.
- Optional applications receive new bindings only when their app flag is enabled.
- Raycast uses `cmd+alt+space`; `cmd+space` remains macOS Spotlight.

Hammerspoon's keybinding overlay should describe AeroSpace bindings but should
not define them a second time. The overlay must be generated from the selected
local allowlist or maintained beside it so the displayed shortcuts cannot drift.

### Keybinding Acceptance Test

Before enabling AeroSpace on `minidevbox`, test the selected profile in this
order:

1. Normal macOS text fields: cursor movement, selection, copy, paste, window
   cycling, and `cmd+space` Spotlight behavior.
2. A shell outside tmux and Herdr: Meta keys, history, word movement, and
   terminal shortcuts.
3. tmux: `ctrl+a` prefix, pane navigation, copy mode, and paste buffer.
4. Herdr: `ctrl+b` prefix, pane focus, tab navigation, sidebar, and copy mode.
5. Neovim: `alt+j/k`, `ctrl+d/u`, leader mappings, AI mappings, and terminal
   navigation.
6. Finder and the primary browser: standard application shortcuts.
7. External monitor focus and workspace movement.
8. Hammerspoon overlay and every enabled global action.

The profile is not ready if any existing binding silently changes behavior. A
conflicting shortcut must be remapped or left unbound; it must not be resolved
by changing tmux, Herdr, or Neovim to accommodate AeroSpace.

## Progressive Adoption Stages

Each stage must be independently buildable, reviewable, and reversible.

### Stage 0: Profile Only

Add the profile schema and default-disabled behavior. No new packages or
runtime behavior should be enabled.

Acceptance criteria:

- Existing host configurations evaluate with the profile omitted.
- Existing package lists are unchanged.
- No new files, launch agents, or keybindings are active.

### Stage 1: Optional Applications

Add conditional deltas for Raycast, Bun, and Fastfetch. Keep FluidVoice behind a
privacy and permission gate; its license and cask provenance are reviewed, but
it must not be enabled in the first test activation until the remaining behavior
is explicitly accepted.

Acceptance criteria:

- A true flag adds only its package.
- A false flag adds nothing new.
- Existing packages are not moved or duplicated.
- Disabling a true flag is understood to remove that managed package under the
  repository's `zap` cleanup policy.
- FluidVoice remains disabled until its privacy and permission approval gate
  passes.

### Stage 2: JankyBorders

Add borders as an independent desktop feature.

Acceptance criteria:

- Borders start only when enabled.
- Disabling the feature stops its service according to the selected rollback
  policy.
- No window manager or Hammerspoon dependency is introduced.

### Stage 3: AeroSpace

Add the local window-manager configuration, permissions guidance, and optional
watchdog.

Use the completed Keybinding Review above as the input to the configuration.
The first AeroSpace profile must use its explicit allowlist of bindings and must
not assume that upstream Omarchy key names are available on macOS. Any new
binding still requires the acceptance test below on `minidevbox`.

Acceptance criteria:

- Existing tmux, Herdr, Neovim, and macOS shortcuts remain understood.
- No personal app or monitor assumptions are hardcoded without a profile value.
- Clean AeroSpace exit is not treated as a crash.
- Crash-loop behavior is throttled.
- Accessibility and Automation permission requirements are documented.
- Conflicting bindings are either remapped or explicitly left unbound.

### Stage 4: Hammerspoon Helpers

Add only selected helper modules and their permissions documentation.

Acceptance criteria:

- Each helper can be disabled independently.
- No helper runs arbitrary user-controlled shell strings.
- App launch and system-control actions are allowlisted.

### Stage 5: SketchyBar

Add the minimal bar and only then consider optional widgets.

Acceptance criteria:

- Static widgets work without network access.
- No runtime package execution is required.
- Agent usage and weather integrations remain disabled unless separately
  approved.

### Stage 6: Deferred Theme Proposal

Themes are outside the initial adoption scope and have no enabled profile flag
in the first implementation. A future theme proposal must first decide whether
Catppuccin remains primary, define file ownership for every consumer, and add
separate acceptance criteria. No runtime theme downloader or theme mutation
script is part of this strategy.

## Security Gate

No upstream executable code is copied or adapted until it passes both automated
scanning and manual review.

### Source and Dependency Controls

- Pin upstream source to an exact commit.
- Record the commit and source paths used.
- Do not fetch from `main` during activation or runtime.
- Do not use `curl | bash`.
- Do not use unpinned `bunx`, `npx`, or equivalent package execution.
- Avoid runtime GitHub API calls and raw-file downloads.
- Prefer Nix derivations or pinned Homebrew inputs for dependencies.
- Do not introduce secrets, credentials, or private paths.

### Static Checks

The implementation should run these checks inside the approved container
workflow, not on the host:

- ShellCheck for shell scripts.
- `shfmt` validation for shell formatting.
- Luacheck for Hammerspoon Lua.
- Semgrep for dangerous shell, Lua, Swift, and Nix patterns.
- Gitleaks for accidental secrets.
- Trivy filesystem scanning for dependency and secret findings.
- `statix` and Nix evaluation checks for Nix code.
- Plist parsing and structural validation for launchd files.

### Manual Review Requirements

Review every use of:

- `curl`, `wget`, GitHub APIs, and other network access.
- `eval`, `source`, shell interpolation, and command substitution.
- `hs.execute`, `hs.task`, `os.execute`, `io.popen`, and AppleScript.
- `osascript`, `open`, `launchctl`, `defaults`, `pkill`, `killall`, and
  process termination.
- Accessibility, Automation, and persistent launchd permissions.
- Writes outside declared Nix/Home Manager ownership.
- Package managers that resolve code dynamically.

Security scanning is evidence, not proof of safety. The minimum acceptance bar
is pinned provenance, minimal local reimplementation, automated scans with no
unreviewed findings, and manual approval of every privileged or networked
operation.

## Rollback

Every feature must be removable through the same profile that enabled it.

Rollback must define:

- Whether the package remains installed or is removed.
- Whether launchd agents are unloaded.
- Whether Homebrew services are stopped.
- Whether Accessibility permissions remain manually assigned.
- Whether generated user files are removed or preserved.
- Whether keybindings are restored to their previous state.

Nix-managed files should roll back through activation. Mutable runtime state must
be stored in a dedicated path with an explicit cleanup policy.

macOS Accessibility and Automation permissions are not automatically revoked by
nix-darwin. Rollback documentation must identify the relevant applications and
give the manual System Settings path for revoking access if the user wants a
complete removal. Leaving a permission in place after disabling a feature is
safe but must be stated explicitly.

## Decisions

All decisions are confirmed:

- Cleanup policy: option 1; disabling a managed optional package removes it.
- First test user: `devel@minidevbox` via `mkHomeUser`.
- Admin `r1pp3r` on `minidevbox` has an explicit all-false profile and remains
  on the plain baseline.
- Herdr: no changes; keep the current configuration exactly as-is.
- Ghostty: optional app flag, not an implicit desktop dependency.
- Raycast: acceptable as an optional proprietary application.
- FluidVoice: GPLv3 license and Homebrew cask provenance reviewed; acceptable
  once privacy and permission behavior is explicitly accepted. Remains disabled
  in the first test activation.
- Hammerspoon: full opt-in as a stage.
- JankyBorders tested before AeroSpace: confirmed.
- Themes: deferred to a separate proposal.
- `ttfx`: excluded from the initial adoption.
- Secondary users can independently opt in via `mkHomeUser` with their own
  profile. Cask apps are installed to `~/Applications` when not already present
  in `/Applications`.

## Implementation Status

All non-theme stages are implemented:

| Stage | Status |
|---|---|
| 0: Profile plumbing | Done |
| 1: Optional applications | Done |
| 2: JankyBorders | Done |
| 3: AeroSpace | Done |
| 4: Hammerspoon | Done |
| 5: SketchyBar | Done |
| 6: Themes | Deferred |

### Files added

- `modules/omarchy4mac/defaults.nix` -- profile normalization.
- `modules/omarchy4mac/keybindings.nix` -- single AeroSpace binding registry and
  renderers for AeroSpace TOML and the Hammerspoon display overlay.
- `modules/dotfiles/macos/.config/borders/bordersrc` -- JankyBorders config.
- `modules/dotfiles/macos/.config/aerospace/aerospace.toml` -- AeroSpace config
  with `ctrl+alt` safe bindings.
- `modules/dotfiles/macos/.hammerspoon/init.lua` -- modular Hammerspoon loader.
- `modules/dotfiles/macos/.hammerspoon/keybindings.lua` -- shortcut overlay.
- `modules/dotfiles/macos/.hammerspoon/caffeine.lua` -- keep-awake toggle.
- `modules/dotfiles/macos/.config/sketchybar/sketchybarrc` -- minimal bar.
- `modules/dotfiles/macos/.config/sketchybar/plugins/front_app.sh`
- `modules/dotfiles/macos/.config/sketchybar/plugins/clock.sh`
- `modules/dotfiles/macos/.config/sketchybar/plugins/battery.sh`
- `modules/dotfiles/macos/.config/sketchybar/plugins/network.sh`

### Files modified

- `flake.nix` -- `omarchy4mac` parameter in `mkDarwin` and `mkHomeUser`,
  normalization, `devel@minidevbox` test profile.
- `modules/homebrew.nix` -- accepts and passes `omarchy4mac`.
- `modules/homebrew/brews.nix` -- function accepting `{ lib, omarchy4mac }`,
  conditional formula appends.
- `modules/homebrew/casks.nix` -- accepts `{ lib, host, omarchy4mac }`,
  conditional cask appends.
- `modules/home.nix` -- accepts `omarchy4mac`, conditionally renders the shared
  AeroSpace/Hammerspoon binding files, and defines user launchd agents for
  Borders and SketchyBar.
- `modules/home-standard.nix` -- accepts `omarchy4mac`, fixed `brews.nix` call,
  added `installOmarchyCasks` activation for `~/Applications`.

## Next Steps

1. Build or switch the two all-false profiles and confirm the optional package,
   cask, dotfile, and launchd deltas are empty.
2. To begin progressive adoption later, enable one profile flag at a time.
3. Grant Accessibility permission to AeroSpace and Hammerspoon in System
   Settings > Privacy & Security > Accessibility.
4. Run the keybinding acceptance test from the Keybinding Review section.
5. To enable FluidVoice later, set `fluidvoice = true` in the profile and
   accept the privacy and permission behaviors documented above.
