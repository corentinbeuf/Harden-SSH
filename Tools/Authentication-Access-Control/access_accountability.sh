#!/bin/bash

function Block-RootConnection ()
{
    if grep -Eq "^(#)?PermitRootLogin (yes|prohibit-password)" /etc/ssh/sshd_config; then
        echo -e "${GREEN}[Task P12] : Disable the root connection in SSH.${NC}"
        sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config
        sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P12] : Root connection has already been blocked${NC}"
    fi
}

function Set-PrintLastLogon ()
{
    if ! grep -Fxq "PrintLastLog yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P13] : Display information related to the user’s last login.${NC}"
        sed -i "s/#PrintLastLog yes/PrintLastLog yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P13] : Print last log has already been setup${NC}"
    fi
}