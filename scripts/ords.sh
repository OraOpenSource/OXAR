#!/bin/bash

#*** ORDS ***
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_ORDS_FILE_URL
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
if [ "$OOS_DEPLOY_TYPE" == "VAGRANT" ]; then
  #Replace mnemonics
  perl -i -p -e "s/OOS_APEX_PUB_USR_PWD/$OOS_APEX_PUB_USR_PWD/g" $OOS_SOURCE_DIR/ords/defaults.properties
  perl -i -p -e "s/OOS_ORACLE_TNS_PORT/$OOS_ORACLE_TNS_PORT/g" $OOS_SOURCE_DIR/ords/defaults.properties

  # Attempt silent ORDS configuration if provisioned though Vagrant
  java -jar ords.war set-properties --conf defaults $OOS_SOURCE_DIR/ords/defaults.properties
  java -jar ords.war set-properties --conf apex $OOS_SOURCE_DIR/ords/apex.properties
  java -jar ords.war set-properties --conf apex_al $OOS_SOURCE_DIR/ords/apex_al.properties
  java -jar ords.war set-properties --conf apex_rt $OOS_SOURCE_DIR/ords/apex_rt.properties
else
  echo; echo Manual input required for ORDS config; echo
  echo dbserver: localhost
  echo database listen port: $OOS_ORACLE_TNS_PORT
  echo Enter 1 db service name, or 2 for db SID: 1
  echo Enter the db service name: xe
  echo Enter the db user name: APEX_PUBLIC_USER
  echo Enter the db password for APEX_PUBLIC_USER: $OOS_APEX_PUB_USR_PWD
  echo Confirm password: $OOS_APEX_PUB_USR_PWD
  echo Enter 1 for pwds for RESTful Services db users, 2 use the same pwd as used for APEX_PUBLIC_USER, 3 to skip this step: 2
  echo Enter 1 if to start in standalone mode, 2 to exit: 2
  echo

  java -jar ords.war

  #SQL Developer administration
  echo; echo Manual input required for ORDS admin listener; echo
  echo; echo password: $OOS_ORDS_PASSWORD
  echo confirm password: $OOS_ORDS_PASSWORD
  echo;
  java -jar ords.war user $OOS_ORDS_USERNAME "Listener Administrator"
fi;

#Make tomcat the owner
chown -R tomcat.tomcat /ords/conf

#Deploy to Tomcat
cd ${CATALINA_HOME}/webapps/
cp /ords/ords.war .

#Copy APEX images
cd /ords
cp -r $OOS_SOURCE_DIR/tmp/apex/images .
mv images apex_images

