#!/bin/bash
#build.sh
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
OOS_UTILS_DIR=${OOS_SOURCE_DIR}/utils
OOS_LOG_DIR=${OOS_SOURCE_DIR}/logs
OOS_INSTALL_LOG=${OOS_LOG_DIR}/install.log
OOS_ERROR_LOG=${OOS_LOG_DIR}/error.log

mkdir -p ${OOS_LOG_DIR}
# Create empty log files
> ${OOS_INSTALL_LOG}
> ${OOS_ERROR_LOG}
mkdir -p $OOS_SOURCE_DIR/tmp
cd $OOS_SOURCE_DIR

#See http://stackoverflow.com/questions/692000/how-do-i-write-stderr-to-a-file-while-using-tee-with-a-pipe
#and http://stackoverflow.com/questions/21465297/tee-stdout-and-stderr-to-separate-files-while-retaining-them-on-their-respective
#Load configurations
(echo; echo \* Loading configurations \*; echo) | tee ${OOS_INSTALL_LOG}
if [ "$VERBOSE_OUT" = true ]
then
  source ./config.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
else
  source ./config.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
fi

#Dependencies
(echo; echo \* Running updates \*; echo) | tee ${OOS_INSTALL_LOG} --append

cd $OOS_SOURCE_DIR
if [ "$VERBOSE_OUT" = true ]
then
  source ./scripts/packages.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
else
  source ./scripts/packages.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
fi

#Install ratom (optional)
(echo; echo \* Installing ratom \*; echo) | tee ${OOS_INSTALL_LOG} --append
if [ "$(which ratom)" == "" ]; then
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/ratom.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/ratom.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi
else
  echo ratom already installed
fi

#Oracle install
if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  #Expand swap
  (echo; echo \* Expanding Swap Space \*; echo) | tee ${OOS_INSTALL_LOG}  --append
  cd $OOS_SOURCE_DIR

  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/swap_space.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/swap_space.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi


  (echo; echo \* Installing Oracle XE \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR

  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/oraclexe.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/oraclexe.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi

  #Oracle config
  (echo; echo \* Oracle Config \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/oracle_config.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/oracle_config.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi
fi

#APEX install
if [ "$OOS_MODULE_APEX" = "Y" ]; then
  (echo; echo \* Installing APEX \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/apex.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/apex.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi


  (echo; echo \* Configuring APEX \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/apex_config.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/apex_config.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi
fi

#12: Install Oracle Node driver
if [ "$OOS_MODULE_NODE_ORACLEDB" = "Y" ]; then
  (echo; echo \* Installing node-oracledb \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/node-oracledb.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/node-oracledb.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi
fi

#Node4ORDS
if [ "$OOS_MODULE_NODE4ORDS" = "Y" ]; then
  (echo; echo \* Installing Node4ORDS \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/node4ords.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/node4ords.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi
fi

#Tomcat
if [ "$OOS_MODULE_TOMCAT" = "Y" ]; then
  (echo; echo \* Installing Tomcat \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/tomcat.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  else
    source ./scripts/tomcat.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
  fi
fi

#Firewalld
(echo; echo \* Configuring firewalld \*; echo) | tee ${OOS_INSTALL_LOG} --append
cd $OOS_SOURCE_DIR
if [ "$VERBOSE_OUT" = true ]; then
  source ./scripts/firewalld.sh > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)
else
  source ./scripts/firewalld.sh >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)
fi


#ORDS
#This includes some manual intervention now
if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  (echo; echo \* Installing ORDS \*; echo) | tee ${OOS_INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  source ./scripts/ords.sh
fi

#*** CLEANUP ***
# Leave files for now
# echo; echo \* Cleanup \*; echo
# cd $OOS_SOURCE_DIR
# rm -rf tmp

#Reboot if not deployed through Vagrant.
if [ "$OOS_DEPLOY_TYPE" != "VAGRANT" ];
  then
    echo "Installation complete. You can review logs at ${OOS_LOG_DIR}"
    echo Rebooting in: ; for i in {15..1..1};do echo -n "$i." && sleep 1; done
    shutdown -r now
fi;
