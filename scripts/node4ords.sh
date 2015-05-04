#!/bin/bash
#Create app
mkdir /var/www
cd /var/www

#Get project
git clone https://github.com/OraOpenSource/node4ords.git
cd ./node4ords
sed -i "s/http\:\/\/localhost:8080/http\:\/\/localhost:${OOS_TOMCAT_PORT}/" config.js
npm install --unsafe-perm

#Start on boot
cd $OOS_SOURCE_DIR

cp init.d/node4ords /etc/systemd/system/node4ords.service
mkdir -p /ords/conf/node4ords
cp init.d/node4ords.conf /ords/conf/node4ords/

systemctl enable node4ords.service
systemctl start node4ords.service
