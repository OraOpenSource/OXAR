#!/bin/bash

#*** FIREWALLD ***
cd $OOS_SOURCE_DIR/tmp
systemctl stop firewalld

if hash ufw 2>/dev/null; then
    update-rc.d firewalld disable

    echo "y" | ufw enable
    ufw allow http
    ufw allow ssh

    if [ "$OOS_FIREWALL_ORACLE_YN" == "Y" ]; then
        ufw allow ${OOS_ORACLE_TNS_PORT}/tcp
    fi

    if [ "$OOS_FIREWALL_TOMCAT_YN" == "Y" ]; then
        ufw allow ${OOS_TOMCAT_PORT}/tcp
    fi
    ufw reload
    ufw status

else
    #Adding Tomcat firewall ports just in case want to test
    #Can copy other examples from: /usr/lib/firewalld/services/
    cd /etc/firewalld/services

    cp $OOS_SOURCE_DIR/firewalld/*.xml .

    #Replace dynamic ports
    perl -i -p -e "s/OOS_ORACLE_TNS_PORT/$OOS_ORACLE_TNS_PORT/g" oracle.xml
    perl -i -p -e "s/OOS_TOMCAT_PORT/$OOS_TOMCAT_PORT/g" tomcat.xml


    systemctl start firewalld
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --zone=public --add-service=https --permanent
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
fi
