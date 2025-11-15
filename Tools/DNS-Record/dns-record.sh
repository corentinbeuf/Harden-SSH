#!/bin/bash

function Setup-DNSValidation ()
{
    if ! grep -Fxq "VerifyHostKeyDNS ask" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R31] : SSH host key fingerprints obtained through DNS records should not be trusted without complimentary verifications.${NC}"
        sed -i '/    GSSAPIAuthentication yes/a VerifyHostKeyDNS ask' /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}[Task R31] : DNS fingerprint validation has already setup${NC}"
    fi
}