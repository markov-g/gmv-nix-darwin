# Routes MAS installs/upgrades during nix-darwin activation (runs as root).
#
# Detection is adaptive:
#   1. Try `mas list` — correct when Spotlight is healthy; returns Adam IDs.
#   2. If mas list returns empty, fall back to filesystem check:
#      glob match on /Applications/<name>*.app + _MASReceipt/receipt present
#      (receipt confirms MAS provenance, not just name coincidence).
#
# Keys in mas.nix should be the app's canonical short name (e.g. "Keynote").
# The glob handles regional suffixes ("Keynote Creator Studio.app" etc.).
# Exception: names that share a prefix with unrelated apps must be exact.
#
# `mas install` and `mas upgrade` run as root (need /usr/sbin/installer) with
# SUDO_UID/GID/USER set so mas can reach the user's App Store XPC services.
#
# Output goes directly to the darwin-rebuild switch terminal (synchronous).
{ pkgs, lib, config, user, host, enableMas, ... }:

let
  masApps    = import ./mas.nix { inherit host enableMas; };
  masEntries = lib.mapAttrsToList (name: id: { inherit name id; }) masApps;
  realMas    = "/Users/${user}/PACKAGEMGMT/Homebrew/bin/mas";
in
lib.mkIf (enableMas && masApps != {}) {
  homebrew.masApps = lib.mkForce {};

  system.activationScripts.postActivation.text = lib.mkAfter ''
    USER_UID=$(/usr/bin/id -u ${user} 2>/dev/null || echo "")
    USER_GID=$(/usr/bin/id -g ${user} 2>/dev/null || echo "")
    if [ -z "$USER_UID" ]; then
      echo "[mas-install] could not resolve uid for ${user} — skipping"
    elif [ ! -x "${realMas}" ]; then
      echo "[mas-install] ${realMas} not found — skipping"
    else
      echo "[mas-install] reconciling MAS apps as ${user} (uid $USER_UID)"

      export SUDO_UID="$USER_UID"
      export SUDO_GID="$USER_GID"
      export SUDO_USER="${user}"

      # Probe Spotlight via mas list.
      # Suppress warnings (stderr); capture only the ID column (stdout).
      MAS_LIST=$(${realMas} list 2>/dev/null | /usr/bin/awk '{print $1}' || true)
      if [ -n "$MAS_LIST" ]; then
        echo "[mas-install] detection: Spotlight healthy — using mas list"
      else
        echo "[mas-install] detection: mas list empty — Spotlight unavailable, using filesystem fallback"
      fi

      ${lib.concatMapStringsSep "\n" ({name, id}: ''
        INSTALLED=0

        if [ -n "$MAS_LIST" ]; then
          # Spotlight path: check Adam ID returned by mas list
          echo "$MAS_LIST" | /usr/bin/grep -q "^${toString id}$" && INSTALLED=1
        else
          # Filesystem fallback: glob match + MAS receipt confirms provenance
          for _app in "/Applications/${name}"*.app; do
            if [ -d "$_app" ] && [ -f "$_app/Contents/_MASReceipt/receipt" ]; then
              INSTALLED=1
              break
            fi
          done
        fi

        if [ "$INSTALLED" = "1" ]; then
          echo "[mas-install]   ${name}: already installed"
        else
          echo "[mas-install]   ${name} (${toString id}): not found — installing..."
          ${realMas} install ${toString id} 2>&1 \
            || echo "[mas-install]   ${name}: install failed (may need 'Get' from App Store GUI first)"
        fi
      '') masEntries}

      if [ -n "$MAS_LIST" ]; then
        echo "[mas-install] upgrading outdated MAS apps..."
        ${realMas} upgrade 2>&1 \
          || echo "[mas-install] upgrade pass had errors"
      else
        echo "[mas-install] skipping upgrade — Spotlight unavailable (App Store auto-updates handle this)"
      fi
    fi
  '';
}
