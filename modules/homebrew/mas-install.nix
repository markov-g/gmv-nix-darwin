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
      export MAS_NO_AUTO_INDEX=1

      echo "[mas-install] DEBUG whoami=$(whoami)"
      echo "[mas-install] DEBUG SUDO_UID=$SUDO_UID SUDO_GID=$SUDO_GID SUDO_USER=$SUDO_USER"
      echo "[mas-install] DEBUG HOME=${"\${HOME:-unset}"} PATH=${"\${PATH:-unset}"}"
      echo "[mas-install] DEBUG mas version=$(${realMas} version 2>&1 || true)"

      MAS_LIST_OUTPUT=$(${realMas} list 2>&1)
      MAS_LIST_STATUS=$?
      echo "[mas-install] DEBUG mas list exit=$MAS_LIST_STATUS"
      echo "[mas-install] DEBUG mas list output BEGIN"
      echo "$MAS_LIST_OUTPUT"
      echo "[mas-install] DEBUG mas list output END"

      INSTALLED=$(printf '%s\n' "$MAS_LIST_OUTPUT" | /usr/bin/awk '/^[[:space:]]*[0-9]+[[:space:]]/ { print $1 }' || true)
      echo "[mas-install] DEBUG installed ids BEGIN"
      printf '%s\n' "$INSTALLED"
      echo "[mas-install] DEBUG installed ids END"

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