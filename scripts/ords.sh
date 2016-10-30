#!/bin/bash

#*** ORDS ***
ORDS_SOURCE_DIR=${OOS_SOURCE_DIR}/tmp/ords
ORDS_PARAMS=${ORDS_SOURCE_DIR}/params/ords_params.properties
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_ORDS_FILE_URL

#stop tomcat before upgrading/installing ORDS
systemctl stop ${TOMCAT_SERVICE_NAME}

#Create a directory to unzip ORDS into (tmp/ords)
mkdir -p ${ORDS_SOURCE_DIR}
cd ${ORDS_SOURCE_DIR}
#extract ords*.zip
unzip ../$OOS_ORDS_FILENAME
#move the parameters file from ords to tmp/ords/ (where ords files are)
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

java -jar ords.war configdir /etc

#Since the manual installation changes over time, beginning with 3.0.4, check
#the version to act per version. Parameters set in the validation (fired from
#config_validations.sh)
#Available:
# * VERSION_NUM
# * ORDS_MAJOR
# * ORDS_MINOR
# * ORDS_REVISION

#3.0.4
#Refer to: http://docs.oracle.com/cd/E56351_01/doc.30/e56293/install.htm#CHDFJHEA
if [[ "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.4" ]]; then
    #Make a folder to unzip ords.war into (tmp/ords/ords-archive)
    mkdir -p ords-archive
    cd ords-archive
    #unzip all the files
    unzip ../ords.war

    #Manual installation is stored in this path (scripts/install/core)
    #This parameters etc changes over time.
    #See: http://docs.oracle.com/cd/E56351_01/doc.30/e56293/install.htm#CHDFJHEA
    cd scripts/install/core
    #Need to remove the hide property so the password can be piped in
    sed -i.backup s/HIDE// ords_manual_install.sql
    sqlplus -L sys/${OOS_ORACLE_PWD} as sysdba @ords_manual_install_db_def_tbs.sql ${ORDS_SOURCE_DIR}/logs/ << EOF1
        ${OOS_ORDS_PUBLIC_USER_PASSWORD}
#indent removed to properly read EOF1 (without tab prefix) to end statement
EOF1

    #config ORDS
    cd ${ORDS_SOURCE_DIR}
    java -jar ords.war
    rm -rf ords-archive
elif [[ "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.5"
    || "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.6"
    || "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.7"
    || "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.8" ]]; then
    java -jar ords.war install simple
fi

cd ${ORDS_SOURCE_DIR}
java -jar ords.war set-property security.verifySSL false
java -jar ords.war set-property security.requestValidationFunction wwv_flow_epg_include_modules.authorize

if [ "${OOS_ENABLE_XLS2COLLECTION}" == "Y" ]; then
    java -jar ords.war set-property apex.excel2collection true
    java -jar ords.war set-property apex.excel2collection.useSheetName true
fi

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

systemctl start ${TOMCAT_SERVICE_NAME}
