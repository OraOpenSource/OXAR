#!/bin/bash
#TODO purpose/description
#TODO this is still under development


#CU = Create User
OOS_UTIL_CU_USERNAME=$1
OOS_UTIL_CU_RSA_PUB_KEY_URL=$2


if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root."
  echo "Try using sudo"
  exit 1
fi



#Create User
useradd $OOS_UTIL_CU_USERNAME

#Add User to sudoers
#echo '$OOS_UTIL_CU_USERNAME ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

#Add user to wheel group (CentOS)
useradd -G wheel $OOS_UTIL_CU_USERNAME


#Setup for authorized_keys
runuser -l $OOS_UTIL_CU_USERNAME -c 'mkdir -p ~/.ssh'
runuser -l $OOS_UTIL_CU_USERNAME -c 'chmod 700 ~/.ssh'
runuser -l $OOS_UTIL_CU_USERNAME -c 'touch ~/.ssh/authorized_keys'
runuser -l $OOS_UTIL_CU_USERNAME -c 'chmod 640 ~/.ssh/authorized_keys'

#Download ssh key and pipe into authorized_keys
curl -L "$OOS_UTIL_CU_RSA_PUB_KEY_URL" >> $(eval echo "~$OOS_UTIL_CU_USERNAME")/.ssh/authorized_keys
