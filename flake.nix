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
    # pkgs   = nixpkgs.legacyPackages.${system};
    host   = "MACFXHLQH3MTP";   # or builtins.getEnv "HOSTNAME";   # or get with: scutil --get LocalHostName
    user = "mch12700";
  in {
    # darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
    darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
      inherit system;

      modules = [
        ./modules/system.nix                       
        home-manager.darwinModules.home-manager
        {                                  
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          # expose extra vars inside HM modules
          home-manager.extraSpecialArgs = { inherit user; };

          home-manager.users.${user}   = import ./modules/home.nix;
        }
      ];
    };
  };
}
