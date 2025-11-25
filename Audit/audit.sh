#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

ADMINISTRATIVE_IP="$(hostname -I | awk '{print $2}')"

function Print-Ok() {
    echo -e "${GREEN}[ OK ]${NC} $1"
    ((OK_COUNT++))
}

function Print-Fail() {
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

function Get-PackagePresence() {
    local option="$1"
    local desc="$2"

    if dpkg -l | awk '/^ii/ {print $2}' | grep -qi "^${option}$"; then
        Print-Ok "$desc"
    else
        Print-Fail "$desc (missing or incorrect). Package missing : $option"
    fi
}

function Get-PackageIfIsRemoved() {
    local option="$1"
    local desc="$2"

    if dpkg -l | awk '/^ii/ {print $2}' | grep -qi "^${option}"; then
        Print-Fail "$desc (missing or incorrect), package : $option"
    else
        Print-Ok "$desc"
    fi
}

function Get-LineInFile() {
    local option="$1"
    local file="$2"
    local desc="$3"

    if grep -Fxq "$option" "$file"; then
        Print-Fail "$desc (missing or incorrect)"
    else
        Print-Ok "$desc"
    fi
}

#!/bin/bash

function Check-SSHDHardening() {
    local desc="$1"
    local sshd_bin="/usr/sbin/sshd"
    ERREUR=0

    # PIE
    if readelf -h "$sshd_bin" | grep -q "Type:.*DYN"; then
        ERREUR=0
    else
        ERREUR=1
    fi

    # RELRO
    if readelf -l "$sshd_bin" | grep -q "GNU_RELRO"; then
        if readelf -d "$sshd_bin" | grep -q "BIND_NOW"; then
            ERREUR=0
        else
            ERREUR=1
        fi
    else
        ERREUR=1
    fi

    # NX / No Exec Stack
    if readelf -W -S "$sshd_bin" | grep -q "GNU_STACK"; then
        if readelf -W -S "$sshd_bin" | grep -q "GNU_STACK.*RWE"; then
            ERREUR=1
        else
            ERREUR=0
        fi
    fi

    # Stack protector
    if objdump -d "$sshd_bin" | grep -q "__stack_chk_fail"; then
        ERREUR=0
    else
        ERREUR=1
    fi

    if [ ${ERREUR} -eq 1 ]; then
        Print-Fail "$desc (missing or incorrect)"
    else
        Print-Ok "$desc"
    fi
}

function Get-DSAKey () {
    local pattern="$1"
    local desc="$2"
    local results
    results=$(find / -type f -name "$pattern" 2>/dev/null)

    if [ -n "$results" ]; then
        while IFS= read -r file; do
            Print-Fail "$file : $desc (missing or incorrect)"
        done <<< "$results"
    else
        Print-Ok "$desc"
    fi
}

function Get-ECDSAKeySize() {
    local desc="$1"

    for key in /root/.ssh/id_ecdsa /home/*/.ssh/id_ecdsa; do
        [ -f "$key" ] || continue
        key_size=$(ssh-keygen -lf "$key" | awk '{print $1}')
        if (( key_size < 256 )); then
            Print-Fail "$key : $desc (missing or incorrect)"
        else
            Print-Ok "$desc"
        fi
    done
}

function Get-RSAKey () {
    local pattern="$1"
    local desc="$2"
    local results
    results=$(find / -type f -name "$pattern" 2>/dev/null)

    if [ -n "$results" ]; then
        while IFS= read -r file; do
            Print-Fail "$desc (missing or incorrect)"
        done <<< "$results"
    else
        Print-Ok "$desc"
    fi
}

function Check-KeyLifetime () {
    local path="$1"
    local desc="$2"

    for dir in $path; do
        if [ -d "$dir" ]; then
            if find "$dir" -type f -mtime +1095 | grep -q .; then
                Print-Fail "$dir : $desc (missing or incorrect)"
            else
                Print-Ok "$dir : $desc"
            fi
        fi
    done
}

function Get-Permission ()
{
    local path="$1"
    local perms="$2"
    local desc="$3"

    for file in $path;
    do
        if [ "$(sudo stat -c "%a" "$file")" -ne $perms ]; then
            Print-Fail "$file : $desc (missing or incorrect)"
        else
            Print-Ok "$file : $desc"
        fi
    done
}

function Check-PasswordProtection ()
{
    local pattern="$1"
    local desc="$2"
    local files=($pattern)

    for key in "${files[@]}"; do
        [ -f "$key" ] || continue
        [[ "$key" == *.pub ]] && continue
        if ssh-keygen -y -f "$key" >/dev/null 2>&1; then
            Print-Fail "$key : $desc (missing or incorrect)"
        else
            Print-Ok "$key : $desc"
        fi
    done
}

function Get-Folder() {
    local option="$1"
    local desc="$2"

    if [ -d "$option" ]; then
        Print-Ok "$desc"
    else
        Print-Fail "$desc (missing or incorrect)"
    fi
}

function Get-File() {
    local option="$1"
    local desc="$2"

    if [ -f "$option" ]; then
        Print-Ok "$desc"
    else
        Print-Fail "$desc (missing or incorrect)"
    fi
}

function Get-Group() {
    local option="$1"
    local desc="$2"

    if getent group "$option" &>/dev/null; then
        Print-Ok "$desc"
    else
        Print-Fail "$desc (missing or incorrect)"
    fi
}

echo -e "\n===================================="
echo -e "        🔍 SSH HARDENING AUDIT"
echo -e "===================================="

Get-SSHdOption "Protocol" "2" "R1 - SSHv2 specified"
Get-PackagePresence "openssh-server" "R2 - OpenSSH-Server is installed"
Get-PackageIfIsRemoved "telnetd" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "inetutils-telnetd" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "inetutils-telnet" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "rsh-server" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "rsh-client" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "rsh-redone-client" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "rsh-redone-server" "R3 - TELNET, RSH and RLOGIN is uninstalled"
Get-PackageIfIsRemoved "vsftpd" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "proftpd" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "pure-ftpd" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "inetutils-ftpd" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "tftpd" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "inetutils-ftp" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "rsh-client" "R4 - FTP and RCP is uninstalled"
Get-PackageIfIsRemoved "rsh-redone-client" "R4 - FTP and RCP is uninstalled"
Get-SSHdOption "PermitTunnel" "no" "R5 - SSH tunnel disabled"
Get-SSHOption "   StrictHostKeyChecking" "ask" "R6 - HostKey checking enabled"
Get-DSAKey "*id_dsa*" "R7 - Client DSA key removed"
Get-DSAKey "*ssh_host_dsa_key*" "R7 - Server DSA key removed"
Get-SSHdOption "RequiredRSASize" "2048" "R8 - RSA key sized defined"
Get-ECDSAKeySize "R9 - Size of ECDSA key is correct"
Get-RSAKey "*id_rsa*" "R10 - No RSA key on this server"
#R11
#R12
Get-Permission "/etc/ssh/ssh_host_rsa_key" "600" "R13 - Permissions on host key file are correct"
Get-Permission "/etc/ssh/ssh_host_ecdsa_key" "600" "R13 - Permissions on host key file are correct"
Get-SSHdOption "StrictModes" "yes" "R14 - Private keys protected with AES128-CBC mode."
Get-SSHOption "   Ciphers" "aes128-ctr,aes192-ctr,aes256-ctr" "R15 - Encryption algorithm defined"
Get-SSHOption "   MACs" "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "R15 - Encryption algorithm defined"
Get-SSHdOption "Ciphers" "aes128-ctr,aes192-ctr,aes256-ctr" "R15 - Encryption algorithm defined"
Get-SSHdOption "MACs" "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com" "R15 - Encryption algorithm defined"
Get-PackagePresence "binutils" "R16 - Binutils is installed"
Check-SSHDHardening "R16 - SSHd service is correctly compiled"
Get-SSHdOption "PubkeyAuthentication" "yes" "R17 - Pubkey authentication defined"
Get-SSHdOption "HostKeyAlgorithms" "ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256" "R17 - Hostkey algorithm defined"
Get-SSHdOption "PubkeyAcceptedAlgorithms" "ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,rsa-sha2-512,rsa-sha2-256" "R17 - Pubkey accepted algorithms defined"
Get-SSHdOption "GSSAPIAuthentication" "yes" "R17 - GSSAPI authentication defined"
Get-SSHdOption "GSSAPICleanupCredentials" "yes" "R17 - GSSAPI cleanup credentials defined"
Get-PackagePresence "krb5-user" "R17 - Package 'krb5-user' is installed"
if apt list --installed 2>/dev/null | grep -qi libpam-krb5; then
    Print-Ok "R17 - Package 'libpam-krb5' is installed"
else
    Print-Fail "R17 - Package 'libpam-krb5' is installed (missing or incorrect)"
fi
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
Get-SSHdOption "ListenAddress" "${ADMINISTRATIVE_IP}" "R25 - Administrative address defined"
Get-SSHdOption "Port" "26" "R26 - Specific SSH port defined"
Get-SSHdOption "AllowTcpForwarding" "no" "R27 - TCP forwarding disabled"
Get-SSHdOption "X11Forwarding" "no" "R28 - X11 forwarding disabled"
Get-SSHOption "   ForwardX11Trusted" "no" "R28 - X11 forwarding disabled"
#R29
Get-SSHdOption "RevokedKeys" "/etc/ssh/revoked_keys" "R30 - Revoked key file defined"
Get-File "/etc/ssh/revoked_keys" "R30 - Revoked key file created"
Get-SSHOption "VerifyHostKeyDNS" "ask" "R31 - HostKey DNS verification defined"

Check-KeyLifetime "/root/.ssh" "P1 - Root SSH key has less has less than 3 years"
Check-KeyLifetime "/home/*/.ssh" "P1 - User SSH key has less has less than 3 years"
Get-Permission "/root/.ssh" "700" "P2 - Permissions on root ssh folder are correct"
Get-Permission "/home/*/.ssh" "700" "P2 - Permissions on user ssh folder are correct"
Check-PasswordProtection "/root/.ssh/id_*" "P3 - Root private key are password protection"
Check-PasswordProtection "/home/*/.ssh/id_*" "P3 - User private key are password protection"
Get-Permission "/root/.ssh/id_*" "600" "P4 - Permissions on root key file are correct"
Get-Permission "/home/*/.ssh/id_*" "600" "P4 - Permissions on user key file are correct"
Get-SSHdOption "UsePrivilegeSeparation" "sandbox" "P5 - Separation of privileges defined"
Get-SSHdOption "Subsystem" "sftp internal-sftp" "P6 - SFTP subsystem defined"
Get-Group "sftp-users" "P6 - SFTP group created"
Get-SSHdOption "Match Group" "sftp-users" "P6 - SFTP group permissions defined"
Get-Folder "/sftp-home" "P6 - SFTP folder created"
Get-SSHdOption "PasswordAuthentication" "yes" "P7 - Password authentication defined"
Get-SSHdOption "Match User" "root" "P7 - Root user permissions defined"
Get-SSHdOption "Match Group" "sudo" "P7 - Sudoers permissions defined"
Get-SSHdOption "KerberosAuthentication" "no" "P8 - Kerberos authentication disabled"
Get-SSHdOption "GSSAPIAuthentication" "yes" "P8 - GSSAPI authentication enabled"
Get-LineInFile "pam_krb5" "/etc/pam.d/sshd" "P8 - 'pam_krb5' module not present in SSH PAM file"
Get-SSHdOption "PermitEmptyPasswords" "no" "P9 - Connection without password disabled"
Get-SSHdOption "LoginGraceTime" "30" "P10 - Login grace time defined"
Get-SSHdOption "MaxAuthTries" "2" "P11 - Maximum authentication try defined"
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