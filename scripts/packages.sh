#!/bin/bash

if [ -n "$(command -v yum)" ]; then
  echo; echo \* Installing packages with yum \*
  yum update -y
  #required for rlwrap
  yum install epel-release -y

  yum install \
  unzip \
  libaio \
  bc \
  perl \
  java-1.7.0-openjdk-src.x86_64 \
  git \
  firewalld \
  java \
  which \
  net-tools \
  htop \
  rlwrap -y

elif [ -n "$(command -v apt-get)" ]; then
  echo; echo \* Installing packages with apt-get \*
  apt-get update -y
  apt-get install \
  unzip \
  libaio1 \
  unixodbc \
  openssh-server \
  bc \
  perl \
  openjdk-7-jdk \
  git-core \
  ufw \
  gnome-nettool \
  curl \
  alien \
  htop \
  rlwrap -y
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
