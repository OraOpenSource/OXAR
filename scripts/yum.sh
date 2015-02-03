#!/bin/bash

yum update -y
yum install unzip -y
yum install libaio -y
yum install bc -y
yum install perl -y
yum install java-1.7.0-openjdk-src.x86_64 -y
yum install git -y
yum install wget -y
yum install firewalld -y

#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
#Download and install Node.js
cd $OOS_SOURCE_DIR/tmp
curl -sL https://rpm.nodesource.com/setup | bash -
yum install -y nodejs
