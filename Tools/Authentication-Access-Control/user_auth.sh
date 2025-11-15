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

function Set-LoginGraceTime ()
{
    if ! grep -Fxq "LoginGraceTime 30" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P10] : Define a time period for the authentication operation.${NC}"
        sed -i "s/#LoginGraceTime 2m/LoginGraceTime 30/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P10] : Login grace time is already setup${NC}"
    fi
}

function Set-MaxAuthTry ()
{
    if ! grep -Fxq "MaxAuthTries 2" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P11] : Limit the number of connection attempts.${NC}"
        sed -i "s/#MaxAuthTries 6/MaxAuthTries 2/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P11] : The maximum authentication test number is already configured${NC}"
    fi
}