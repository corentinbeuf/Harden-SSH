# Harden-SSH

This script permit to secure your SSH service on one Linux server.
All the tasks performed in this script are based on the ANSSI guide, accessible from this link : [(Open)SSH secure use recommendations](https://cyber.gouv.fr/publications/usage-securise-dopenssh). Available in French ans in English.

## Hardening
### Requirements
- [x] Only version 2 of the SSH protocol shall be authorized.
- [ ] SSH shall be used instead of historical protocols (TELNET, RSH, RLOGIN) for remote shell access.
- [ ] TELNET, RSH and RLOGIN remote access servers shall be uninstalled from the system.
- [ ] SCP or SFTP shall be used instead of historical protocols (RCP, FTP) for file transfers.
- [ ] The implementation of SSH tunnels shall only be applied to protocols that do not provide robust security mechanisms and that can benefit from it (for example: X11, VNC). This recommendation does not exempt from using additional low level security protocols, such as IPsec 2.
- [x] The server authenticity shall always be checked prior to access. This is achieved through preliminary machine authentication by checking the server public key fingerprint, or by verifying the server certificate.
- [x] The use of DSA keys is not recommended.
- [x] The minimum key size shall be 2048 bits for RSA.
- [ ] The minimum key size shall be 256 bits for ECDSA.
- [ ] ECDSA keys should be favoured over RSA keys when supported by SSH clients and servers.
- [ ] Keys should be generated in a context where the RNG is reliable, or at least in an environment where enough entropy has been accumulated.
- [ ] Some rules can ensure that the entropy pool is properly filled: 
    * keys must be generated on a physical equipment;
    * system must have several independent sources of entropy;
    * key generation shall occur only after a long period of activity (several minutes or even hours)
- [x] The private key should only be known by the entity who needs to prove its identity to a third party and possibly to a trusted authority. This private key should be properly protected in order to avoid its disclosure to any unauthorized person.
- [x] Private keys shall be password protected using AES128-CBC mode.
- [ ] The encryption algorithm shall either be AES128-CTR, AES192-CTR or AES256-CTR. The integrity mechanism shall rely on HMAC-SHA1, HMAC-SHA256 or HMACSHA512.
- [ ] A preliminary step in hardening the sshd service is to use proper compilation flags.
- [ ] User authentication should be performed with one of the following mechanisms, given by order of preference:
    * ECDSA asymmetric cryptography;
    * RSA asymmetric cryptography;
    * symmetric cryptography (Kerberos tickets from the GSSAPI);
    * authentication modules that expose neither the user password nor its hash (third-party PAM or BSD Auth modules);
    * password check against a database (such as passwd/shadow) or a directory.
- [ ] Users rights shall follow the least privilege principle. Restrictions can be applied on several parameters: available commands, source IP, redirection of forwarding permissions. . .
- [ ] When SSH bouncing is necessary through a relay host, Agent Forwarding (-A option of ssh) should be used.
- [ ] The relay host server shall be a trusted host.
- [ ] Every user must have his own, unique, non-transferable account.
- [ ] Access to a service shall be restricted to users having a legitimate need. This restriction shall apply on a white-list basis: only explicitly allowed users shall connect to a host via SSH and possibly from specified source IP addresses.
- [ ] The ability for a user to tamper with the environment shall be denied by default. Usersupplied environment variables shall be selected on a case-by-case basis.
- [ ] Users shall only execute strictly necessary commands. This restriction can be achieved in the following ways:
    * using the ForceCommand directive on a per user basis in the sshd_config file;
    * specifying some options in the authorized_keys file (See 4.3.1);
    * using secure binaries such as sudo or su
- [ ] The SSH server shall only listen on the administration network.
- [ ] When the SSH server is exposed to an uncontrolled network, one should change its listening port (22). Preference should be given to privileged ports (below 1024).
- [ ] Except for duly justified needs, any flow forwarding feature shall be turned off:
    * in the SSH server configuration;
    * in the local firewall by blocking connections.
- [ ] X11 forwarding shall be disabled on the server.
- [ ] It is recommended to create distinct CAs when their roles differ. There will be, for example:
    * one CA for the “hosts” CA role;
    * one CA for the “users” CA role.
  
Each CA private key shall be protected by a unique and robust password.
- [ ] If a key cannot be considered safe anymore, it shall be quickly revoked at the SSH level.
- [ ] SSH host key fingerprints obtained through DNS records should not be trusted without complimentary verifications.

### Personnal requirements
- [ ] The lifetime of SSh keys must be a maximum of 3 years.
- [ ] Access to the user’s private key must be done only with the user account in question.
- [ ] Generate a passphrase for all user keys.
- [ ] Limit access to the .ssh folder.
- [x] Implement the separation of privileges.
- [ ] Implement the principle of least privilege for users using SFTP only.
- [ ] Do not use a password for privileged accounts.
- [ ] Do not use the PAM module 'pam_krb5'.
- [x] Disable login without password.
- [x] Define a time period for the authentication operation.
- [x] Limit the number of connection attempts.
- [X] Disable the root connection in SSH.
- [X] Display information related to the user’s last login.