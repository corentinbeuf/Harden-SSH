#!/bin/bash

function Create-RevocationFile ()
{

    FILE=/etc/ssh/revoked_keys
    if ! [ -f "$FILE" ]; then
        echo -e "${GREEN}[Task R30] : If a key cannot be considered safe anymore, it shall be quickly revoked at the SSH level.${NC}"
        sudo touch "$FILE"
    else
        echo -e "${YELLOW}[Task R30] : Revocked file already exist${NC}"
    fi

    if ! grep -Fxq "RevokedKeys /etc/ssh/revoked_keys" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R30] : If a key cannot be considered safe anymore, it shall be quickly revoked at the SSH level.${NC}"
        sudo sed -i '/# Expect .ssh\/authorized_keys2 to be disregarded by default in future./i RevokedKeys /etc/ssh/revoked_keys' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R30] : Revocked file already exist${NC}"
    fi
}