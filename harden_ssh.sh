#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

chmod +x "$SCRIPT_DIR/Menu/detailed_menu.sh"
chmod +x "$SCRIPT_DIR/Audit/audit.sh"

source "$SCRIPT_DIR/Tools/ssh_protocol.sh"
source "$SCRIPT_DIR/Tools/remote_shell_administration.sh"
source "$SCRIPT_DIR/Tools/Cryptography/authentication.sh"
source "$SCRIPT_DIR/Tools/Cryptography/key_generation.sh"
source "$SCRIPT_DIR/Tools/Cryptography/access_control.sh"
source "$SCRIPT_DIR/Tools/Cryptography/choosing-symmetric-algorithms.sh"
source "$SCRIPT_DIR/Tools/System-Hardening/hardening-compilation.sh"
source "$SCRIPT_DIR/Tools/System-Hardening/privilege_separation.sh"
source "$SCRIPT_DIR/Tools/System-Hardening/sftp-chroot.sh"
source "$SCRIPT_DIR/Tools/Authentication-Access-Control/user_auth.sh"
source "$SCRIPT_DIR/Tools/Authentication-Access-Control/agent_auth.sh"
source "$SCRIPT_DIR/Tools/Authentication-Access-Control/access_accountability.sh"
source "$SCRIPT_DIR/Tools/Authentication-Access-Control/allow-users.sh"
source "$SCRIPT_DIR/Tools/Authentication-Access-Control/restrictions_of_the_user_environment.sh"
source "$SCRIPT_DIR/Tools/Protocole-Network-Access/listen-address-port.sh"
source "$SCRIPT_DIR/Tools/Protocole-Network-Access/tcp-forwarding.sh"
source "$SCRIPT_DIR/Tools/Protocole-Network-Access/x11-forwarding.sh"
source "$SCRIPT_DIR/Tools/OpenSSH-PKI/revocation.sh"
source "$SCRIPT_DIR/Tools/DNS-Record/dns-record.sh"

function CheckRequirements ()
{
    if [ "$(sudo lsb_release -si)" = "Debian" ] || [ "$(sudo lsb_release -si)" = "Ubuntu" ]; then
        echo -e ""
    else
        echo -e "${RED} This script is created to run only on Debian or Ubuntu !${NC}"
        exit 1
    fi

    if ! sudo apt list --installed sudo &>/dev/null; then
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

function Show-Banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╦ ╦┌─┐┬─┐┌┬┐┌─┐┌┐┌   ╔═╗╔═╗╦ ╦
    ╠═╣├─┤├┬┘ ││├┤ │││───╚═╗╚═╗╠═╣
    ╩ ╩┴ ┴┴└──┴┘└─┘┘└┘   ╚═╝╚═╝╩ ╩
EOF
    echo -e "${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  SSH Hardening & Security Configuration${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Version:${NC} ${VERSION}"
    echo -e "${CYAN}  Author:${NC}  ${AUTHOR}"
    echo -e "${CYAN}  GitHub:${NC}  ${GITHUB}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

function Backup-SSHFolder ()
{
    BACKUP_DIR="/tmp/ssh_backup_$(date +%Y%m%d_%H%M%S)"
    sudo mkdir -p "$BACKUP_DIR"

    for user_home in /root /home/*; do
        ssh_dir="$user_home/.ssh"
        
        if [ -d "$ssh_dir" ]; then
            dest="$BACKUP_DIR/$(basename "$user_home")"
            sudo mkdir -p "$dest"
            sudo cp -a "$ssh_dir" "$dest/"
            echo -e "${GREEN}Backup created for SSH configuration to $BACKUP_DIR${NC}"
        else
            echo -e "${YELLOW}No .ssh directory for $user_home, skipping${NC}"
        fi
    done

    CONFIG_BACKUP_DIR="/tmp/ssh_config_$(date +%Y%m%d_%H%M%S)"
    if [ -d "/etc/ssh" ]; then
        sudo mkdir -p "$CONFIG_BACKUP_DIR"
        sudo cp -a /etc/ssh/* "$CONFIG_BACKUP_DIR"
        echo -e "${GREEN}Backup created for SSH configuration to $CONFIG_BACKUP_DIR${NC}"
    else
        echo -e "${RED}Impossible to backup /etc/ssh folder${NC}"
        return 1
    fi
    # sudo mkdir -p "/tmp/ssh_config_$(date +%Y%m%d_%H%M%S)"
    # sudo cp -r /etc/ssh/* "/tmp/ssh_config_$(date +%Y%m%d_%H%M%S)"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Aucune couleur

VERSION="2.0"
AUTHOR="Corentin Beuf"
GITHUB="https://github.com/corentinbeuf/Harden-SSH"

CheckRequirements
Show-Banner
Backup-SSHFolder

PS3="Please select a task ? "
options=("Audit" "Configure all tasks" "Configure a specific task" "Quit")

select choix in "${options[@]}"; do
    case $REPLY in
        1)
            ./Audit/audit.sh
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

            Set-ManagementIPAddress #R25
            Set-SSHPort #R26
            Block-TCPForwarding #R27
            Block-X11Forwarding #R28
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
            if [ "$(lsb_release -si)" = "Ubuntu" ]; then
                sudo systemctl restart ssh
                echo "Exit"
                break
            else
                sudo systemctl daemon-reload
                sudo systemctl restart sshd
                echo "Exit"
                break
            fi
            ;;
        *)
            echo -e "${RED} Invalid option, please try again !${NC}"
            ;;
    esac
done