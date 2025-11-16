#!/bin/bash

function Block-PasswordForHighlyPrivilegedUsers ()
{
    if ! grep -Fxq "PasswordAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P8] : Do not use a password for privileged accounts - Other users.${NC}"
        sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P8] : Password auth has already setup for other user${NC}"
    fi

    if ! grep -Fxq "Match Group sudo" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P8] : Do not use a password for privileged accounts - Sudoers.${NC}"
        echo "Match Group sudo
    PasswordAuthentication no
    PubkeyAuthentication yes" >> /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P8] : Auth for sudoers has already setup${NC}"
    fi
}

function Remove-PAMKrb5 ()
{
    if ! grep -Fxq "KerberosAuthentication no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P8] : Do not use the PAM module 'pam_krb5' - Kerberos.${NC}"
        sed -i "s/#KerberosAuthentication no/KerberosAuthentication no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P8] : pam_krb5 module is already disabled${NC}"
    fi

    if ! grep -Fxq "GSSAPIAuthentication yes" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P8] : Do not use the PAM module 'pam_krb5' - GSSAPI.${NC}"
        sed -i "s/#GSSAPIAuthentication no/GSSAPIAuthentication yes/g" /etc/ssh/sshd_config
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