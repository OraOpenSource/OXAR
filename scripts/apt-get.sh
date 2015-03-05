#!/bin/bash
#yum update -y
apt-get update
#yum install unzip -y
apt-get install unzip
#yum install libaio -y
apt-get install libaio
#yum install bc -y
apt-get install bc
#yum install perl -y
apt-get install perl
#yum install java-1.7.0-openjdk-src.x86_64 -y
apt-get install java-1.7.0-openjdk-src.x86_64
#yum install git -y
apt-get install git-core
#yum install firewalld -y
apt-get install firewalld
#yum install java -y
apt-get install java
#yum install which -y
apt-get install which
#yum install net-tools -y
apt-get install net-tools
#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
#Download and install Node.js
if [ "$OOS_MODULE_NODEJS" = "Y" ]; then
  echo; echo \* Installing NodeJS \*
  cd $OOS_SOURCE_DIR/tmp
  #curl -sL https://rpm.nodesource.com/setup | bash -
  curl -sL https://deb.nodesource.com/set | bash -
  #yum install -y nodejs
  apt-get install nodejs
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
