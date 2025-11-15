#!/bin/bash

function Block-EmptyPassword ()
{
    if ! grep -Fxq "PermitEmptyPasswords no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P9] : Disable login without password.${NC}"
        sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P9] : The connection with empty password has already been blocked${NC}"
    fi
}