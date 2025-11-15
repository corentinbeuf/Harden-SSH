#!/bin/bash

function Block-RootConnection ()
{
    if ! grep -Fxq "#PermitRootLogin no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R21] : Every user must have his own, unique, non-transferable account.${NC}"
        sed -i "s/#PermitRootLogin prohibit-password/#PermitRootLogin no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R21] : Root connection has already been blocked${NC}"
    fi
}