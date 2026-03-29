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
    mkDarwin = { host, user, system ? "aarch64-darwin", enableMas ? true }:
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit host user inputs enableMas; };

        modules = [
          # ── Set target platform (replaces deprecated `system` arg) ───────
          { nixpkgs.hostPlatform = system; }

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
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit host user inputs; };
            home-manager.sharedModules   = [ inputs.sops-nix.homeManagerModules.sops ];
            home-manager.users.${user}   = import ./modules/home.nix;
          })
        ];
      };

    # ── Helper: standalone Home Manager for standard (non-admin) users ───────
    # These users get dotfiles + Nix packages + brews-only Homebrew.
    # No darwin-rebuild needed — activate with:
    #   home-manager switch --flake .#<user>@<host>
    # Users & Groups; the other homeConfigurations entry is never activated.
    mkHomeUser = { user, host, system ? "aarch64-darwin" }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs user host; };
        modules = [
          ./modules/home-standard.nix          # dotfiles + brews-only Homebrew
          inputs.sops-nix.homeManagerModules.sops
        ];
      };

  in {
    darwinConfigurations = {
      # Apply:  darwin-rebuild switch --flake .#<host>
      # Build:  darwin-rebuild build  --flake .#<host>  (no activation)

      "r1pp3r" = mkDarwin {
        host   = "r1pp3r";
        user   = "r1pp3r"; 
        system = "aarch64-darwin";
      };

      "SE1FXHLQH3MTP" = mkDarwin {
        host   = "SE1FXHLQH3MTP";
        user   = "mch12700";    # different username on work machine
        system = "aarch64-darwin";
      };

      "minidevbox" = mkDarwin {
        host      = "minidevbox";
        user      = "r1pp3r";
        system    = "aarch64-darwin";
      };      

      "minidevboxvm" = mkDarwin {
        host      = "minidevboxvm";
        user      = "devel";
        system    = "aarch64-darwin";        
      };

      "openclaw" = mkDarwin {
        host   = "openclaw";
        user   = "r1pp3r";
        system = "aarch64-darwin";
        enableMas = false;   # no Apple ID on this machine
      };      
      
      # Uncomment + fill in to add another machine:      
      # "worklaptop" = mkDarwin {
      #   host   = "worklaptop";
      #   user   = "gmarkov";    # different username on work machine
      #   system = "aarch64-darwin";
      #   enableMas = false;   # no Apple ID on this machine
      # };
    };

    # ── Standalone Home Manager — standard users (brews only, no casks) ─────
    # This is a passive registry — nothing is activated unless you explicitly run:
    #   home-manager switch --flake .#<user>@<host>
    #
    # Rules:
    #   - Only list machines where you actually create a secondary user in macOS
    #     Users & Groups. Unlisted machines are unaffected.
    #   - XOR per machine: create ONE of llmautomation/devel in macOS, activate
    #     only that entry. The other entry is inert until used.
    #   - Adding a new machine: create the macOS account, add an entry here,
    #     then run home-manager switch as that user.
    homeConfigurations = {

      # ── minidevbox — pick one: llmautomation (AI/automation workloads)
      #                           devel         (general dev work)
      "llmautomation@minidevbox" = mkHomeUser {
        user = "llmautomation";
        host = "minidevbox";
      };
      "devel@minidevbox" = mkHomeUser {
        user = "devel";
        host = "minidevbox";
      };

      # ── minidevboxvm — devel fits best for VM-based dev environments
      "devel@minidevboxvm" = mkHomeUser {
        user = "devel";
        host = "minidevboxvm";
      };

      "llmautomation@openclaw" = mkHomeUser {
        user = "llmautomation";
        host = "openclaw";
      };

      # ── Add future machines here as needed, e.g.:
      # "llmautomation@somenewhostname" = mkHomeUser {
      #   user = "llmautomation";
      #   host = "somenewhostname";
      # };
    };
  };
}
