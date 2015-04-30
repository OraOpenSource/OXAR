#!/bin/bash

#*** SQLcl ***
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_MODULE_SQLCL

unzip $OOS_SQLCL_FILENAME

#Make dir if doesn't exist
mkdir -p /oracle

#remove existing copy of sqlcl
rm -rf /oracle/sqlcl
cp -r sqlcl /oracle

#Give sqlcl execute permission
cd /oracle/sqlcl/bin
chmod 755 sql

#rename to sqlcl so no confusion (optional)
mv sql sqlcl

#Temporary access:
PATH=$PATH:/oracle/sqlcl/bin

#Permanent access:
cp $OOS_SOURCE_DIR/profile.d/oos_sqlcl.sh /etc/profile.d/
