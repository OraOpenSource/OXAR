#!/bin/bash

cd $OOS_SOURCE_DIR
yum install gcc-c++ -y

git clone https://github.com/oracle/node-oracledb.git
cd node-oracledb

export NODE_PATH=/usr/lib/node_modules
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

npm install -g

#Note: pathadd function added as part of yum.sh
echo
echo "" >> /etc/profile
echo "export NODE_PATH=/usr/lib/node_modules" >> /etc/profile
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib" >> /etc/profile

#rerun profile to load full path
. /etc/profile
