{ inputs, ... }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
in
{
  homebrew = {
    enable                  = true;          # tells nix-darwin to run `brew bundle`
    brews                   = brews;
    casks                   = casks;
    # masApps                 = {};            # add MAS apps later if you like

    onActivation = {
      autoUpdate = false;   # don’t refresh taps
      upgrade    = false;   # don’t bump versions
      cleanup    = "none";  # keep unlisted packages around
    };
  };
}
