{ config, lib, pkgs, inputs, user, host, ... }:

# ── Standard-user Home Manager config ────────────────────────────────────────
# Inherits ALL dotfiles, packages, and activation scripts from home.nix.
# Adds a brews-only Homebrew instance at ~/PACKAGEMGMT/Homebrew.
# No casks — GUI apps are already installed system-wide by the admin account.
#
# Activate (as the standard user, no sudo):
#   home-manager switch --flake ~/.config/nix-darwin#<user>@<host>
#
# First-time bootstrap on a new machine:
#   1. Log in as the standard user
#   2. Nix is already available (system-wide from admin's darwin-rebuild)
#   3. Clone the repo:  git clone ... ~/.config/nix-darwin --branch mac-mini
#   4. Run the activation above — it will:
#      a. Link all dotfiles (same as admin)
#      b. Install Homebrew (portable) to ~/PACKAGEMGMT/Homebrew
#      c. Run brew bundle (formulas only)

let
  allBrews = import ./homebrew/brews.nix;

  # Extract "owner/repo" from tap-qualified entries ("owner/repo/formula")
  tapFromEntry = e:
    let parts = lib.splitString "/" e;
    in if builtins.length parts == 3
       then "${builtins.elemAt parts 0}/${builtins.elemAt parts 1}"
       else null;

  neededTaps = lib.unique (lib.filter (t: t != null) (map tapFromEntry allBrews));

  # Build a Brewfile in the Nix store — formulas only, no casks, no mas
  brewfile = pkgs.writeText "Brewfile-standard" (
    # Declare taps first so brew bundle can fetch them before formulas
    lib.concatMapStrings (t: "tap \"${t}\"\n") neededTaps
    + "\n"
    + lib.concatMapStrings (b: "brew \"${b}\"\n") allBrews
  );

in
{
  # ── Inherit everything from home.nix ──────────────────────────────────────
  # Dotfiles, ~/bin scripts, Nix packages (direnv, autojump, home-manager…),
  # TPM bootstrap, fzf-git bootstrap, SSH key generation, p10k check,
  # sleepwatcher launchd agent, and sops secrets.
  imports = [ ./home.nix ];

  # ── Homebrew — portable install, brews only ───────────────────────────────

  # Step 1: install Homebrew itself if not present
  # Uses the portable tarball method — no root, no installer script, works
  # at any prefix on Apple Silicon.
  home.activation.bootstrapHomebrew = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    BREW_PREFIX="${config.home.homeDirectory}/PACKAGEMGMT/Homebrew"
    if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
      echo "[bootstrap] Installing Homebrew (portable) to $BREW_PREFIX ..."
      $DRY_RUN_CMD mkdir -p "$BREW_PREFIX"
      $DRY_RUN_CMD curl -fsSL \
        https://github.com/Homebrew/brew/tarball/master \
        | tar xz --strip-components 1 -C "$BREW_PREFIX"
      echo "[bootstrap] Homebrew installed."
    else
      echo "[bootstrap] Homebrew already present at $BREW_PREFIX — skipping install."
    fi
  '';

  # Step 2: install all formulas from the shared brews list
  # brew bundle --no-lock: don't write a Brewfile.lock (Nix pins inputs instead)
  # brew bundle is idempotent — safe to re-run on every home-manager switch
  home.activation.installBrews = lib.hm.dag.entryAfter [ "bootstrapHomebrew" ] ''
    BREW_PREFIX="${config.home.homeDirectory}/PACKAGEMGMT/Homebrew"
    if [ -x "$BREW_PREFIX/bin/brew" ]; then
      echo "[bootstrap] Installing Homebrew formulas (brews only, no casks)..."
      $DRY_RUN_CMD "$BREW_PREFIX/bin/brew" bundle \
        --file=${brewfile} \
        --no-lock \
        --no-upgrade
      echo "[bootstrap] Brew bundle complete."
    else
      echo "[bootstrap] WARNING: brew not found at $BREW_PREFIX — skipping formula install."
    fi
  '';
}