# Routes MAS installs/upgrades via mas 4.0+'s sudo flow.
# We're already root via darwin-rebuild's outer sudo, so we set SUDO_UID/USER/GID
# manually to mimic `sudo mas install` being run from the user's terminal.
{ pkgs, lib, config, user, host, enableMas, ... }:

let
  masApps = import ./mas.nix { inherit host enableMas; };
  masIds = lib.attrValues masApps;
  realMas = "/Users/${user}/PACKAGEMGMT/Homebrew/bin/mas";
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

      INSTALLED=$(${realMas} list 2>/dev/null | /usr/bin/awk '{print $1}' || true)
      ${lib.concatMapStringsSep "\n" (id: ''
        if echo "$INSTALLED" | /usr/bin/grep -q "^${toString id}$"; then
          echo "[mas-install]   ${toString id}: already installed"
        else
          echo "[mas-install]   ${toString id}: installing..."
          ${realMas} install ${toString id} 2>&1 \
            || echo "[mas-install]   ${toString id}: install failed"
        fi
      '') masIds}

      echo "[mas-install] upgrading outdated MAS apps..."
      ${realMas} upgrade 2>&1 \
        || echo "[mas-install] upgrade pass had errors"
    fi
  '';
}