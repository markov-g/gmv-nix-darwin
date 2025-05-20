
{ config, pkgs, lib, inputs, ... }:
{
  #################################
  # HOME-MANAGER INTEGRATION ###
  #################################
  programs.home-manager.enable        = true;
  home-manager.useGlobalPkgs          = true;
  home-manager.useUserPackages        = true;

  #################################################
  # 4) Hook in per-user config from home.nix #
  #################################################
  home-manager.users.mch12700 = {
    imports = [ inputs.self + /home.nix ];
  };
}