#!/bin/bash

yum update -y
yum install unzip -y
yum install libaio -y
yum install bc -y
yum install perl -y
yum install java-1.7.0-openjdk-src.x86_64 -y
yum install git -y
yum install wget -y
yum install firewalld -y

#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
#Download and install Node.js
cd $OOS_SOURCE_DIR/tmp
curl -sL https://rpm.nodesource.com/setup | bash -
yum install -y nodejs


#Configure path to include /usr/local/bin (required for ratom)
#Some instances of CentOS don't have this predefined
#Code from: http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
cd ~
echo "" >> /etc/profile
echo 'pathadd() {' >> /etc/profile
echo '    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then' >> /etc/profile
echo '        PATH="${PATH:+"$PATH:"}$1"' >> /etc/profile
echo '    fi' >> /etc/profile
echo '}' >> /etc/profile
echo "" >> /etc/profile
echo "pathadd /usr/local/bin" >> /etc/profile
echo "" >> /etc/profile
