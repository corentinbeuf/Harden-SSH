#!/bin/bash

function Remove-OldProtocols() {

    packages_to_remove=(
        telnetd
        inetutils-telnetd
        inetutils-telnet
        rsh-server
        rsh-client
        rsh-redone-client
        rsh-redone-server
    )

    for package in "${packages_to_remove[@]}"; do
        if dpkg -l | awk '/^ii/ {print $2}' | grep -qw "$package"; then
            echo -e "${GREEN}[Task R3] : TELNET, RSH and RLOGIN remote access servers shall be uninstalled from the system.${NC}"
            apt remove -y "$package" >/dev/null 2>&1
        else
            echo -e "${YELLOW}[Task R3] : TELNET, RSH and RLOGIN has already removed.${NC}"
        fi
    done
}