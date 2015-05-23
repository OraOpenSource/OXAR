#!/bin/bash

if [ -n "$(command -v yum)" ]; then
    yum install tomcat tomcat-admin-webapps -y

    # Set tomcat environmental variables such as CATALINA_HOME
    . /etc/tomcat/tomcat.conf
    TOMCAT_SERVICE_NAME=tomcat.service

elif [ -n "$(command -v apt-get)" ]; then

    apt-get install tomcat7 tomcat7-admin -y
    # Set tomcat environmental variables such as CATALINA_HOME
    CATALINA_HOME=/var/lib/tomcat7
    TOMCAT_SERVICE_NAME=tomcat7.service

else

    echo; echo \* No known package manager found \* >&2
    exit 1
fi

systemctl stop ${TOMCAT_SERVICE_NAME}

#Add a user into tomcat-users.xml (/etc/tomcat/tomcat-user.xml) as defined in config.properties
perl -i -p -e "s/<tomcat-users>/<tomcat-users>\n  <\!-- Auto generated content by http\:\/\/www.github.com\/OraOpenSource\/oraclexe-apex install scripts -->\n  <role rolename=\"manager-gui\"\/>\n  <user username=\"${OOS_TOMCAT_USERNAME}\" password=\"${OOS_TOMCAT_PASSWORD}\" roles=\"manager-gui\"\/>\n  <\!-- End auto-generated content -->/g" ${CATALINA_HOME}/conf/tomcat-users.xml

# Set the preferred port
if [[ "${OOS_TOMCAT_PORT}" != 8080 ]]; then

  sed -i "s/port\=\"8080\"/port\=\"${OOS_TOMCAT_PORT}\"/" ${CATALINA_HOME}/conf/server.xml
fi


systemctl enable ${TOMCAT_SERVICE_NAME}
systemctl start ${TOMCAT_SERVICE_NAME}
