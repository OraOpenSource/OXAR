#!/bin/bash

#*** NODE.JS ***


#Create app
mkdir /var/www
cd /var/www

#Get project
git clone https://github.com/OraOpenSource/node4ords.git
cd ./node4ords
npm install --unsafe-perm

#Start on boot
cd $OOS_SOURCE_DIR

cp init.d/node4ords /etc/init.d/
chmod 755 /etc/init.d/node4ords

if [ -n "$(command -v chkconfig)" ]; then
  chkconfig --add node4ords
  chkconfig --level 234 node4ords on
elif [ -n "$(command -v update-rc.d)" ]; then
  update-rc.d node4ords defaults
fi

/etc/init.d/node4ords start
