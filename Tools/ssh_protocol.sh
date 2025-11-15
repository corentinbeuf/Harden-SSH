#!/bin/bash

function Setup-SSHProtocol ()
{
    if ! grep -Fxq "Protocol 2" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R1] : Setup SSH Protocol version${NC}"
        sed -i '/#Port 22/i Protocol 2' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R1] : SSH Protocol version already setup${NC}"
    fi
}