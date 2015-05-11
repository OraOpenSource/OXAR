#!/bin/bash
# echo_title.sh
# Purpose: Wrapper for echoing titles
args=$#
title=$1

if [[ $args -ne 1 ]]; then
  echo "echo_title.sh: Invalid number of arguments" >&2
  echo "Usage: echo_title.sh <description>" >&2
  exit 1
fi

(echo; echo \* $title \*; echo) | tee ${OOS_INSTALL_LOG} --append
