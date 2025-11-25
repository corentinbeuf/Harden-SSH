#!/bin/bash

function Remove-AllDSAKey ()
{
    dsa_client_files=$(find / -type f -name "*id_dsa*" -print 2>/dev/null);
    dsa_server_files=$(find / -type f -name "*ssh_host_dsa_key*" -print 2>/dev/null);

    #Client files
    if [ -n "$dsa_client_files" ]; then
        while IFS= read -r client_file; do
            echo -e "${GREEN}[Task R7] : The use of DSA keys is not recommended - Client files.${NC}"
            sudo rm -rf "$client_file"
        done <<< "$dsa_client_files"
    else
        echo -e "${YELLOW}[Task R7] : No file containing DSA keys was found${NC}"
    fi

    # Server files
    if [ -n "$dsa_server_files" ]; then
        while IFS= read -r server_file; do
            echo -e "${GREEN}[Task R7] : The use of DSA keys is not recommended - Server files.${NC}"
            sudo rm -rf "$server_file"
        done <<< "$dsa_server_files"
    else
        echo -e "${YELLOW}[Task R7] : No file containing DSA keys was found${NC}"
    fi
}

function Setup-RSAKeySize ()
{
    version=$(ssh -V 2>&1 | awk '{print $1}' | cut -d'_' -f2)
    major=$(echo "$version" | cut -d'.' -f1)
    minor=$(echo "$version" | cut -d'.' -f2 | sed 's/[^0-9].*//')

    if (( major > 9 || (major == 9 && minor >= 1) )); then
        if ! grep -Fxq "RequiredRSASize 2048" "/etc/ssh/sshd_config"; then
            echo -e "${GREEN}[Task R8] : The minimum key size shall be 2048 bits for RSA.${NC}"
            sudo sed -i '/#HostKey \/etc\/ssh\/ssh_host_rsa_key/i RequiredRSASize 2048' /etc/ssh/sshd_config
        else
            echo -e "${YELLOW}[Task R8] : The minimum size of RSA key is already setup${NC}"
        fi
    else
        echo -e "${RED}[Task R8] : The version of OpenSSh is too old for this parameter${NC}"
    fi
}

function Check-ECDSAKeySize() {
    for key in /root/.ssh/id_ecdsa /home/*/.ssh/id_ecdsa; do
        [ -f "$key" ] || continue
        key_size=$(ssh-keygen -lf "$key" | awk '{print $1}')
        if (( key_size < 256 )); then
            echo -e "${RED}[Task R9] : Key $key is too small. Please generate new key with this command : ssh-keygen -t ecdsa -b 256"
        else
            echo -e "${YELLOW}[Task R9] : The minimum size of the key '$key' is sufficient"
        fi
    done
}

function Check-KeyLifetime ()
{
    for dir in /root/.ssh /home/*/.ssh; do
        if [ -d "$dir" ]; then
            if find "$dir" -type f -mtime +1095 | grep -q .; then
                echo "${YELLOW}SSH key are more than 3 years : $dir ${NC}"
            else
                echo -e "${YELLOW}[Task P1] : Your SSH keys has less than 3 years${NC}"
            fi
        fi
    done
}

function Check-RSAKeyPresence ()
{
    rsa_files=$(find / -type f -name "*id_rsa*" -print 2>/dev/null);

    #Client files
    if [ -n "$rsa_files" ]; then
        while IFS= read -r file; do
            echo -e "${GREEN}[Task R10] : ECDSA keys should be favoured over RSA keys when supported by SSH clients and servers.${NC}"
            sudo rm -rf "$file"
        done <<< "$rsa_files"
    else
        echo -e "${YELLOW}[Task R10] : No RSA keys was found${NC}"
    fi
}