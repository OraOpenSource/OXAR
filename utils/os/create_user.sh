#!/bin/bash
#Create user with RSA public key (so no password)


args=$#

if [[ $args -lt 2 ]]; then
  echo "create_use.sh: Invalid number of arguments" >&2
  echo "Usage: create_user.sh <username> <password> <rsa_pub_key (optional)>" >&2
  exit 1
fi

#CU = Create User
OOS_UTIL_CU_USERNAME=$1
OOS_UTIL_CU_PASSWORD=$2
OOS_UTIL_CU_RSA_PUB_KEY=$3


if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root."
  echo "Try using sudo"
  exit 1
fi


#Create User
useradd $OOS_UTIL_CU_USERNAME
echo $OOS_UTIL_CU_USERNAME:$OOS_UTIL_CU_PASSWORD | /usr/sbin/chpasswd

#Add User to sudoers
#echo '$OOS_UTIL_CU_USERNAME ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

#Add user to wheel group (CentOS)
usermod -a -G wheel $OOS_UTIL_CU_USERNAME
usermod -a -G sshd $OOS_UTIL_CU_USERNAME

#Future: to change password: echo $new_os_user:$new_os_pass | /usr/sbin/chpasswd


#Setup for authorized_keys
cd /home/$OOS_UTIL_CU_USERNAME
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
chown -R $OOS_UTIL_CU_USERNAME:$OOS_UTIL_CU_USERNAME /home/$OOS_UTIL_CU_USERNAME

# Set the SSH key
if ! [ -z "$OOS_UTIL_CU_RSA_PUB_KEY" ]; then
  echo "Adding RSA key"
  echo $OOS_UTIL_CU_RSA_PUB_KEY >> /home/$OOS_UTIL_CU_USERNAME/.ssh/authorized_keys
fi
