{ config, inputs, user, ... }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
in
{
  homebrew = {
    enable                  = true;           # tells nix-darwin to run `brew bundle`
    # taps                  = builtins.attrNames config.nix-homebrew.taps;
    taps                    = builtins.attrNames config.nix-homebrew.prefixes."/Users/${user}/PACKAGEMGMT/Homebrew".taps;
    prefix                  = "/Users/${user}/PACKAGEMGMT/Homebrew";
    brews                   = brews;
    casks                   = casks;
    masApps                 = {               # add MAS apps later if you like
        "1Password 7" = 1333542190;
        "Bible Study" = 472790630;
	"CaptureTrades: Trading Journal" = 6478657062;
        "Developer" = 640199958;
        "Hotspot Shield" = 771076721;
        "Kagi for Safari" = 1622835804;
        "Keynote" = 409183694;
        "Kiwix" = 997079563;
        "Microsoft OneNote" = 784801555;
        "MoneyWiz 2025 Personal Finance" = 1511185140;        
        "Numbers" = 409203825;
        "Pages" = 409201541;
	"Perplexity: Ask Anything" = 6714467650;
        "Pixelmator Pro" = 1289583905;
        "Quiver" = 866773894;        
        "Telegram" = 747648890;
        "Termius" = 1176074088;
        "Texifier" = 458866234;        
        "UTM" = 1538878817;
        "Webull" = 1334590352;
        "Windows App" = 1295203466;
        "Workspaces 2" = 1540284555;
        "Xcode" = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      upgrade    = true;
      cleanup    = "zap";   # one of: "none" (default)	Leave unlisted formulae installed—you never lose anything. | "uninstall"	Run brew bundle install --cleanup, which will brew uninstall every formula not in your lists. | "zap"	Same as "uninstall", but for casks also runs brew uninstall --zap, removing all associated files.
    };
  };
}
