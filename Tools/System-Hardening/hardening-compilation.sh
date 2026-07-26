#!/bin/bash

function Check-SSHDHardening() {
    local sshd_bin="/usr/sbin/sshd"
    ERREUR=0

    if ! sudo apt-get list --installed binutils &>/dev/null; then
        sudo apt-get install binutils -y &>/dev/null
    fi

    # PIE
    if sudo readelf -h "$sshd_bin" | sudo grep -q "Type:.*DYN"; then
        ERREUR=0
    else
        ERREUR=1
    fi

    # RELRO
    if sudo readelf -l "$sshd_bin" | sudo grep -q "GNU_RELRO"; then
        if sudo readelf -d "$sshd_bin" | sudo grep -q "BIND_NOW"; then
            ERREUR=0
        else
            ERREUR=1
        fi
    else
        ERREUR=1
    fi

    # NX / No Exec Stack
    if sudo readelf -W -S "$sshd_bin" | sudo grep -q "GNU_STACK"; then
        if sudo readelf -W -S "$sshd_bin" | sudo grep -q "GNU_STACK.*RWE"; then
            ERREUR=1
        else
            ERREUR=0
        fi
    fi

    # Stack protector
    if sudo objdump -d "$sshd_bin" | sudo grep -q "__stack_chk_fail"; then
        ERREUR=0
    else
        ERREUR=1
    fi

    if [ ${ERREUR} -eq 1 ]; then
        echo -e "${RED}[Task R16] : SSHd is not properly compiled. Please compile it with the hardening rules.${NC}"
    else
        echo -e "${YELLOW}[Task R16] : SSHd is correctly compiled${NC}"
    fi
}
