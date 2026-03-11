function proxy_on() {
    set -x
    # Uncomment to set a specific proxy host and port
    # local FIXED_PROXY="de.coia.siemens.net:9400"

    local proxy_settings=$(scutil --proxy)
    if [ -z ${FIXED_PROXY} ]; then
        local proxy_host=$(echo "${proxy_settings}" | awk '/HTTPProxy/ {print $3}')
        local proxy_port=$(echo "${proxy_settings}" | awk '/HTTPPort/ {print $3}')
        if [ ! -z ${proxy_host} -a ! -z ${proxy_port} ]; then
            local proxy="${proxy_host}:${proxy_port}"
        fi
    else
        local proxy=${FIXED_PROXY}
    fi
    if [ ! -z ${proxy} ]; then
        proxy="http://${proxy}"
        export http_proxy=${proxy}
        export https_proxy=${proxy}
        export ftp_proxy=${proxy}
        export all_proxy=${proxy}
        export HTTP_PROXY=${proxy}
        export HTTPS_PROXY=${proxy}
        export FTP_PROXY=${proxy}
        export ALL_PROXY=${proxy}
        export no_proxy=$(echo "${proxy_settings}" | perl -n -e '/^\s+\d+ : (.+)/ and print "$1,"' | sed 's/,$//')
        export NO_PROXY=${no_proxy}
        export ssh_no_proxy=$(echo "${proxy_settings}" | perl -n -e '/^\s+\d+ : (.+)/ and print "$1\$|"' | sed 's/|$//')
    fi
    set +x
}

function proxy_off() {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset all_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset FTP_PROXY
    unset ALL_PROXY
    unset no_proxy
    unset NO_PROXY
    unset ssh_no_proxy
}

function proxy_auto() {
    local proxy_settings=$(scutil --proxy)
    if echo "${proxy_settings}" | grep -q "HTTPEnable : 1"; then
        proxy_on
    else
        proxy_off
    fi
}

proxy_auto
