{ config, pkgs, user, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = user;
  home.homeDirectory = builtins.toPath "/Users/${user}";

  # packages to install
  home.packages = with pkgs; [
    # home-manager binary
    (inputs.home-manager.packages.${pkgs.system}.home-manager)
    # pkgs is the set of all packages in the default home.nix implementation
    direnv
    nix-direnv
    autojump    
  ];

  # Raw configuration files
  home.file.".zshrc".source = ./dotfiles/macos/.zshrc.${user};


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
