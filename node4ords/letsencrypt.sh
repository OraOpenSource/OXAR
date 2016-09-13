# mkdir public
# touch public/index.html

# This script will generate a valid letsencrypt cert for the provided domainName
# Server MUST be associated with the domain for this to work
#
# To run:
# ./letsencrypt.sh <dns> <email>
# Example:
# ./letsencrypt.sh oxartest.odbopensource.com martin@odbopensource.com


domainName=$1
emailAddress=$2

# Validate parameters
if [[ -z "$domainName" ]]; then
  echo "Missing Domain Name"
  exit 1
fi

if [[ -z "$emailAddress" ]]; then
  echo "Missing Email Address"
  exit 1
fi

# To lowercase
domainName="${domainName,,}"
emailAddress="${emailAddress,,}"


# stop node4ords
# Need to do this since it's using port 80 and certbot needs to create a simple web server to prove domain ownership
pm2 stop node4ords

# Generate cert
certbot certonly --standalone -d $domainName -m $emailAddress --agree-tos

# Update Node4ORDS with new config
cd /opt/node4ords
sed -ri "s/(^config\.web\.https\.keyPath\s+=)[^=]*$/\1 '\/etc\/letsencrypt\/live\/$domainName\/privkey.pem'/" config.js
sed -ri "s/(^config\.web\.https\.certPath\s+=)[^=]*$/\1 '\/etc\/letsencrypt\/live\/$domainName\/fullchain.pem'/" config.js

# pm2 stop simpleweb
pm2 start node4ords --watch
