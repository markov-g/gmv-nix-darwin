# Called as: import ./homebrew/mas.nix { inherit host enableMas; }
# Returns the masApps attrset for that machine, or {} when enableMas = false.
#
# Pattern mirrors casks.nix: shared entries (installed everywhere) are merged
# with per-host entries.  Machines with enableMas = false get an empty set so
# `homebrew.masApps` is set but empty — brew bundle stays clean.
{ host, enableMas }:

if !enableMas then {} else

let
  # ── Apps installed on every enableMas machine ─────────────────────────────
  shared = {
    "1Password 7"                    = 1333542190;    
    "Termius"                        = 1176074088;
    # "Texifier"                       = 458866234;
    "UTM"                            = 1538878817;    
    "Windows App"                    = 1295203466;
    "Workspaces 2"                   = 1540284555;
    "Xcode"                          = 497799835;
  };

  # ── Per-host extras ────────────────────────────────────────────────────────
  hostSpecific = {
    "r1pp3r" = {
        "Bible Study"                    = 472790630;
        "Kagi for Safari"                = 1622835804;
        "Keynote"                        = 409183694;
        "Microsoft OneNote"              = 784801555;
        "MoneyWiz 2025 Personal Finance" = 1511185140;
        "Numbers"                        = 409203825;
        "Pages"                          = 409201541;
        "Quiver"                         = 866773894;
        "Webull"                         = 1334590352;
        # "Nautik"  = 1672838783;  # k8s
    };

    "SE1FXHLQH3MTP" = {
      # work machine — add work-specific MAS apps here
    };

    "minidevbox" = {
      # dev box — add if needed
    };
  };

in
  shared // (hostSpecific.${host} or {})
