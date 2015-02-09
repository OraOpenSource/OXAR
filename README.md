<!-- TOC depth:6 withLinks:1 updateOnSave:1 -->
- [Oracle XE & APEX](#oracle-xe-apex)
- [Current Software Versions](#current-software-versions)
- [Supported OS's](#supported-oss)
- [Prebuilt Images](#prebuilt-images)
- [Manual Build](#manual-build)
	- [Download](#download)
- [If not root run:](#if-not-root-run)
- [sudo -i](#sudo-i)
	- [Configure](#configure)
- [Look for "CHANGEME" in this file](#look-for-changeme-in-this-file)
		- [APEX](#apex)
	- [Build](#build)
- [Eventually you will be able to do the following](#eventually-you-will-be-able-to-do-the-following)
- [Dependent on issue #2](#dependent-on-issue-2)
- [. build.sh](#-buildsh)
- [For now you must open build.sh and run each section manually](#for-now-you-must-open-buildsh-and-run-each-section-manually)
- [This is due to an ORDS issue that doesn't allow for silent install. Once fixed you won't need to run each section manually](#this-is-due-to-an-ords-issue-that-doesnt-allow-for-silent-install-once-fixed-you-wont-need-to-run-each-section-manually)
- [How to connect](#how-to-connect)
	- [Oracle / SQL*Plus](#oracle-sqlplus)
	- [APEX](#apex)
		- [APEX Web Listener](#apex-web-listener)
		- [ORDS](#ords)
	- [Tomcat Manager](#tomcat-manager)
- [Port Configurations](#port-configurations)
- [Other](#other)
	- [Editing server files locally](#editing-server-files-locally)
<!-- /TOC -->

#Oracle XE & APEX
The goal of this project is to make it easy for developers to quickly build and/or launch a fully functional instance of Oracle XE and APEX. The code provided in this project handles the automatic build. There is also a listing below of prebuilt images for popular cloud providers.

*Note: Currently these machines are not recommended for production us as they lack backup scripts, SSL encryption for APEX, etc. These features will be implemented in future releases.*

#Current Software Versions
<table>
  <tr>
    <th>App</th>
    <th>Version</th>
  </tr>
  <tr>
    <td>Oracle</td>
    <td>Oracle XE 11.2.0.2.0</td>
  </tr>
  <tr>
    <td>APEX</td>
    <td>4.2.6.00.03</td>
  </tr>
  <tr>
    <td>ORDS</td>
    <td>2.0.10.289.08.09</td>
  </tr>
  <tr>
    <td>Tomcat</td>
    <td>7.0.57</td>
  </tr>
</table>

#Supported OS's
This script currently works on the following operating systems

<table>
  <tr>
    <th>OS</th>
    <th>Version</th>
  </tr>
  <tr>
    <td>CentOS</td>
    <td>7.0.1406</td>
  </tr>
  <tr>
    <td>Fedora</td>
    <td>21</td>
  </tr>
</table>

#Prebuilt Images
The goal of this project is to have prebuilt images for major cloud providers. You can use the any of the public images below. Alternative you can build your own image with the instructions further down on this page.

<table>
  <tr>
    <th>Provider</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Digital Ocean</td>
    <td>There is a build for this, however Digital Ocean does not currently support publically sharing droplets.</td>
  </tr>
  <tr>
    <td>Amazon EC2</td>
    <td>
      OS username: fedora<br>
      Region: us-west-2<br>
      AMI: <a href="https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#LaunchInstanceWizard:ami=ami-e7280dd7" target="_blank">ami-e7280dd7</a><br>
      Review the <a href="docs/amazon_aws.md">AWS EC2 setup</a> doc
    </td>
  </tr>


</table>

#Manual Build
If you don't want to use a prebuilt image, you can build your own vm with the following instructions.

##Download
```bash
#If not root run:
#sudo -i

cd /tmp
yum install git -y
git clone https://github.com/OraOpenSource/oraclexe-apex.git
cd oraclexe-apex
```

##Configure
You then can optionally modify the config file to change the default installation options.

```bash
#Look for "CHANGEME" in this file
vi config.sh
```

###APEX
There are additional APEX configurations that you may want to make in the ```scripts/oracle_config.sql``` file. You can run them later on or manually configure them in the APEX admin account.

##Build
To build the server run the following commands. It is very important that you run it starting from the same folder that it resides in.
```bash
#Eventually you will be able to do the following
#Dependent on issue #2
#. build.sh

#For now you must open build.sh and run each section manually
#This is due to an ORDS issue that doesn't allow for silent install. Once fixed you won't need to run each section manually

```


#How to connect

##Oracle / SQL*Plus
Since direct connections to the database aren't encrypted you will need to tunnel your connection over SSH. Jeff Smith has a good example on [how to connect using SQL Developer](http://www.thatjeffsmith.com/archive/2014/09/30-sql-developer-tips-in-30-days-day-17-using-ssh-tunnels/).

<table>
  <tr>
    <th>Username</th>
    <th>Password</th>
    <th>Comments</th>
  </tr>
  <tr>
    <td>OOS_USER</td>
    <td>oracle</td>
    <td>User you can use to develop with right away</td>
  </tr>
  <tr>
    <td>SYS</td>
    <td>oracle</td>
    <td></td>
  </tr>
  <tr>
    <td>SYSTEM</td>
    <td>oracle</td>
    <td></td>
  </tr>
  <tr>
    <td>APEX_PUBLIC_USER</td>
    <td>oracle</td>
    <td></td>
  </tr>
</table>


##APEX
To connect to APEX go to http://&lt;server_name&gt;/ and it will direct you to the APEX login page.

<table>
  <tr>
    <th>Workspace</th>
    <th>Username</th>
    <th>Password</th>
    <th>Comments</th>
  </tr>
  <tr>
    <td>INTERNAL</td>
    <td>admin</td>
    <td>Oracle1!</td>
    <td>Workspace administor account</td>
  </tr>
  <tr>
    <td>OOS_USER</td>
    <td>oos_user</td>
    <td>oracle</td>
    <td>You can start developing on this account. It is linked to OOS_USER schema</td>
  </tr>
</table>



###APEX Web Listener
This project uses [Node4ORDS](https://github.com/OraOpenSource/node4ords) as a web listener. The Node4ORDS project provides the ability to server static content and will provide additional web server functionality. Please read its documentation for more information.

Node4ORDS is install in ```/var/www/node4ords```. It can be controlled by:
```bash
/etc/init.d/node4ords start
/etc/init.d/node4ords stop
/etc/init.d/node4ords restart
/etc/init.d/node4ords status
```

Static content can be put in ```/var/www/node4ords/public/``` and referenced by http://&lt;server_name&gt;/public/&lt;filepath&gt;

###ORDS
ORDS is located in ```/ords```

The APEX images are stored in ```/ords/apex_images```


##Tomcat Manager
This server uses [Apache Tomcat](http://tomcat.apache.org/) as the web container for ORDS. By default, the firewall restricts public access to the Tomcat server directly. If you do want to make it accessible run:

```bash
service firewalld start
firewall-cmd --zone=public --add-service=tomcat
```

You can then access Tomcat via http://&lt;server_name&gt;:8080 and Tomcat Manager via http://&lt;server_name&gt;:8080/manager

<table>
  <tr>
    <th>Username</th>
    <th>Password</th>
    <th>Comments</th>
  </tr>
  <tr>
    <td>tomat</td>
    <td>oracle</td>
    <td>Admin account</td>
  </tr>
</table>


By default the admin account is tomcat/oracle

To disable Tomcat firewall access run: *note: if you don't disable it, the next time the server is rebooted it will be disabled.*

```bash
firewall-cmd --zone=public --remove-service=tomcat
```

Tomcat is located in ```/usr/share/apache-tomcat-7.0.57/```. *Note that the location may vary depending on version number.* It can be controlled by:

```bash
/etc/init.d/tomcat stop
/etc/init.d/tomcat start
```

#Port Configurations
The default port settings are as follows:
<table>
  <tr>
    <th>Port</th>
    <th>Service</th>
    <th>Open</th>
    <th>Comments</th>
  </tr>
  <tr>
  	<td>22</td>
  	<td>SSH</td>
  	<td>Yes</td>
  	<td></td>
  </tr>
  <tr>
  	<td>80</td>
  	<td>Node.js</td>
  	<td>Yes</td>
  	<td>HTTP Server</td>
  </tr>
  <tr>
    <td>1521</td>
    <td>Oracle SQL connection</td>
    <td>No</td>
  	<td></td>
   </tr>
  <tr>
  	<td>8080</td>
  	<td>Tomcat</td>
  	<td>No</td>
  	<td></td>
  </tr>
  <tr>
  	<td>8081</td>
  	<td>PL/SQL Gateway</td>
  	<td>No</td>
  	<td>Disabled by default</td>
  </tr>
</table>



#Other
##Editing server files locally
To make it easier to edit files on the server (and avoid using vi), [Remote-Atom](https://github.com/randy3k/remote-atom) (ratom) is installed by default. This requires that you have the [Atom](https://atom.io/) text editor on your desktop and have installed the [ratom](https://github.com/randy3k/remote-atom).

When you connect to the server use the following connection string:
```bash
ssh -R 52698:localhost:52698 root@<server_name>
```
*Note: Port 52698 is the default port and can be changed in the plugins settings in Atom*

Once you're connect to edit a file locally simply type:
```bash
ratom <myfile>
```
The file will then appear in your Atom editor.
