#!/bin/bash

function Setup-AuthentificationAgent ()
{
    if ! grep -Fxq "AllowAgentForwarding no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R19] : When SSH bouncing is necessary through a relay host, Agent Forwarding (-A option of ssh) should be used - Agent Forwarding.${NC}"
        sed -i "s/#AllowAgentForwarding yes/AllowAgentForwarding no/g" /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R19] : Agent auth are already disabled${NC}"
    fi

    if ! grep -Fxq "ForwardAgent no" "/etc/ssh/sshd_config"; then
        echo -e "${GREEN}[Task R19] : When SSH bouncing is necessary through a relay host, Agent Forwarding (-A option of ssh) should be used - Forward Agent.${NC}"
        sed -i '/AllowAgentForwarding no/a ForwardAgent yes' /etc/ssh/sshd_config
    else
        echo -e "${YELLOW}[Task R19] : Forward agent param are already disabled${NC}"
    fi
    ForwardAgent yes
}