#!/bin/bash

source ./Tools/ssh_protocol.sh
source ./Tools/Cryptography/authentication.sh
source ./Tools/Cryptography/key_generation.sh
source ./Tools/Cryptography/access_control.sh
source ./Tools/System-Hardening/privilege_separation.sh
source ./Tools/Authentication-Access-Control/user_auth.sh

function CheckRequirements ()
{
    if ! apt list --installed sudo &>/dev/null; then
        echo -e "${RED} Sudo is not installed on the server, please install it !${NC}"
        exit 1
    fi

    if [ "$(whoami)" = "root" ]; then
        echo -e "${RED} You are logged in as root, please log in with a user with sudo rights !${NC}"
        exit 1
    fi

    if ! groups "$USER" | grep -qw "sudo"; then
        echo -e "${RED} You do not have sudo rights, please add sudo rights to this user. !${NC}"
        exit 1
    fi    
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Aucune couleur

CheckRequirements

PS3="Please select a task ? "
options=("Configure all tasks" "Configure a specific task" "Quitter")

select choix in "${options[@]}"; do
    case $REPLY in
        1)
            Setup-SSHProtocol

            Setup-CheckAuthenticityServer
            Remove-AllDSAKey
            Setup-RSAKeySize

            Setup-PermissionForPrivateKeys
            Setup-ProtectPrivateKeyUsingAESWithCBC

            Block-RootConnection

            Setup-PrivilegeSeparationSanboxing

            Block-EmptyPassword
            Set-LoginGraceTime
            Set-MaxAuthTry
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
            echo -e "${RED} Invalid option, please try again !${NC}"
            ;;
    esac
done