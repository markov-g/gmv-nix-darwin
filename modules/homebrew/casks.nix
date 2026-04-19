# Called as: import ./homebrew/casks.nix { inherit host; }
# Returns the merged cask list for that machine: shared ++ hostSpecific
{ host }:

let
  # ── Shared casks — installed on every machine ─────────────────────────────
  shared = [
    { name = "brave-browser";             greedy = true; }
    { name = "carbon-copy-cloner";        greedy = true; }
    { name = "claude";                    greedy = true; }
#    { name = "container";                 greedy = true; }  
    { name = "font-fira-code";            greedy = true; }
    { name = "font-fira-code-nerd-font";  greedy = true; }
    { name = "font-hack-nerd-font";       greedy = true; }
    { name = "font-source-code-pro";      greedy = true; }
    { name = "iterm2";                    greedy = true; }
    { name = "jetbrains-toolbox";         greedy = true; }    
    { name = "jordanbaird-ice";           greedy = true; }
    { name = "microsoft-edge";            greedy = true; }    
    { name = "murus";                     greedy = true; }
    { name = "opensc-app";                greedy = true; }
    { name = "openvpn-connect";           greedy = true; }    
    { name = "orbstack";                  greedy = true; }
    { name = "orion";                     greedy = true; }
    { name = "podman-desktop";            greedy = true; }
    { name = "visual-studio-code";        greedy = true; }
    { name = "xquartz";                   greedy = true; }
    { name = "xtool-org/tap/xtool";       greedy = true; }        
  ];

  # ── Per-host casks — merged with shared above ─────────────────────────────
  # Add a new host key when you add a machine to darwinConfigurations.
  # Omitting a host key is fine — it gets shared only.
  hostSpecific = {
    "r1pp3r" = [
      { name = "devonthink";                greedy = true; }
      # { name = "github-copilot-for-xcode";  greedy = true; }      
      { name = "ledger-wallet";             greedy = true; }  
      { name = "multipass";                 greedy = true; }          
      { name = "path-finder";               greedy = true; }
      { name = "proton-mail-bridge";        greedy = true; }
      { name = "replit";                    greedy = true; }
      { name = "thinkorswim";               greedy = true; }
      { name = "tradingview";               greedy = true; }   

      # ── Security & Privacy (Objective-See + others) — on every machine ──────
      { name = "blockblock";                greedy = true; }   # persistence monitor
      { name = "gpg-suite";                 greedy = true; }   # GPG encryption
      { name = "knockknock";                greedy = true; }   # persistent-software scanner
      { name = "lulu";                      greedy = true; }   # outgoing firewall
      { name = "malwarebytes";              greedy = true; }   # on-demand malware scanner
      { name = "oversight";                 greedy = true; }   # mic/camera alerts
      { name = "protonvpn";                 greedy = true; }   # VPN
      { name = "reikey";                    greedy = true; }   # keylogger guard
      { name = "signal";                    greedy = true; }   # E2EE messaging   
    ];

    "SE1FXHLQH3MTP" = [
      { name = "multipass";                 greedy = true; }    
    ];

    "minidevbox" = [
      { name = "claude-code";               greedy = true; }
      { name = "chatgpt";                   greedy = true; }
      { name = "codex";                     greedy = true; }
      { name = "freelens";                  greedy = true; }
      { name = "freetube";                  greedy = true; }      
      { name = "github";                    greedy = true; }
      # { name = "ledger-wallet";             greedy = true; }
      { name = "lm-studio";                 greedy = true; }
      { name = "multipass";                 greedy = true; }
      { name = "proton-mail-bridge";        greedy = true; }
      { name = "replit";                    greedy = true; }
      { name = "thinkorswim";               greedy = true; }
      { name = "tradingview";               greedy = true; }

      # ── Security & Privacy (Objective-See + others) — on every machine ──────
      { name = "blockblock";                greedy = true; }   # persistence monitor
      { name = "gpg-suite";                 greedy = true; }   # GPG encryption
      { name = "knockknock";                greedy = true; }   # persistent-software scanner
      { name = "lulu";                      greedy = true; }   # outgoing firewall
      { name = "malwarebytes";              greedy = true; }   # on-demand malware scanner
      { name = "oversight";                 greedy = true; }   # mic/camera alerts
      { name = "protonvpn";                 greedy = true; }   # VPN
      { name = "reikey";                    greedy = true; }   # keylogger guard
      { name = "signal";                    greedy = true; }   # E2EE messaging   
    ];

    "minidevboxvm" = [
      # lightweight — no heavy GUI apps in a VM
    ];

    "openclaw" = [
      { name = "claude-code";               greedy = true; }
      { name = "chatgpt";                   greedy = true; }
      { name = "codex";                     greedy = true; }
      { name = "freelens";                  greedy = true; }
      { name = "freetube";                  greedy = true; }      
      { name = "github";                    greedy = true; }
      # { name = "ledger-wallet";             greedy = true; }
      { name = "lm-studio";                 greedy = true; }
      
      # ── Security & Privacy (Objective-See + others) — on every machine ──────
      { name = "blockblock";                greedy = true; }   # persistence monitor
      { name = "gpg-suite";                 greedy = true; }   # GPG encryption
      { name = "knockknock";                greedy = true; }   # persistent-software scanner
      { name = "lulu";                      greedy = true; }   # outgoing firewall
      { name = "malwarebytes";              greedy = true; }   # on-demand malware scanner
      { name = "oversight";                 greedy = true; }   # mic/camera alerts
      { name = "protonvpn";                 greedy = true; }   # VPN
      { name = "reikey";                    greedy = true; }   # keylogger guard
      { name = "signal";                    greedy = true; }   # E2EE messaging   
    ];
  };

in
  shared ++ (hostSpecific.${host} or [])

# # Plain Nix list – GUI apps
# [
#   { name = "brave-browser";             greedy = true; }
#   { name = "claude";                    greedy = true; }
#   { name = "claude-code";               greedy = true; } 
# # { name = "chatbox";                   greedy = true; } 
#   { name = "chatgpt";                   greedy = true; }  
#   { name = "codex";                     greedy = true; }
#   { name = "devonthink";                greedy = true; }
#   { name = "font-fira-code";            greedy = true; }
#   { name = "font-fira-code-nerd-font";  greedy = true; }
#   { name = "font-hack-nerd-font";       greedy = true; }
#   { name = "font-source-code-pro";      greedy = true; }
#   { name = "freelens";                  greedy = true; }
#   { name = "freetube";                  greedy = true; }
#   { name = "github"; 			              greedy = true; }
#   { name = "github-copilot-for-xcode";  greedy = true; }
#   { name = "iterm2";                    greedy = true; }
#   { name = "jetbrains-toolbox";         greedy = true; }
#   { name = "jordanbaird-ice";           greedy = true; }
#   #{ name = "ledger-wallet";             greedy = true; }
#   { name = "lm-studio";                 greedy = true; }
#   # ── Security & Privacy (Objective-See + others) ──────────────────────────
#   { name = "blockblock";                greedy = true; }   # persistence monitor (LaunchAgents/Daemons)
#   { name = "gpg-suite";                 greedy = true; }   # GPG encryption + key management
#   { name = "knockknock";                greedy = true; }   # on-demand persistent-software scanner
#   { name = "lulu";                      greedy = true; }   # outgoing firewall (already present)
#   { name = "microsoft-edge";            greedy = true; }
#   { name = "multipass";                 greedy = true; }
#   { name = "malwarebytes";              greedy = true; }   # on-demand malware scanner
#   { name = "murus";                     greedy = true; }
#   { name = "opensc-app";                greedy = true; }
#   { name = "openvpn-connect";           greedy = true; }  
#   { name = "orbstack";                  greedy = true; }
#   { name = "orion";                     greedy = true; }
#   { name = "path-finder";               greedy = true; }  
#   { name = "podman-desktop";            greedy = true; }  
#   { name = "oversight";                 greedy = true; }   # mic/camera activation alerts
#   { name = "proton-mail-bridge";        greedy = true; }
#   { name = "protonvpn";                 greedy = true; }   # VPN (free tier, no-log)
#   { name = "reikey";                    greedy = true; }   # keyboard event tap detector (keylogger guard)
#   { name = "replit";                    greedy = true; }
#   { name = "thinkorswim";               greedy = true; }
#   { name = "signal";                    greedy = true; }   # E2EE messaging
#   { name = "tradingview";               greedy = true; }
#   { name = "visual-studio-code";        greedy = true; }
#   { name = "xquartz";                   greedy = true; }
#   { name = "xtool-org/tap/xtool";       greedy = true; }
# ]
