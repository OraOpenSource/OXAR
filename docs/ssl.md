# OXAR SSL Configuration

OXAR now supports SSL out of the box with an unsigned certificate. To access go to `https://<server_name>`. You will be shown a warning that the certificate is unsigned. Accept and continue.

To manage SSL options (including forcing SSL) modify `/opt/node4ords/config.js`. Complete documentation on all options on the [Node4ORDS](https://github.com/OraOpenSource/node4ords/) main page.

The default configuration for the unsigned certificate (in `/opt/node4ords/config.js`) is:

```js
config.web.https.keyPath = '/var/www/certs/localhost.key';
config.web.https.certPath = '/var/www/certs/localhost.crt';
```

## Signed Certificate

You can easily generate a signed certificate by running [node4ords/letsencrypt.sh](../node4ords/letsencrypt.sh). This requires that the domain name be associated to the servers current IP address. [Let’s Encrypt](https://letsencrypt.org/) is a free certificate authority and is used to obtain the signed certificate.

This script will generate a signed certificate for OXAR. **It requires the domain name associated with the server's IP address and a valid email address.** If the server's IP address is not mapped to the domain name then it will fail. If you do run the script and Let's Encrypt fails then you can restore the SSL configuration using the above settings.

Syntax: `./node4ords/letsencrypt.sh <domainname> <emailaddress>`

Node4ORDS will be stopped and restarted during this process and its configuration will be updated to use the new signed certificates rather than the default unsigned certificate.

## Forcing HTTPS over HTTP

To force HTTPS only connections modify `/opt/node4ords/config.js` and set `config.web.https.forceHttps = true`. In the future this option may be `true` by default.
