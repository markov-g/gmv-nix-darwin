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
    host   = builtins.getEnv "HOSTNAME";   # or get with: scutil --get LocalHostName
  in {
    # darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
    darwinConfigurations.MACFXHLQH3MTP = nix-darwin.lib.darwinSystem {
      inherit system pkgs;

      modules = [
        ./modules/system.nix                       # your system settings
        home-manager.darwinModules.home-manager
        {                                   # HM integration glue
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.users.mch12700   = import ./modules/home.nix;

          # optional: expose inputs to home-manager configs
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
