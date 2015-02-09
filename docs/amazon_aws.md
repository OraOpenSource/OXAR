#Amazon AWS configuration
This document covers the minimal required configuartion for machines on Amazon's EC2 service.

Unless specified otherwise, all of steps assume that you start on the AWS EC2 page.

#Key Pairs
You can use a username/password to SSH into the OS, however you may want to create a key pair for quicker access.

1. Generate an SSH key. Follow steps 1 & 2 from https://help.github.com/articles/generating-ssh-keys/ to create an SSH key.
2. On the left menu, click *Networking & Security -> Key Pairs*.
3. Click on the *Import Key Pair* button and upload ```id_rsa.pub```.

#Security Group
Security groups act as a hard firewall to grant inbound and outbound permission to an EC2 machine. Each machine should be connected to at least one security groups. In order for to SSH and access APEX you will need to create a security group granting such access. To create the security group:

1. On the left menu click *Networking & Security -> Security Groups*.
2. Click the *Create Security Group* button.
  1. Security group name: Oracle XE - APEX
  2. Description: Access to SSH and APEX
  3. Add Rule.
    1. Type: SSH
    2. Source: Anywhere
  4. Add Rule.
    1. Type: HTTP
    2. Source: Anywhere
3. Click the *Create* button.
4. When launching an EC2 AMI, make sure to select this security group.
