#!/bin/bash

#*** TOMCAT ***
yum install tomcat tomcat-admin-webapps -y

# Set tomcat environmental variables such as CATALINA_HOME
. /etc/tomcat/tomcat.conf

#Add a user into tomcat-users.xml (/etc/tomcat/tomcat-user.xml) as defined in config.properties
perl -i -p -e "s/<tomcat-users>/<tomcat-users>\n  <\!-- Auto generated content by http\:\/\/www.github.com\/OraOpenSource\/oraclexe-apex install scripts -->\n  <role rolename=\"manager-gui\"\/>\n  <user username=\"${OOS_TOMCAT_USERNAME}\" password=\"${OOS_TOMCAT_PASSWORD}\" roles=\"manager-gui\"\/>\n  <\!-- End auto-generated content -->/g" ${CATALINA_HOME}/conf/tomcat-users.xml

# Set the preferred port
if [[ "${OOS_TOMCAT_PORT}" != 8080 ]]; then
  sed -i "s/port\=\"8080\"/port\=\"${OOS_TOMCAT_PORT}\"/" ${CATALINA_HOME}/conf/server.xml
fi

#Auto start tomcat
#tomcat service location: /usr/lib/systemd/system/tomcat.service
systemctl enable tomcat.service
systemctl start tomcat.service
