#!/bin/bash

if [ -n "$(command -v yum)" ]; then
  echo; echo \* Installing packages with yum \*
  yum update -y
  yum install unzip -y
  yum install libaio -y
  yum install bc -y
  yum install perl -y
  yum install java-1.7.0-openjdk-src.x86_64 -y
  yum install git -y
  yum install firewalld -y
  yum install java -y
  yum install which -y
  yum install net-tools -y
elif [ -n "$(command -v apt-get)" ]; then
  echo; echo \* Installing packages with apt-get \*
  apt-get update -y
  apt-get install unzip -y
  apt-get install libaio1 -y
  apt-get install unixodbc -y
  apt-get install openssh-server -y
  apt-get install bc -y
  apt-get install perl -y
  apt-get install openjdk-7-jdk -y
  apt-get install git-core -y
  apt-get install ufw -y
  apt-get install gnome-nettool -y
  apt-get install curl -y
  apt-get install alien -y
else
  echo; echo \* No known package manager found \*
fi

#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
#Download and install Node.js
if [ "$OOS_MODULE_NODEJS" = "Y" ]; then
  echo; echo \* Installing NodeJS \*
  cd $OOS_SOURCE_DIR/tmp
  if [ -n "$(command -v yum)" ]; then
    curl -sL https://rpm.nodesource.com/setup | bash -
    yum install -y nodejs
  elif [ -n "$(command -v apt-get)" ]; then
    curl -sL https://deb.nodesource.com/setup | bash -
    apt-get install nodejs -y
  else
    echo; echo \* No known package manager found \*
  fi

  #13: Bower support (since node.js will be installed by default)
  echo; echo \* Installing Bower \*; echo
  if [ "$(which bower)" == "" ]; then
    npm install -g bower
  else
    echo bower already installed
  fi
fi
#Configure path to include /usr/local/bin (required for ratom)
#Some instances of CentOS don't have this predefined
#Code from: http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
cd ~
echo "" >> /etc/profile
echo 'pathadd() {' >> /etc/profile
echo ' if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then' >> /etc/profile
echo ' PATH="${PATH:+"$PATH:"}$1"' >> /etc/profile
echo ' fi' >> /etc/profile
echo '}' >> /etc/profile
echo "" >> /etc/profile
echo "pathadd /usr/local/bin" >> /etc/profile
echo "" >> /etc/profile
#rerun profile to load full path
. /etc/profile



#Install rlwrap
cd $OOS_SOURCE_DIR/linux
tar -xzvf $OOS_RLWRAP_FILENAME
cd $OOS_RLWRAP_NAME
./configure
make
make install
cd ..
rm -rf $OOS_RLWRAP_NAME
