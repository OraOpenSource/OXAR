#!/bin/bash

#*** ORDS ***
ORDS_SOURCE_DIR=${OOS_SOURCE_DIR}/tmp/ords
ORDS_PARAMS=${ORDS_SOURCE_DIR}/params/ords_params.properties
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_ORDS_FILE_URL

${OOS_SERVICE_CTL} stop ${TOMCAT_SERVICE_NAME}

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
sed -i s/OOS_APEX_LISTENERUN_PWD/${OOS_APEX_LISTENERUN_PWD}/ ${ORDS_PARAMS}
sed -i s/OOS_APEX_REST_PUB_USR_PWD/${OOS_APEX_REST_PUB_USR_PWD}/ ${ORDS_PARAMS}
sed -i s/OOS_ORACLE_PWD/${OOS_ORACLE_PWD}/ ${ORDS_PARAMS}

#clean conf folder out, or create
if [[ -d /etc/ords/ ]]; then
  rm -rf /etc/ords/*
else
  mkdir -p /etc/ords/
fi

mkdir -p ords-archive
cd ords-archive
unzip ../ords.war
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
rm -rf ords-archive

java -jar ords.war configdir /etc

#config ORDS
java -jar ords.war

#Make tomcat the owner of the configuration
chown -R ${TOMCAT_USER}.${TOMCAT_USER} /etc/ords

rm -rf ${CATALINA_HOME}/webapps/ords/ ${CATALINA_HOME}/webapps/ords.war
mv ords.war ${CATALINA_HOME}/webapps/

#Place ords files in ${ORACLE_HOME}/ords
mkdir -p ${ORACLE_HOME}/ords
ln -sf ${CATALINA_HOME}/webapps/ords.war ${ORACLE_HOME}/ords/ords.war
ln -sf /etc/ords $ORACLE_HOME/ords/conf
mv * ${ORACLE_HOME}/ords/

#Copy APEX images
mkdir -p /ords
cd /ords
rm -rf apex_images/
cp -rf ${OOS_SOURCE_DIR}/tmp/apex/images apex_images/

#Make images accessible when using tomcat directly
ln -sf /ords/apex_images/ ${CATALINA_HOME}/webapps/i

${OOS_SERVICE_CTL} start ${TOMCAT_SERVICE_NAME}
