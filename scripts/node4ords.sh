#!/bin/bash
#Create app
mkdir -p /var/www #for /var/www/public created in the node4ords installation
cd /opt

#Get project
git clone https://github.com/OraOpenSource/node4ords.git
cd ./node4ords
npm install --unsafe-perm
sed -i "s/http\:\/\/localhost:8080/http\:\/\/localhost:${OOS_TOMCAT_PORT}/" config.js

# 33 Enable SSL and generate a random cert to get started
# /var/www is created by node4ords by default
cd /var/www
mkdir certs
cd certs

# Generate an unsigned certificate
openssl req \
  -newkey rsa:2048 -nodes -keyout localhost.key \
  -x509 -days 365 -out localhost.crt \
  -subj "/C=CA/ST=Alberta/L=Calgary/O=Dis/CN=localhost"

# Modify Node4ORDS Config
cd /opt/node4ords
sed -i 's/CHANGEME_HTTPS_KEYPATH/\/var\/www\/certs\/localhost.key/g' config.js
sed -i 's/CHANGEME_HTTPS_CERTPATH/\/var\/www\/certs\/localhost.crt/g' config.js
sed -i 's/config.web.https.enabled = false;/config.web.https.enabled = true;/g' config.js


#Start on boot
# 176 Use pm2 instead of systemctl
pm2 start app.js --name="node4ords" --watch
pm2 save
