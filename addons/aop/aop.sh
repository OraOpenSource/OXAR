#!/bin/bash

# *** AOP ***
cd $OOS_SOURCE_DIR

# Create schema for AOP
cd $OOS_SOURCE_DIR/oracle
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @create_user.sql $OOS_AOP_SCHEMA_NAME $OOS_AOP_SCHEMA_PASS Y


cd $OOS_SOURCE_DIR

# Create AOP Workspace
echo creating AOP APEX Workspace
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @apex/create_workspace.sql $OOS_AOP_APEX_WORKSPACE $OOS_AOP_SCHEMA_NAME

# Create AOP Workspace User
echo creating AOP APEX User
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @apex/create_user.sql $OOS_AOP_APEX_WORKSPACE $OOS_AOP_SCHEMA_NAME $OOS_AOP_APEX_USER_NAME $OOS_AOP_APEX_USER_PWD


# AOP ACL
echo Setting up AOP
cd $OOS_SOURCE_DIR/addons/aop
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @aop_setup.sql $OOS_AOP_SCHEMA_NAME
echo exit | sqlplus $OOS_AOP_SCHEMA_NAME/$OOS_AOP_SCHEMA_PASS @aop_db_pkg.sql 
echo exit | sqlplus $OOS_AOP_SCHEMA_NAME/$OOS_AOP_SCHEMA_PASS @install_db_sample_obj.sql 
echo exit | sqlplus $OOS_AOP_SCHEMA_NAME/$OOS_AOP_SCHEMA_PASS @aop_sample3_db_obj.sql 
echo exit | sqlplus $OOS_AOP_SCHEMA_NAME/$OOS_AOP_SCHEMA_PASS @aop_db_sample_pkg.sql 
echo exit | sqlplus $OOS_AOP_SCHEMA_NAME/$OOS_AOP_SCHEMA_PASS @db_pkg_native_compile.sql 
# install sample database app here (APEX 5.1 - change to _50 for APEX 5.0 version)
echo exit | sqlplus sys/$OOS_ORACLE_PWD as sysdba @install_apex_app.sql $OOS_AOP_APEX_WORKSPACE $OOS_AOP_SCHEMA_NAME 500 AOP aop_sample3_apex_app_51.sql