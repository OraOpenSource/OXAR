***This document is best viewed in [flatdoc format](http://oraopensource.github.io/flatdoc?repo=oxar&path=README.md)***
<a name="constants"></a>

# Oracle XE & APEX
The goal of the OXAR (pronounced "Oscar") project is to make it easy for developers to quickly build and/or launch a fully functional instance of Oracle XE and APEX. The scripts provided in this project handle the automatic build.

*Note: Currently this build lacks a backup script. It is recommended to do your own backup*

For more information and to signup for our email list go to [oraopensource.com](http://www.oraopensource.com). You can follow the related blogs on this project [here](http://www.oraopensource.com/blog/?category=OXAR).

If you need additional help, there is a [How-To video](http://www.oraopensource.com/blog/2015/2/25/video-how-to-build-oracle-xe-apex-machine) for this installation which walks you through the entire process.

# Current Software Versions
App              | Version                 | Description
------           | ------                  | ------
Oracle XE        | 11.2.0.2.0              |
SQLcl            | 4.1.0 Release Candidate | Command line SQL (beta)
APEX             | 5.0.3.00.03             | Currently supports APEX 5.x and APEX 4.x releases. Just reference the appropriate file in `config.properties`
ORDS             | 3.0.8.277.08.01    |
Tomcat           | 7.0.57
Node JS          | 6.x                     |

## Node.js Tools
App              | Version                 | Description
------           | ------                  | ------
Node-oracledb    | 0.3.1                   | [Node.js driver for Oracle](https://github.com/oracle/node-oracledb)
[pm2](https://github.com/Unitech/pm2) | latest | Process manager for Node.js apps


# Supported OS's
This script currently works on the following Linux distributions

OS | Minimum version | Comments
------ | ------ | ------
Oracle Linux  | 7.2 |
CentOS        | 7.0.1406 |
~~Fedora~~        | ~~21~~ |
~~Debian~~        | ~~8.0~~ | See #198 for more information
~~Ubuntu~~        | ~~16.04~~ | See #198 for more information

# Deployment Options

Option | Description
------ | ------
Native Build | This is the default option and assumes thats you will be running this script on the machine that it will be installed on. Common uses of this is to run in a VM or cloud machine.
[Vagrant](https://www.vagrantup.com/) | Vagrant is a tool for building development environments. Some additional configuration is required when running this script with Vagrant. These changes are noted in the documentation
Prebuilt Images | Due to licensing issues, we can not provide a prebuilt image or appliance. As such you will need to manually build the VM yourself with the provided scripts. </br></br>If you are using Amazon AWS EC2, please be sure to follow the configuration steps listed [here](docs/amazon_aws.md).


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

git clone https://github.com/OraOpenSource/oxar.git
cd oxar
```

###Vagrant
Run the following on your host machine *(you will need `git` installed on your host machine)*:

```bash
git clone https://github.com/OraOpenSource/oxar.git
cd oxar
```

## Configure
Regardless of whether you're doing a native or Vagrant based build, you will need to modify the `config.properties` file prior to running the installation script. At a minimum, you will need to replace the CHANGME tokens to point to the appropriate files. Read below for help on modifying this file. *If doing a Vagrant install, you can modify `config.properties` using your local text editor.*

```bash
#Hints for vi:
#Type:<esc key>?CHANGEME   to search for CHANGEME
#Once done modifying an entry, hit <esc> and type: n  to search for next entry

vi config.properties
```

### Files
**Due to licensing requirements, you must download the Oracle installation files and modify the following parameters in the config file with the location of these files.**

Parameter | Description
------ | ------
`OOS_ORACLE_FILE_URL` | [Download](http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html)
`OOS_APEX_FILE_URL` | [Download](http://download.oracleapex.com)
`OOS_ORDS_FILE_URL` | [Download](http://www.oracle.com/technetwork/developer-tools/rest-data-services/overview/index.html)
`OOS_SQLCL_FILE_URL` | [Download](http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html) *This is an optional file*


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

#### File Help

To assist getting your Oracle installation files configured for OXAR one approach is to use [Dropbox](http://dropbox.com). Once you have downloaded the install files, store them on dropbox and then reference them using the [Shared Link](https://www.dropbox.com/en/help/167) feature. Note that you need to change the `...?dl=0` to a `...?dl=1` at the end of the file. *For copyright purposes you should only use these links for your OXAR install and not share them publicly.*

Instead of having to use `vi` to edit the file you can use `sed` to find and replace. An example is as follows: *(Note: the escaping of forward slashes (`/`) in the URL)*
```bash
sed -i 's/OOS_ORACLE_FILE_URL=CHANGEME/OOS_ORACLE_FILE_URL=https:\/\/www.dropbox.com\/s\/SHAREDLINKCODE\/oracle-xe-11.2.0-1.0.x86_64.rpm.zip?dl=1/g' config.properties
sed -i 's/OOS_APEX_FILE_URL=CHANGEME/OOS_APEX_FILE_URL=https:\/\/www.dropbox.com\/s\/SHAREDLINKCODE\/apex_5.0.3_en.zip?dl=1/g' config.properties
sed -i 's/OOS_ORDS_FILE_URL=CHANGEME/OOS_ORDS_FILE_URL=https:\/\/www.dropbox.com\/s\/SHAREDLINKCODE\/ords.3.0.2.294.08.40.zip?dl=1/g' config.properties
sed -i 's/OOS_SQLCL_FILE_URL=/OOS_SQLCL_FILE_URL=https:\/\/www.dropbox.com\/s\/SHAREDLINKCODE\/sqlcl-4.2.0.16.049.0843-no-jre.zip?dl=1/g' config.properties
```

#### Files-Vagrant
Vagrant automatically maps your current folder to `/vagrant` on its VM. You can copy your files to the subdirectory `files` in `oraclexe_apex` (on your host machine) and reference them with `/vagrant/files/<filename>`. The `files` subdirectory has been added to [.gitignore](.gitignore) to exclude the installation files from version control.

Example:
```bash
OOS_ORACLE_FILE_URL=file:///vagrant/files/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
```

### Modules
You can optionally chose which modules you want installed. This install supports the following optional modules which can be modified in ```config.properties```

Module | Default | Description
------ | ------ | ------
`OOS_MODULE_ORACLE` | Y | Install Oracle XE
`OOS_MODULE_APEX` | Y | Install's APEX and all of it's components (Tomcat, ORDS, etc)


### APEX
There are additional APEX configurations that you may want to make in the ```scripts/apex_config.sql``` file. You can run them later on or manually configure them in the APEX admin account.

### Vagrant
By default you don't need to configure anything, however you may want to modify various things about your Vagrant machine. To do so, modify `Vagrantfile`.

## Build
To build the server run the following commands. It is very important that you run it starting from the same folder that it resides in.

### Native Install

```bash
. build.sh
```

### Vagrant

```bash
vagrant up
```

# Add-ons

OXAR now supports 3rd party add-ons to be included into OXAR. Current list of add-ons:

Name | Description
--- | ---
[APEX Office Print](addons/aop) | Flexible print server for Oracle Application Express (APEX) to generate your Office and PDF-documents in no time and effort - we make printing easy.

# Securing the Server

If you use OXAR in a production instance or is available on the internet it is recommended that you lock down certain features. Review our [Securing System](docs/securing_system.md) document.


# How to connect

## Oracle / SQL*Plus / SQLcl

There are many different ways to connect to Oracle with SQL*Plus. The [How to Connect to Oracle](docs/connect_oracle.md) document covers them.

Username | Password | Description
------ | ------ | ------
`OOS_USER` | `oracle` | User you can use to develop with right away
`SYS` | `oracle` |
`SYSTEM` | `oracle` |
`APEX_PUBLIC_USER` | `oracle` |

To start/stop/restart Oracle run the following commands:
```bash
/etc/init.d/oracle-xe start
/etc/init.d/oracle-xe stop
/etc/init.d/oracle-xe restart
```

## APEX
To connect to APEX go to `http://<server_name>/` or `https://<server_name>/` and it will direct you to the APEX login page.

Workspace | Username | Password | Description
------ | ------ | ------ | ------
`INTERNAL` | `admin` | `Oracle1!` | Workspace administrator account
`OOS_USER` | `oos_user` | `oracle` | You can start developing on this account. It is linked to OOS_USER schema


### APEX Web Listener
This project uses [Node4ORDS](https://github.com/OraOpenSource/node4ords) as a web listener. The Node4ORDS project provides the ability to serve static content and will provide additional web server functionality. Please read its documentation for more information.

Node4ORDS is installed in `/opt/node4ords`. It can be controlled by:
```bash
pm2 start node4ords --watch
pm2 stop node4ords
# For older versions of OXAR
# systemctl start node4ords
# systemctl stop node4ords
```

Static content can be put in `/var/www/public/` and referenced by `http://<server_name>/public/<filepath>`. More information about the web listener configuration can be found at the [Node4ORDS](https://github.com/OraOpenSource/node4ords) project page.

#### SSL
OXAR now supports SSL out of the box with an unsigned certificate. For configurations options and how to obtained a signed certificate read the [SSL docs](docs/ssl.md)

### ORDS
[Oracle REST Data Services (ORDS)](http://www.oracle.com/technetwork/developer-tools/rest-data-services/overview/) allows web servers (such as Tomcat) to connect serve up APEX pages. It is located in `/ords`

The APEX images are stored in `/ords/apex_images`

Since ORDS is a module that is added to Tomcat, there is no direct stop/stop commands for it. To restart ORDS, restart Tomcat.

## Tomcat Manager
This server uses [Apache Tomcat](http://tomcat.apache.org/) as the web container for ORDS. By default, the firewall restricts public access to the Tomcat server directly. *Note: To access APEX, you do not need to reference Tomcat directly (via port 8080 by default). Connecting to Tomcat is only required for additional debugging or configuration.*

If you do want to make it accessible run:

```bash
service firewalld start
firewall-cmd --zone=public --add-service=tomcat
```

You can then access Tomcat Manager via `http://<server_name>:8080/manager` or Application Express via `http://<server_name>:8080/ords`

Username | Password | Description
------ | ------ | ------
`tomcat` | `oracle` | Admin account


By default the admin account is tomcat/oracle

To disable Tomcat firewall access run: *note: if you don't disable it, the next time the server is rebooted it will be disabled.*

```bash
firewall-cmd --zone=public --remove-service=tomcat
```

Tomcat is located in `/usr/share/tomcat/`. Tomcat can be controlled by:

```bash
systemctl stop tomcat@oxar
systemctl start tomcat@oxar
```

## Shell Access for Vagrant
For VM created by Vagrant, the following user accounts can be used to access the VMs via SSH:

Box | Username | Password | Description
------ | ------ | ------ | ------
boxcutter/ol72 | vagrant | vagrant | User account
boxcutter/ol72 | root | vagrant | Root account

# Port Configurations
The default port settings are as follows:

Port | Service | Open | Description
------ | ------ | ------ | ------
22 | SSH | Yes |
80 | Node.js | Yes | HTTP Server
1521 | Oracle SQL connection | Optional (default: No) |
8080 | Tomcat | Optional (default: No) |
8081 | PL/SQL Gateway | No | Disabled by default

Optional ports can be configured in`config.properties` in the `FIREWALL` section. If you want to modify the firewall settings after running the build script, open `scripts/firewalld.sh` and look for examples on how to open (both temporarily and permanently).

To start/stop the Firewall:
```bash
systemctl start firewalld
systemctl stop firewalld
```

## Vagrant Port Mapping
The following ports are mapped to the host and can be configured in [Vagrantfile](Vagrantfile):

Port | Host Port | Service | Description
------ | ------ | ------ | ------
22 | 50022 | SSH | An additional port may be assigned by Vagrant.
80 | 50080 | Node.js | HTTP Server
1521 | 50521 | Oracle SQL connection | The port is mapped but usable only if permitted by firewall rules **.

** See [Port Configurations](#port-configurations).

# Other
## OS Utility Scripts
When setting up a new server their are some common things that you may want to do such as creating a new user, disabling root SSH access, etc. Though these tasks are outside the goal of this project, we've created a new folder [`utils/os`](utils/os) to store some of these common scripts which may help when setting up a new server.

## Oracle Utility Scripts
This install uses some common Oracle scripts that may be useful to run at a later time. For example, the `create_user.sql`, creates a user with all the necessary privileges to start using. For more info, go to the [`oracle`](oracle) folder.

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
