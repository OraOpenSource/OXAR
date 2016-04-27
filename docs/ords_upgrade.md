# Upgrading ORDS

To upgrade ORDS, you need to grab the latest copy of ORDS onto your server. Before starting the upgrade, it won't be a bad idea to stop Tomcat.

```bash
sudo systemctl stop tomcat
```

Now, assuming the version you wish to upgrade to is 3.0.4.60.12.48, and you have downloaded the file `ords.3.0.4.60.12.48.zip` onto your server, you first need to extract the files.

```bash
unzip ords.3.0.4.60.12.48.zip -d ords304
```

Now that the latest ORDS files have been extracted to your server, we can begin to upgrade. It's a matter of launching ords and specifying the configuration directory (OXAR places the configuration for ords in `/etc`).

```bash
cd ords304
java -jar ords.war
```

Here, you will be prompted to answer some questions, as per:

```
This Oracle REST Data Services instance has not yet been configured.
Please complete the following prompts

Enter the location to store configuration data:/etc

Verify ORDS schema in Database Configuration apex with connection host: localhost port: 1521 sid: xe


Please login with SYSDBA privileges to verify Oracle REST Data Services schema. Installation may be required.


Enter the username with SYSDBA privileges to verify the installation [SYS]:
Enter the database password for SYS:
Confirm password:
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172911_00016.log
Apr 27, 2016 5:29:11 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.2.223
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172911_00233.log
Apr 27, 2016 5:29:14 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.3.329
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172914_00846.log
Apr 27, 2016 5:29:15 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.3.344
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172915_00845.log
Apr 27, 2016 5:29:16 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.3.349
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172916_00007.log
Apr 27, 2016 5:29:16 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.4.4
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172916_00029.log
Apr 27, 2016 5:29:16 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.4.15
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172916_00446.log
Apr 27, 2016 5:29:17 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.4.19
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172917_00908.log
Apr 27, 2016 5:29:18 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.4.25
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172918_00265.log
Apr 27, 2016 5:29:18 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.4.41
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172918_00275.log
Apr 27, 2016 5:29:19 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Upgrading Oracle REST Data Services schema to version 3.0.4.54
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172919_00082.log
... Log file written to /home/trent/ords304/logs/ordsupgrade_2016-04-27_172919_00865.log
Apr 27, 2016 5:29:21 PM oracle.dbtools.installer.Installer upgradeORDS
INFO: Completed upgrade for Oracle REST Data Services version 3.0.4.60.12.48.  Elapsed time: 00:00:10.454

Enter 1 if you wish to start in standalone mode or 2 to exit [1]:2
```

Once, that upgrade process completes, you need to move `ords.war` to the Tomcat webapps directory, before starting up Tomcat again.

```bash
sudo cp ords.war /usr/share/tomcat/webapps/
sudo systemctl start tomcat
```
