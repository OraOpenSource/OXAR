# Securing Linux

This document describes how to secure your linux environment. You should consider these suggestions if you are putting your OXAR installation on the internet or any publicly available server.

**Note: we are not security experts and as such these are recommendations that we've found helpful in the past. By no means will this guarantee that your server is 100% secure**

To help out we've provided a script below that you can use and alter as you see fit. At the beginning they're variables (tagged with `CHANGEME` that should be filled out. It's recommended that you run this line by line so that you can determine if you want to execute each command. If you don't, just skip that line.


```bash

# CHANGEME *** Change the values of these variables ***

oxar_folder=CHANGEME
new_os_user=CHANGEME
new_os_pass=CHANGEME
id_rsa_pub=CHANGEME
host_name=CHANGEME

# Only change if any of the default settings were changed
oracle_system_pass=oracle
apex_workspace_oos_user=OOS_USER

# Ex:
# new_os_user=martin
# new_os_pass=martin
# id_rsa_pub="ssh-rsa keyinfothat_is_obtained_from_your_comptuer_~.ssh/id_rsa.pub_file"
# oxar_folder="/tmp/oxar"
# host_name=prod01
# Note: hostname is not required but nice to set

# Set hostname
hostnamectl set-hostname $host_name

#to see status:
#hostnamectl status


# Create new OS user
cd $oxar_folder
./utils/os/create_user.sh $new_os_user $new_os_pass $id_rsa_pub

# Disable root SSH login
echo '' >> /etc/ssh/sshd_config
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config

# Disable password authentication alltogether
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl reload sshd


# APEX changes
echo -e "exec apex_instance_admin.remove_workspace(p_workspace => '$apex_workspace_oos_user', p_drop_users => 'Y');\n exit;" | sqlplus system/oracle

```
