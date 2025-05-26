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
      "Kagi for Safari" = 1622835804;
      "Microsoft To Do" = 1274495053;
      "Quiver"          = 866773894;
      "Termius"         = 1176074088;
      "UTM"             = 1538878817;
      "Windows App"     = 1295203466;
      "Workspaces"      = 1540284555;
      "Xcode"           = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      upgrade    = true;
      cleanup    = "uninstall";   # one of: "none" (default)	Leave unlisted formulae installed—you never lose anything. | "uninstall"	Run brew bundle install --cleanup, which will brew uninstall every formula not in your lists. | "zap"	Same as "uninstall", but for casks also runs brew uninstall --zap, removing all associated files.
    };
  };
}
