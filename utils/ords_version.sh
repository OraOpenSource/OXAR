#!/bin/bash
# ords_version.sh
# Purpose:

args=$#
download_util=$1
download_path=$2
download_dest=$3

#exit codes
EX_INVALID_ARGS=1
EX_INVALID_ORDS=2

function printUsage {
    echo "Usage: ords_version.sh /path/to/download/script /path/to/ords.zip /path/to/download/dest" >&2
}

if [[ $args -ne 3 ]]; then
  echo "ords_version.sh: Invalid number of arguments" >&2
  printUsage
  exit ${EX_INVALID_ARGS}
fi

mkdir -p ${download_dest}

cd ${download_dest}
${download_util} ${download_path}
unzip ${OOS_ORDS_FILENAME} ords.war

#Since the manual installation changes over time, beginning with 3.0.4, check
#the version to act per version.
#
#-1 hack - to force the script to exit if it expects input (it would by default
#expect a path to be set)
VERSION_STR=$(echo "-1" | java -jar ${download_dest}/ords.war version)
VERSION_PREFIX="Oracle REST Data Services "

#Make sure the output of java -jar ords.war version returns as expected
if [[ "${VERSION_STR}" != ${VERSION_PREFIX}* ]]; then
    echo "The version of ORDS you are attempting to install is not supported" >&2
    echo "Please grab the latest version and try again" >&2
    exit ${EX_INVALID_ORDS}
fi

#Strip the prefix from the start of the version so we can pass the number version
#Syntax: http://stackoverflow.com/a/16623897/3476713
VERSION_NUM=${VERSION_STR#${VERSION_PREFIX}}

#Split up the version number
IFS='.' read -r -a VERSION_CMPS <<< "${VERSION_NUM}"
ORDS_MAJOR=${VERSION_CMPS[0]}
ORDS_MINOR=${VERSION_CMPS[1]}
ORDS_REVISION=${VERSION_CMPS[2]}
