#!/bin/bash

#*** VALIDATIONS ***
#Moved to separate file for issue #17
echo; echo Config Validations; echo;

# (don't modify the CHANGEME here)

if [ "$OOS_OS_TYPE" = "" ]; then
  echo OOS_OS_TYPE must be specified to RHEL or Debian
  exit 1
else
  echo OOS_OS_TYPE=$OOS_OS_TYPE
fi

if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  if [ "$OOS_ORACLE_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORACLE_FILE_URL" = "" ]; then
    echo OOS_ORACLE_FILE_URL must be specified
    exit 1
  else
    echo OOS_ORACLE_FILE_URL=$OOS_ORACLE_FILE_URL
  fi
fi

if [ "$OOS_MODULE_APEX" = "Y" ]; then
  if [ "$OOS_APEX_FILE_URL" = "CHANGEME" ] || [ "$OOS_APEX_FILE_URL" = "" ]; then
    echo OOS_APEX_FILE_URL must be specified
    exit 1
  else
    echo OOS_APEX_FILE_URL=$OOS_APEX_FILE_URL
  fi
fi

if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  if [ "$OOS_ORDS_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORDS_FILE_URL" = "" ]; then
    echo OOS_ORDS_FILE_URL must be specified
    exit 1
  else
    echo OOS_ORDS_FILE_URL=$OOS_ORDS_FILE_URL
  fi
fi
