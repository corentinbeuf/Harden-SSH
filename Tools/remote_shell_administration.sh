#!/bin/bash

function Get-SSHPresence() {

    if ! apt list --installed openssh-server &>/dev/null; then
        echo -e "${GREEN}[Task R2] : SSH shall be used instead of historical protocols (TELNET, RSH, RLOGIN) for remote shell access.${NC}"
        apt-get install -y openssh-server
    else
        echo -e "${YELLOW}[Task R2] : SSH Server has intalled and is in running state.${NC}"
    fi

    if ! systemctl is-active --quiet sshd &>/dev/null; then
        systemctl start sshd
    fi

    if ! systemctl is-enable --quiet sshd &>/dev/null; then
        systemctl enable sshd
    fi
}

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
            apt-get remove -y "$package" >/dev/null 2>&1
            apt-get purge -y "$package" >/dev/null 2>&1
        else
            echo -e "${YELLOW}[Task R3] : TELNET, RSH and RLOGIN has already removed.${NC}"
        fi
    done
}