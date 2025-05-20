{ config, pkgs, lib, inputs, ... }:
{
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
}
