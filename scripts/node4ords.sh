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

# TODO mdsouza: if this works delete everything below along with corresponding files
# TODO mdsouza: update documentation (remove old, document pm2)
# cd ${OOS_SOURCE_DIR}
#
# cp node4ords/node4ords.conf /etc/node4ords.conf
# cp node4ords/node4ords /usr/local/bin/node4ords
#
# cp -f init.d/node4ords.service /etc/systemd/system/
# cp node4ords/rsyslog.conf /etc/rsyslog.d/node4ords.conf
# systemctl restart rsyslog
# systemctl enable node4ords.service
# systemctl start node4ords.service
