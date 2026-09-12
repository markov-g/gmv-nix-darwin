{ config, lib, inputs, user, host, enableMas, omarchy4mac, ... }:

let
  brews = import ./homebrew/brews.nix { inherit lib omarchy4mac; };
  casks = import ./homebrew/casks.nix { inherit lib host omarchy4mac; };
  masApps = import ./homebrew/mas.nix   { inherit host enableMas; };
in
{
  homebrew = {
    enable                  = true;
    taps                    = builtins.attrNames config.nix-homebrew.prefixes."/Users/${user}/PACKAGEMGMT/Homebrew".taps
      ++ lib.optional (omarchy4mac.enable &&
        (omarchy4mac.desktop.borders || omarchy4mac.desktop.sketchybar))
        "FelixKratz/formulae";
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
