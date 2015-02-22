#!/bin/bash

#Notes
#
#Some input is required before running
#Search for CHANGEME and modify before running
#
#
#- Passwords
#All passwords (expect for APEX Admin) are set to "oracle" by default. You can change accordingly
#
#
#- ratom
#This tool allows you to edit files in atom on your desktop rather than vi on server
#You must install the Atom editor: https://atom.io/ along with the Remote Atom plugin: https://github.com/randy3k/remote-atom
#When connecting to server use:
#ssh -R 52698:localhost:52698 root@<server_name/ip>
#
#To edit a file on the server, simply type:
#ratom <my_file> and then look in your Atom editor to modify


#*** LINUX ***
OOS_SOURCE_DIR=$PWD
mkdir -p $OOS_SOURCE_DIR/tmp

#Required packages and updates


#Yum updates
echo; echo \* Running yum updates \*; echo
cd $OOS_SOURCE_DIR
source ./scripts/yum.sh


#Load configurations
echo; echo \* Loading configurations \*; echo
cd $OOS_SOURCE_DIR
source ./config.sh

#Install ratom (optional)
echo; echo \* Installing ratom \*; echo
if [ "$(which ratom)" == "" ]; then
  cd $OOS_SOURCE_DIR
  source ./scripts/ratom.sh
else
  echo ratom already installed
fi


#Oracle install
if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  #Expand swap
  echo; echo \* Expanding Swap Space \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/swap_space.sh

  echo; echo \* Installing Oracle XE \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/oracexe.sh

  #Oracle config
  echo; echo \* Oracle Config \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/oracle_config.sh
fi

#APEX install
if [ "$OOS_MODULE_APEX" = "Y" ]; then
  echo; echo \* Installing APEX \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/apex.sh

  echo; echo \* Configuring APEX \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/apex_config.sh
fi


#Node.js
if [ "$OOS_MODULE_NODE4ORDS" = "Y" ]; then
  echo; echo \* Installing Node.js \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/node4ords.sh
fi


#Tomcat
if [ "$OOS_MODULE_TOMCAT" = "Y" ]; then
  echo; echo \* Installing Tomcat \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/tomcat.sh
fi


#Firewalld
echo; echo \* Configuring firewalld \*; echo
cd $OOS_SOURCE_DIR
source ./scripts/firewalld.sh



#ORDS
#**** Note for now must run this manually (step by step)
if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  echo; echo \* Installing ORDS \*; echo
  cd $OOS_SOURCE_DIR
  source ./scripts/ords.sh
fi;



#*** CLEANUP ***
echo; echo \* Cleanup \*; echo
cd $OOS_SOURCE_DIR
rm -rf tmp

#Reboot
shutdown -r now
