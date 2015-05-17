#!/bin/bash

#*** SQLcl ***
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_SQLCL_FILE_URL

unzip $OOS_SQLCL_FILENAME

#Make dir if doesn't exist
rm -rf ${ORACLE_HOME}/sqlcl
cp -r sqlcl/ ${ORACLE_HOME}/
chown -R oracle.dba ${ORACLE_HOME}/sqlcl/

#Give sqlcl execute permission
cd ${ORACLE_HOME}/sqlcl/bin
chmod 755 sql

#rename to sqlcl so no confusion (optional)
mv sql sqlcl

#Symbolic link in oracle_home/bin
ln -sf ${ORACLE_HOME}/sqlcl/bin/sqlcl ${ORACLE_HOME}/bin/sqlcl
