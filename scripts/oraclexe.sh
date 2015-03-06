#!/bin/bash

#*** ORACLE ***
#Get Files needed to install
cd $OOS_SOURCE_DIR/tmp
curl -O -C - $OOS_ORACLE_FILE_URL

#Install Oracle
cd $OOS_SOURCE_DIR/tmp
unzip $OOS_ORACLE_FILENAME
cd Disk1
if [ $OOS_OS_TYPE = "Debian" ] then
  alien --scripts -d $OOS_ORACLE_FILENAME_RPM
else
  rpm -ivh $OOS_ORACLE_FILENAME_RPM
fi


#Silent configuration
cd response/
#Note: Use double quotes as pearl doesn't expand shell variables with single quotes
perl -i -p -e "s/ORACLE_HTTP_PORT=8080/ORACLE_HTTP_PORT=$OOS_ORACLE_HTTP_PORT/g" xe.rsp
perl -i -p -e "s/ORACLE_PASSWORD=<value required>/ORACLE_PASSWORD=$OOS_ORACLE_PWD/g" xe.rsp
perl -i -p -e "s/ORACLE_CONFIRM_PASSWORD=<value required>/ORACLE_CONFIRM_PASSWORD=$OOS_ORACLE_PWD/g" xe.rsp
perl -i -p -e "s/ORACLE_LISTENER_PORT=1521/ORACLE_LISTENER_PORT=$OOS_ORACLE_TNS_PORT/g" xe.rsp


#/etc/init.d/oracle-xe configure responseFile=xe.rsp >> XEsilentinstall.log
/etc/init.d/oracle-xe configure responseFile=xe.rsp

#Configure env variables
cd /u01/app/oracle/product/11.2.0/xe/bin
. ./oracle_env.sh

#Configure for all profiles (so accesible on boot login)
echo . $ORACLE_HOME/bin/oracle_env.sh >> /etc/profile

#Update the .ora files to use localhost instead of the current hostname
#This is required since Amazon AMIs change the hostname
cd $ORACLE_HOME/network/admin
#backup files
mv listener.ora listener.bkp
mv tnsnames.ora tnsnames.bkp

#cp new files from OOS
cp $OOS_SOURCE_DIR/oracle/listener.ora .
cp $OOS_SOURCE_DIR/oracle/tnsnames.ora .

perl -i -p -e "s/1521/$OOS_ORACLE_TNS_PORT/g" listener.ora
perl -i -p -e "s/1521/$OOS_ORACLE_TNS_PORT/g" tnsnames.ora

#restart oracle
/etc/init.d/oracle-xe stop
/etc/init.d/oracle-xe start

#Cleanup
cd $OOS_SOURCE_DIR/tmp
rm -rf $OOS_ORACLE_FILENAME
rm -rf Disk1
