#!/bin/bash

#*** ORDS ***
ORDS_SOURCE_DIR=${OOS_SOURCE_DIR}/tmp/ords
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_ORDS_FILE_URL

systemctl stop tomcat

mkdir -p ${ORDS_SOURCE_DIR}
cd ${ORDS_SOURCE_DIR}
unzip ../$OOS_ORDS_FILENAME
mv -f ${OOS_SOURCE_DIR}/ords/ords_params.properties params/ords_params.properties

#clean conf folder out, or create
if [[ -d /ords/conf/ords ]]; then
  rm -rf /ords/conf/ords/*
else
  mkdir -p /ords/conf/ords
fi

unzip ords.war
cd scripts/install/core

#Remove the HIDE property. Script fails otherwise
sed -i.backup s/HIDE// ords_manual_create_rest_users.sql

# 3 inputs: for ords_public_user - password; tablespace; temp tablespace
sqlplus sys/oracle as sysdba @ords_manual_install.sql SYSAUX TEMP ${ORDS_SOURCE_DIR}/scripts/ << EOF1
oracle
USERS
TEMP
EOF1

cd ${ORDS_SOURCE_DIR}

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

#Make tomcat the owner of the configuration
chown -R tomcat.tomcat /ords/conf

#Source tomcat.conf to ensure ${CATALINA_HOME} is set
. /etc/tomcat/tomcat.conf
rm -rf ${CATALINA_HOME}/webapps/ords/ ${CATALINA_HOME}/webapps/ords.war
mv ords.war ${CATALINA_HOME}/webapps/

#Copy APEX images
cd /ords
rm -rf apex_images/
cp -rf ${OOS_SOURCE_DIR}/tmp/apex/images apex_images/

#Make images accessible when using tomcat directly
ln -sf /ords/apex_images/ /usr/share/tomcat/webapps/i

systemctl start tomcat
