#!/bin/bash

# Parameters
# AOP_EMAIL: Required - email to that is registered (or will be registered) with your AOP account
#

clear

if [[ $(whoami) != "root" ]]; then
  echo "This program must be run as root." >&2
  echo "Try: sudo install_aop_local.sh my@email.com" >&2
  exit 1
fi

if (( $# != 1 )); then
  echo "Please provide an email you want to be registered with."
  echo "Usage: ./install_aop_local.sh my@email.com"
  exit 1
fi

# Parameter Definition
AOP_EMAIL=$1

AOP_LIBRE_OFFICE_VER="5.2.1"
AOP_LIBRE_OFFICE_VER_SHORT="5.2"

if [ -n "$(command -v yum)" ]; then
  AOP_OS_NAME=centos
elif [ -n "$(command -v apt-get)" ]; then
  AOP_OS_NAME=debian
else
  echo "Unknown OS"
  exit(1);
fi



echo
echo "The email you will be registered with at https://www.apexofficeprint.com is:"
echo "$AOP_EMAIL"
echo

echo
echo "Searching for latest version ... (might take a couple of seconds)"
echo

# *** Call AOP Webservice to get the latest version of AOP ***
url=$(curl -s -X GET 'https://www.apexofficeprint.com/ords/apexofficeprint/oxar/local/$AOP_EMAIL')

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

# Installing Libre Office
# AOP Guide: https://www.apexofficeprint.com/docs/#1010-how-to-read-and-convert-documents-docx-xlsx-pptx-pdf-on-linux
# Libre Office guide: https://wiki.documentfoundation.org/Documentation/Install/Linux#First_time_installing_LibreOffice_on_GNU.2FLinux.3F

# TODO mdsouza: need to separate debian from fedora
echo
echo "*** Installing LibreOffice ***"

if [ "$AOP_OS_NAME" == "centos" ]
  yum install wget cairo cups libXinerama -y
  wget http://download.documentfoundation.org/libreoffice/stable/$AOP_LIBRE_OFFICE_VER/rpm/x86_64/LibreOffice_"$AOP_LIBRE_OFFICE_VER"_Linux_x86-64_rpm.tar.gz
  tar xzvf LibreOffice_"$AOP_LIBRE_OFFICE_VER"_Linux_x86-64_rpm.tar.gz
  cd LibreOffice_"$AOP_LIBRE_OFFICE_VER".2_Linux_x86-64_rpm/RPMS
  yum localinstall *.rpm -y

elif [ "$AOP_OS_NAME" == "debian" ]; then
  apt-get install wget cairo cups libXinerama -y
  wget http://download.documentfoundation.org/libreoffice/stable/$AOP_LIBRE_OFFICE_VER/deb/x86_64/LibreOffice_"$AOP_LIBRE_OFFICE_VER"_Linux_x86-64_deb.tar.gz
  tar xzvf LibreOffice_"$AOP_LIBRE_OFFICE_VER"_Linux_x86-64_deb.tar.gz
  cd LibreOffice_"$AOP_LIBRE_OFFICE_VER".2_Linux_x86-64_deb/DEBS
  dpkg -i -y *.deb
fi
cd /tmp


echo >> /etc/profile
echo "AOP local version" >> /etc/profile
echo "export PATH=\$PATH:/opt/libreoffice$AOP_LIBRE_OFFICE_VER_SHORT/program">> /etc/profile
echo >> /etc/profile

export PATH=$PATH:/opt/libreoffice$AOP_LIBRE_OFFICE_VER_SHORT/program

echo "*** LibreOffice installed - Version***"
soffice --version


echo
echo "Starting AOP"
echo
# TODO need to create a service
./aop/APEXOfficePrintRH64 &

echo
echo Local installation of AOP complete and running on port 8010!
echo
