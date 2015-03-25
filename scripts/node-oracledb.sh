#!/bin/bash

cd $OOS_SOURCE_DIR
if [ -n "$(command -v yum)" ]; then
  yum install gcc-c++ -y
elif [ -n "$(command -v apt-get)" ]; then
  apt-get install gcc -y
fi

git clone https://github.com/oracle/node-oracledb.git
cd node-oracledb

export NODE_PATH=/usr/lib/node_modules
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

npm install -g

#Note: pathadd function added as part of packages.sh
echo
echo "" >> /etc/profile
echo "export NODE_PATH=/usr/lib/node_modules" >> /etc/profile
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib" >> /etc/profile

#rerun profile to load full path
. /etc/profile
