#!/bin/bash

cd $OOS_SOURCE_DIR
if [ -n "$(command -v yum)" ]; then
  yum install gcc-c++ -y
elif [ -n "$(command -v apt-get)" ]; then
  apt-get install gcc -y
fi

git clone https://github.com/oracle/node-oracledb.git
cd node-oracledb

npm install -g

cd ${OOS_SOURCE_DIR}
cp profile.d/oos_nodejs.sh /etc/profile.d/

#rerun profile to load full path
. /etc/profile
