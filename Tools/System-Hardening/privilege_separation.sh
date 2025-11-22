#!/bin/bash

function Setup-PrivilegeSeparationSanboxing ()
{
    if ! grep -Fxq "UsePrivilegeSeparation sandbox" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task P5] : Implement the separation of privileges.${NC}"
        sudo sed -i '/#VersionAddendum none/a UsePrivilegeSeparation sandbox' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task P5] : Sanboxing are already setup${NC}"
    fi
}