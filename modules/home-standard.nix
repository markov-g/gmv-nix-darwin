{ config, lib, pkgs, inputs, user, host, omarchy4mac ? {
  enable = false;
  apps = { raycast = false; fluidvoice = false; bun = false; fastfetch = false; ghostty = false; };
  desktop = { aerospace = false; borders = false; hammerspoon = false; sketchybar = false; };
  themes = { enable = false; };
  screensaver = { enable = false; };
}, ... }:

# ── Standard-user Home Manager config ────────────────────────────────────────
# Inherits ALL dotfiles, packages, and activation scripts from home.nix.
# Adds a brews-only Homebrew instance at ~/PACKAGEMGMT/Homebrew.
# When omarchy4mac is enabled, also installs conditional formulas and
# cask apps to ~/Applications (user-scoped, no admin required).
#
# Activate (as the standard user, no sudo):
#   home-manager switch --flake ~/.config/nix-darwin#<user>@<host>
#
# First-time bootstrap on a new machine:
#   1. Log in as the standard user
#   2. Nix is already available (system-wide from admin's darwin-rebuild)
#   3. Clone the repo:  git clone ... ~/.config/nix-darwin --branch mac-mini
#   4. Run the activation above -- it will:
#      a. Link all dotfiles (same as admin)
#      b. Install Homebrew (portable) to ~/PACKAGEMGMT/Homebrew
#      c. Run brew bundle (formulas only)
#      d. If omarchy4mac is enabled, install cask apps to ~/Applications

let
  allBrews = import ./homebrew/brews.nix { inherit lib omarchy4mac; };
  allCasks = import ./homebrew/casks.nix { inherit lib host omarchy4mac; };

  # Extract "owner/repo" from tap-qualified entries ("owner/repo/formula")
  tapFromEntry = e:
    let parts = lib.splitString "/" e;
    in if builtins.length parts == 3
       then "${builtins.elemAt parts 0}/${builtins.elemAt parts 1}"
       else null;

  neededTaps = lib.unique (lib.filter (t: t != null)
    (map tapFromEntry (allBrews ++ (map (cask: cask.name) allCasks))));

  # Build a Brewfile in the Nix store -- formulas only, no casks, no mas
  brewfile = pkgs.writeText "Brewfile-standard" (
    # Declare taps first so brew bundle can fetch them before formulas
    lib.concatMapStrings (t: "tap \"${t}\"\n") neededTaps
    + "\n"
    + lib.concatMapStrings (b: "brew \"${b}\"\n") allBrews
  );

  # Helper: generate a shell snippet that installs a cask to ~/Applications
  # if it is not already present in /Applications or ~/Applications.
  checkAndInstallCask = name: appName: ''
    if [ ! -d "/Applications/${appName}.app" ] && \
       [ ! -d "$HOME/Applications/${appName}.app" ]; then
      echo "[omarchy4mac] Installing ${name} to ~/Applications..."
      if [ -x "$BREW_BIN" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/Applications"
        $DRY_RUN_CMD "$BREW_BIN" install --cask \
          --appdir="$HOME/Applications" "${name}" || {
          echo "[omarchy4mac] WARNING: ${name} install failed. Install manually:"
          echo "  brew install --cask --appdir=~/Applications ${name}"
        }
      else
        echo "[omarchy4mac] WARNING: brew not available. Install ${name} manually:"
        echo "  brew install --cask --appdir=~/Applications ${name}"
      fi
    else
      echo "[omarchy4mac] ${appName} already installed, skipping."
    fi
  '';

in
{
  # ── Inherit everything from home.nix ──────────────────────────────────────
  # Dotfiles, ~/bin scripts, Nix packages (direnv, autojump, home-manager...),
  # TPM bootstrap, fzf-git bootstrap, SSH key generation, p10k check,
  # sleepwatcher launchd agent, and sops secrets.
  imports = [ ./home.nix ];

  # ── Homebrew -- portable install, brews only ───────────────────────────────

  # Step 1: install Homebrew itself if not present
  # Uses the portable tarball method -- no root, no installer script, works
  # at any prefix on Apple Silicon.
  home.activation.bootstrapHomebrew = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    BREW_PREFIX="${config.home.homeDirectory}/PACKAGEMGMT/Homebrew"
    if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
      echo "[bootstrap] Installing Homebrew (portable) to $BREW_PREFIX ..."
      $DRY_RUN_CMD mkdir -p "$BREW_PREFIX"
      $DRY_RUN_CMD /usr/bin/curl -fsSL \
        https://github.com/Homebrew/brew/tarball/master \
        | /usr/bin/tar xz --strip-components 1 -C "$BREW_PREFIX"
      echo "[bootstrap] Homebrew installed."
    else
      echo "[bootstrap] Homebrew already present at $BREW_PREFIX -- skipping install."
    fi
  '';

  # Step 2: install all formulas from the shared brews list
  # brew bundle --no-lock: don't write a Brewfile.lock (Nix pins inputs instead)
  # brew bundle is idempotent -- safe to re-run on every home-manager switch
  home.activation.installBrews = lib.hm.dag.entryAfter [ "bootstrapHomebrew" ] ''
    BREW_BIN="${config.home.homeDirectory}/PACKAGEMGMT/Homebrew/bin/brew"
    if [ -x "$BREW_BIN" ]; then
      echo "[bootstrap] Installing Homebrew formulas (brews only, no casks)..."
      $DRY_RUN_CMD "$BREW_BIN" bundle \
        --file=${brewfile} \
        --no-upgrade
      echo "[bootstrap] Brew bundle complete."
    else
      echo "[bootstrap] WARNING: brew not found at $BREW_BIN -- skipping formula install."
    fi
  '';

  # Step 3: install omarchy4mac cask apps to ~/Applications when enabled
  # Checks /Applications (admin-installed) and ~/Applications (user-installed)
  # before attempting install. Idempotent and non-destructive.
  home.activation.installOmarchyCasks = lib.hm.dag.entryAfter [ "installBrews" ] ''
    BREW_BIN="${config.home.homeDirectory}/PACKAGEMGMT/Homebrew/bin/brew"
    ${lib.optionalString (omarchy4mac.enable && omarchy4mac.desktop.aerospace)
      (checkAndInstallCask "nikitabobko/tap/aerospace" "AeroSpace")}
    ${lib.optionalString (omarchy4mac.enable && omarchy4mac.desktop.hammerspoon)
      (checkAndInstallCask "hammerspoon" "Hammerspoon")}
    ${lib.optionalString (omarchy4mac.enable && omarchy4mac.apps.raycast)
      (checkAndInstallCask "raycast" "Raycast")}
    ${lib.optionalString (omarchy4mac.enable && omarchy4mac.apps.fluidvoice)
      (checkAndInstallCask "fluidvoice" "FluidVoice")}
    ${lib.optionalString (omarchy4mac.enable && omarchy4mac.apps.ghostty)
      (checkAndInstallCask "ghostty" "Ghostty")}
  '';
}
