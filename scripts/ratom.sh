#!/bin/bash

#*** REMOTE ATOM ***
#https://github.com/randy3k/remote-atom
#This is to make files easier to edit in Atom
cd $OOS_SOURCE_DIR/tmp
curl -o /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod +x /usr/local/bin/rmate
mv /usr/local/bin/rmate /usr/local/bin/ratom
