{ inputs, ... }:

let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
in
{
  homebrew = {
    enable                  = true;          # tells nix-darwin to run `brew bundle`
    mutableBrews            = false;         # block ad-hoc `brew install …`﻿:contentReference[oaicite:1]{index=1}
    onActivation.autoUpdate = false;         # keep rebuilds deterministic
    brews                   = brews;
    casks                   = casks;
    masApps                 = {};            # add MAS apps later if you like
  };
}
