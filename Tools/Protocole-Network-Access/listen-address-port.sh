#!/bin/bash

function Set-ManagementIPAddress ()
{
    ADMINISTRATIVE_IP="$(hostname -I | awk '{print $2}')"

    if ! grep -Fxq "ListenAddress ${ADMINISTRATIVE_IP}" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R25] : The SSH server shall only listen on the administration network.${NC}"
        sudo sed -i "s/#ListenAddress 0.0.0.0/ListenAddress ${ADMINISTRATIVE_IP}/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R25] : Management IP address is already defined${NC}"
    fi
}

function Set-SSHPort ()
{
    if ! grep -Fxq "Port 26" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R26] : When the SSH server is exposed to an uncontrolled network, one should change its listening port (22). Preference should be given to privileged ports (below 1024).${NC}"
        sudo sed -i "s/#Port 22/Port 26/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R26] : The SSH port has already changed${NC}"
    fi
}