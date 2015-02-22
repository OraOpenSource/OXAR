#!/usr/bin/env bash
#Example from: http://stackoverflow.com/questions/5228345/bash-script-how-to-reference-a-file-for-variables



#Module Options (Y/N)
#CHANGEME (for the modules below)

#Added as part of #11
OOS_MODULE_ORACLE=Y
#APEX=APEX, Tomcat, ORDS
OOS_MODULE_APEX=Y



#DO NOT modify these modules
OOS_MODULE_ORDS=Y
if [ "$OOS_MODULE_APEX" = "N" ]; then
  OOS_MODULE_ORDS=N;
fi;

OOS_MODULE_TOMCAT=Y
if [ "$OOS_MODULE_APEX" = "N" ]; then
  OOS_MODULE_TOMCAT=N;
fi;

#Always install Node.js
OOS_MODULE_NODEJS=Y

OOS_MODULE_NODE4ORDS=Y
if [ "$OOS_MODULE_APEX" = "N" ]; then
  OOS_MODULE_NODE4ORDS=N;
fi;


OOS_MODULE_NODE_ORACLEDB=Y
if [ "$OOS_MODULE_ORACLE" = "N" ]; then
  OOS_MODULE_NODE_ORACLEDB=N;
fi;


echo \*\*\* Module Configuration \*\*\*
echo Oracle XE: $OOS_MODULE_ORACLE
echo APEX: $OOS_MODULE_APEX
echo ORDS: $OOS_MODULE_ORDS
echo Tomcat: $OOS_MODULE_TOMCAT
echo Node4ORDS: $OOS_MODULE_NODE4ORDS
echo Node.js: $OOS_MODULE_NODEJS
echo Node-oracledb: $OOS_MODULE_NODE_ORACLEDB



#System

#Oracle
OOS_ORACLE_PWD=oracle
#Use 8081 so no conflicts with Tomcat. This is configured for plsql gateway (not used)
OOS_ORACLE_HTTP_PORT=8081
OOS_ORACLE_TNS_PORT=1521

#URL to download Oracle XE rpm from
#Ex: http://<server_name>/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
#To download go to: http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html
#Can be url (like http://myserver.com/file.zip) or file reference (file:///tmp/file.zip)
OOS_ORACLE_FILE_URL=CHANGEME
OOS_ORACLE_FILENAME=${OOS_ORACLE_FILE_URL##*/}
OOS_ORACLE_FILENAME_RPM=${OOS_ORACLE_FILENAME%.*}


#Create Oracle and APEX User (optional)
#If Change to "N" to disable creating default Oracle User
OOS_ORACLE_CREATE_USER_YN=Y
OOS_ORACLE_USER_NAME=oos_user
OOS_ORACLE_USER_PASS=oracle
OOS_APEX_CREATE_USER_YN=Y
OOS_APEX_USER_WORKSPACE=oos_user
OOS_APEX_USER_NAME=oos_user
OOS_APEX_USER_PASS=oracle



#APEX Configs
#URL to download APEX from
#Ex: http://<server_name>/apex_4.2.6_en.zip
#To download go to: http://download.oracleapex.com
#Can be url (like http://myserver.com/file.zip) or file reference (file:///tmp/file.zip)
OOS_APEX_FILE_URL=CHANGEME
OOS_APEX_ZIP_FILENAME=${OOS_APEX_FILE_URL##*/}
#Note: APEX admin password has rules associated with it, which is why it is a more complicated password
OOS_APEX_ADMIN_PWD=Oracle1!
OOS_APEX_PUB_USR_PWD=oracle

#APEX REST
OOS_APEX_LISTENERUN_PWD=oracle
OOS_APEX_REST_PUB_USR_PWD=oracle

#ORDS
#File for Oracle Rest Data Services (ORDS) download
#Ex: http://<server_name>/ords.3.0.0.343.07.58.zip
#To download go to: http://www.oracle.com/technetwork/developer-tools/rest-data-services/overview/index.html
#Note, for now ORDS 2 is in production. ORDS 3 specific scripts have also been included and need to be finalized once its out of beta
#Can be url (like http://myserver.com/file.zip) or file reference (file:///tmp/file.zip)
OOS_ORDS_FILE_URL=CHANGEME
OOS_ORDS_FILENAME=${OOS_ORDS_FILE_URL##*/}



#TOMCAT config
#Note: If not a tar.gz then remove the additional ".*" in OOS_TC_NAME
OOS_TC_FILE_URL=https://s3-us-west-2.amazonaws.com/orclfiles/apache-tomcat-7.0.57.tar.gz
OOS_TC_FILENAME=${OOS_TC_FILE_URL##*/}
OOS_TC_NAME=${OOS_TC_FILENAME%.*.*}

OOS_TC_USERNAME=tomcat
OOS_TC_PWD=oracle



#*** VALIDATIONS ***
# (don't modify the CHANGEME here)
if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  if [ "$OOS_ORACLE_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORACLE_FILE_URL" = "" ]; then
    echo OOS_ORACLE_FILE_URL must be specified
    exit 1
  else
    echo OOS_ORACLE_FILE_URL=$OOS_ORACLE_FILE_URL
  fi
fi

if [ "$OOS_MODULE_APEX" = "Y" ]; then
  if [ "$OOS_APEX_FILE_URL" = "CHANGEME" ] || [ "$OOS_APEX_FILE_URL" = "" ]; then
    echo OOS_APEX_FILE_URL must be specified
    exit 1
  else
    echo OOS_APEX_FILE_URL=$OOS_APEX_FILE_URL
  fi
fi

if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  if [ "$OOS_ORDS_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORDS_FILE_URL" = "" ]; then
    echo OOS_ORDS_FILE_URL must be specified
    exit 1
  else
    echo OOS_ORDS_FILE_URL=$OOS_ORDS_FILE_URL
  fi
fi
