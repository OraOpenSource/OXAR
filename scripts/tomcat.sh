#!/bin/bash

#*** TOMCAT ***
#Instructions: http://www.davidghedini.com/pg/entry/install_tomcat_7_on_centos
#Tuning: http://javamaster.wordpress.com/2013/03/13/apache-tomcat-tuning-guide/
cd $OOS_SOURCE_DIR/tmp
curl -O -C - $OOS_TC_FILE_URL
tar -xzf $OOS_TC_FILENAME
mv $OOS_TC_NAME /usr/share

cd /etc/init.d

cp $OOS_SOURCE_DIR/init.d/tomcat .
perl -i -p -e "s/OOS_TC_NAME/$OOS_TC_NAME/g" tomcat

chmod 755 tomcat

#Start tomcat at startup
if [ -n "$(command -v chkconfig)" ]; then
  chkconfig --add tomcat
  chkconfig --level 234 tomcat on
elif [ -n "$(command -v update-rc.d)" ]; then
  update-rc.d tomcat defaults
fi

#Configure Users
cd /usr/share/$OOS_TC_NAME/conf/

#Add the following in <tomcat-users> section (change the password)
# <role rolename=\"manager-gui\"/>
#  <user username=\"$OOS_TC_USERNAME\" password=\"$OOS_TC_PWD\" roles=\"manager-gui\"/>
perl -i -p -e "s/<tomcat-users>/<tomcat-users>\n<role rolename=\"manager-gui\"\/>\n<user username=\"$OOS_TC_USERNAME\" password=\"$OOS_TC_PWD\" roles=\"manager-gui\"\/>/g" tomcat-users.xml


#service tomcat start
#service tomcat stop
#service tomcat restart
/etc/init.d/tomcat start


#Log file
#less /usr/share/apache-tomcat-7.0.47/logs/catalina.out
#use G to go to end of file

#Manager
#http://<your_ip_address_or_domain_name>:8080/manager/
