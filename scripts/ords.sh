#!/bin/bash

#*** ORDS ***
ORDS_SOURCE_DIR=${OOS_SOURCE_DIR}/tmp/ords
ORDS_PARAMS=${ORDS_SOURCE_DIR}/params/ords_params.properties
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_ORDS_FILE_URL

systemctl stop tomcat

mkdir -p ${ORDS_SOURCE_DIR}
cd ${ORDS_SOURCE_DIR}
unzip ../$OOS_ORDS_FILENAME
mv -f ${OOS_SOURCE_DIR}/ords/ords_params.properties ${ORDS_PARAMS}

#Update values from config.properties
sed -i s/OOS_APEX_PUB_USR_PWD/${OOS_APEX_PUB_USR_PWD}/ ${ORDS_PARAMS}
sed -i s/OOS_ORDS_PUBLIC_USER_PASSWORD/${OOS_ORDS_PUBLIC_USER_PASSWORD}/ ${ORDS_PARAMS}
sed -i s/OOS_ORACLE_TNS_PORT/${OOS_ORACLE_TNS_PORT}/ ${ORDS_PARAMS}
sed -i s/OOS_ORDS_DEFAULT_TABLESPACE/${OOS_ORDS_DEFAULT_TABLESPACE}/ ${ORDS_PARAMS}
sed -i s/OOS_ORDS_TEMP_TABLESPACE/${OOS_ORDS_TEMP_TABLESPACE}/ ${ORDS_PARAMS}

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
${OOS_ORDS_PUBLIC_USER_PASSWORD}
${OOS_ORDS_DEFAULT_TABLESPACE}
${OOS_ORDS_TEMP_TABLESPACE}
EOF1

cd ${ORDS_SOURCE_DIR}

java -jar ords.war configdir /ords/conf

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
  java -jar ords.war

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
