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
        "1Password 7" = 1333542190;
        "Developer" = 640199958;
        "Evibe" = 1666870677;
        "Ground News" = 1324203419;
        "Haskell" = 841285201;
        "Hotspot Shield" = 771076721;
        "iThoughtsX" = 720669838;
        "Kagi for Safari" = 1622835804;
        "Keynote" = 409183694;
        "Kiwix" = 997079563;
        "LiquidText" = 922765270;
        "Microsoft Excel" = 462058435;
        "Microsoft OneNote" = 784801555;
        "Microsoft Outlook" = 985367838;
        "Microsoft PowerPoint" = 462062816;
        "Microsoft To Do" = 1274495053;
        "Microsoft Word" = 462054704;
        "Moom Classic" = 419330170;
        "Nautik" = 1672838783;
        "Numbers" = 409203825;
        "OneDrive" = 823766827;
        "Pages" = 409201541;
        "Pixelmator Pro" = 1289583905;
        "Quiver" = 866773894;
        "Structured" = 1499198946;
        "Studies" = 1071676469;
        "Swift Playground" = 1496833156;
        "Telegram" = 747648890;
        "Termius" = 1176074088;
        "Texifier" = 458866234;
        "Trello" = 1278508951;
        "UTM" = 1538878817;
        "Windows App" = 1295203466;
        "Xcode" = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      upgrade    = true;
      cleanup    = "uninstall";   # one of: "none" (default)	Leave unlisted formulae installed—you never lose anything. | "uninstall"	Run brew bundle install --cleanup, which will brew uninstall every formula not in your lists. | "zap"	Same as "uninstall", but for casks also runs brew uninstall --zap, removing all associated files.
    };
  };
}
