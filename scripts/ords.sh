#!/bin/bash

#*** ORDS ***
cd $OOS_SOURCE_DIR/tmp
curl -O -C - $OOS_ORDS_FILE_URL
mkdir ords
cd ords
unzip ../$OOS_ORDS_FILENAME
cd ..
mv ords /
cd /ords

mkdir conf
java -jar ords.war configdir /ords/conf

#ORDS 3 (when out of beta)
#java -jar ords.war install advanced
#java -jar ords.war install simple
#config: /usr/share/ords/

#ORDS2
if [ "$OOS_DEPLOY_TYPE" == "VAGRANT" ]; 
  then 
    # Attempt silent ORDS configuration if provisioned though Vagrant
    java -jar ords.war set-properties --conf defaults /vagrant/ords/defaults.properties
    java -jar ords.war set-properties --conf apex /vagrant/ords/apex.properties
    java -jar ords.war set-properties --conf apex_al /vagrant/ords/apex_al.properties
    java -jar ords.war set-properties --conf apex_rt /vagrant/ords/apex_rt.properties
  else
    # Skip manual ORDS setup procedures
    echo; echo Manual input required for ORDS config; echo
    echo dbserver: localhost
    echo database listen port: $OOS_ORACLE_TNS_PORT
    echo Enter 1 db service name, or 2 for db SID: 1
    echo Enter the db service name: xe
    echo Enter the db user name: APEX_PUBLIC_USER
    echo Enter the db password for APEX_PUBLIC_USER: $OOS_APEX_PUB_USR_PWD
    echo Confirm password: $OOS_APEX_PUB_USR_PWD
    echo Enter 1 for pwds for RESTful Services db users, 2 use the same pwd as used for APEX_PUBLIC_USER, 3 to skip this step :2
    echo Enter 1 if to start in standalone mode, 2 to exit:2
    echo

    java -jar ords.war

    #SQL Developer administration
    echo; echo Manual input required for ORDS admin listener; echo
    java -jar ords.war user adminlistener "Listener Administrator"
fi;

#Deploy to Tomcat
cd /usr/share/$OOS_TC_NAME/webapps
cp /ords/ords.war .

#Copy APEX images
cd /ords
cp -r $OOS_SOURCE_DIR/tmp/apex/images .
mv images apex_images
