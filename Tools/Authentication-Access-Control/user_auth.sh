#!/bin/bash

function Set-UserAuthMechanisms ()
{
    if ! grep -Fxq "PubkeyAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R17] : User authentication should be performed with one of the following mechanisms - Pubkey auth.${NC}"
        sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R17] : Pubkey auth has already enabled${NC}"
    fi

    if ! grep -Fxq "HostKeyAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R17] : User authentication should be performed with one of the following mechanisms - Hostkey algorithms.${NC}"
        sudo sed -i '/PubkeyAuthentication yes/a HostKeyAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R15] : Hostkey algorithms are already setup${NC}"
    fi

    if ! grep -Fxq "PubkeyAcceptedAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R17] : User authentication should be performed with one of the following mechanisms - Pubkey algorithms.${NC}"
        sudo sed -i '/HostKeyAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256/a PubkeyAcceptedAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R15] : Hostkey algorithms are already setup${NC}"
    fi

    if ! grep -Fxq "GSSAPIAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R17] : User authentication should be performed with one of the following mechanisms - GSSAPI.${NC}"
        sudo sed -i "s/#GSSAPIAuthentication no/GSSAPIAuthentication yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R17] : GSSAPI is already setup${NC}"
    fi

    if ! grep -Fxq "GSSAPICleanupCredentials yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R17] : User authentication should be performed with one of the following mechanisms - GSSAPI cleanup credentials.${NC}"
        sudo sed -i "s/#GSSAPICleanupCredentials yes/GSSAPICleanupCredentials yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R17] : GSSAPI cleanup credentiels is already setup${NC}"
    fi

    packages_to_install=(
        "krb5-user"
        "libpam-krb5"
    )

    for package in "${packages_to_install[@]}"; do
        if dpkg -l | awk '{print $2}' | grep -qi "$package"; then
            echo -e "${GREEN}[Task R17] : ${package} was installed on the server.${NC}"
            sudo apt-get install -y $package >/dev/null 2>&1
        else
            echo -e "${YELLOW}[Task R17] : Kerberos packages has already installed.${NC}"
        fi
    done

    if ! grep -Fxq "UsePAM yes" "/etc/ssh/sshd_config"; then
        echo -e "${RED}[Task R17] : Please enable PAM auth in SSHd config.${NC}"
    else
        echo -e "${YELLOW}[Task R17] : PAM auth is already enabled${NC}"
    fi
 
    if ! grep -Fxq "PasswordAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R17] : User authentication should be performed with one of the following mechanisms - Password authentication.${NC}"
        sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R17] : Password auth has already setup for other user${NC}"
    fi
}

function Block-PasswordForHighlyPrivilegedUsers ()
{
    if ! grep -Fxq "PasswordAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P7] : Do not use a password for privileged accounts - Other users.${NC}"
        sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P7] : Password auth has already setup for other user${NC}"
    fi

    # Adding this line in case the root account is used
    if ! grep -Fxq "Match User root" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P7] : Do not use a password for privileged accounts - Root.${NC}"
        sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF
Match User root
    PasswordAuthentication no
    PubkeyAuthentication yes
EOF
    else
        echo -e "${YELLOW}[Task P7] : Auth for root has already setup${NC}"
    fi

    if ! grep -Fxq "Match Group sudo" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P7] : Do not use a password for privileged accounts - Sudoers.${NC}"
        sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF
Match Group sudo
    PasswordAuthentication no
    PubkeyAuthentication yes
EOF
    else
        echo -e "${YELLOW}[Task P7] : Auth for sudoers has already setup${NC}"
    fi
}

function Remove-PAMKrb5 ()
{
    if ! grep -Fxq "KerberosAuthentication no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P8] : Do not use the PAM module 'pam_krb5' - Kerberos.${NC}"
        sudo sed -i "s/#KerberosAuthentication no/KerberosAuthentication no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P8] : pam_krb5 module is already disabled${NC}"
    fi

    if ! grep -Fxq "GSSAPIAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P8] : Do not use the PAM module 'pam_krb5' - GSSAPI.${NC}"
        sudo sed -i "s/#GSSAPIAuthentication no/GSSAPIAuthentication yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P8] : pam_krb5 module is already disabled${NC}"
    fi

    if grep -q pam_krb5 /etc/pam.d/sshd; then
        echo -e "${RED}[Task P8] pam_krb5 detected in '/etc/pam.d/sshd'. Please remove it!${NC}"
    fi
}

function Block-EmptyPassword ()
{
    if ! grep -Fxq "PermitEmptyPasswords no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P9] : Disable login without password.${NC}"
        sudo sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P9] : The connection with empty password has already been blocked${NC}"
    fi
}

function Set-LoginGraceTime ()
{
    if ! grep -Fxq "LoginGraceTime 30" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P10] : Define a time period for the authentication operation.${NC}"
        sudo sed -i "s/#LoginGraceTime 2m/LoginGraceTime 30/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P10] : Login grace time is already setup${NC}"
    fi
}

function Set-MaxAuthTry ()
{
    if ! grep -Fxq "MaxAuthTries 2" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P11] : Limit the number of connection attempts.${NC}"
        sudo sed -i "s/#MaxAuthTries 6/MaxAuthTries 2/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P11] : The maximum authentication test number is already configured${NC}"
    fi
}