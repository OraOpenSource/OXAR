#!/bin/bash

clear

if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root." >&2
  echo "Try: sudo install_aop_local.sh my@email.com" >&2
  exit 1
fi

if (( $# != 1 ))
then
  echo "Please provide an email you want to be registered with."
  echo "Usage: ./install_aop_local.sh my@email.com"
  exit 1
fi

echo 
echo "The email you will be registered with at https://www.apexofficeprint.com is:"
echo "$1"
echo

echo
echo "Searching for latest version ... (might take a couple of seconds)"
echo

# *** Call AOP Webservice to get the latest version of AOP ***
url=$(curl -s -X GET 'https://www.apexrnd.be/ords/apexofficeprint/aop/oxar/dgielis@apexrnd.be/$1')

#echo "the url to download is: $url" 

echo
echo "Downloading file ..."
echo
wget $url -O aop_local.zip

echo
echo "Unzipping file"
echo
unzip aop_local.zip

rm aop_local.zip

aop=$(find . -name APEXOfficePrintRH64)

echo 
echo "Copying $aop to /aop"
echo
mkdir /aop
cp $aop /aop/.

echo
echo "Starting AOP"
echo
./aop/APEXOfficePrintRH64 &

echo
echo Local installation of AOP complete and running on port 8010!
echo

