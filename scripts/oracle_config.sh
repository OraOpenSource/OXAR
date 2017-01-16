#!/bin/bash
cd $OOS_SOURCE_DIR/oracle
sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @oracle_config.sql

#Create Oracle Users
if [ "$OOS_ORACLE_CREATE_USER_YN" = "Y" ]; then
  echo Creating Oracle User
  echo exit | sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @create_user.sql $OOS_ORACLE_USER_NAME $OOS_ORACLE_USER_PASS $OOS_ORACLE_CREATE_USER_DEMO_DATA_YN
else
  echo Not creating Oracle User
fi
cd $OOS_SOURCE_DIR/oracle

#XE has SYSTEM as the Default tablespace by default. Set back to USERS
echo Setting default tablespace
sqlplus -L sys/${OOS_ORACLE_PWD} as sysdba @default_tablespace.sql << EOF1
USERS
EOF1

#Unlock sample data as described in docs: http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm#XEGSG120
echo Unlocking sample data \(schema: hr\)
sqlplus -L sys/${OOS_ORACLE_PWD} as sysdba @unlock_sample_data.sql << EOF1
${OOS_HR_PASSWORD}
EOF1
