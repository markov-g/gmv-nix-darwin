# Normalize the omarchy4mac profile: fill in missing keys with defaults.
# Called from flake.nix before passing to specialArgs.
{ omarchy4mac ? {} }:

let
  apps = omarchy4mac.apps or {};
  desktop = omarchy4mac.desktop or {};
  themes = omarchy4mac.themes or {};
  screensaver = omarchy4mac.screensaver or {};
in
{
  enable = omarchy4mac.enable or false;

  apps = {
    raycast     = apps.raycast or false;
    fluidvoice  = apps.fluidvoice or false;
    bun         = apps.bun or false;
    fastfetch   = apps.fastfetch or false;
    ghostty     = apps.ghostty or false;
  };

  desktop = {
    aerospace   = desktop.aerospace or false;
    borders     = desktop.borders or false;
    hammerspoon = desktop.hammerspoon or false;
    sketchybar  = desktop.sketchybar or false;
  };

  themes = {
    enable = themes.enable or false;
  };

  screensaver = {
    enable = screensaver.enable or false;
  };
}
