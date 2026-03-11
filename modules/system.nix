{ pkgs, user, host, inputs, ... }:
{
  # Don't let Determinate's top level enable nix; nix-darwin takes over.
  nix.enable = false;

  system.primaryUser = user;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ########################################
  # Machine identity (set per-host in flake.nix via `host` arg)
  ########################################
  networking.hostName      = host;   # scutil --get LocalHostName
  networking.computerName  = host;   # Finder / Bonjour display name
  networking.localHostName = host;   # .local mDNS name (no spaces/dots)

  ########################################
  # Security
  ########################################
  # Allow Touch ID to authenticate sudo in Terminal
  security.pam.enableSudoTouchIdAuth = true;

  ########################################
  # Keyboard
  ########################################
  system.keyboard.enableKeyMapping      = true;
  # system.keyboard.remapCapsLockToEscape = true;   # vim-friendly; remove if unwanted

  ########################################
  # Shell — puts /run/current-system/sw/bin on $PATH
  ########################################
  programs.zsh.enable = true;

  ########################################
  # System packages (available everywhere, no package-manager sourcing needed)
  # Reference: https://mynixos.com/nix-darwin/options/environment.systemPackages
  ########################################
  environment.systemPackages = with pkgs; [
    vim
    tmux
    inputs.fh.packages.${pkgs.system}.default

    # ── Core CLI replacements (always available, no package-manager sourcing) ──
    bat        # cat with syntax highlighting
    eza        # modern ls
    fzf        # fuzzy finder
    fd         # fast find (fzf companion)
    git-delta  # better git diff / pager
    ripgrep    # rg — fast grep
    jq         # JSON processor (essential everywhere)

    # ── Editor ────────────────────────────────────────────────────────────────
    neovim     # editor — LazyVim config in ~/.config/nvim

    # ── Git TUI ───────────────────────────────────────────────────────────────
    lazygit    # best git TUI — <leader>gg in nvim, or `lg` in shell
    gitui      # fast Rust-based git TUI — `gu` in shell

    # ── Shell history & navigation ────────────────────────────────────────────
    atuin      # shell history search (Ctrl-R replacement, syncs across machines)
    zoxide     # smarter cd — `z <fuzzy>`, `zi` for interactive

    # ── System monitoring ─────────────────────────────────────────────────────
    bottom     # btm — beautiful interactive process/resource monitor
    htop       # classic top replacement
    ncdu       # ncurses disk usage explorer

    # ── File management ───────────────────────────────────────────────────────
    yazi       # blazing-fast terminal file manager with preview

    # ── Diff / code analysis ──────────────────────────────────────────────────
    difftastic # structural diff — understands syntax (dt / difft)
    dust       # better `du` — visual disk usage tree
    tokei      # code statistics by language

    # ── HTTP & API ────────────────────────────────────────────────────────────
    xh         # fast HTTPie-compatible HTTP client

    # ── JSON / data ───────────────────────────────────────────────────────────
    jless      # interactive JSON viewer / pager

    # ── Kubernetes ────────────────────────────────────────────────────────────
    k9s        # Kubernetes TUI

    # ── Documentation ─────────────────────────────────────────────────────────
    tealdeer   # fast community `tldr` pages — `tldr <command>`

    # ── Markdown ──────────────────────────────────────────────────────────────
    glow       # render Markdown beautifully in terminal

    # ── Benchmarking ──────────────────────────────────────────────────────────
    hyperfine  # command-line benchmarking tool

    # ── Misc process tools ────────────────────────────────────────────────────
    procs      # modern `ps` replacement with colour and tree view

    # ── Encryption / Security ──────────────────────────────────────────────────
    gnupg      # GPG encryption, signing, key management (`gpg` command)
    age        # modern simple file encryption (also used internally by sops-nix)
    ssh-to-age # derive age key from SSH key — required for sops-nix bootstrap
  ];

  ########################################
  # macOS system defaults
  # Discover options:
  #   https://mynixos.com/nix-darwin/options/system.defaults
  #   https://daiderd.com/nix-darwin/manual/index.html
  #   github:LnL7/nix-darwin → modules/system/defaults/
  ########################################
  system.defaults = {

    # ── Dock ──────────────────────────────────────────────────────────────────
    dock.autohide               = true;
    dock.autohide-delay         = 0.0;
    dock.autohide-time-modifier = 0.15;
    dock.show-recents           = false;
    dock.mru-spaces             = false;   # don't reorder spaces by recency
    dock.minimize-to-application = true;
    dock.tilesize               = 48;

    # ── Finder ────────────────────────────────────────────────────────────────
    finder.AppleShowAllFiles              = true;
    finder.ShowPathbar                    = true;
    finder.ShowStatusBar                  = true;
    finder.FXPreferredViewStyle           = "clmv";   # column view
    finder.FXDefaultSearchScope           = "SCcf";   # search current folder
    finder._FXShowPosixPathInTitle        = true;
    finder.FXEnableExtensionChangeWarning = false;

    # ── Global domain ─────────────────────────────────────────────────────────
    NSGlobalDomain.ApplePressAndHoldEnabled              = false;  # key repeat
    NSGlobalDomain.KeyRepeat                             = 2;
    NSGlobalDomain.InitialKeyRepeat                      = 15;
    NSGlobalDomain.AppleInterfaceStyle                   = "Dark";
    NSGlobalDomain.AppleShowAllExtensions                = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled  = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled   = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled    = false;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud     = false;
    NSGlobalDomain."com.apple.swipescrolldirection"      = false;  # non-natural scroll

    # ── Trackpad ──────────────────────────────────────────────────────────────
    trackpad.Dragging              = true;
    trackpad.TrackpadThreeFingerDrag = true;

    # ── Login window ──────────────────────────────────────────────────────────
    loginwindow.GuestEnabled = false;

    # ── Application Layer Firewall (ALF) ─────────────────────────────────────
    alf.globalstate                    = 1;  # enable macOS application firewall
    alf.stealthenabled                 = 1;  # stealth mode — don't respond to pings
    alf.allowsignedenabled             = 0;  # don't auto-allow ALL signed apps
    alf.allowdownloadsignedenabled     = 0;  # don't auto-allow App Store apps

    # ── Screensaver ───────────────────────────────────────────────────────────
    screensaver.askForPassword      = 1;   # require password to unlock screensaver
    screensaver.askForPasswordDelay = 0;   # immediately (no grace period)

    # ── Spaces / Mission Control ──────────────────────────────────────────────
    spaces.spans-displays = false;

    # ── Menu bar clock ────────────────────────────────────────────────────────
    menuExtraClock.Show24Hour   = true;
    menuExtraClock.ShowSeconds  = false;

    # ── Activity Monitor ──────────────────────────────────────────────────────
    ActivityMonitor.OpenMainWindow = true;
    ActivityMonitor.IconType       = 5;   # CPU history in dock icon

    # ── Software Update ───────────────────────────────────────────────────────
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

    # ── Raw plist writes (for anything not covered by nix-darwin options) ─────
    # CustomUserPreferences."com.apple.screencapture" = {
    #   location = "/Users/${user}/Desktop/Screenshots";
    #   type     = "png";
    #   disable-shadow = true;
    # };
  };

  system.stateVersion = 6;
}
