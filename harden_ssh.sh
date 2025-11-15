#!/bin/bash

function Setup-SSHProtocol ()
{
    echo "[Task R1] : Setup SSH Protocol version"
    sed -i '/#Port 22/i Protocol 2' /etc/ssh/sshd_config
}