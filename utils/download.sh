#!/bin/bash
# download.sh
# Purpose: The OOS build script is designed to output stdout to logs/install.log
# and stderr to logs/error.log. Curl seems to push everything into stderr, so
# want to tweak that slightly to pipe it to stderr then if an error code occured
# return that to stderr
args=$#
download_path=$1

if [[ $args -ne 1 ]]; then
  echo "download.sh: Invalid number of arguments" >&2
  echo "Usage: download.sh file_path" >&2
  exit 1
fi

# Adapted from: http://stackoverflow.com/questions/12451278/bash-capture-stdout-to-a-variable-but-still-display-it-in-the-console
echo "Requesting to download file ${download_path}"
#127: Added -L option to help assist with dropbox.com links.
DOWNLOAD_OUTPUT=$(curl -L -O -C - ${download_path} --progress-bar 2> >(tee /dev/tty))

exit_code=$?
if [[ $exit_code = 0 ]]; then
  echo "Download of ${download_path} completed successfully"
  exit $exit_code
else
  echo "While trying to download $download_path the program returned $exit_code" >&2
  echo ${DOWNLOAD_OUTPUT} >&2
  exit $exit_code
fi
