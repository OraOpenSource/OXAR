#!/bin/bash

#Notes
#
#Some input is required before running
#Search for CHANGEME and modify before running
#
#
#- Passwords
#All passwords (expect for APEX Admin) are set to "oracle" by default. You can change accordingly
#
#
#- ratom
#This tool allows you to edit files in atom on your desktop rather than vi on server
#You must install the Atom editor: https://atom.io/ along with the Remote Atom plugin: https://github.com/randy3k/remote-atom
#When connecting to server use:
#ssh -R 52698:localhost:52698 root@<server_name/ip>
#
#To edit a file on the server, simply type:
#ratom <my_file> and then look in your Atom editor to modify

#*** LINUX ***


mkdir -p logs
INSTALL_LOG=logs/install.log
ERROR_LOG=logs/error.log

#Parsing arguments adapted from: http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
VERBOSE_OUT=false
while [[ $# > 0 ]]; do
  key="$1"
  case $key in
    -v|--verbose)
      VERBOSE_OUT=true
      ;;
    *)
      echo "Unsupported flag: $key"
      exit 1;
  esac

  shift
done

OOS_SOURCE_DIR=$PWD

mkdir -p $OOS_SOURCE_DIR/tmp
cd $OOS_SOURCE_DIR


#Load configurations
(echo; echo \* Loading configurations \*; echo) | tee ${INSTALL_LOG}
if [ "$VERBOSE_OUT" = true ]
then
  source ./config.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/configout.log
  cat logs/configout.log
else
  source ./config.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
fi

#Dependencies
(echo; echo \* Running updates \*; echo) | tee ${INSTALL_LOG} --append

cd $OOS_SOURCE_DIR
if [ "$VERBOSE_OUT" = true ]
then
  source ./scripts/packages.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/dependencies.log
  cat logs/dependencies.log
else
  source ./scripts/packages.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
fi

#Install ratom (optional)
(echo; echo \* Installing ratom \*; echo) | tee ${INSTALL_LOG} --append
if [ "$(which ratom)" == "" ]; then
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/ratom.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/ratom.log
    cat ratom.log
  else
    source ./scripts/ratom.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
else
  echo ratom already installed
fi

#Oracle install
if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  #Expand swap
  (echo; echo \* Expanding Swap Space \*; echo) | tee ${INSTALL_LOG}  --append
  cd $OOS_SOURCE_DIR

  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/swap_space.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/swapspace.log
    cat logs/swapspace.log
  else
    source ./scripts/swap_space.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi


  (echo; echo \* Installing Oracle XE \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR

  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/oraclexe.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/oraclexe.log
    cat logs/oraclexe.log
  else
    source ./scripts/oraclexe.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi

  #Oracle config
  (echo; echo \* Oracle Config \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/oracle_config.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/oracleconfig.log
    cat logs/oracleconfig.log
  else
    source ./scripts/oracle_config.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
fi

#APEX install
if [ "$OOS_MODULE_APEX" = "Y" ]; then
  (echo; echo \* Installing APEX \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/apex.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/apexinstall.log
    cat logs/apexinstall.log
  else
    source ./scripts/apex.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi


  (echo; echo \* Configuring APEX \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/apex_config.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/apexinstall.log
    cat logs/apexconfig.log
  else
    source ./scripts/apex_config.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
fi

#12: Install Oracle Node driver
if [ "$OOS_MODULE_NODE_ORACLEDB" = "Y" ]; then
  (echo; echo \* Installing node-oracledb \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/node-oracledb.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/nodeoracledb.log
    cat logs/nodeoracledb.log
  else
    source ./scripts/node-oracledb.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
fi

#Node4ORDS
if [ "$OOS_MODULE_NODE4ORDS" = "Y" ]; then
  (echo; echo \* Installing Node4ORDS \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/node4ords.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/node4ords.log
    cat logs/node4ords.log
  else
    source ./scripts/node4ords.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
fi

#Tomcat
if [ "$OOS_MODULE_TOMCAT" = "Y" ]; then
  (echo; echo \* Installing Tomcat \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/tomcat.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/node4ords.log
    cat logs/node4ords.log
  else
    source ./scripts/tomcat.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
fi

#Firewalld
(echo; echo \* Configuring firewalld \*; echo) | tee ${INSTALL_LOG} --append
cd $OOS_SOURCE_DIR
if [ "$VERBOSE_OUT" = true ]; then
  source ./scripts/firewalld.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/firewallconfig.log
  cat logs/firewallconfig.log
else
  source ./scripts/firewalld.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
fi


#ORDS
#This includes some manual intervention now
if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  (echo; echo \* Installing ORDS \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/ords.sh >> ${INSTALL_LOG} 2> ${ERROR_LOG} &>> logs/ordsinstall.log
    cat logs/ordsinstall.log
  else
    source ./scripts/ords.sh 2>&1 >> ${INSTALL_LOG} | tee ${ERROR_LOG} --append
  fi
fi

#*** CLEANUP ***
# Leave files for now
# echo; echo \* Cleanup \*; echo
# cd $OOS_SOURCE_DIR
# rm -rf tmp

#Reboot if not deployed through Vagrant.
if [ "$OOS_DEPLOY_TYPE" != "VAGRANT" ];
  then
    echo Rebooting in: ; for i in {15..1..1};do echo -n "$i." && sleep 1; done
    shutdown -r now
fi;
