#!/bin/bash

#*** SWAP SPACE ***
#http://www.cyberciti.biz/faq/linux-add-a-swap-file-howto/
dd if=/dev/zero of=/swapfile1 bs=1024 count=2099200
mkswap /swapfile1
chown root:root /swapfile1
chmod 0600 /swapfile1
swapon /swapfile1
#Add swapfile to end of fstab for boot
echo /swapfile1 swap swap defaults 0 0 >> /etc/fstab

#Verify that it’s enabled
#free -m
