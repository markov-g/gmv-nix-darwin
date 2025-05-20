{
  description = "GMv's super basic macOS Nix SetUp via nix-darwin + Home-Manager flake";

  inputs = {
    # core packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-darwin itself
     nix-darwin = {
      # url = "github:nix-darwin/nix-darwin";
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
      overlays = [ nix-darwin.overlays.default ];
    };
    host = builtins.getEnv "HOSTNAME";  # or hard-code
  in {
    darwinConfigurations = {
      # use your short hostname here - # must match the name you pass to darwin-rebuild
      "MACFXHLQH3MTP" = nix-darwin.lib.darwinSystem {        
      # "${host}" = nix-darwin.lib.darwinSystem {
        inherit system pkgs;
        
        # disable the nixpkgs‐release assertion on master
        enableNixpkgsReleaseCheck = false;        

        # bring in your nix-darwin modules + HM
        modules = [          
          ./modules/system.nix
          home-manager.darwinModules.home-manager
          ./modules/home-manager.nix 
        ];

        # pass inputs into your modules
        specialArgs = { inherit inputs; };
      };
    };
  };
}
