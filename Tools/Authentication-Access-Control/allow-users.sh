#!/bin/bash

function Setup-Allowusers ()
{
    if ! grep -Fxq "#AllowUsers example@10.10.10.1" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R22] : Access to a service shall be restricted to users having a legitimate need. This restriction shall apply on a white-list basis: only explicitly allowed users shall connect to a host via SSH and possibly from specified source IP addresses.${NC}"
        sudo sed -i '/AcceptEnv LANG LC_*/a #AllowUsers example@10.10.10.1' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R22] : Allow users is already defined${NC}"
    fi
}