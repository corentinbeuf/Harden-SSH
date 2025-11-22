#!/bin/bash

function Setup-SymmetricAlgorithms ()
{
    if ! grep -Fxq "   Ciphers aes128-ctr,aes192-ctr,aes256-ctr" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
        sudo sed -i "s/#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc/   Ciphers aes128-ctr,aes192-ctr,aes256-ctr/g" /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
    fi

    #TODO: Get version of OpenSSH. If OpenSSH version is under v5.9, configure '   MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1'
    if ! grep -Fxq "   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
        sudo sed -i "s/#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com/   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com/g" /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
    fi

    if ! grep -Fxq "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
        sudo sed -i '/# Ciphers and keying/a Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
    fi

    #TODO: Get version of OpenSSH. If OpenSSH version is under v5.9, configure '   MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1'
    if ! grep -Fxq "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R15] : The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.${NC}"
        sudo sed -i '/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/a MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R15] : Symetric algorithms are already setup${NC}"
    fi
}