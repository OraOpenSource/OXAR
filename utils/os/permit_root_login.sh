#!/bin/bash
#The goal of this script is to set the PermitRootLogin flag for SSH logins
#Ideally it would be used to disable root login
#TODO this is still under development


#Inputs
OOS_OS_SSH_PERMIT_ROOT_LOGIN_YN=$1


if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root."
  echo "Try using sudo"
  exit 1
fi



OOS_OS_SSH_PERMIT_ROOT_LOGIN_YES_NO=yes

if [ "$OOS_OS_SSH_PERMIT_ROOT_LOGIN_YN" = "N" ]; then
  OOS_OS_SSH_PERMIT_ROOT_LOGIN_YES_NO=no
fi


# Set permission
sed -i 's/#\?PermitRootLogin.*/PermitRootLogin $OOS_OS_SSH_PERMIT_ROOT_LOGIN_YES_NO/i' sshd_config
# restart sshd service
service sshd restart
