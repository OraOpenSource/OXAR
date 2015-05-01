#!/bin/bash
cd $OOS_SOURCE_DIR/oracle
sqlplus sys/$OOS_ORACLE_PWD as sysdba @oracle_config.sql

#Create Oracle Users
if [ "$OOS_ORACLE_CREATE_USER_YN" = "Y" ]; then
  echo Creating Oracle User
  sqlplus sys/$OOS_ORACLE_PWD as sysdba @oracle_create_user.sql $OOS_ORACLE_USER_NAME $OOS_ORACLE_USER_PASS $OOS_ORACLE_CREATE_USER_DEMO_DATA_YN

else
  echo Not creating Oracle User
fi

#Create ACL
if [ "$OOS_ORACLE_ACL_APEX_ALL_YN" = "Y" ]; then
  echo Creating Network ACL ALL
  sqlplus sys/$OOS_ORACLE_PWD as sysdba @apex_acl_all.sql
else
  echo Not creating Oracle User
fi
