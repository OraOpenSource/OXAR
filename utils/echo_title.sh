#!/bin/bash
# echo_title.sh
# Purpose: Wrapper for echoing titles
args=$#
OOS_ECHO_TITLE=$1

if [[ $args -ne 1 ]]; then
  echo "echo_title.sh: Invalid number of arguments" >&2
  echo "Usage: echo_title.sh <description>" >&2
  exit 1
fi

(echo; echo \* $OOS_ECHO_TITLE \*; echo) | tee ${OOS_INSTALL_LOG} --append
