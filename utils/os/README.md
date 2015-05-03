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
. create_user.sh <username> <ssh_key>
```

Where `ssh_key` is the URL to an public key. Examples are: `http://myserver.com/id_rsa.pub` or a file path e.g. `file:///tmp/id_rsa.pub`. This user is created without a password.

The following article explains how to generate your own SSH key:[https://help.github.com/articles/generating-ssh-keys/](https://help.github.com/articles/generating-ssh-keys/)
