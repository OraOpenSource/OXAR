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
mkdir $OOS_SOURCE_DIR/tmp

#Required packages and updates


#Yum updates
cd $OOS_SOURCE_DIR
source ./scripts/yum.sh


#Load configurations
cd $OOS_SOURCE_DIR
source ./config.sh

#Install ratom (optional)
cd $OOS_SOURCE_DIR
source ./scripts/ratom.sh

#Expand swap
cd $OOS_SOURCE_DIR
source ./scripts/swap_space.sh

#Oracle install
cd $OOS_SOURCE_DIR
source ./scripts/oracexe.sh

#TODO Oracle update of .ora files


#APEX install
cd $OOS_SOURCE_DIR
source ./scripts/apex.sh

#Oracle config
cd $OOS_SOURCE_DIR
source ./scripts/oracle_config.sh


#Node.js
cd $OOS_SOURCE_DIR
source ./scripts/node4ords.sh


#Tomcat
cd $OOS_SOURCE_DIR
source ./scripts/tomcat.sh


#Firewalld
cd $OOS_SOURCE_DIR
source ./scripts/firewalld.sh



#ORDS
#**** Note for now must run this manually (step by step)
cd $OOS_SOURCE_DIR
source ./scripts/ords.sh



#*** CLEANUP ***
cd $OOS_SOURCE_DIR
rm -rf tmp

#Reboot
shutdown -r now
