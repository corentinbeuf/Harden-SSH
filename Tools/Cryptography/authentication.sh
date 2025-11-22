#!/bin/bash

function Setup-CheckAuthenticityServer ()
{
    if ! grep -Fxq "   StrictHostKeyChecking ask" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R6] : The server authenticity shall always be checked prior to access. This is achieved through preliminary machine authentication by checking the server public key fingerprint, or by verifying the server certificate.${NC}"
        sudo sed -i "s/#   StrictHostKeyChecking ask/   StrictHostKeyChecking ask/g" /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}[Task R6] : The param to check the server authenticity is already setup${NC}"
    fi
}