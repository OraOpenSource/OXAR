#OS Utils

*Note: The scripts in this folder are still under development and may change in the near future.*

##Permit Root SSH Login
It is highly recommended to disable root access to SSH logins. To do so run:

```bash
. permit_root_ssh_login.sh N
```

##Create User
To create a new user run:

```bash
./create_user.sh <username> <password> <ssh_key (optional)>

#Ex:
./create_user.sh martin martin "ssh-rsa keyinformation..."
```

Name | Description
---- | ----
`username` | OS username
`password` | Password
`ssh_key` | Public SSH key on your system. Can be used for passwordless login (recommended). The following article explains how to generate your own SSH key: [https://help.github.com/articles/generating-ssh-keys/](https://help.github.com/articles/generating-ssh-keys/). If using this variable put in quotes to escape any spaces.
