#!/bin/bash

TOMCAT_OXAR_SERVICE_NAME=tomcat@oxar

if [ -n "$(command -v yum)" ]; then
    yum install tomcat tomcat-admin-webapps -y

    # Set tomcat environmental variables such as CATALINA_HOME
    . /etc/tomcat/tomcat.conf
    TOMCAT_USER=tomcat
    TOMCAT_SERVICE_NAME=tomcat
    
    #Modifications to tomcat service file. Recommendation is to make a copy of the `@`
    #version. So making a copy and naming it oxar. 
    #Add `oracle-xe` to the After clause to encourage waiting for the db to be up and running
    cp /usr/lib/systemd/system/${TOMCAT_SERVICE_NAME}.service /usr/lib/systemd/system/${TOMCAT_OXAR_SERVICE_NAME}.service
    sed -i 's/After=syslog.target network.target/After=syslog.target network.target oracle-xe.service/' /usr/lib/systemd/system/${TOMCAT_OXAR_SERVICE_NAME}.service
    

elif [ -n "$(command -v apt-get)" ]; then

    apt-get install tomcat7 tomcat7-admin -y
    # Set tomcat environmental variables such as CATALINA_HOME
    CATALINA_HOME=/var/lib/tomcat7
    TOMCAT_SERVICE_NAME=tomcat7
    TOMCAT_USER=tomcat7
    
    #Modifications to the tomcat7 init script. For consistency, naming the same
    #as Red Hat counter part (it uses a service file rather than init script).
    cp /etc/init.d/${TOMCAT_SERVICE_NAME} /etc/init.d/${TOMCAT_OXAR_SERVICE_NAME}
    #According to https://wiki.debian.org/LSBInitScripts, the `Should-Start` clause
    #should wait for specified services to start if available.
    #https://wiki.debian.org/LSBInitScripts
    #See also https://refspecs.linuxbase.org/LSB_3.0.0/LSB-PDA/LSB-PDA/facilname.html
    sed -i 's/# Should-Start:      \$named/# Should-Start:      \$named oracle-xe/' /etc/init.d/${TOMCAT_OXAR_SERVICE_NAME}
    #Also replace the script executable path
    sed -i 's/\/etc\/init\.d\/tomcat7/\/etc\/init.d\/tomcat@oxar/' /etc/init.d/${TOMCAT_OXAR_SERVICE_NAME}
    #and the provides name to match script name
    sed -i 's/Provides:          tomcat7/Provides:          tomcat@oxar/' /etc/init.d/${TOMCAT_OXAR_SERVICE_NAME}
    
else

    echo; echo \* No known package manager found \* >&2
    exit 1
fi

#Reload systemd just in case anything is cached with this service name
systemctl daemon-reload
#Stop and dissable tomcat from sytem startup
systemctl stop ${TOMCAT_SERVICE_NAME}
systemctl disable ${TOMCAT_SERVICE_NAME}

#Add a user into tomcat-users.xml (/etc/tomcat/tomcat-user.xml) as defined in config.properties
perl -i -p -e "s/<tomcat-users>/<tomcat-users>\n  <\!-- Auto generated content by http\:\/\/www.github.com\/OraOpenSource\/oraclexe-apex install scripts -->\n  <role rolename=\"manager-gui\"\/>\n  <user username=\"${OOS_TOMCAT_USERNAME}\" password=\"${OOS_TOMCAT_PASSWORD}\" roles=\"manager-gui\"\/>\n  <\!-- End auto-generated content -->/g" ${CATALINA_HOME}/conf/tomcat-users.xml

# Copy the configuration template over
cp -f ${CATALINA_HOME}/conf/server.xml ${CATALINA_HOME}/conf/server_original.xml
# See #150
\cp -f $OOS_SOURCE_DIR/tomcat/server.xml ${CATALINA_HOME}/conf/server.xml

# Set the preferred port
sed -i "s/OOS_TOMCAT_SERVER_PORT/${OOS_TOMCAT_PORT}/" ${CATALINA_HOME}/conf/server.xml

systemctl enable ${TOMCAT_OXAR_SERVICE_NAME}
systemctl start ${TOMCAT_OXAR_SERVICE_NAME}
