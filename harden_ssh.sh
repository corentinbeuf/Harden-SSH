#!/bin/bash

source ./Tools/ssh_protocol.sh
source ./Tools/cryptography_authentication.sh
source ./Tools/cryptography_key_generation.sh
source ./Tools/cryptography_access_control.sh
source ./Tools/system_hardening_privilege_separtion.sh

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
            Remove-AllDSAKey
            Setup-RSAKeySize

            Setup-PermissionForPrivateKeys
            Setup-ProtectPrivateKeyUsingAESWithCBC

            Setup-PrivilegeSeparationSanboxing
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