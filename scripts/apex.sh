#!/bin/bash

#*** APEX ***
#Download APEX
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_APEX_FILE_URL
unzip $OOS_APEX_ZIP_FILENAME

#Install APEX
echo "@apexins SYSAUX SYSAUX TEMP /i/" > run.sql
cd apex
sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @../run.sql

#Change APEX admin password
cd $OOS_SOURCE_DIR/tmp

#${OOS_APEX_ZIP_FILENAME,,} converts to lowercase
if [[ ${OOS_APEX_ZIP_FILENAME,,} != "apex_5"* ]]
then
  echo "Pre APEX 5.x Install. Using old change password method";

  echo "@apxxepwd $OOS_APEX_ADMIN_PWD" > run.sql
  echo 'exit' >> run.sql
  cd apex
  sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @../run.sql

else
  echo "APEX 5.0 Install. Using new change password method";

  #Need to remove the "HIDE" from the accept statement or else the << EOF1 doesn't work
  cd apex
  perl -i -p -e 's/password \[\] " HIDE/password \[\] "/g' apxchpwd.sql

  #Make sure no indents
sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @apxchpwd << EOF1
$OOS_APEX_ADMIN_USER_NAME
$OOS_APEX_ADMIN_EMAIL
$OOS_APEX_ADMIN_PWD
EOF1
fi




#APEX REST install
cd $OOS_SOURCE_DIR/tmp
#Setup restful services
echo "@apex_rest_config_core.sql $OOS_APEX_LISTENERUN_PWD $OOS_APEX_REST_PUB_USR_PWD" > run.sql
echo "exit" >> run.sql
cd apex
sqlplus -L sys/$OOS_ORACLE_PWD as sysdba @../run.sql
