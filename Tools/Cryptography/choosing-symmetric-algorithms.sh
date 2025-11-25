#!/bin/bash

function Setup-SymmetricAlgorithms ()
{
    version=$(ssh -V 2>&1 | awk '{print $1}' | cut -d'_' -f2)
    major=$(echo "$version" | cut -d'.' -f1)
    minor=$(echo "$version" | cut -d'.' -f2 | sed 's/[^0-9].*//')

    if ! grep -Fxq "   Ciphers aes128-ctr,aes192-ctr,aes256-ctr" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
        sudo sed -i "s/#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc/   Ciphers aes128-ctr,aes192-ctr,aes256-ctr/g" /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
    fi

    if (( major > 6 || (major == 6 && minor >= 3) )); then
        if ! grep -Fxq "   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "/etc/ssh/ssh_config"; then
            echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
            sudo sed -i "s/#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com/   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com/g" /etc/ssh/ssh_config
        else
            echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
        fi
    else
        if ! grep -Fxq "   MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1" "/etc/ssh/ssh_config"; then
            echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
            sudo sed -i "s/#   MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1/   MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1/g" /etc/ssh/ssh_config
        else
            echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
        fi
    fi

    if ! grep -Fxq "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
        sudo sed -i '/# Ciphers and keying/a Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
    fi

    if (( major > 6 || (major == 6 && minor >= 3) )); then
        if ! grep -Fxq "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "/etc/ssh/sshd_config"; then
            echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
            sudo sed -i '/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/a MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com' /etc/ssh/sshd_config
        else
            echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
        fi
    else
        if ! grep -Fxq "MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1" "/etc/ssh/sshd_config"; then
            echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
            sudo sed -i '/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/a MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1' /etc/ssh/sshd_config
        else
            echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
        fi
    fi
}