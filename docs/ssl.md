# OXAR SSL Configuration

OXAR now supports SSL out of the box with an unsigned certificate. To access go to `https://<server_name>`. You will be shown a warning that the certificate is unsigned. Accept and continue.

To manage SSL options (including forcing SSL) modify `/opt/node4ords/config.js`. Complete documentation on all options on the [Node4ORDS](https://github.com/OraOpenSource/node4ords/) main page.

## Signed Certificate

You can easily generate a signed certificate by running [../node4ords/letsencrypt.sh](node4ords/letsencrypt.sh). This requires that the domain name be associated to the servers current IP address. [Let’s Encrypt](https://letsencrypt.org/) is a free certificate authority and is used to obtain the signed certificate.

This script will generate a signed certificate for OXAR. It requires the domain name associated with the server's IP address and a valid email address.

Syntax: `./node4ords/letsencrypt.sh <domainname> <emailaddress>`

Node4ORDS will be stopped and restarted during this process and its configuration will be updated to use the new signed certificates rather than the default unsigned certificate.
