By default, specific configuration are not prensent in the main script. To implement, a specific configuration, example are provided below :

- R19 : When SSH bouncing is necessary through a relay host, Agent Forwarding (-A option of ssh) should be used.
    - On client server :
      - Edit "**~/.ssh/config**"
      - Add these lines and adjuste with your configuration :
        ```
        Host bastion
            HostName bastion.example.com
            User admin
            ForwardAgent yes

        Host server-final
            HostName 10.0.2.12
            User admin
            ProxyJump bastion
            ForwardAgent yes
        ```
      - Edit "**~/.ssh/config**"
      - Add this line and adjuste with your configuration :
        ```
        AllowAgentForwarding no
        ```

    - On server :
      - Edit "**/etc/ssh/sshd_config**"
      - Add this line and adjuste with your configuration :
        ```
        AllowAgentForwarding yes
        ```
    - Restart "**sshd**" service when your configuration is implement
  
- R22 : Access to a service shall be restricted to users having a legitimate need. This restriction shall apply on a white-list basis: only explicitly allowed users shall connect to a host via SSH and possibly from specified source IP addresses.
  - Edit "**/etc/ssh/sshd_config**".
  - Uncomment this line : 
    ```
    #AllowUsers example@10.10.10.1
    ```
  - Define your users and IP.
  - Restart "**sshd**" service.

- R30 : If a key cannot be considered safe anymore, it shall be quickly revoked at the SSH level.
  - In the script, the file is created and he is specified in SSH configuration. To add revoked in this file, execute this command (change SSh key) :
    ```bash
    echo "ssh-rsa AAAAB3NzaC1yc2..." >> /etc/ssh/revoked_keys
    ```

- P6 : Implement the principle of least privilege for users using SFTP only.
  - In the script, the main folder is created. For each users who want to use SFTP, you need to create folder.
  - Create user folder :
    ```bash
    sudo mkdir chown /sftp-home/user1
    ```
  - Apply the permissions on the folder.
    ```bash
    sudo chown root:root /sftp-home/user1
    ```
  - Create folder and add the permissions on the folder where the user has the possibility to modify content.
    ```bash
    mkdir /sftp-home/user1/uploads
    chown user1:sftp-users /sftp-home/user1/uploads
    chmod 750 /sftp-home/user1/uploads
    ```

- P7 : Do not use a password for privileged accounts.
  - You need to send the publickey on the server to connect with privilegied user.
  - Create "**.ssh**" folder and apply the correct permissions :
    ```bash
    sudo mkdir -p /home/administrator/.ssh
    sudo chmod 700 /home/administrator/.ssh
    ```
  - Add the public key in the file :
    ```bash
    echo "public_key" >> /home/administrator/.ssh/authorized_keys
    ```
  - Apply the correct permissions on this file :
    ```bash
    sudo chmod 600 /home/administrator/.ssh/authorized_keys
    sudo chown -R administrator:administrator /home/administrator/.ssh
    ```