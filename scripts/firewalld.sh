#!/bin/bash

#*** FIREWALLD ***
cd $OOS_SOURCE_DIR/tmp
service firewalld start


#Adding Tomcat firewall ports just in case want to test
#Can copy other examples from: /usr/lib/firewalld/services/
cd /etc/firewalld/services

\cp $OOS_SOURCE_DIR/scripts/tomcat.xml .

systemctl start firewalld
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

#To add Tomcat just run these scripts
#service firewalld stop
#service firewalld start
#firewall-cmd --zone=public --add-service=tomcat
#firewall-cmd --zone=public --remove-service=tomcat

systemctl enable firewalld
