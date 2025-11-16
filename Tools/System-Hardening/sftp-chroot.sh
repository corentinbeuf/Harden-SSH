#!/bin/bash

function Setup-SFTPPermission ()
{
    if ! grep -Fxq "Subsystem sftp internal-sftp" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Subsystem.${NC}"
        sed -i "s/Subsystem       sftp    \/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P6] : SFTP subsystem is already defined${NC}"
    fi

    if ! awk -F':' '/^sftp-users/{print $1}' /etc/group; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Group.${NC}"
        addgroup sftp-users
    else
        echo -e "${YELLOW}[Task P6] : SFTP group is already created${NC}"
    fi

    if ! grep -Fxq "Match group sftp-users" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Permission.${NC}"
        echo "Match Group sftp-users
    ChrootDirectory /sftp-home/%u
    ForceCommand internal-sftp
    AllowTCPForwarding no
    X11Forwarding no
    PasswordAuthentication yes" >> /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P6] : SFTP permissions are already setup${NC}"
    fi

    if [ -d "$DIRECTORY" ]; then
        echo -e "${GREEN}[Task P6] : Implement the principle of least privilege for users using SFTP only - Directories.${NC}"
        mkdir /sftp-home
        chown root:root /sftp-home
        chmod 755 /sftp-home
    else
        echo -e "${YELLOW}[Task P6] : SFTP directories are already created${NC}"
    fi
}