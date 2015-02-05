#!/bin/bash

#*** ORACLE ***
#Get Files needed to install
cd $OOS_SOURCE_DIR/tmp
wget $OOS_ORACLE_FILE_URL

#Install Oracle
cd $OOS_SOURCE_DIR/tmp
unzip $OOS_ORACLE_FILENAME
cd Disk1
rpm -ivh $OOS_ORACLE_FILENAME_RPM

#Silent configuration
cd response/
#Note: Use double quotes as pearl doesn't expand shell variables with single quotes
perl -i -p -e "s/ORACLE_HTTP_PORT=8080/ORACLE_HTTP_PORT=$OOS_ORACLE_HTTP_PORT/g" xe.rsp
perl -i -p -e "s/ORACLE_PASSWORD=<value required>/ORACLE_PASSWORD=$OOS_ORACLE_PWD/g" xe.rsp
perl -i -p -e "s/ORACLE_CONFIRM_PASSWORD=<value required>/ORACLE_CONFIRM_PASSWORD=$OOS_ORACLE_PWD/g" xe.rsp

#/etc/init.d/oracle-xe configure responseFile=xe.rsp >> XEsilentinstall.log
/etc/init.d/oracle-xe configure responseFile=xe.rsp

#Configure env variables
cd /u01/app/oracle/product/11.2.0/xe/bin
. ./oracle_env.sh

#Configure for all profiles (so accesible on boot login)
echo . /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh >> /etc/profile

#Cleanup
cd $OOS_SOURCE_DIR/tmp
rm -rf $OOS_ORACLE_FILE_URL
rm -rf Disk1
