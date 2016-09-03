#!/bin/bash

#*** ORACLE ***
#Get Files needed to install
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh $OOS_ORACLE_FILE_URL

#Install Oracle
cd $OOS_SOURCE_DIR/tmp
unzip $OOS_ORACLE_FILENAME
cd Disk1
if [ -n "$(command -v yum)" ]; then
  rpm -ivh $OOS_ORACLE_FILENAME_RPM
elif [ -n "$(command -v apt-get)" ]; then
  echo; echo \* OS changes prior to install of DB \*; echo

  if ! df | grep -q "/dev/shm"; then
    rm -rf /dev/shm
    mkdir /dev/shm
    mount -t tmpfs shmfs -o size=2048m /dev/shm
  fi

  if ! [[ -e /sbin/chkconfig ]]; then
    cp ${OOS_SOURCE_DIR}/oracle/chkconfig /sbin/chkconfig
    ADDED_CHKCONFIG='Y'
  fi

  #mount -B /run/shm /dev/shm
  touch /dev/shm/.oracle-shm
  ln -s /usr/bin/awk /bin/awk
#  mkdir /var/lock/subsys
#  touch /var/lock/subsys/listener
  echo; echo \* convert RPM to DEB \*; echo
  alien --scripts -d $OOS_ORACLE_FILENAME_RPM
  echo; echo \* Begin DB install \*; echo
  dpkg --install oracle-xe_11.2.0-2_amd64.deb

  # Post-install changes
  # Substitute `/var/lock/subsys` with `/var/run` to store pid files
  perl -i -p -e "s/\/var\/lock\/subsys/\/var\/run/g" /etc/init.d/oracle-xe

  # Setup the oracle-shm service
  cp $OOS_SOURCE_DIR/init.d/oracle-shm /etc/init.d/
  chmod 755 /etc/init.d/oracle-shm

  # Start Oracle XE services at boot
  if [ -n "$(command -v update-rc.d)" ]; then
    update-rc.d oracle-shm defaults 01 99
    update-rc.d oracle-xe defaults
  fi

  if [[ ${ADDED_CHKCONFIG} = 'Y' ]]; then
    rm -f /sbin/chkconfig
  fi

  echo; echo \* DB install complete \*; echo
fi

#Silent configuration
cd response/
#Note: Use double quotes as pearl doesn't expand shell variables with single quotes
perl -i -p -e "s/ORACLE_HTTP_PORT=8080/ORACLE_HTTP_PORT=$OOS_ORACLE_HTTP_PORT/g" xe.rsp
perl -i -p -e "s/ORACLE_PASSWORD=<value required>/ORACLE_PASSWORD=$OOS_ORACLE_PWD/g" xe.rsp
perl -i -p -e "s/ORACLE_CONFIRM_PASSWORD=<value required>/ORACLE_CONFIRM_PASSWORD=$OOS_ORACLE_PWD/g" xe.rsp
perl -i -p -e "s/ORACLE_LISTENER_PORT=1521/ORACLE_LISTENER_PORT=$OOS_ORACLE_TNS_PORT/g" xe.rsp


#/etc/init.d/oracle-xe configure responseFile=xe.rsp >> XEsilentinstall.log
echo; echo \* begin DB configure \*; echo
/etc/init.d/oracle-xe configure responseFile=xe.rsp
echo; echo \* DB configure complete \*; echo

#Configure env variables
cd /u01/app/oracle/product/11.2.0/xe/bin
. ./oracle_env.sh

#Create a profile to set environment
cd ${OOS_SOURCE_DIR}/profile.d
#Use | as field seperator to get around issue with / being field separator
# See: http://askubuntu.com/questions/76785/how-to-escape-file-path-in-sed
# Alternate solution: http://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
sed -i "s|ORACLE_HOME|${ORACLE_HOME}|" 20oos_oraclexe.sh
cp 20oos_oraclexe.sh /etc/profile.d/

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

cd $OOS_SOURCE_DIR/oracle/
sqlplus -L system/${OOS_ORACLE_PWD} @validate.sql > /dev/null
DB_VALIDATE_RESULT=$?
if [[ $DB_VALIDATE_RESULT -ne 0 ]]; then
    echo "The database installation seems to have failed. Exiting install" >&2
    echo "Please check logs for an indication of what went wrong" >&2
    exit $DB_VALIDATE_RESULT
fi

#Cleanup
cd $OOS_SOURCE_DIR/tmp
rm -rf $OOS_ORACLE_FILENAME
rm -rf Disk1
