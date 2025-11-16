#!/bin/bash

function Setup-PermissionForPrivateKeys ()
{
    files=("/etc/ssh/ssh_host_rsa_key" "/etc/ssh/ssh_host_ecdsa_key")

    for file in "${files[@]}";
    do
        if [ "$(stat -c "%a" $file)" -ne "600" ]; then
            echo -e "${GREEN}[Task R13] : The private key should only be known by the entity who needs to prove its identity to a third party and possibly to a trusted authority. This private key should be properly protected in order to avoid its disclosure to any unauthorized person.${NC}"
            chmod 600 "$file"
        else
            echo -e "${YELLOW}[Task R13] : The files have the correct permissions${NC}"
        fi
    done
}

function Setup-PermissionForUserPrivateKeys() 
{
    dirs=(/root/.ssh /home/*/.ssh)

    for dir in "${dirs[@]}"; do
        [ -d "$dir" ] || continue
        if [ "$(stat -c "%a" "$dir")" -ne 700 ]; then
            echo -e "${GREEN}[Task P2] : Fixing permissions for directory $dir${NC}"
            chmod 700 "$dir"
        fi

        for key in "$dir"/id_*; do
            [ -f "$key" ] || continue
            if [ "$(stat -c "%a" "$key")" -ne 600 ]; then
                echo -e "${GREEN}[Task P2] : Fixing private key permissions: $key${NC}"
                chmod 600 "$key"
            fi
        done

        echo -e "${YELLOW}[Task P2] : The files have the correct permissions${NC}"
    done
}

function Setup-ProtectPrivateKeyUsingAESWithCBC ()
{
    if ! grep -Fxq "StrictModes yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R14] : Private keys shall be password protected using AES128-CBC mode.${NC}"
        sed -i "s/#StrictModes yes/StrictModes yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R14] : Private key has already protect using AES-CBC mode${NC}"
    fi
}