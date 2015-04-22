#!/bin/bash

INSTALL_LOG=logs/install.log
ERROR_LOG=logs/error.log
mkdir -p logs

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

#See http://stackoverflow.com/questions/692000/how-do-i-write-stderr-to-a-file-while-using-tee-with-a-pipe
#and http://stackoverflow.com/questions/21465297/tee-stdout-and-stderr-to-separate-files-while-retaining-them-on-their-respective
#Load configurations
(echo; echo \* Loading configurations \*; echo) | tee ${INSTALL_LOG}
if [ "$VERBOSE_OUT" = true ]
then
  source ./config.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
else
  source ./config.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
fi

#Dependencies
(echo; echo \* Running updates \*; echo) | tee ${INSTALL_LOG} --append

cd $OOS_SOURCE_DIR
if [ "$VERBOSE_OUT" = true ]
then
  source ./scripts/packages.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
else
  source ./scripts/packages.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
fi

#Install ratom (optional)
(echo; echo \* Installing ratom \*; echo) | tee ${INSTALL_LOG} --append
if [ "$(which ratom)" == "" ]; then
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/ratom.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/ratom.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
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
    source ./scripts/swap_space.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/swap_space.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi


  (echo; echo \* Installing Oracle XE \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR

  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/oraclexe.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/oraclexe.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi

  #Oracle config
  (echo; echo \* Oracle Config \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/oracle_config.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/oracle_config.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi
fi

#APEX install
if [ "$OOS_MODULE_APEX" = "Y" ]; then
  (echo; echo \* Installing APEX \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true  ]; then
    source ./scripts/apex.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/apex.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi


  (echo; echo \* Configuring APEX \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/apex_config.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/apex_config.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi
fi

#12: Install Oracle Node driver
if [ "$OOS_MODULE_NODE_ORACLEDB" = "Y" ]; then
  (echo; echo \* Installing node-oracledb \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/node-oracledb.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/node-oracledb.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi
fi

#Node4ORDS
if [ "$OOS_MODULE_NODE4ORDS" = "Y" ]; then
  (echo; echo \* Installing Node4ORDS \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/node4ords.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/node4ords.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi
fi

#Tomcat
if [ "$OOS_MODULE_TOMCAT" = "Y" ]; then
  (echo; echo \* Installing Tomcat \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/tomcat.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/tomcat.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
  fi
fi

#Firewalld
(echo; echo \* Configuring firewalld \*; echo) | tee ${INSTALL_LOG} --append
cd $OOS_SOURCE_DIR
if [ "$VERBOSE_OUT" = true ]; then
  source ./scripts/firewalld.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
else
  source ./scripts/firewalld.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
fi


#ORDS
#This includes some manual intervention now
if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  (echo; echo \* Installing ORDS \*; echo) | tee ${INSTALL_LOG} --append
  cd $OOS_SOURCE_DIR
  if [ "$VERBOSE_OUT" = true ]; then
    source ./scripts/ords.sh > >(tee ${INSTALL_LOG} --append) 2> >(tee ${ERROR_LOG} --append >&2)
  else
    source ./scripts/ords.sh >> ${INSTALL_LOG} 2> >(tee ${ERROR_LOG} --append >&2)
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
