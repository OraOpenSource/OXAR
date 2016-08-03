#!/bin/bash

# *** AOP ***
cd $OOS_SOURCE_DIR

# Create schema for AOP
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @utils/oracle/create_user.sql $OOS_AOP_SCHEMA_NAME $OOS_AOP_SCHEMA_PASS

# Create AOP Workspace
echo creating AOP APEX Workspace
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @utils/apex/create_workspace.sql $OOS_AOP_APEX_WORKSPACE $OOS_AOP_SCHEMA_NAME

# Create AOP Workspace User
echo creating AOP APEX User
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @../utils/apex/create_user.sql $OOS_AOP_APEX_WORKSPACE $OOS_AOP_SCHEMA_NAME $OOS_AOP_APEX_USER_NAME $OOS_AOP_APEX_USER_PWD
