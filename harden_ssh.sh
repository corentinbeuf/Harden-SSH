#!/bin/bash

chmod +x Menu/detailed_menu.sh
chmod +x Audit/audit_sshd_config.sh
chmod +x Audit/audit_ssh_config.sh

source ./Tools/ssh_protocol.sh
source ./Tools/remote_shell_administration.sh
source ./Tools/Cryptography/authentication.sh
source ./Tools/Cryptography/key_generation.sh
source ./Tools/Cryptography/access_control.sh
source ./Tools/Cryptography/choosing-symmetric-algorithms.sh
source ./Tools/System-Hardening/hardening-compilation.sh
source ./Tools/System-Hardening/privilege_separation.sh
source ./Tools/System-Hardening/sftp-chroot.sh
source ./Tools/Authentication-Access-Control/user_auth.sh
source ./Tools/Authentication-Access-Control/agent_auth.sh
source ./Tools/Authentication-Access-Control/access_accountability.sh
source ./Tools/Authentication-Access-Control/allow-users.sh
source ./Tools/Authentication-Access-Control/restrictions_of_the_user_environment.sh
source ./Tools/Protocole-Network-Access/listen-address-port.sh
source ./Tools/Protocole-Network-Access/tcp-forwarding.sh
source ./Tools/Protocole-Network-Access/x11-forwarding.sh
source ./Tools/OpenSSH-PKI/revocation.sh
source ./Tools/DNS-Record/dns-record.sh

function CheckRequirements ()
{
    if [ "$(lsb_release -si)" = "Debian" ] || [ "$(lsb_release -si)" = "Ubuntu" ]; then
        echo -e ""
    else
        echo -e "${RED} This script is created to run only on Debian or Ubuntu !${NC}"
        exit 1
    fi

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
options=("Audit" "Configure all tasks" "Configure a specific task" "Quit")

select choix in "${options[@]}"; do
    case $REPLY in
        1)
            ;;
        2)
            Setup-SSHProtocol #R1
            Get-SSHPresence #R2
            Remove-OldProtocols #R3
            Get-FTPPresence #R4
            Disable-SSHTunnels #R5
            Setup-CheckAuthenticityServer #R6
            Remove-AllDSAKey #R7
            Setup-RSAKeySize #R8
            Check-ECDSAKeySize #R9
            Check-RSAKeyPresence #R10

            Setup-PermissionForPrivateKeys #R13
            Setup-ProtectPrivateKeyUsingAESWithCBC #R14
            Setup-SymmetricAlgorithms #R15
            Check-SSHDHardening #R16
            Set-UserAuthMechanisms #R17

            Setup-AuthentificationAgent #R19

            Setup-Allowusers #R22
            Block-EnvironmentModification #R23

            Set-SSHPort #R25
            Block-TCPForwarding #R26
            Block-X11Forwarding #R27
            Block-X11Trusted #R28

            Create-RevocationFile #R30
            Setup-DNSValidation #R31

            Check-KeyLifetime #P1
            Setup-PermissionForUserPrivateKeys #P2 & P4
            Check-PasswordProtection #P3
            Setup-PrivilegeSeparationSanboxing #P5
            Setup-SFTPPermission #P6
            Block-PasswordForHighlyPrivilegedUsers #P7
            Remove-PAMKrb5 #P8
            Block-EmptyPassword #P9
            Set-LoginGraceTime #P10
            Set-MaxAuthTry #P11
            Block-RootConnection #P12 & R21
            Set-PrintLastLogon #P13
            ;;
        3)
            ./Menu/detailed_menu.sh
            ;;
        4)
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