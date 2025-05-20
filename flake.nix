{
  description = "GMv's super basic macOS Nix SetUp via nix-darwin + Home-Manager flake";

  inputs = {
    nixpkgs      .url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin   .url = "github:LnL7/nix-darwin";
    nix-darwin   .inputs.nixpkgs.follows = "nixpkgs";

    home-manager .url = "github:nix-community/home-manager";
    home-manager .inputs.nixpkgs.follows = "nixpkgs";

    ######################################
    # Homebrew bootstrap (nix-homebrew)
    ######################################
    nix-homebrew.url   = "github:zhaofengli/nix-homebrew";

    # Pin the two official taps so your build is reproducible
    homebrew-core  = { url = "github:homebrew/homebrew-core";  flake = false; };
    homebrew-cask  = { url = "github:homebrew/homebrew-cask";  flake = false; };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, ... }@inputs:
  let
    system    = "aarch64-darwin";
    # pkgs    = nixpkgs.legacyPackages.${system};
    host      = "MACFXHLQH3MTP";   # or builtins.getEnv "HOSTNAME";   # or get with: scutil --get LocalHostName
    user      = "mch12700";
  in {
    # darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
    darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
      inherit system;

      # make `user` available to every module
      specialArgs = { inherit user inputs; };

      modules = [
        # ---------- macOS-level configuration ----------
        ./modules/system.nix  

        # Tell nix-darwin where the *real* home directory is
        ({ ... }: { users.users.${user}.home = "/Users/${user}"; })

        # ── Homebrew core (pinned) ───────────────────────────────
        nix-homebrew.darwinModules.nix-homebrew
        ({ nix-homebrew = {
            enable      = true;
            user        = user;
            mutableTaps = false;
            # NOTE: autoMigrate only copies the *default* prefixes
            #       (/opt/homebrew, /usr/local). It has no effect on
            #       your custom ~/PACKAGEMGMT prefix, so we drop it.
            # autoMigrate  = true;

            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
            };

            prefixes."/Users/${user}/PACKAGEMGMT/Homebrew" = {
              library = "/Users/${user}/PACKAGEMGMT/Homebrew/Library";
              autoMigrate = true;
              # You could pin extra taps *specific to this prefix*
              taps = { 
                "kylef/formulae"     = null;   # null → follow upstream HEAD
                "mas-cli/tap"        = null;
                "swiftbrew/tap"      = null;
              };
            };
          };
        })

        # ── Declarative formulas / casks list ───────────────────
        ./modules/homebrew.nix

        # ---------- Home-Manager integration ----------
        home-manager.darwinModules.home-manager
        ({
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;

          # pass `user` into Home-Manager modules
          home-manager.extraSpecialArgs = { inherit user inputs; };

          # per-user HM configuration
          home-manager.users.${user} = import ./modules/home.nix;
        })
      ];
    };
  };
}
