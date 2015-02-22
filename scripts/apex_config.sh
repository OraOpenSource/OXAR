#!/bin/bash
cd $OOS_SOURCE_DIR/apex
perl -i -p -e "s/OOS_APEX_PUB_USR_PWD/$OOS_APEX_PUB_USR_PWD/g" apex_config.sql

sqlplus sys/$OOS_ORACLE_PWD as sysdba @apex_config.sql


#Create APEX Users
if [ "$OOS_APEX_CREATE_USER_YN" = "Y" ]; then
  echo creating APEX User
  perl -i -p -e "s/OOS_ORACLE_USER_NAME/$OOS_ORACLE_USER_NAME/g" apex_create_user.sql
  perl -i -p -e "s/OOS_APEX_USER_WORKSPACE/$OOS_APEX_USER_WORKSPACE/g" apex_create_user.sql
  perl -i -p -e "s/OOS_APEX_USER_NAME/$OOS_APEX_USER_NAME/g" apex_create_user.sql
  perl -i -p -e "s/OOS_APEX_USER_PASS/$OOS_APEX_USER_PASS/g" apex_create_user.sql

  sqlplus sys/$OOS_ORACLE_PWD as sysdba @apex_create_user.sql
else
  echo Not creating APEX User
fi
