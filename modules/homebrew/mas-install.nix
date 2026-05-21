# Routes MAS installs/upgrades via a user LaunchAgent so mas runs in the
# user's own session, where Spotlight is indexed and `mas list` works.
#
# The activation script only kicks the agent; the agent does the actual work.
# Each run writes a timestamped log; /tmp/mas-install-latest.log is a symlink
# to the most recent one. Tail that after darwin-rebuild switch.
{ pkgs, lib, config, user, host, enableMas, ... }:

let
  masApps    = import ./mas.nix { inherit host enableMas; };
  masEntries = lib.mapAttrsToList (name: id: { inherit name id; }) masApps;
  realMas    = "/Users/${user}/PACKAGEMGMT/Homebrew/bin/mas";
  latestLog  = "/tmp/mas-install-latest.log";
  agentId    = "com.${user}.mas-install";
in
lib.mkIf (enableMas && masApps != {}) {
  homebrew.masApps = lib.mkForce {};

  # ── LaunchAgent (runs in user session — Spotlight works here) ────────────
  home-manager.users.${user}.launchd.agents.${agentId} = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          # Each run gets its own timestamped log file.
          RUNLOG="/tmp/mas-install-$(date +%Y%m%d-%H%M%S).log"
          exec > "$RUNLOG" 2>&1
          ln -sf "$RUNLOG" ${latestLog}

          echo "=== mas-install run started at $(date) ==="
          echo ""
          echo "[DEBUG] user identity  : $(id)"
          echo "[DEBUG] HOME           : $HOME"
          echo "[DEBUG] mas binary     : ${realMas}"

          if [ ! -x "${realMas}" ]; then
            echo "[ERROR] mas binary not found or not executable — aborting"
            exit 1
          fi

          echo "[DEBUG] mas version    : $(${realMas} version 2>&1)"
          echo "[DEBUG] spotlight /    : $(/usr/bin/mdutil -s / 2>/dev/null | /usr/bin/tr -d '\n' || echo unknown)"
          echo ""
          echo "[DEBUG] agent plist    : /Users/${user}/Library/LaunchAgents/${agentId}.plist"
          echo "[DEBUG] kick manually  : launchctl kickstart -k gui/$(id -u)/${agentId}"
          echo "[DEBUG] unload agent   : launchctl bootout gui/$(id -u) /Users/${user}/Library/LaunchAgents/${agentId}.plist"
          echo "[DEBUG] remove cleanly : remove ${agentId} from mas-install.nix and run darwin-rebuild switch"
          echo "[DEBUG] past logs      : ls -lt /tmp/mas-install-*.log"
          echo ""

          echo "--- mas list (raw output) ---"
          ${realMas} list 2>&1 || true
          echo "--- end mas list ---"
          echo ""

          INSTALLED=$(${realMas} list 2>/dev/null | /usr/bin/awk '{print $1}' || true)
          INSTALLED_COUNT=$(echo "$INSTALLED" | /usr/bin/grep -c '[0-9]' 2>/dev/null || echo 0)
          echo "[DEBUG] detected $INSTALLED_COUNT installed MAS app(s)"
          echo "[DEBUG] ${toString (builtins.length masEntries)} app(s) declared for this host"
          echo ""

          echo "--- reconcile ---"
          ${lib.concatMapStringsSep "\n" ({name, id}: ''
            echo "[mas-install] ${name} (${toString id})"
            if echo "$INSTALLED" | /usr/bin/grep -q "^${toString id}$"; then
              echo "              -> already installed, skipping"
            else
              echo "              -> not in mas list, installing..."
              ${realMas} install ${toString id} 2>&1 \
                || echo "              -> install failed (may need 'Get' from App Store GUI first)"
            fi
          '') masEntries}
          echo "--- end reconcile ---"
          echo ""

          echo "--- upgrade pass ---"
          ${realMas} upgrade 2>&1 \
            || echo "[WARN] upgrade pass had errors"
          echo "--- end upgrade pass ---"
          echo ""
          echo "=== mas-install done at $(date) ==="
        ''
      ];
      RunAtLoad = false;
    };
  };

  # ── Activation: kick the agent immediately after rebuild ─────────────────
  system.activationScripts.postActivation.text = lib.mkAfter ''
    USER_UID=$(/usr/bin/id -u ${user} 2>/dev/null || echo "")
    if [ -z "$USER_UID" ]; then
      echo "[mas-install] could not resolve uid for ${user} — skipping"
    elif [ ! -x "${realMas}" ]; then
      echo "[mas-install] ${realMas} not found — skipping"
    else
      echo "[mas-install] kicking agent for ${user} (uid $USER_UID)"
      echo "[mas-install] monitor: tail -f ${latestLog}"
      /bin/launchctl kickstart -k "gui/$USER_UID/${agentId}" 2>/dev/null \
        || echo "[mas-install] agent not loaded yet — will run at next login"
    fi
  '';
}
