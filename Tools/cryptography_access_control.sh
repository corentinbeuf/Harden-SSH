#!/bin/bash

function Setup-PermissionForPrivateKeys ()
{
    files=("/etc/ssh/ssh_host_rsa_key" "/etc/ssh/ssh_host_ecdsa_key")

    for file in "${files[@]}";
    do
        if [ "$(stat -c "%a" $file)" -ne "600" ]; then
            echo -e "${YELLOW}[Task R13] : The private key should only be known by the entity who needs to prove its identity to a third party and possibly to a trusted authority. This private key should be properly protected in order to avoid its disclosure to any unauthorized person.${NC}"
            chmod 600 "$file"
        else
            echo -e "${YELLOW}[Task R13] : The files have the correct permissions${NC}"
        fi
    done
}