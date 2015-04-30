[![Analytics](https://ga-beacon.appspot.com/UA-59573016-4/oraclexe-apex/README.md?pixel)](https://github.com/igrigorik/ga-beacon)***This document is best viewed in [flatdoc format](http://oraopensource.github.io/flatdoc?repo=oraclexe-apex&path=README.md)***
<a name="constants"></a>

# Oracle XE & APEX
The goal of this project is to make it easy for developers to quickly build and/or launch a fully functional instance of Oracle XE and APEX. The scripts provided in this project handle the automatic build.

*Note: Currently this build is not recommended for production us as it lacks backup scripts, SSL encryption for APEX, etc. These features will be implemented in future releases.*

For more information and to signup for our email list go to [oraopensource.com](http://www.oraopensource.com). You can follow the related blogs on this project [here](http://www.oraopensource.com/blog/?category=Oracle+XE+%2B+APEX+VM).

If you need additional help, there is a [How-To video](http://www.oraopensource.com/blog/2015/2/25/video-how-to-build-oracle-xe-apex-machine) for this installation which walks you through the entire process.

# Current Software Versions
<table>
  <tr>
    <th>App</th>
    <th>Version</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Oracle XE</td>
    <td>11.2.0.2.0</td>
    <td></td>
  </tr>
  <tr>
    <td>APEX</td>
    <td>5.0.0.00.31</td>
    <td>Currently supports APEX 5.x and APEX 4.x releases. Just reference the appropriate file in config.properties</td>
  </tr>
  <tr>
    <td>ORDS</td>
    <td>2.0.10.289.08.09</td>
    <td></td>
  </tr>
  <tr>
    <td>Tomcat</td>
    <td>7.0.57</td>
    <td></td>
  </tr>
  <tr>
    <td>Node-oracledb</td>
    <td>0.3.1</td>
    <td>Node.js driver for Oracle: <a href="https://github.com/oracle/node-oracledb" target="_blank">https://github.com/oracle/node-oracledb</a></td>
  </tr>
</table>


# Supported OS's
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
  <tr>
    <td>Oracle Enterprise Linux</td>
    <td>7.0</td>
  </tr>
  <tr>
    <td>Debian (pending)</td>
    <td>7.8</td>
  </tr>
</table>

# Deployment Options

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Native Build</td>
    <td>This is the default option and assumes thats you will be running this script on the machine that it will be installed on. Common uses of this is to run in a VM or cloud machine.</td>
  </tr>
  <tr>
    <td><a href="https://www.vagrantup.com/" target="_blank">Vagrant</a></td>
    <td>Vagrant is a tool for building development environments. Some additional configuration is required when running this script with Vagrant. These changes are noted in the documentation</td>
  </tr>
  <tr>
    <td>Prebuilt Images</td>
    <td>Due to licensing issues, we can not provide a prebuilt image or appliance. As such you will need to manually build the VM yourself with the provided scripts.<br><br>

If you are using Amazon AWS EC2, please be sure to follow the configuration steps listed <a href="docs/amazon_aws.md">here</a>.</td>
  </tr>
</table>

# Build
You can build your own VM with the following instructions.

## Download
###Native Build

```bash
#Ensure user is currently root
if [ "$(whoami)" != "root" ]; then
  sudo -i
fi

cd /tmp

#Install Git
if [ -n "$(command -v yum)" ]; then
  #RHEL type OS
  yum install git -y
else
  #Debian type OS
  apt-get install git-core
fi

git clone https://github.com/OraOpenSource/oraclexe-apex.git
cd oraclexe-apex
```

###Vagrant
Run the following on your host machine *(you will need `git` installed on your host machine)*:

```bash
git clone https://github.com/OraOpenSource/oraclexe-apex.git
cd oraclexe-apex
```

## Configure

*If doing a Vagrant install can modify `config.properties` in your local text editor.*

```bash
#Look for "CHANGEME" in this file
#Hints for vi:
#Type:<esc key>?CHANGEME   to search for CHANGEME
#Once done modifying an entry, hit <esc> and type: n  to search for next entry
#Read below for help on modifying this file
vi config.properties
```

### Files
**Due to licensing requirements, you must download the Oracle installation files and modify the following parameters in the config file with the location of these files.**

<table>
  <tr>
    <th>Parameter</th>
    <th>Desc</th>
  </tr>
  <tr>
    <td>OOS_ORACLE_FILE_URL</td>
    <td>Download: http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html</td>
  </tr>
  <tr>
    <td>OOS_APEX_FILE_URL</td>
    <td>Download: http://download.oracleapex.com</td>
  </tr>
  <tr>
    <td>OOS_ORDS_FILE_URL</td>
    <td>Download: http://www.oracle.com/technetwork/developer-tools/rest-data-services/overview/index.html</td>
  </tr>
</table>

These can be references to files on a web server or to the location on the server. Some examples:

```bash
#Assuming the file resided on myserver.com
OOS_ORACLE_FILE_URL=http://myserver.com/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
#Assuming the file is placed in the /tmp folder on the machine
OOS_ORACLE_FILE_URL=file:///tmp/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
```

You can copy files from your local machine to the remote server easily using ```scp```. Example:

```bash
scp oracle-xe-11.2.0-1.0.x86_64.rpm.zip username@servername.com:/tmp
```

####Files-Vagrant
Vagrant automatically maps your current folder to `/vagrant` on its VM. You can copy your files to the subdirectory `files` in `oraclexe_apex` (on your host machine) and reference them with `/vagrant/files/<filename>`. The `files` subdirectory has been added to [.gitignore](.gitignore) to exclude the installation files from version control.

Example:
```bash
OOS_ORACLE_FILE_URL=file:///vagrant/files/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
```

### Modules
You can optionally chose which modules you want installed. This install supports the following optional modules which can be modified in ```config.properties```

<table>
  <tr>
    <th>Module</th>
    <th>Default</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>OOS_MODULE_ORACLE</td>
    <td>Y</td>
    <td>Install Oracle XE</td>
  </tr>
  <tr>
    <td>OOS_MODULE_APEX</td>
    <td>Y</td>
    <td>Install's APEX and all of it's components (Tomcat, ORDS, etc)</td>
  </tr>
</table>

### APEX
There are additional APEX configurations that you may want to make in the ```scripts/apex_config.sql``` file. You can run them later on or manually configure them in the APEX admin account.

###Vagrant
By default you don't need to configure anything, however you may want to modify various things about your Vagrant machine. To do so, modify `Vagrantfile`.

## Build
To build the server run the following commands. It is very important that you run it starting from the same folder that it resides in.

###Native Install

```bash
#If installing APEX/ORDS, you will be prompted for some configuration options at some point (issue #2)
. build.sh
```

###Vagrant

```bash
vagrant up
```

# How to connect

## Oracle / SQL*Plus

They're many different ways to connec to Oracle with SQL*Plus. The [How to Connect to Oracle](docs/connect_oracle.md) document covers them.
<table>
  <tr>
    <th>Username</th>
    <th>Password</th>
    <th>Description</th>
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


## APEX
To connect to APEX go to http://&lt;server_name&gt;/ and it will direct you to the APEX login page.

<table>
  <tr>
    <th>Workspace</th>
    <th>Username</th>
    <th>Password</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>INTERNAL</td>
    <td>admin</td>
    <td>Oracle1!</td>
    <td>Workspace administrator account</td>
  </tr>
  <tr>
    <td>OOS_USER</td>
    <td>oos_user</td>
    <td>oracle</td>
    <td>You can start developing on this account. It is linked to OOS_USER schema</td>
  </tr>
</table>



### APEX Web Listener
This project uses [Node4ORDS](https://github.com/OraOpenSource/node4ords) as a web listener. The Node4ORDS project provides the ability to serve static content and will provide additional web server functionality. Please read its documentation for more information.

Node4ORDS is install in ```/var/www/node4ords```. It can be controlled by:
```bash
/etc/init.d/node4ords start
/etc/init.d/node4ords stop
/etc/init.d/node4ords restart
/etc/init.d/node4ords status
```

Static content can be put in ```/var/www/public/``` and referenced by `http://<server_name>/public/<filepath>`. More information about the web listner configuration can be found at the [Node4ORDS](https://github.com/OraOpenSource/node4ords) project page.

### ORDS
ORDS is located in ```/ords```

The APEX images are stored in ```/ords/apex_images```


## Tomcat Manager
This server uses [Apache Tomcat](http://tomcat.apache.org/) as the web container for ORDS. By default, the firewall restricts public access to the Tomcat server directly. If you do want to make it accessible run:

```bash
service firewalld start
firewall-cmd --zone=public --add-service=tomcat
```

You can then access Tomcat Manager via `http://<server_name>:8080/manager` or Application Express via `http://<server_name>:8080/ords`

<table>
  <tr>
    <th>Username</th>
    <th>Password</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>tomcat</td>
    <td>oracle</td>
    <td>Admin account</td>
  </tr>
</table>


By default the admin account is tomcat/oracle

To disable Tomcat firewall access run: *note: if you don't disable it, the next time the server is rebooted it will be disabled.*

```bash
firewall-cmd --zone=public --remove-service=tomcat
```

Tomcat is located in `/usr/share/tomcat/`. Tomcat can be controlled by:

```bash
systemctl stop tomcat
systemctl start tomcat
```

# Port Configurations
The default port settings are as follows:
<table>
  <tr>
    <th>Port</th>
    <th>Service</th>
    <th>Open</th>
    <th>Description</th>
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
    <td>Optional (default: No)</td>
  	<td></td>
   </tr>
  <tr>
  	<td>8080</td>
  	<td>Tomcat</td>
  	<td>Optional (default: No)</td>
  	<td></td>
  </tr>
  <tr>
  	<td>8081</td>
  	<td>PL/SQL Gateway</td>
  	<td>No</td>
  	<td>Disabled by default</td>
  </tr>
</table>

Open Optional ports can be configured in`config.properties` in the `FIREWALL` section. If you want to modify the firewall settings after running the build script, open `scripts/firewalld.sh` and look for examples on how to open (both temporarily and permanently).

## Vagrant Port Mapping
The following ports are mapped to the host and can be configured in [Vagrantfile](Vagrantfile):
<table>
  <tr>
    <th>Port</th>
    <th>Host Port</th>
    <th>Service</th>
    <th>Description</th>
  </tr>
  <tr>
  	<td>22</td>
    <td>50022</td>
  	<td>SSH</td>
  	<td>An additional port may be assigned by Vagrant.</td>
  </tr>
  <tr>
  	<td>80</td>
    <td>50080</td>
  	<td>Node.js</td>
  	<td>HTTP Server</td>
  </tr>
  <tr>
    <td>1521</td>
    <td>50521</td>
    <td>Oracle SQL connection</td>
  	<td>The port is mapped but usable only if permitted by firewall rules **.</td>
  </tr>
</table>
** See [Port Configurations](#port-configurations).

# Other
## Editing server files locally
To make it easier to edit files on the server (and avoid using vi), [Remote-Atom](https://github.com/randy3k/remote-atom) (ratom) is installed by default. This requires that you have the [Atom](https://atom.io/) text editor on your desktop and have installed the [ratom](https://github.com/randy3k/remote-atom).

When you connect to the server use the following connection string:
```bash
ssh -R 52698:localhost:52698 <username>@<server_name_or_ip_address>
```
*Note: Port 52698 is the default port and can be changed in the plugins settings in Atom*

Once you're connected, to edit a file locally, simply type:
```bash
ratom <myfile>
```
The file will then appear in your Atom editor.
