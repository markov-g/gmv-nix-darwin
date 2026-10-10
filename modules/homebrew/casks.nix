# Called as: import ./homebrew/casks.nix { inherit host; }
# Returns the merged cask list for that machine: shared ++ hostSpecific ++ engram
{ host }:

let
  # ── Engram (local-only memory MCP server) ─────────────────────────────────
  # Only on hosts listed in engram-hosts.nix -- see that file for why this is
  # gated rather than shared. Kept as its own list (not folded into
  # hostSpecific) so one shared engram-hosts.nix stays the single source of
  # truth across flake.nix (tap), here (cask), homebrew.nix (trust reminder),
  # and opencode.jsonc (MCP block) -- add/remove a host in one place only.
  engramHosts = import ../engram-hosts.nix;
  engramCasks =
    if builtins.elem host engramHosts
    then [ { name = "gentleman-programming/tap/engram"; greedy = true; } ]
    else [ ];
  # ── Shared casks — installed on every machine ─────────────────────────────
  shared = [
    { name = "1password-cli"; greedy = true; }
    { name = "1password"; greedy = true; }
    { name = "brave-browser"; greedy = true; }
    { name = "carbon-copy-cloner"; greedy = true; }
    { name = "chatgpt"; greedy = true; }
    { name = "claude"; greedy = true; }    
    { name = "codex"; greedy = true; }
    { name = "devpod"; greedy = true; }
    # { name = "container"; greedy = true; }
    { name = "font-fira-code"; greedy = true; }
    { name = "font-fira-code-nerd-font"; greedy = true; }
    { name = "font-hack-nerd-font"; greedy = true; }
    { name = "font-source-code-pro"; greedy = true; }
    { name = "google-gemini"; greedy = true; }
    { name = "iterm2"; greedy = true; }
    { name = "jetbrains-toolbox"; greedy = true; }
    { name = "jordanbaird-ice"; greedy = true; }
    { name = "microsoft-edge"; greedy = true; }
    { name = "murus"; greedy = true; }
    { name = "obsidian"; greedy = true; }
    { name = "opencode-desktop"; greedy = true; }
    { name = "opensc-app"; greedy = true; }
    { name = "openvpn-connect"; greedy = true; }
    { name = "orbstack"; greedy = true; }
    { name = "orion"; greedy = true; }
    { name = "podman-desktop"; greedy = true; }
    { name = "terminal-browser"; greedy = true; } # zenbu-labs/terminal-browser -- see terminal-browser skill
    { name = "visual-studio-code"; greedy = true; }
    { name = "xquartz"; greedy = true; }
    { name = "xtool-org/tap/xtool"; greedy = true; }
    # Terminal for agent-driven development. Human-interactive use only --
    # NOT wired into oh-my-opencode-slim's multiplexer config (Herdr stays
    # the subagent-pane backend). See opencode.jsonc/oh-my-opencode-slim.jsonc.
    { name = "zentty"; greedy = true; }
  ];

  # ── Per-host casks — merged with shared above ─────────────────────────────
  # Add a new host key when you add a machine to darwinConfigurations.
  # Omitting a host key is fine — it gets shared only.
  hostSpecific = {
    "r1pp3r" = [
      { name = "devonthink"; greedy = true; }
      # { name = "github-copilot-for-xcode"; greedy = true; }
      { name = "ledger-wallet"; greedy = true; }
      { name = "multipass"; greedy = true; }
      { name = "path-finder"; greedy = true; }
      { name = "proton-mail-bridge"; greedy = true; }
      { name = "replit"; greedy = true; }
      { name = "thinkorswim"; greedy = true; }
      { name = "tradingview"; greedy = true; }

      # ── Security & Privacy (Objective-See + others) — on every machine ──────
      { name = "blockblock"; greedy = true; } # persistence monitor
      { name = "gpg-suite"; greedy = true; } # GPG encryption
      { name = "knockknock"; greedy = true; } # persistent-software scanner
      { name = "lulu"; greedy = true; } # outgoing firewall
      { name = "malwarebytes"; greedy = true; } # on-demand malware scanner
      { name = "oversight"; greedy = true; } # mic/camera alerts
      { name = "protonvpn"; greedy = true; } # VPN
      { name = "reikey"; greedy = true; } # keylogger guard
      { name = "signal"; greedy = true; } # E2EE messaging
    ];

    "SE1FXHLQH3MTP" = [
      { name = "blockblock"; greedy = true; } # persistence monitor
      { name = "freelens"; greedy = true; }
      { name = "knockknock"; greedy = true; } # persistent-software scanner
      { name = "lulu"; greedy = true; } # outgoing firewall
      { name = "multipass"; greedy = true; }
      { name = "mindmac"; greedy = true; }
      { name = "oversight"; greedy = true; } # mic/camera alerts
      { name = "path-finder"; greedy = true; }
      { name = "proton-mail-bridge"; greedy = true; }
      { name = "reikey"; greedy = true; } # keylogger guard
      { name = "thinkorswim"; greedy = true; }
      { name = "tradingview"; greedy = true; }
    ];

    "SE1L649RJQC4F" = [
      { name = "blockblock"; greedy = true; } # persistence monitor
      { name = "knockknock"; greedy = true; } # persistent-software scanner
      { name = "lulu"; greedy = true; } # outgoing firewall
      { name = "multipass"; greedy = true; }
      { name = "mindmac"; greedy = true; }
      { name = "oversight"; greedy = true; } # mic/camera alerts
      { name = "path-finder"; greedy = true; }
      { name = "proton-mail-bridge"; greedy = true; }
      { name = "reikey"; greedy = true; } # keylogger guard
      { name = "thinkorswim"; greedy = true; }
      { name = "tradingview"; greedy = true; }
    ];

    "minidevbox" = [
      { name = "aionui"; greedy = true; }
      { name = "claude-code"; greedy = true; }
      { name = "chatgpt"; greedy = true; }
      { name = "codex"; greedy = true; }
      { name = "freelens"; greedy = true; }
      { name = "freetube"; greedy = true; }
      { name = "github"; greedy = true; }
      # { name = "ledger-wallet"; greedy = true; }
      { name = "lm-studio"; greedy = true; }
      { name = "multipass"; greedy = true; }
      { name = "proton-mail-bridge"; greedy = true; }
      { name = "replit"; greedy = true; }
      { name = "thinkorswim"; greedy = true; }
      { name = "tradingview"; greedy = true; }

      # ── Security & Privacy (Objective-See + others) — on every machine ──────
      { name = "blockblock"; greedy = true; } # persistence monitor
      { name = "gpg-suite"; greedy = true; } # GPG encryption
      { name = "knockknock"; greedy = true; } # persistent-software scanner
      { name = "lulu"; greedy = true; } # outgoing firewall
      { name = "malwarebytes"; greedy = true; } # on-demand malware scanner
      { name = "oversight"; greedy = true; } # mic/camera alerts
      { name = "protonvpn"; greedy = true; } # VPN
      { name = "reikey"; greedy = true; } # keylogger guard
      { name = "signal"; greedy = true; } # E2EE messaging
    ];

    "minidevboxvm" = [
      # lightweight — no heavy GUI apps in a VM
    ];

    "openclaw" = [
      { name = "claude-code"; greedy = true; }
      { name = "chatgpt"; greedy = true; }
      { name = "codex"; greedy = true; }
      { name = "freelens"; greedy = true; }
      { name = "freetube"; greedy = true; }
      { name = "github"; greedy = true; }
      # { name = "ledger-wallet"; greedy = true; }
      { name = "lm-studio"; greedy = true; }

      # ── Security & Privacy (Objective-See + others) — on every machine ──────
      { name = "blockblock"; greedy = true; } # persistence monitor
      { name = "gpg-suite"; greedy = true; } # GPG encryption
      { name = "knockknock"; greedy = true; } # persistent-software scanner
      { name = "lulu"; greedy = true; } # outgoing firewall
      { name = "malwarebytes"; greedy = true; } # on-demand malware scanner
      { name = "oversight"; greedy = true; } # mic/camera alerts
      { name = "protonvpn"; greedy = true; } # VPN
      { name = "reikey"; greedy = true; } # keylogger guard
      { name = "signal"; greedy = true; } # E2EE messaging
    ];
  };

in
shared ++ (hostSpecific.${host} or [ ]) ++ engramCasks
