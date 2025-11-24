#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

function Print-Ok() {
    echo -e "${GREEN}[ OK ]${NC} $1"
    ((OK_COUNT++))
}

function Print-Failt() {
    echo -e "${RED}[ FAIL ]${NC} $1"
    ((FAIL_COUNT++))
}

function Print-Warn() {
    echo -e "${YELLOW}[ WARN ]${NC} $1"
    ((WARN_COUNT++))
}

function Get-SSHOption() {
    local option="$1"
    local expected="$2"
    local desc="$3"

    if grep -Eq "^\s*$option\s+$expected" /etc/ssh/ssh_config; then
        Print-Ok "$desc"
    else
        Print-Fail "$desc (missing or incorrect)"
    fi
}

function Get-SSHdOption() {
    local option="$1"
    local expected="$2"
    local desc="$3"

    if grep -Eq "^\s*$option\s+$expected" /etc/ssh/sshd_config; then
        Print-Ok "$desc"
    else
        Print-Fail "$desc (missing or incorrect)"
    fi
}


echo -e "\n===================================="
echo -e "        🔍 SSH HARDENING AUDIT"
echo -e "===================================="

Get-SSHdOption "Protocol" "2" "R1 - SSHv2 specified"
#R2
#R3
#R4
Get-SSHdOption "PermitTunnel" "no" "R5 - SSH tunnel disabled"
Get-SSHOption "   StrictHostKeyChecking" "ask" "R6 - HostKey checking enabled"
#R7
Get-SSHdOption "RequiredRSASize" "2048" "R8 - RSA key sized defined"
#R9
#R10
#R11
#R12
#R13
Get-SSHdOption "StrictModes" "yes" "R14 - Private keys protected with AES128-CBC mode."
Get-SSHOption "   Ciphers" "aes128-ctr,aes192-ctr,aes256-ctr" "R15 - Encryption algorithm defined"
Get-SSHOption "   MACs" "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "R15 - Encryption algorithm defined"
Get-SSHdOption "Ciphers" "aes128-ctr,aes192-ctr,aes256-ctr" "R15 - Encryption algorithm defined"
Get-SSHdOption "MACs" "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "R15 - Encryption algorithm defined"
#R16
Get-SSHdOption "PubkeyAuthentication" "yes" "R17 - Pubkey authentication defined"
Get-SSHdOption "HostKeyAlgorithms" "ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256" "R17 - Hostkey algorithm defined"
Get-SSHdOption "PubkeyAcceptedAlgorithms" "ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256" "R17 - Pubkey accepted algorithms defined"
Get-SSHdOption "GSSAPIAuthentication" "yes" "R17 - GSSAPI authentication defined"
Get-SSHdOption "GSSAPICleanupCredentials" "yes" "R17 - GSSAPI cleanup credentials defined"
#R17 : KRB5 packages not tested
Get-SSHdOption "UsePAM" "yes" "R17 - PAM authentication defined"
Get-SSHdOption "PasswordAuthentication" "yes" "R17 - Password authentication defined"
#R18
Get-SSHdOption "AllowAgentForwarding" "no" "R19 - Agent forwarding disabled"
#R20
Get-SSHdOption "PermitRootLogin" "no" "R21 - Root login disabled"
#Get-SSHdOption "AllowUsers" "" "R22 - Allow users defined"
#Get-SSHdOption "AllowGroups" "" "R22 - Allow groups defined"
Get-SSHdOption "PermitUserEnvironment" "no" "R23 - User environment defined"
#R24
#Get-SSHdOption "ListenAddress" "no" "R25 - Administrative address defined" #TODO : get IP
Get-SSHdOption "Port" "26" "R26 - Specific SSH port defined"
Get-SSHdOption "AllowTcpForwarding" "no" "R27 - TCP forwarding disabled"
Get-SSHdOption "X11Forwarding" "no" "R28 - X11 forwarding disabled"
Get-SSHOption "   ForwardX11Trusted" "no" "R28 - X11 forwarding disabled"
#R29
Get-SSHdOption "RevokedKeys" "/etc/ssh/revoked_keys" "R30 - Revoked key file defined" #TODO : Test if file is created
Get-SSHOption "VerifyHostKeyDNS" "ask" "R31 - HostKey DNS verification defined"

#P1
#P2
#P3
#P4
Get-SSHdOption "UsePrivilegeSeparation" "sandbox" "P5 - Separation of privileges defined"
Get-SSHdOption "Subsystem" "sftp internal-sftp" "P6 - SFTP subsystem defined"
#P6 TODO : Test if sftp group exist
Get-SSHdOption "Match Group" "sftp-users" "P6 - SFTP group permissions defined"
#P6 TODO : Test if sftp folder exist
Get-SSHdOption "PasswordAuthentication" "yes" "P7 - Password authentication defined"
Get-SSHdOption "Match User" "root" "P7 - Root user permissions defined"
Get-SSHdOption "Match Group" "sudo" "P7 - Sudoers permissions defined"
Get-SSHdOption "KerberosAuthentication" "no" "P8 - Kerberos authentication disabled"
Get-SSHdOption "GSSAPIAuthentication" "yes" "P8 - GSSAPI authentication enabled"
#P8 TODO : Check if pam_krb5 is defined in sshd pam file
Get-SSHdOption "PermitEmptyPasswords" "no" "P9 - Connection without password diabled"
#P10
#P11
Get-SSHdOption "PermitRootLogin" "no" "P12 - Root login disabled"
Get-SSHdOption "PrintLastLog" "yes" "P13 - Print last logon defined"
#P14

echo -e "\n===================================="
echo -e "            📊 RESULT SUMMARY"
echo -e "===================================="
echo -e "${GREEN}OK     : $OK_COUNT${NC}"
echo -e "${YELLOW}WARN   : $WARN_COUNT${NC}"
echo -e "${RED}FAIL   : $FAIL_COUNT${NC}"

echo ""
if [[ "$FAIL_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}✅ Server is compliant with hardened SSH configuration.${NC}"
else
    echo -e "${RED}❌ Server is NOT compliant — review FAILED checks.${NC}"
fi

# TODO : juste avoir un résumé à la fin