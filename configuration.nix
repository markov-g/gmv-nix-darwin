{ config, pkgs, lib, inputs, ... }:

{

  ##############################################################################
  # 1) Import the nix-darwin–wrapped Home-Manager module from your flake inputs #
  ##############################################################################
  imports = [ inputs.home-manager.darwinModules.home-manager ];


  #################################
  # 2) System-level nix-darwin bits
  #################################

  # Don’t let Determinate’s top level enable nix; nix-darwin takes over.
  nix.enable = false;  

  # Keep the daemon running so you can use flakes
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # -------------------------------
  #   ← Add your system packages here
  # -------------------------------
  environment.systemPackages = with pkgs; [
    vim    
    bat                # cat with syntax highlight
    exa                # modern ls replacement    
  ];

  # (Optional) macOS services, e.g. 
  # services.karabiner-elements.enable = true;


  #################################
  # 3) HOME-MANAGER INTEGRATION ###
  #################################
  programs.home-manager.enable        = true;
  home-manager.useGlobalPkgs          = true;
  home-manager.useUserPackages        = true;

  #################################################
  # 4) Hook in per-user config from home.nix #
  #################################################
  home-manager.users.mch12700 = {
    imports = [ ./home.nix ];
  };
}
