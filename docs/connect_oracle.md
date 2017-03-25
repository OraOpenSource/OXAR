# How to Connect to Oracle

By default Oracle listens to port 1521 for SQL*Plus connections. This is an unencrypted connection, meaning that all data is sent in clear text. Even in corporate settings, it may not be a good practice to connect directly to 1521 as someone could then look at the data you're sending and/or obtain the connection information to your database. This definitely not a recommended practice if you connect to 1521 over the internet.

The best way to get around this is to restrict access to port 1521 (which the build scripts do by default) and then leverage SSH tunnelling to connect to your database. They are several ways to do this.

## SQL Developer

There are already good articles about how to do this so it won't be covering in [this document](http://www.thatjeffsmith.com/archive/2014/09/30-sql-developer-tips-in-30-days-day-17-using-ssh-tunnels/). For pre-4.1 installations view this article. For versions 4.1 and onwards SQL Developer has a new SSH Hosts tab dedicated to SSH tunnelling which is covered in [this article](http://dbaontap.com/2015/03/10/ssh-tunnel-with-sqldev-4-1-ea1-and-ea2-side-by-side/).

## SSH Tunnelling

Ther are some cases where you may to run an SQL\*Plus script which is stored on your local machine. In order to run it you need to do two things: open an SSH tunnel that maps a local port to the server's port 1521, and then connect via SQL*Plus to that new local port.

To create the tunnel, open a new terminal window and run the following command. In this example it will map local port 1525 to remort port 1521.

```bash
ssh -L 1525:localhost:1521 giffy@vcentos
```
In another terminal window, connect to the Oracle database using the following command.

```bash
sqlplus giffy/oracle@//localhost:1525/XE
```

Note that it is connecting to `localhost` on port 1525 and not directly to the server (port 1521 on `vcentos`).

When doing SSH tunnelling, you may want to keep two different terminal windows open. If the tunnel drops, you can easily reconnect. If you don't want to have two windows open (or tabs if you use a good terminal app such as [iTerm](http://iterm2.com/) for Mac) then you can always suffix the open tunnel command with ` &`.

You can also setup SSH tunnelling on Windows using Putty. [This article](http://howto.ccs.neu.edu/howto/windows/ssh-port-tunneling-with-putty/) describes how to do it using [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).

## Opening Port 1521

Though not recommending on public networks, you may want to open port 1521 for a direct connection to the database. This is ideal when using a Virtual Machine (VM) on your system with a local internal network. There are several ways to open port 1521 from the firewall.

If you haven't already run the build script, you can modify the `OOS_FIREWALL_ORACLE_YN` setting to `Y` in `config.sh`. If you've already run the build script and installed Oracle then run the following commands as `root`:

```bash
firewall-cmd --zone=public --add-service=oracle --permanent
firewall-cmd --reload
```

If you run into any issues it's probably because you used an older version (pre 0.2.0) of the build script that did not include the `oracle` firewall configuration. To manually create it run:

```bash
cd /etc/firewalld/services
cp /usr/lib/firewalld/services/http.xml .
mv http.xml oracle.xml
vi oracle.xml
# Modify accordingly. The most important thing being the port, change from 80 to 1521
```
</code></pre>

Then run the `firewall-cmd` commands above to register the firewall changes.

You can now connect directly to the server by running:

```bash
sqlplus giffy/oracle@//vcentos:1521/XE
```

## SQLcl

SQLcl is the new command line interface that will replace SQL*Plus. [This article](http://www.talkapex.com/2015/04/installing-sqlcl.html) describes how to install it on your local machine. You can use sqlcl then with the SQL Tunnelling technique covered above.

SQLcl is now an optional install. If installed you can run it locally on the machine, just like you would an `sqlplus` command. Instead use `sqlcl`.

### SSH tunnel

The default configuration of this project is to leave the TNS port (1521) closed. If this is the case, you will need to use an ssh tunnel to connect. This can be achieved either with your OS as described above, or by using the `sshtunnel` command available in `sqlcl`.

If you haven't already generated an authentication key, you will want to do that first (on your client machine). This can be done with the command `ssh-keygen`. The default key file should save to `$HOME/.ssh/id_rsa`. Once that has been created, you will want to push that data to the server. This can be done with the command `ssh-copy-id` (which will also allow you to ssh to the server without entering a password each time).

note: `ssh-copy-id` is utility that copies your public key to the server to the file $HOME/.ssh/authorized_keys where $HOME is the home directory of the user you are connecting to with your key file. If your system doesn't have `ssh-copy-id` you just need to copy the contents of your public key file (typically $HOME/.ssh/id_rsa.pub) on your client machine to the file $HOME/.ssh/authorized_keys on the server. After copying the key, if you get the error: `Agent admitted failure to sign using the key.` when trying to ssh to the machine, you may need to add the authentication key to the ssh agent. This can be done with the command `ssh-add`.

Once that has been completed, we will be able to use the `sshtunnel` command in `sqlcl`. For example, my servers IP address is 192.168.1.10; my key file is located at: /home/trent/.ssh/id_rsa.pub; the TNS port is 1521; and I want to map it to port 8888 on localhost. So, I launch `sqlcl` with the `/nolog` flag, and then run: `sshtunnel trent@192.168.1.10 -i /home/trent/.ssh/id_rsa -L 8888:localhost:1521`.

Then I can connect to the database on localhost using the port 8888.

Sample output:

```
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/trent/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/trent/.ssh/id_rsa.
Your public key has been saved in /home/trent/.ssh/id_rsa.pub.
The key fingerprint is:
#output ommitted
$ ssh-copy-id trent@192.168.1.10
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
trent@192.168.1.10's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'trent@192.168.1.10'"
and check to make sure that only the key(s) you wanted were added.

$ ./sql /nolog

SQLcl: Release 4.2.0.15.177.0246 RC on Wed Aug 19 07:59:47 2015

Copyright (c) 1982, 2015, Oracle.  All rights reserved.


SQL> sshtunnel trent@192.168.1.10 -i /home/trent/.ssh/id_rsa -L 8888:localhost:1521

Passphrase for /home/trent/.ssh/id_rsa *************
SSH Tunnel connected
SQL> connect oos_user/oracle@localhost:8888/xe

Connected
```
