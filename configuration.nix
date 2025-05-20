{ config, pkgs, lib, inputs, ... }:

{
  # turn off the built-in release check
  nix-darwin.enableNixpkgsReleaseCheck = false;
  
  # Don’t let Determinate’s top level enable nix; nix-darwin takes over.
  nix.enable = false;  

  # Keep the daemon running so you can use flakes
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # Home-Manager as a module
  programs.home-manager.enable = true;

  # Your user
  users.users."mch12700" = {
    isNormalUser = true;
    home = "/Users/mch12700";
    shell = pkgs.zsh;
  };

  # -------------------------------
  #   ← Add your system packages here
  # -------------------------------
  environment.systemPackages = with pkgs; [
    vim    
    bat                # cat with syntax highlight
    exa                # modern ls replacement    
  ];

  # You can drop your home-manager config inline or import a separate file:
  home-manager.users.mch12700 = import ./home.nix;
}
