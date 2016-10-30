#!/bin/bash

#*** VALIDATIONS ***
#Moved to separate file for issue #17
echo; echo Config Validations; echo;

if [ -n "$(command -v yum)" ]; then
  echo package manager is yum
elif [ -n "$(command -v apt-get)" ]; then
  echo package manager is apt-get
else
  echo package manager cannot be detected >&2
  exit 1
fi

if [ "$OOS_MODULE_ORACLE" = "Y" ]; then
  if [ "$OOS_ORACLE_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORACLE_FILE_URL" = "" ]; then
    echo OOS_ORACLE_FILE_URL must be specified >&2
    exit 1
  elif ! curl --silent --head $OOS_ORACLE_FILE_URL --output /dev/null; then
    echo "The Oracle file URL specified, $OOS_ORACLE_FILE_URL, appears invalid." >&2
    exit 1
  else
    echo OOS_ORACLE_FILE_URL=$OOS_ORACLE_FILE_URL
  fi
fi

if [ "$OOS_MODULE_APEX" = "Y" ]; then
  if [ "$OOS_APEX_FILE_URL" = "CHANGEME" ] || [ "$OOS_APEX_FILE_URL" = "" ]; then
    echo OOS_APEX_FILE_URL must be specified >&2
    exit 1
  elif ! curl --silent --head $OOS_APEX_FILE_URL --output /dev/null; then
    echo "The APEX file URL specified, $OOS_APEX_FILE_URL, appears invalid" >&2
    exit 1
  else
    echo OOS_APEX_FILE_URL=$OOS_APEX_FILE_URL
  fi

  if [[ ${OOS_ORACLE_HTTP_PORT} = ${OOS_TOMCAT_PORT} ]]; then
    echo "OOS_ORACLE_HTTP_PORT and OOS_TOMCAT_PORT must run on separate ports. Both are set to ${OOS_ORACLE_HTTP_PORT}" >&2
    exit 1
  fi
fi

if [ "$OOS_MODULE_ORDS" = "Y" ]; then

  if [ "$OOS_ORDS_FILE_URL" = "CHANGEME" ] || [ "$OOS_ORDS_FILE_URL" = "" ]; then
    echo OOS_ORDS_FILE_URL must be specified >&2
    exit 1
  elif ! curl --silent --head $OOS_ORDS_FILE_URL --output /dev/null; then
    echo "The ORDS file URL specified, $OOS_ORDS_FILE_URL, appears invalid" >&2
    exit 1
  else
    source ${OOS_SOURCE_DIR}/utils/ords_version.sh ${OOS_SOURCE_DIR}/utils/download.sh ${OOS_ORDS_FILE_URL} ${OOS_SOURCE_DIR}/tmp/ords/

    #149 temporarily removed validations
    if [[ "$?" != "0" ]]; then
        exit 1
    elif [[ ! "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.4" ]] \
        && [[ ! "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.5" ]] \
        && [[ ! "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.6" ]] \
        && [[ ! "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.7" ]] \
        && [[ ! "${ORDS_MAJOR}.${ORDS_MINOR}.${ORDS_REVISION}" == "3.0.8" ]]; then
        echo "This version of ORDS is not yet supprted in OXAR" >&2
        echo "Please report this at http://github.com/OraOpenSource/oxar/issues" >&2
        exit 1
    else
        echo OOS_ORDS_FILE_URL=$OOS_ORDS_FILE_URL
    fi
    echo OOS_ORDS_FILE_URL=$OOS_ORDS_FILE_URL

  fi
fi

if [ ! -z "${OOS_SQLCL_FILE_URL}" ]; then
  if ! curl --silent --head $OOS_SQLCL_FILE_URL --output /dev/null; then
    echo "The SQLcl file URL specified, $OOS_SQLCL_FILE_URL, appears invalid" >&2
    exit 1
  else
    echo OOS_SQLCL_FILE_URL=$OOS_SQLCL_FILE_URL
  fi
fi
