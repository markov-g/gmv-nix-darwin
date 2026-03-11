{
  description = "GMv's macOS Nix setup — nix-darwin + Home-Manager (multi-machine)";

  inputs = {
    nixpkgs      .url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin   .url = "github:LnL7/nix-darwin";
    nix-darwin   .inputs.nixpkgs.follows = "nixpkgs";

    home-manager .url = "github:nix-community/home-manager";
    home-manager .inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    ######################################
    # Homebrew bootstrap (nix-homebrew)
    ######################################
    nix-homebrew.url   = "github:zhaofengli/nix-homebrew";

    homebrew-core  = { url = "github:homebrew/homebrew-core";  flake = false; };
    homebrew-cask  = { url = "github:homebrew/homebrew-cask";  flake = false; };
    mas-cli-tap    = { url = "github:mas-cli/homebrew-tap";    flake = false; };
    xtool-org-tap  = { url = "github:xtool-org/homebrew-tap";  flake = false; };

    # FlakeHub
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    kylef-formulae = { url = "github:kylef/homebrew-formulae"; flake = false; };
    swiftbrew-tap  = { url = "github:swiftbrew/homebrew-tap";  flake = false; };
    sdkman-tap     = { url = "github:sdkman/homebrew-tap";     flake = false; };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }@inputs:

  let
    # ── Helper: build a darwinSystem for one machine ─────────────────────────
    # host, user, system are injected into every module via specialArgs.
    # To add a machine: copy a block in darwinConfigurations below.
    mkDarwin = { host, user, system ? "aarch64-darwin" }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit host user inputs; };

        modules = [
          # ── macOS-level configuration ──────────────────────────────────────
          ./modules/system.nix

          # home directory for the primary user
          ({ ... }: { users.users.${user}.home = "/Users/${user}"; })

          # ── Homebrew ───────────────────────────────────────────────────────
          nix-homebrew.darwinModules.nix-homebrew
          ({ ... }: { nix-homebrew = {
            enable      = true;
            user        = user;
            mutableTaps = true;
            autoMigrate = true;
            taps        = {};

            prefixes."/Users/${user}/PACKAGEMGMT/Homebrew" = {
              enable  = true;
              library = "/Users/${user}/PACKAGEMGMT/Homebrew/Library";
              taps = {
                "kylef/formulae" = inputs.kylef-formulae;
                "mas-cli/tap"    = inputs.mas-cli-tap;
                "swiftbrew/tap"  = inputs.swiftbrew-tap;
                "sdkman/tap"     = inputs.sdkman-tap;
                "xtool-org/tap"  = inputs.xtool-org-tap;
              };
            };
          }; })

          ./modules/homebrew.nix

          # ── Home Manager ───────────────────────────────────────────────────
          home-manager.darwinModules.home-manager
          ({ ... }: {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit host user inputs; };
            home-manager.sharedModules   = [ inputs.sops-nix.homeManagerModules.sops ];
            home-manager.users.${user}   = import ./modules/home.nix;
          })
        ];
      };

  in {
    darwinConfigurations = {
      # Apply:  darwin-rebuild switch --flake .#<host>
      # Build:  darwin-rebuild build  --flake .#<host>  (no activation)

      "minidevbox" = mkDarwin {
        host   = "minidevbox";
        user   = "r1pp3r";
        system = "aarch64-darwin";
      };

      # Uncomment + fill in to add another machine:
      # "macbook" = mkDarwin {
      #   host   = "macbook";
      #   user   = "r1pp3r";
      #   system = "aarch64-darwin";
      # };

      # "worklaptop" = mkDarwin {
      #   host   = "worklaptop";
      #   user   = "gmarkov";    # different username on work machine
      #   system = "aarch64-darwin";
      # };
    };
  };
}
