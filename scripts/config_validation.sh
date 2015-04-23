#!/bin/bash

#*** VALIDATIONS ***
#Moved to separate file for issue #17
echo; echo Config Validations; echo;

# (don't modify the CHANGEME here)

if [ -n "$(command -v yum)" ]; then
  echo package manager is yum
elif [ -n "$(command -v apt-get)" ]; then
  echo package manager is apt-get
else
  >&2 echo package manager cannot be detected
  exit 1
fi

if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  if [ "$OOS_ORACLE_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORACLE_FILE_URL" = "" ]; then
    >&2 echo OOS_ORACLE_FILE_URL must be specified
    exit 1
  else
    echo OOS_ORACLE_FILE_URL=$OOS_ORACLE_FILE_URL
  fi
fi

if [ "$OOS_MODULE_APEX" = "Y" ]; then
  if [ "$OOS_APEX_FILE_URL" = "CHANGEME" ] || [ "$OOS_APEX_FILE_URL" = "" ]; then
    >&2 echo OOS_APEX_FILE_URL must be specified
    exit 1
  else
    echo OOS_APEX_FILE_URL=$OOS_APEX_FILE_URL
  fi
fi

if [ "$OOS_MODULE_ORDS" = "Y" ]; then
  if [ "$OOS_ORDS_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORDS_FILE_URL" = "" ]; then
    >&2 echo OOS_ORDS_FILE_URL must be specified
    exit 1
  else
    echo OOS_ORDS_FILE_URL=$OOS_ORDS_FILE_URL
  fi
fi
