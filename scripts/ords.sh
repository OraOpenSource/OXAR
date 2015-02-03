#!/bin/bash

#*** ORDS ***
cd $OOS_SOURCE_DIR/tmp
wget $OOS_ORDS_FILE_URL
mkdir ords
cd ords
unzip ../$OOS_ORDS_FILENAME
cd ..
mv ords /
cd /ords

mkdir conf
java -jar ords.war configdir /ords/conf

#ORDS 3 (when out of beta)
#java -jar ords.war install advanced
#java -jar ords.war install simple
#config: /usr/share/ords/

#ORDS2
java -jar ords.war

#SQL Developer administration
java -jar ords.war user adminlistener "Listener Administrator"

#Deploy to Tomcat
cd /usr/share/$OOS_TC_NAME/webapps
cp /ords/ords.war .

/etc/init.d/tomcat restart

#Copy APEX images
cd /ords
cp -r $OOS_SOURCE_DIR/tmp/apex/images .
mv images apex_images
