#!/bin/bash

function Get-SSHPresence() {

    if ! apt list --installed openssh-server &>/dev/null; then
        echo -e "${GREEN}[Task R2] : SSH shall be used instead of historical protocols (TELNET, RSH, RLOGIN) for remote shell access.${NC}"
        apt-get install -y openssh-server
    else
        echo -e "${YELLOW}[Task R2] : SSH Server has intalled and is in running state.${NC}"
    fi

    if ! systemctl is-active --quiet ssh &>/dev/null; then
        systemctl start sshd
    fi

    if ! systemctl is-enabled --quiet ssh &>/dev/null; then
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

function Disable-SSHTunnels ()
{
    if ! grep -Fxq "PermitTunnel no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R5] : The implementation of SSH tunnels shall only be applied to protocols that do not provide robust security mechanisms and that can benefit from it (for example: X11, VNC). This recommendation does not exempt from using additional low level security protocols, such as IPsec - Tunnel.${NC}"
        sed -i "s/#PermitTunnel no/PermitTunnel no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task RH] : SSH tunnels has already disabled${NC}"
    fi

    if ! grep -Fxq "AllowTcpForwarding no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R5] : The implementation of SSH tunnels shall only be applied to protocols that do not provide robust security mechanisms and that can benefit from it (for example: X11, VNC). This recommendation does not exempt from using additional low level security protocols, such as IPsec - TCP Forwarding.${NC}"
        sed -i "s/#AllowTcpForwarding yes/AllowTcpForwarding no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R5] : TCP forwarding has already blocked${NC}"
    fi

    if ! grep -Fxq "X11Forwarding no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R5] : The implementation of SSH tunnels shall only be applied to protocols that do not provide robust security mechanisms and that can benefit from it (for example: X11, VNC). This recommendation does not exempt from using additional low level security protocols, such as IPsec - X11 Forwarding.${NC}"
        sed -i "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R5] : X11 forwarding has already blocked${NC}"
    fi
}