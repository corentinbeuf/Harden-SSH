#!/bin/bash

function Block-EnvironmentModification ()
{
    if ! grep -Fxq "PermitUserEnvironment no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R23] : The ability for a user to tamper with the environment shall be denied by default. Usersupplied environment variables shall be selected on a case-by-case basis.${NC}"
        sed -i "s/#PermitUserEnvironment no/PermitUserEnvironment no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R23] : The modification of the environment has already been blocked${NC}"
    fi
}