#!/bin/sh
set -e

root_disk() {
    diskutil info -plist /
}

apfs_volumes_for() {
    disk=$1
    diskutil apfs list -plist "$disk"
}

disk_identifier() {
    xpath -e "/plist/dict/key[text()='ParentWholeDisk']/following-sibling::string[1]/text()" 2>/dev/null
}

volume_list_true() {
    key=$1 t=$2
    xpath -e "/plist/dict/array/dict/key[text()='Volumes']/following-sibling::array/dict/key[text()='$key']/following-sibling::true[1]" 2> /dev/null
}

volume_get_string() {
    key=$1 i=$2
    xpath -e "/plist/dict/array/dict/key[text()='Volumes']/following-sibling::array/dict[$i]/key[text()='$key']/following-sibling::string[1]/text()" 2> /dev/null
}

find_nix_volume() {
    disk=$1
    i=1
    volumes=$(apfs_volumes_for "$disk")
    while true; do
        name=$(echo "$volumes" | volume_get_string "Name" "$i")
        if [ -z "$name" ]; then
            break
        fi
        case "$name" in
            OneD*)
                echo "$name"
                break
                ;;
        esac
        i=$((i+1))
    done
}

test_fstab() {
    grep -q "/OneD apfs rw" /etc/fstab 2>/dev/null
}

test_nix_symlink() {
    [ -L "/OneD" ] || grep -q "^OneD." /etc/synthetic.conf 2>/dev/null
}

test_synthetic_conf() {
    grep -q "^OneD$" /etc/synthetic.conf 2>/dev/null
}

test_nix() {
    test -d "/OneD"
}

test_filevault() {
    disk=$1
    apfs_volumes_for "$disk" | volume_list_true FileVault | grep -q true || return
    ! sudo xartutil --list >/dev/null 2>/dev/null
}

main() {
    (
        echo ""
        echo "     ------------------------------------------------------------------ "
        echo "    | This installer will create a volume for the OneD store and        |"
        echo "    | configure it to mount at /OneD.  Follow these steps to uninstall. |"
        echo "     ------------------------------------------------------------------ "
        echo ""
        echo "  1. Remove the entry from fstab using 'sudo vifs'"
        echo "  2. Destroy the data volume using 'diskutil apfs deleteVolume'"
        echo "  3. Remove the 'OneD' line from /etc/synthetic.conf or the file"
        echo ""
    ) >&2

    if test_nix_symlink; then
        echo "error: /OneD is a symlink, please remove it and make sure it's not in synthetic.conf (in which case a reboot is required)" >&2
        echo "  /OneD -> $(readlink "/OneD")" >&2
        exit 2
    fi

    if ! test_synthetic_conf; then
        echo "Configuring /etc/synthetic.conf..." >&2
        echo OneD | sudo tee -a /etc/synthetic.conf
        if ! test_synthetic_conf; then
            echo "error: failed to configure synthetic.conf" >&2
            exit 1
        fi
    fi

    if ! test_nix; then
        echo "Creating mountpoint for /OneD..." >&2
        /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t || true
        if ! test_nix; then
            sudo mkdir -p /OneD 2>/dev/null || true
        fi
        if ! test_nix; then
            echo "error: failed to bootstrap /OneD, a reboot might be required" >&2
            exit 1
        fi
    fi

    disk=$(root_disk | disk_identifier)
    volume=$(find_nix_volume "$disk")
    if [ -z "$volume" ]; then
        echo "Creating a OneD volume..." >&2

        if test_filevault "$disk"; then
            echo "error: FileVault detected, refusing to create unencrypted volume" >&2
            exit 1
        fi

        sudo diskutil apfs addVolume "$disk" APFS 'OneD' -mountpoint /OneD
        volume="OneD"
    else
        echo "Using existing '$volume' volume" >&2
    fi

    if ! test_fstab; then
        echo "Configuring /etc/fstab..." >&2
        label=$(echo "$volume" | sed 's/ /\\040/g')
        printf "\$a\nLABEL=%s /OneD apfs rw,nobrowse\n.\nwq\n" "$label" | EDITOR=ed sudo vifs
    fi

    echo "" >&2
    echo "The following options can be enabled to disable spotlight indexing" >&2
    echo "of the volume, which might be desirable." >&2
    echo "" >&2
    echo "   $ sudo mdutil -i off /OneD" >&2
    echo "" >&2
}

main "$@"
