#How to Connect to Oracle

By default Oracle listens to port 1521 for SQL*Plus connections. This is an unencrypted connection, meaning that all data is sent in clear text. Even in corporate settings, it may not be a good practice to connect directly to 1521 as someone could then look at the data you're sending and/or obtain the connection information to your database. This definitely not a recommended practice if you connect to 1521 over the internet.

The best way to get around this is to restrict access to port 1521 (which the build scripts do by default) and then leverage SSH tunnelling to connect to your database. They're several ways to do this.

##SQL Developer
They're already good articles about how to do this so it won't be covering in [this document](http://www.thatjeffsmith.com/archive/2014/09/30-sql-developer-tips-in-30-days-day-17-using-ssh-tunnels/). For pre-4.1 installations view this article. For versions 4.1 and onwards SQL Developer has a new SSH Hosts tab dedicated to SSH tunnelling which is covered in [this article](http://dbaontap.com/2015/03/10/ssh-tunnel-with-sqldev-4-1-ea1-and-ea2-side-by-side/).

##SSH Tunnelling

They're some cases where you may to run an SQL\*Plus script which is stored on your local machine. In order to run it you need to do two things: open an SSH tunnel that maps a local port to the server's port 1521, and then connect via SQL*Plus to that new local port. 

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

##Opening Port 1521

Though not recommending on public networks, you may want to open port 1521 for a direct connection to the database. This is ideal when using a Virtual Machine (VM) on your system with a local internal network. They're several ways to open port 1521 from the firewall. 

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