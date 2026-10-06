{ config, lib, inputs, user, host, enableMas, ... }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix { inherit host; };
  masApps = import ./homebrew/mas.nix   { inherit host enableMas; };
  engramHosts = import ./engram-hosts.nix;
  engramEnabled = builtins.elem host engramHosts;
in
{
  homebrew = {
    enable                  = true;
    taps                    = builtins.attrNames config.nix-homebrew.prefixes."/Users/${user}/PACKAGEMGMT/Homebrew".taps;
    prefix                  = "/Users/${user}/PACKAGEMGMT/Homebrew";
    brews                   = brews;
    casks                   = casks;

    # masApps is per-host, defined in modules/homebrew/mas.nix.
    # Returns {} when enableMas = false (machines without an Apple ID).
    inherit masApps;

    onActivation = {
      autoUpdate = true;
      upgrade    = true;
      cleanup    = "zap";
    };
  };

  # Reminder for Homebrew's Tap Trust gate (see docs.brew.sh/Taps): tapping
  # gentleman-programming/tap does NOT grant trust for the formulas/casks
  # inside it -- brew bundle will silently fail to install Engram on first
  # run until a human runs `brew trust` once, interactively. There is no
  # declarative/non-interactive bypass for this (confirmed from Homebrew's
  # own docs), so the most we can do is make the required command
  # impossible to miss in the activation output. See engram-hosts.nix for
  # which machines this applies to.
  system.activationScripts.postActivation.text = lib.mkIf engramEnabled (lib.mkAfter ''
    echo ""
    echo "[engram] gentleman-programming/tap requires one-time manual trust."
    echo "[engram] If Engram failed to install above with an 'untrusted tap' error, run:"
    echo "[engram]   /Users/${user}/PACKAGEMGMT/Homebrew/bin/brew trust --cask gentleman-programming/tap/engram"
    echo "[engram] Then re-run: darwin-rebuild switch --flake ~/.config/nix-darwin#${host}"
    echo ""
  '');
}
