#!/bin/bash

function Setup-SFTPPermission ()
{
    if ! grep -Fxq "Subsystem sftp internal-sftp" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Subsystem.${NC}"
        sudo sed -i '/^Subsystem[[:space:]]\+sftp/d' /etc/ssh/sshd_config
        sudo sed -i '/# override default of no subsystems/a Subsystem sftp internal-sftp' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P6] : SFTP subsystem is already defined${NC}"
    fi

    if ! getent group sftp-users &>/dev/null; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Group.${NC}"
        sudo addgroup sftp-users &>/dev/null
    else
        echo -e "${YELLOW}[Task P6] : SFTP group is already created${NC}"
    fi

    if ! grep -Fxq "Match Group sftp-users" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Permission.${NC}"
        sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF
Match Group sftp-users
    ChrootDirectory /sftp-home/%u
    ForceCommand internal-sftp
    AllowTCPForwarding no
    X11Forwarding no
EOF
    else
        echo -e "${YELLOW}[Task P6] : SFTP permissions are already setup${NC}"
    fi

    if [ ! -d "/sftp-home" ]; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Directories.${NC}"
        sudo mkdir -p /sftp-home
        sudo chown root:root /sftp-home
        sudo chmod 755 /sftp-home
    else
        echo -e "${YELLOW}[Task P6] : SFTP directories are already created${NC}"
    fi
}