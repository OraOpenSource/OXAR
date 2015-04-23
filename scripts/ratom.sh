#!/bin/bash

#*** REMOTE ATOM ***
#https://github.com/randy3k/remote-atom
#This is to make files easier to edit in Atom
cd $OOS_SOURCE_DIR/tmp
${OOS_UTILS_DIR}/download.sh https://raw.githubusercontent.com/aurora/rmate/master/rmate
chmod +x rmate
mv rmate /usr/local/bin/ratom
