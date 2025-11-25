#!/bin/bash

source Tools/ssh_protocol.sh
source Tools/remote_shell_administration.sh
source Tools/Cryptography/authentication.sh
source Tools/Cryptography/key_generation.sh
source Tools/Cryptography/access_control.sh
source Tools/Cryptography/choosing-symmetric-algorithms.sh
source Tools/System-Hardening/hardening-compilation.sh
source Tools/System-Hardening/privilege_separation.sh
source Tools/System-Hardening/sftp-chroot.sh
source Tools/Authentication-Access-Control/user_auth.sh
source Tools/Authentication-Access-Control/agent_auth.sh
source Tools/Authentication-Access-Control/access_accountability.sh
source Tools/Authentication-Access-Control/allow-users.sh
source Tools/Authentication-Access-Control/restrictions_of_the_user_environment.sh
source Tools/Protocole-Network-Access/listen-address-port.sh
source Tools/Protocole-Network-Access/tcp-forwarding.sh
source Tools/Protocole-Network-Access/x11-forwarding.sh
source Tools/OpenSSH-PKI/revocation.sh
source Tools/DNS-Record/dns-record.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

RED_MENU=$'\e[0;31m'
CYAN_MENU=$'\e[0;36m'
NC_MENU=$'\e[0m'

PS3="Please select a task ? "
options=("${CYAN_MENU}R1 - Setup SSH Protocol${NC_MENU}"\
 "${CYAN_MENU}R2 - Get if SSH is installed${NC_MENU}"\
 "${CYAN_MENU}R3 - Remove old protocols (TELNET, RSH, RLOGIN)${NC_MENU}"\
 "${CYAN_MENU}R4 - Check presence of FTP or RCP protocol${NC_MENU}"\
 "${CYAN_MENU}R5 - Disable SSH tunnels${NC_MENU}"\
 "${CYAN_MENU}R6 - Check authenticity server${NC_MENU}"\
 "${CYAN_MENU}R7 - Remove DSA key${NC_MENU}"\
 "${CYAN_MENU}R8 - Setup RSA key size minimum${NC_MENU}"\
 "${CYAN_MENU}R9 - Check ECDSA key size${NC_MENU}"\
 "${CYAN_MENU}R10 - Check presence of RSA key${NC_MENU}"\
 "${CYAN_MENU}R11 - ${NC_MENU}"\
 "${CYAN_MENU}R12 - ${NC_MENU}"\
 "${CYAN_MENU}R13 - Setup permissions on ech private key${NC_MENU}"\
 "${CYAN_MENU}R14 - Protect private keys with AES128-CBC mode${NC_MENU}"\
 "${CYAN_MENU}R15 - Define yhe possible symmetrical algorithms possible to use${NC_MENU}"\
 "${CYAN_MENU}R16 - Check if the sshd daemon is hardened since its compilation${NC_MENU}"\
 "${CYAN_MENU}R17 - Setup user authentication mechanisms${NC_MENU}"\
 "${CYAN_MENU}R18 - ${NC_MENU}"\
 "${CYAN_MENU}R19 - Disable agent forwarding by default${NC_MENU}"\
 "${CYAN_MENU}R20 - ${NC_MENU}"\
 "${CYAN_MENU}R21 - Disable connection with root user${NC_MENU}"
 "${CYAN_MENU}R22 - Setup users and IP allowed to use SSH${NC_MENU}"\
 "${CYAN_MENU}R23 - Block possibility to change environment by the sshd service${NC_MENU}"\
 "${CYAN_MENU}R24 - Define IP of management interface${NC_MENU}"\
 "${CYAN_MENU}R25 - Define new SSH port${NC_MENU}"\
 "${CYAN_MENU}R26 - Disable TCP forwarding${NC_MENU}"\
 "${CYAN_MENU}R27 - Disable X11 forwarding${NC_MENU}"\
 "${CYAN_MENU}R28 - Disable XAA redirection${NC_MENU}"\
 "${CYAN_MENU}R29 - ${NC_MENU}"\
 "${CYAN_MENU}R30 - Create file to add the revoked keys${NC_MENU}"\
 "${CYAN_MENU}R31 - Enable DNS validation${NC_MENU}"\
 "${CYAN_MENU}P1 - Check if private keys are less than 3 years${NC_MENU}"\
 "${CYAN_MENU}P2 - Setup permissions on user ssh folder and files${NC_MENU}"\
 "${CYAN_MENU}P3 - Check if password protection is applied on private keys${NC_MENU}"\
 "${CYAN_MENU}P4 - Setup permissions on user ssh folder and files${NC_MENU}"\
 "${CYAN_MENU}P5 - Enable sandbox to separate privilege${NC_MENU}"\
 "${CYAN_MENU}P6 - Setup permissions for SFTP${NC_MENU}"\
 "${CYAN_MENU}P7 - Disable authentification with password for higly privileged users${NC_MENU}"\
 "${CYAN_MENU}P8 - Disable authentification with 'pam_krb5' module${NC_MENU}"\
 "${CYAN_MENU}P9 - Disable authentification with empty password${NC_MENU}"\
 "${CYAN_MENU}P10 - Set a maximum time to connect${NC_MENU}"\
 "${CYAN_MENU}P11 - Set a maximum try to connect${NC_MENU}"\
 "${CYAN_MENU}P12 - Disable connection with root user${NC_MENU}"\
 "${CYAN_MENU}P13 - Display information about last user logon${NC_MENU}"\
  "${RED_MENU}Return${NC_MENU}")

select choice in "${options[@]}"; do
    case $REPLY in
        1)
            Setup-SSHProtocol #R1
            ;;
        2)
            Get-SSHPresence #R2
            ;;
        3)
            Remove-OldProtocols #R3
            ;;
        4)
            Get-FTPPresence #R4
            ;;
        5)
            Disable-SSHTunnels #R5
            ;;
        6)
            Setup-CheckAuthenticityServer #R6
            ;;
        7)
            Remove-AllDSAKey #R7
            ;;
        8)
            Setup-RSAKeySize #R8
            ;;
        9)
            Check-ECDSAKeySize #R9
            ;;
        10)
            Check-RSAKeyPresence #R10
            ;;
        11)
            ;;
        12)
            ;;
        13)
            Setup-PermissionForPrivateKeys #R13
            ;;
        14)
            Setup-ProtectPrivateKeyUsingAESWithCBC #R14
            ;;
        15)
            Setup-SymmetricAlgorithms #R15
            ;;
        16)
            Check-SSHDHardening #R16
            ;;
        17)
            Set-UserAuthMechanisms #R17
            ;;
        18)
            ;;
        19)
            Setup-AuthentificationAgent #R19
            ;;
        20)
            ;;
        21)
            Block-RootConnection #R21
            ;;
        22)
            Setup-Allowusers #R22
            ;;
        23)
            Block-EnvironmentModification #R23
            ;;
        24)
            Set-ManagementIPAddress
            ;;
        25)
            Set-SSHPort #R25
            ;;
        26)
            Block-TCPForwarding #R26
            ;;
        27)
            Block-X11Forwarding #R27
            ;;
        28)
            Block-X11Trusted #R28
            ;;
        29)
            ;;
        30)
            Create-RevocationFile #R30
            ;;
        31)
            Setup-DNSValidation #R31
            ;;
        32)
            Check-KeyLifetime #P1
            ;;
        33)
            Setup-PermissionForUserPrivateKeys #P2
            ;;
        34)
            Check-PasswordProtection #P3
            ;;
        35)
            Setup-PermissionForUserPrivateKeys #P4
            ;;
        36)
            Setup-PrivilegeSeparationSanboxing #P5
            ;;
        37)
            Setup-SFTPPermission #P6
            ;;
        38)
            Block-PasswordForHighlyPrivilegedUsers #P7
            ;;
        39)
            Remove-PAMKrb5 #P8
            ;;
        40)
            Block-EmptyPassword #P9
            ;;
        41)
            Set-LoginGraceTime #P10
            ;;
        42)
            Set-MaxAuthTry #P11
            ;;
        43)
            Block-RootConnection #P12
            ;;
        44)
            Set-PrintLastLogon #P13
            ;;
        45)
            break
            ;;
        *)
            echo -e "${RED} Invalid option, please try again !${NC}"
            ;;
    esac
done