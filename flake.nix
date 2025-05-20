{
  description = "GMv's super basic macOS Nix SetUp via nix-darwin + Home-Manager flake";

  inputs = {
    # core packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-darwin itself
     nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home Manager as a module
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    system = "aarch64-darwin"; 
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ nix-darwin.overlays.${system} ];
    };
  in {
    darwinConfigurations = {
      # use your short hostname here
      "MACFXHLQH3MTP" = nix-darwin.lib.darwinSystem {
        inherit system pkgs;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
        ];
        # pass inputs into your modules
        specialArgs = { inherit inputs; };
      };
    };
  };
}
