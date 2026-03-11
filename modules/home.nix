{ config, lib, pkgs, inputs, user, host, ... }:

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

  # Raw configuration files (shared across all users/machines)
  home.file = {
    # ── Shell ───────────────────────────────────────────────────
    ".zshrc".source    = ./dotfiles/macos/.zshrc;
    # .zshenv is intentionally NOT managed by Nix — it must remain a regular writable
    # file so that apps like ServBay can inject / rewrite their env blocks.
    # On a new machine, seed it once: cp modules/dotfiles/macos/.zshenv.seed ~/.zshenv
    ".zprofile".source = ./dotfiles/macos/.zprofile;

    # ── Git ─────────────────────────────────────────────────────
    ".gitconfig".source        = ./dotfiles/macos/.gitconfig;
    ".gitignore_global".source = ./dotfiles/macos/.gitignore_global;

    # ── Terminal utilities ───────────────────────────────────────
    ".tmux.conf".source = ./dotfiles/macos/.tmux.conf;
    ".inputrc".source   = ./dotfiles/macos/.inputrc;
    ".screenrc".source  = ./dotfiles/macos/.screenrc;
    ".xinitrc".source   = ./dotfiles/macos/.xinitrc;

    # ── Shell profile chain ──────────────────────────────────────
    ".profile.master".source         = ./dotfiles/macos/.profile.master;
    ".profile.include_always".source = ./dotfiles/macos/.profile.include_always;
    ".profile.nix".source            = ./dotfiles/macos/.profile.nix;
    ".profile.homebrew".source       = ./dotfiles/macos/.profile.homebrew;
    ".profile.macports".source       = ./dotfiles/macos/.profile.macports;
    ".profile.fink".source           = ./dotfiles/macos/.profile.fink;
    ".profile.pkgsrc".source         = ./dotfiles/macos/.profile.pkgsrc;
    ".profile.portage".source        = ./dotfiles/macos/.profile.portage;
    ".profile.kubectl".source        = ./dotfiles/macos/.profile.kubectl;

    # ── SSH ─────────────────────────────────────────────────────
    # NOTE: private key is managed via sops-nix (see secrets/README.md)
    ".ssh/config".source = ./dotfiles/macos/.ssh/config;

    # ── Sleep / wake hooks (used by macOS power management) ──────
    ".sleep"  = { source = ./dotfiles/macos/.sleep;  executable = true; };
    ".wakeup" = { source = ./dotfiles/macos/.wakeup; executable = true; };

    # ── .profile (legacy sh/bash entry-point → delegates to .profile.include_always) ──
    ".profile".source = ./dotfiles/macos/.profile.include_always;

    # ── ~/bin scripts ────────────────────────────────────────────
    "bin/bootstrap-macos.sh"                 = { source = ./dotfiles/macos/bin/bootstrap-macos.sh;                 executable = true; };
    "bin/install-determinate-nix.sh"         = { source = ./dotfiles/macos/bin/install-determinate-nix.sh;         executable = true; };
    "bin/install-macports.sh"                = { source = ./dotfiles/macos/bin/install-macports.sh;                executable = true; };
    "bin/clone-repos.sh"                     = { source = ./dotfiles/macos/bin/clone-repos.sh;                     executable = true; };
    "bin/create-darwin-volume.sh"            = { source = ./dotfiles/macos/bin/create-darwin-volume.sh;            executable = true; };
    "bin/macos-proxy.sh"                     = { source = ./dotfiles/macos/bin/macos-proxy.sh;                     executable = true; };
    "bin/nix-update-all.sh"                  = { source = ./dotfiles/macos/bin/nix-update-all.sh;                  executable = true; };
    "bin/send_command_to_all_tmux_vwindows.sh" = { source = ./dotfiles/macos/bin/send_command_to_all_tmux_vwindows.sh; executable = true; };
    "bin/startTor.sh"                        = { source = ./dotfiles/macos/bin/startTor.sh;                        executable = true; };
    "bin/update-fink"                        = { source = ./dotfiles/macos/bin/update-fink;                        executable = true; };
    "bin/update-homebrew"                    = { source = ./dotfiles/macos/bin/update-homebrew;                    executable = true; };
    "bin/update-macports"                    = { source = ./dotfiles/macos/bin/update-macports;                    executable = true; };

    # ── Scaffold directories (created via a .keep placeholder) ──
    "Applications/.keep".text              = "";
    "git-repos/.keep".text                 = "";
    "git-repos/github.com/.keep".text      = "";
    "git-repos/code.siemens.com/.keep".text = "";
    "git-repos/overleaf.com/.keep".text    = "";
    "git-repos/workspace/.keep".text       = "";
    "kubeconfig/.keep".text                = "";

    # ── Neovim (LazyVim) ──────────────────────────────────────────────────────
    # Config is read-only from the nix store; plugins/data live in ~/.local/share/nvim
    ".config/nvim".source = ./dotfiles/macos/.config/nvim;
  };



  # ── Bootstrap activation scripts ─────────────────────────────────────────────

  # ── Bootstrap TPM (Tmux Plugin Manager) ──────────────────────────────────────
  home.activation.bootstrapTpm = lib.hm.dag.entryAfter ["writeBoundary"] ''
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR/.git" ]; then
      echo "[bootstrap] Cloning TPM (Tmux Plugin Manager)..."
      $DRY_RUN_CMD git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi
  '';

  home.activation.bootstrapFzfGit = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.fzf-git.sh/fzf-git.sh" ]; then
      echo "[bootstrap] Cloning fzf-git.sh..."
      $DRY_RUN_CMD git clone --depth=1 https://github.com/junegunn/fzf-git.sh "$HOME/.fzf-git.sh"
    fi
  '';

  # Generate an SSH key on first run if none exists.
  # On established machines the key is restored from sops secrets (or backup).
  home.activation.generateSshKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
      echo "[bootstrap] No SSH key found — generating ed25519 key..."
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD chmod 700 "$HOME/.ssh"
      $DRY_RUN_CMD /usr/bin/ssh-keygen -t ed25519 -C "${user}@${host}" -N "" -f "$HOME/.ssh/id_ed25519"
      echo "[bootstrap] Public key (add to GitHub/GitLab/etc.):"
      cat "$HOME/.ssh/id_ed25519.pub"
      echo "[bootstrap] Then encrypt it into secrets/secrets.yaml with sops."
    fi
  '';

  # Warn if p10k.zsh is missing (powerlevel10k won't render without it).
  home.activation.checkP10k = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.p10k.zsh" ]; then
      echo "[bootstrap] ~/.p10k.zsh not found."
      echo "            Run: p10k configure"
      echo "            Then commit: cp ~/.p10k.zsh ~/.config/nix-darwin/modules/dotfiles/macos/.p10k.zsh"
      echo "            And add to home.nix: \".p10k.zsh\".source = ./dotfiles/macos/.p10k.zsh;"
    fi
  '';

  # ── sleepwatcher launchd agent ────────────────────────────────────────────────
  # sleepwatcher (installed via Homebrew) runs ~/.sleep on sleep and ~/.wakeup on wake.
  # The agent is defined here so nix-darwin/HM loads it automatically.
  launchd.agents.sleepwatcher = {
    enable = true;
    config = {
      Label            = "de.bernhard-baehr.sleepwatcher";
      ProgramArguments = [
        "${config.home.homeDirectory}/PACKAGEMGMT/Homebrew/bin/sleepwatcher"
        "-V"
        "-s" "${config.home.homeDirectory}/.sleep"
        "-w" "${config.home.homeDirectory}/.wakeup"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  # ── Secrets (sops-nix) ───────────────────────────────────────────────────────
  # Bootstrap: generate age key once from SSH key:
  #   mkdir -p ~/.config/sops/age
  #   ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
  # Then encrypt the secrets file:
  #   sops secrets/secrets.yaml
  # See secrets/README.md for the full bootstrap guide.
  #
  # Guarded with pathExists so the config evaluates cleanly on new machines
  # before secrets/secrets.yaml has been created.
  sops = lib.mkIf (builtins.pathExists ../secrets/secrets.yaml) {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      # Each entry decrypts to a file at the given path, mode 0600.
      # Keys must exist in secrets/secrets.yaml (encrypted with sops).
      "netrc"           = { path = "${config.home.homeDirectory}/.netrc";                    mode = "0600"; };
      "aws_credentials" = { path = "${config.home.homeDirectory}/.aws/credentials";          mode = "0600"; };
      "docker_config"   = { path = "${config.home.homeDirectory}/.docker/config.json";       mode = "0600"; };
      "kube_config"     = { path = "${config.home.homeDirectory}/.kube/config";              mode = "0600"; };
      "ssh_private_key" = { path = "${config.home.homeDirectory}/.ssh/id_ed25519";           mode = "0600"; };
      "ssh_public_key"  = { path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";       mode = "0644"; };
    };
  };

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
