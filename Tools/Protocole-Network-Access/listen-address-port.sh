#!/bin/bash

function Set-SSHPort ()
{
    if ! grep -Fxq "Port 26" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R26] : When the SSH server is exposed to an uncontrolled network, one should change its listening port (22). Preference should be given to privileged ports (below 1024).${NC}"
        sed -i "s/#Port 22/Port 26/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R26] : The SSH port has already changed${NC}"
    fi
}