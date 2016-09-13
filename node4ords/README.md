# Node4ORDS Scripts

## [`letsencrypt.sh`](letsencrypt.sh)

This script will generate a signed certificate for OXAR. It requires the domain name associated with the server's IP address and a valid email address.

Syntax: `./node4ords/letsencrypt.sh <domainname> <emailaddress>`

Node4ORDS will be stopped and restarted during this process and its configuration will be updated to use the new signed certificates rather than the default unsigned certificate.
