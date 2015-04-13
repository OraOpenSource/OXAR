#!/bin/bash
cd $OOS_SOURCE_DIR/oracle
sqlplus sys/$OOS_ORACLE_PWD as sysdba @oracle_config.sql

#Create Oracle Users
if [ "$OOS_ORACLE_CREATE_USER_YN" = "Y" ]; then
  echo creating Oracle User
  sqlplus sys/$OOS_ORACLE_PWD as sysdba @oracle_create_user.sql $OOS_ORACLE_USER_NAME $OOS_ORACLE_USER_PASS $OOS_ORACLE_CREATE_USER_DEMO_DATA_YN

else
  echo Not creating Oracle User
fi
