#!/bin/bash

function Block-X11Forwarding ()
{
    if ! grep -Fxq "X11Forwarding no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R28] : X11 forwarding shall be disabled on the server.${NC}"
        sudo sed -i "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R28] : X11 forwarding has already blocked${NC}"
    fi
}

function Block-X11Trusted ()
{
    if ! grep -Fxq "   ForwardX11Trusted no" "/etc/ssh/ssh_config"; then
        echo -e "${GREEN}[Task R28] : X11 forwarding shall be disabled on the server.${NC}"
        sudo sed -i "s/#   ForwardX11Trusted yes/   ForwardX11Trusted no/g" /etc/ssh/ssh_config
    else
        echo -e "${YELLOW}[Task R28] : X11 forwarding has already blocked${NC}"
    fi
}