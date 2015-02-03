#!/bin/bash

#*** APEX ***
#Download APEX
cd $OOS_SOURCE_DIR/tmp
wget $OOS_APEX_FILE_URL
unzip $OOS_APEX_ZIP_FILENAME

#Install APEX
echo "@apexins SYSAUX SYSAUX TEMP /i/" > run.sql
cd apex
sqlplus sys/$OOS_ORACLE_PWD as sysdba @../run.sql

#Change APEX admin password
cd $OOS_SOURCE_DIR/tmp
echo "@apxxepwd $OOS_APEX_ADMIN_PWD" > run.sql
echo 'exit' >> run.sql
cd apex
sqlplus sys/$OOS_ORACLE_PWD as sysdba @../run.sql


#APEX REST install
cd $OOS_SOURCE_DIR/tmp
#Setup restful services
echo "@apex_rest_config_core.sql $OOS_APEX_LISTENERUN_PWD $OOS_APEX_REST_PUB_USR_PWD" > run.sql
echo "exit" >> run.sql
cd apex
sqlplus sys/$OOS_ORACLE_PWD as sysdba @../run.sql
