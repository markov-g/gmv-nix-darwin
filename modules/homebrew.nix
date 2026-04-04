{ config, lib, inputs, user, host, enableMas, ... }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix { inherit host; };
  masApps = import ./homebrew/mas.nix   { inherit host enableMas; };
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
}
