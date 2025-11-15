#!/bin/bash

function Setup-SSHProtocol ()
{
    if ! grep -Fxq "Protocol 2" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R1] : Setup SSH Protocol version${NC}"
        sed -i '/#Port 22/i Protocol 2' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}SSH Protocol version already setup${NC}"
    fi
}

function Setup-CheckAuthenticityServer ()
{
    if ! grep -Fxq "StrictHostKeyChecking ask" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R6] : The server authenticity shall always be checked prior to access. This is achieved through preliminary machine authentication by checking the server public key fingerprint, or by verifying the server certificate.${NC}"
        sed -i "s/#   StrictHostKeyChecking ask/   StrictHostKeyChecking ask/g" /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}The param to check the server authenticity is already setup${NC}"
    fi
}

function Setup-RSAKeySize ()
{
    #TODO: Get version of OpenSSH. If OpenSSH version is under v9.1, don't execute this function
    if ! grep -Fxq "StrictHostKeyChecking ask" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R8] : The minimum key size shall be 2048 bits for RSA.${NC}"
        sed -i '/#HostKey \/etc\/ssh\/ssh_host_rsa_key/i RequiredRSASize 2048' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}The minimum size of RSA key is already setup${NC}"
    fi
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Aucune couleur

PS3="Please select a task ? "
options=("Configure all tasks" "Configure a specific task" "Quitter")

select choix in "${options[@]}"; do
    case $REPLY in
        1)
            Setup-SSHProtocol

            Setup-CheckAuthenticityServer

            Setup-RSAKeySize
            ;;
        2)
            echo "..."
            ;;
        3)
            echo -e "${YELLOW}[Task] : Restart SSH service${NC}"
            sudo systemctl restart sshd
            echo "Exit"
            break
            ;;
        *)
            echo -e "${RED} Invalide option, please try again !${NC}"
            ;;
    esac
done