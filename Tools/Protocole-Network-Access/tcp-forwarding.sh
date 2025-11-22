#!/bin/bash

function Block-TCPForwarding ()
{
    if ! grep -Fxq "AllowTcpForwarding no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R27] : Except for duly justified needs, any flow forwarding feature shall be turned off.${NC}"
        sudo sed -i "s/#AllowTcpForwarding yes/AllowTcpForwarding no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R27] : TCP forwarding has already blocked${NC}"
    fi
}