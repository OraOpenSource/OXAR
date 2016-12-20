#!/bin/bash

# #149 unzio and java have been moved to build.sh as they are pre-requisites for configuration
if [ -n "$(command -v yum)" ]; then
  echo; echo \* Installing packages with yum \*
  yum update -y
  #required for rlwrap
  yum install epel-release -y

  yum install \
  libaio \
  bc \
  perl \
  git \
  firewalld \
  which \
  net-tools \
  htop \
  sudo \
  rlwrap \
  certbot -y

elif [ -n "$(command -v apt-get)" ]; then
  echo; echo \* Installing packages with apt-get \*
  apt-get update -y

  apt-get install \
  libaio1 \
  unixodbc \
  openssh-server \
  bc \
  perl \
  git-core \
  ufw \
  gnome-nettool \
  curl \
  alien \
  htop \
  sudo \
  rlwrap \
  firewalld \
  certbot -y
else
  echo; echo \* No known package manager found \*
fi

#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
#Download and install Node.js
if [ "$OOS_MODULE_NODEJS" = "Y" ]; then
  echo; echo \* Installing NodeJS \*
  cd $OOS_SOURCE_DIR/tmp
  if [ -n "$(command -v yum)" ]; then
    #175 Get nodejs from nodesource to get latest version
    # curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
    curl --silent --location https://rpm.nodesource.com/setup_7.x | bash -
    yum install -y nodejs
    # "To compile and install native addons from npm you may also need to install build tools:" (https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora)
    yum install -y gcc-c++ make

  elif [ -n "$(command -v apt-get)" ]; then
    #175 Get nodejs from nodesource to get latest version
    # curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
    apt-get install -y nodejs
    # "To compile and install native addons from npm you may also need to install build tools:" (https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora)
    apt-get install -y build-essential

    # Ubuntu's node binary is nodejs, which will cause conflict with node4ords
    # Need to create a link to `node` to ensure it runs as expected.
    # See: http://stackoverflow.com/questions/18130164/nodejs-vs-node-on-ubuntu-12-04
    if ! which node; then
        sudo ln -s $(which nodejs) /usr/bin/node
    fi
  else
    echo; echo \* No known package manager found \*
  fi

  # 176 pm2 process manager for Node.js
  npm install pm2 -g
  # Start PM2 on boot
  if [ -n "$(command -v yum)" ]; then
    pm2 startup redhat
  elif [ -n "$(command -v apt-get)" ]; then
    pm2 startup ubuntu
  else
    echo; echo \* pm2 startup: No known OS platform found. Running generic command \*
    pm2 startup
  fi

  #13: Bower support (since node.js will be installed by default)
  echo; echo \* Installing Bower \*; echo
  if [ "$(which bower)" == "" ]; then
    npm install -g bower
  else
    echo bower already installed
  fi
fi

cd ${OOS_SOURCE_DIR}
cp profile.d/10oos_global.sh /etc/profile.d/

#rerun profile to load full path
. /etc/profile
