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
# 176 Use pm2 instead of systemctl
pm2 start app.js --name="node4ords" --watch
pm2 save
