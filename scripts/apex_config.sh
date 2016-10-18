#!/bin/bash
cd $OOS_SOURCE_DIR/apex
perl -i -p -e "s/OOS_APEX_PUB_USR_PWD/$OOS_APEX_PUB_USR_PWD/g" apex_config.sql

sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @apex_config.sql


#Create APEX Users
if [ "$OOS_APEX_CREATE_USER_YN" = "Y" ]; then
  #Starting in APEX 5 need to separate since can only set one set_security_group_id per session
  echo creating APEX Workspace
  echo exit | sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @create_workspace.sql $OOS_APEX_USER_WORKSPACE $OOS_ORACLE_USER_NAME

  echo creating APEX User
  echo exit | sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @create_user.sql $OOS_APEX_USER_WORKSPACE $OOS_ORACLE_USER_NAME $OOS_APEX_USER_NAME $OOS_APEX_USER_PASS


else
  echo Not creating APEX User
fi
