#!/bin/bash
#Create app
mkdir -p /var/www #for /var/www/public created in the node4ords installation
cd /opt

#Get project
git clone https://github.com/OraOpenSource/node4ords.git
cd ./node4ords
sed -i "s/http\:\/\/localhost:8080/http\:\/\/localhost:${OOS_TOMCAT_PORT}/" config.js
npm install --unsafe-perm

#Start on boot
cd ${OOS_SOURCE_DIR}

cp node4ords/node4ords.conf /etc/node4ords.conf
cp node4ords/node4ords /usr/local/bin/node4ords

if hash systemctl; then
    cp -f init.d/node4ords.service /etc/systemd/system/
    cp node4ords/rsyslog.conf /etc/rsyslog.d/node4ords.conf
    ${OOS_SERVICE_CTL} restart rsyslog
    ${OOS_SERVICE_CTL} enable node4ords.service
    ${OOS_SERVICE_CTL} start node4ords.service
else
    cp -f init.d/node4ords.conf /etc/init/
    ${OOS_SERVICE_CTL} start node4ords
fi
