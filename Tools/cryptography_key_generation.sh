#!/bin/bash

function Remove-AllDSAKey ()
{
    dsa_client_files=$(find / -type f -name "*id_rsa*" -print 2>/dev/null);
    dsa_server_files=$(find / -type f -name "*ssh_host_dsa_key*" -print 2>/dev/null);

    #Client files
    if [ -n "$dsa_client_files" ]; then
        while IFS= read -r client_file; do
            echo -e "${GREEN}[Task R7] : The use of DSA keys is not recommended - Client files.${NC}"
            rm -rf "$client_file"
        done <<< "$dsa_client_files"
    else
        echo -e "${YELLOW}[Task R7] : No file containing DSA keys was found${NC}"
    fi

    # Server files
    if [ -n "$dsa_server_files" ]; then
        while IFS= read -r server_file; do
            echo -e "${GREEN}[Task R7] : The use of DSA keys is not recommended - Server files.${NC}"
            rm -rf "$server_file"
        done <<< "$dsa_server_files"
    else
        echo -e "${YELLOW}[Task R7] : No file containing DSA keys was found${NC}"
    fi
}

function Setup-RSAKeySize ()
{
    #TODO: Get version of OpenSSH. If OpenSSH version is under v9.1, don't execute this function
    if ! grep -Fxq "RequiredRSASize 2048" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R8] : The minimum key size shall be 2048 bits for RSA.${NC}"
        sed -i '/#HostKey \/etc\/ssh\/ssh_host_rsa_key/i RequiredRSASize 2048' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R8] : The minimum size of RSA key is already setup${NC}"
    fi
}