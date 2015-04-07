#!/bin/bash

#*** FIREWALLD ***
cd $OOS_SOURCE_DIR/tmp
service firewalld start


#Adding Tomcat firewall ports just in case want to test
#Can copy other examples from: /usr/lib/firewalld/services/
cd /etc/firewalld/services

cp $OOS_SOURCE_DIR/firewalld/*.xml .

#Replace dynamic ports
perl -i -p -e "s/OOS_ORACLE_TNS_PORT/$OOS_ORACLE_TNS_PORT/g" oracle.xml


systemctl start firewalld
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

#To add Tomcat/Oracle just run these scripts
#service firewalld stop
#service firewalld start

#Note: add the --permanent for permanent usage
#firewall-cmd --zone=public --add-service=tomcat
#firewall-cmd --zone=public --remove-service=tomcat

if [ "$OOS_FIREWALL_TOMCAT_YN" == "Y" ]; then
  firewall-cmd --zone=public --add-service=tomcat --permanent
fi

if [ "$OOS_FIREWALL_ORACLE_YN" == "Y" ]; then
  firewall-cmd --zone=public --add-service=oracle --permanent
fi

#Reload for any changes in above config
firewall-cmd --reload

systemctl enable firewalld


#List zone info for logs
firewall-cmd --zone=public --list-all
