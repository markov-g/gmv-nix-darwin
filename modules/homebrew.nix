{ inputs, user, ... }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
in
{
  homebrew = {
    enable                  = true;           # tells nix-darwin to run `brew bundle`
    brewPrefix              = "/Users/${user}/PACKAGEMGMT/Homebrew/bin";
    brews                   = brews;
    casks                   = casks;
    masApps                 = {               # add MAS apps later if you like
       # e.g. "Xcode" = 497799835;
    };

    onActivation = {
      autoUpdate = false;   # don’t refresh taps
      upgrade    = false;   # don’t bump versions
      cleanup    = "none";  # keep unlisted packages around
    };
  };
}
