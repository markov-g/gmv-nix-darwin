{
  description = "GMv's super basic macOS Nix SetUp via nix-darwin + Home-Manager flake";

  inputs = {
    nixpkgs      .url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin   .url = "github:LnL7/nix-darwin";
    nix-darwin   .inputs.nixpkgs.follows = "nixpkgs";

    home-manager .url = "github:nix-community/home-manager";
    home-manager .inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
  let
    system = "aarch64-darwin";
    pkgs   = nixpkgs.legacyPackages.${system};
    hostname   = "MACFXHLQH3MTP";   # or builtins.getEnv "HOSTNAME";   # or get with: scutil --get LocalHostName
    username = "mch12700";
  in {
    # darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system pkgs;

      modules = [
        ./modules/system.nix                       # your system settings
        home-manager.darwinModules.home-manager
        {                                   # HM integration glue
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username}   = import ./modules/home.nix { inherit username; };

          # optional: expose inputs to home-manager configs
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
