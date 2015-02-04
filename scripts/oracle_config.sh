#!/bin/bash
cd $OOS_SOURCE_DIR/oracle
perl -i -p -e "s/OOS_APEX_PUB_USR_PWD/$OOS_APEX_PUB_USR_PWD/g" oracle_config.sql

sqlplus sys/$OOS_ORACLE_PWD as sysdba @scripts/oracle_config.sql

#Create Oracle Users
if [ "$OOS_CREATE_ORACLE_USER_YN" = "Y" ]; then
  echo creating Oracle User
  perl -i -p -e "s/OOS_ORACLE_USER_NAME/$OOS_ORACLE_USER_NAME/g" oracle_create_user.sql
  perl -i -p -e "s/OOS_ORACLE_USER_PASS/$OOS_ORACLE_USER_PASS/g" oracle_create_user.sql
  perl -i -p -e "s/OOS_APEX_USER_WORKSPACE/$OOS_APEX_USER_WORKSPACE/g" oracle_create_user.sql
  perl -i -p -e "s/OOS_APEX_USER_NAME/$OOS_APEX_USER_NAME/g" oracle_create_user.sql
  perl -i -p -e "s/OOS_APEX_USER_PASS/$OOS_APEX_USER_PASS/g" oracle_create_user.sql

  sqlplus sys/$OOS_ORACLE_PWD as sysdba @oracle_create_user.sql
else
  echo Not creating Oracle User
fi
