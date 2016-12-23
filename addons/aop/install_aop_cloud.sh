#!/bin/bash

# Parameters
# AOP_EMAIL: Required - email to that is registered (or will be registered) with your AOP account
#

clear

if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root." >&2
  echo "Try: sudo install_aop_cloud.sh my@email.com" >&2
  exit 1
fi

if (( $# != 1 )); then
  echo "Please provide an email you want to be registered with."
  echo "Usage: ./install_aop_cloud.sh my@email.com"
  exit 1
fi

# Parameter Definition
AOP_EMAIL=$1

echo
echo "The email you will be registered with at https://www.apexofficeprint.com is:"
echo "$AOP_EMAIL"
echo

echo
echo "Creating your AOP cloud account ... (might take a couple of seconds)"
echo

# *** Call AOP Webservice to get the latest version of AOP ***
curl -s -X GET "https://www.apexofficeprint.com/ords/apexofficeprint/oxar/cloud/${AOP_EMAIL}" > aop_api_key.txt

aop_api_key=`cat aop_api_key.txt`

echo
echo "Your API key is: $aop_api_key"
echo
