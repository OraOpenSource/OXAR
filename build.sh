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
OOS_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$OOS_SOURCE" ]; do # resolve $OOS_SOURCE until the file is no longer a symlink
  OOS_SOURCE_DIR="$( cd -P "$( dirname "$OOS_SOURCE" )" && pwd )"
  OOS_SOURCE="$(readlink "$OOS_SOURCE")"
  [[ $OOS_SOURCE != /* ]] && OOS_SOURCE="$OOS_SOURCE_DIR/$OOS_SOURCE" # if $OOS_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
OOS_SOURCE_DIR="$( cd -P "$( dirname "$OOS_SOURCE" )" && pwd )"

if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root." >&2
  echo "Try: sudo ${OOS_SOURCE_DIR}/${OOS_SOURCE}" >&2
  exit 1
fi

#Parsing arguments adapted from: http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
OOS_VERBOSE_OUT=false
while [[ $# > 0 ]]; do
  key="$1"
  case $key in
    -v|--verbose)
      OOS_VERBOSE_OUT=true
      ;;
    *)
      echo "Unsupported flag: $key"
      exit 1;
  esac

  shift
done

OOS_UTILS_DIR=${OOS_SOURCE_DIR}/utils
OOS_SERVICE_CTL=${OOS_UTILS_DIR}/servicectl.sh
OOS_LOG_DIR=${OOS_SOURCE_DIR}/logs
OOS_INSTALL_LOG=${OOS_LOG_DIR}/install.log
OOS_ERROR_LOG=${OOS_LOG_DIR}/error.log


if [ "$OOS_VERBOSE_OUT" = true ]; then
  OOS_LOG_OPTIONS=" > >(tee ${OOS_INSTALL_LOG} --append) 2> >(tee ${OOS_ERROR_LOG} --append >&2)"
else
  OOS_LOG_OPTIONS=" >> ${OOS_INSTALL_LOG} 2> >(tee ${OOS_ERROR_LOG} --append >&2)"
fi

mkdir -p ${OOS_LOG_DIR}
# Create empty log files
> ${OOS_INSTALL_LOG}
> ${OOS_ERROR_LOG}
mkdir -p $OOS_SOURCE_DIR/tmp
cd $OOS_SOURCE_DIR


# #149 Unzip and Java are pre-requisites for configuration validations
if [ -n "$(command -v yum)" ]; then
  echo; echo \* Installing packages with yum \*
  yum update -y

  yum install \
  unzip \
  java \
  -y

elif [ -n "$(command -v apt-get)" ]; then
  echo; echo \* Installing packages with apt-get \*
  apt-get update -y

  apt-get install \
  unzip \
  openjdk-8-jdk \
  -y
else
  echo; echo \* No known package manager found \*
fi

#See http://stackoverflow.com/questions/692000/how-do-i-write-stderr-to-a-file-while-using-tee-with-a-pipe
#and http://stackoverflow.com/questions/21465297/tee-stdout-and-stderr-to-separate-files-while-retaining-them-on-their-respective
#Load configurations
. ${OOS_UTILS_DIR}/echo_title.sh "Loading configurations"
eval "source ./config.sh $OOS_LOG_OPTIONS"

# Dependencies
. ${OOS_UTILS_DIR}/echo_title.sh "Running updates"
cd $OOS_SOURCE_DIR
eval "source ./scripts/packages.sh $OOS_LOG_OPTIONS"


#Install ratom
. ${OOS_UTILS_DIR}/echo_title.sh "Installing ratom"
if [ "$(which ratom)" == "" ]; then
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/ratom.sh $OOS_LOG_OPTIONS"
else
  echo ratom already installed
fi


#Oracle install
if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  #Expand swap
  . ${OOS_UTILS_DIR}/echo_title.sh "Expanding Swap Space"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/swap_space.sh $OOS_LOG_OPTIONS"

  . ${OOS_UTILS_DIR}/echo_title.sh "Installing Oracle XE"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/oraclexe.sh $OOS_LOG_OPTIONS"

  #Oracle config
  . ${OOS_UTILS_DIR}/echo_title.sh "Oracle Config"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/oracle_config.sh $OOS_LOG_OPTIONS"
fi


#APEX install
if [ "$OOS_MODULE_APEX" = "Y" ]; then
  . ${OOS_UTILS_DIR}/echo_title.sh "Installing APEX"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/apex.sh $OOS_LOG_OPTIONS"

  . ${OOS_UTILS_DIR}/echo_title.sh "Configuring APEX"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/apex_config.sh $OOS_LOG_OPTIONS"
fi


#12: Install Oracle Node driver
if [ "$OOS_MODULE_NODE_ORACLEDB" = "Y" ]; then
  . ${OOS_UTILS_DIR}/echo_title.sh "Installing node-oracledb"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/node-oracledb.sh $OOS_LOG_OPTIONS"
fi


#Node4ORDS
if [ "$OOS_MODULE_NODE4ORDS" = "Y" ]; then
  . ${OOS_UTILS_DIR}/echo_title.sh "Installing Node4ORDS"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/node4ords.sh $OOS_LOG_OPTIONS"
fi

#Tomcat
if [ "$OOS_MODULE_TOMCAT" = "Y" ]; then
  . ${OOS_UTILS_DIR}/echo_title.sh "Installing Tomcat"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/tomcat.sh $OOS_LOG_OPTIONS"
fi

#Firewalld
. ${OOS_UTILS_DIR}/echo_title.sh "Configuring firewalld"
cd $OOS_SOURCE_DIR
eval "source ./scripts/firewalld.sh $OOS_LOG_OPTIONS"

#ORDS
#This includes some manual intervention now
if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  . ${OOS_UTILS_DIR}/echo_title.sh "Installing ORDS"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/ords.sh $OOS_LOG_OPTIONS"
fi


#SQLcl
if [ "$OOS_MODULE_SQLCL" = "Y" ]; then
  . ${OOS_UTILS_DIR}/echo_title.sh "Installing SQLcl"
  cd $OOS_SOURCE_DIR
  eval "source ./scripts/sqlcl.sh $OOS_LOG_OPTIONS"
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
