# Installation notes

Software that is installed apart of this package:

* Oracle XE 11g
* Application Express 5.0
* Oracle REST Data Services
* Tomcat 7.0
* Node.js
* node4ords
* ratom
* rlwrap
* Bower

## Oracle XE 11g

Oracle is installed into the folder: ``/u01/app/oracle/product/11.2.0/xe`. This is most conveniently navigated to with the `$ORACLE_HOME` environment variable. This is set up when ever you log into the terminal via the profile: `/etc/profile.d/20oos_oraclexe.sh`.

## Application Express 5.0

The images for APEX are installed to `/ords/apex_images`.

## Oracle REST Data Services (ORDS)

ORDS is installed into $ORACLE_HOME, under the folder ords. The files located in this folder allow you to learn more (help files), as well as the ords.war file being able to be found here. This is controlled via Tomcat so refer to the tomcat docs for information about starting and stopping the server.

The configuration folder is located at: `/etc/ords/`.

## Tomcat 7

The Tomcat installation is maintained by the sytems' package manager, but you should be able to find all tomcat related files under `/usr/share/tomcat`. The actual ords.war file is found under the webapps directory (alternatively found under $ORACLE_HOME/ords).

To start and stop tomcat, you can run the following command respectively:

```bash
systemctl start tomcat
systemctl stop tomcat
```

The service for tomcat is managed by systemd, and the unit file can be found at `/usr/lib/systemd/system/tomcat.service`.

## ratom

`rmate`, which is actually `rmate`, is a program that allows you to edit files from a remote server using the `atom` text editor. For more information refer to the project site, https://github.com/aurora/rmate, replacing rmate for ratom where necessary.


## rlwrap

`rlwrap` is a readline wrapper useful for common oracle command line tools. For example, by default in SQL*Plus you can't use the keyboard to navigate left or right over your command. By wrapping SQL*Plus around this command, the aforementioned issues are alleviated.

Other features include a history by hitting the up (or down) arrows, as well as support for word completion based on previous typed words, with the tab key.

The installation sets up the wrapping around `sqlplus` and `rman` through the profile: `/etc/profile.d/20oos_oraclexe.sh`, by creating the respective aliases.

## node4ords

`note4ords` is a simple application written in Node.js that aims to be a proxy around the Tomcat web container. The files for this application are found in `/var/www/node4ords` as well as a systemd service file located at: `/etc/systemd/system/node4ords.service`. It also has some easy to set up configurations at: /etc/node4ords.conf.

## Bower
