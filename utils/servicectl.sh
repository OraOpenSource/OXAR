#!/bin/bash
# servicectl.sh
# Purpose: Used to start and stop services. In order to support Ubuntu in these
# build scripts, we need to support the fact that Ubuntu doesn't yet fully
# support systemd - switched over in 15.04

function printUsage {
    echo "Usage: servicectl.sh [status|start|stop|restart] service" >&2
}

function arrayContains {
    # Test if the first argument is a valid service command
    # Function adapted from: http://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value
    local valid_commands=(start stop restart status enable)
    local input_command=$1

    for e in "${valid_commands[@]}"; do
        [[ ${e} == "$input_command" ]] && return 0
    done

    return 1
}

args=$#
input_command=$1
input_service=$2

if ! arrayContains $input_command; then
    echo "${input_command} is not a valid command" >&2
    printUsage
    exit 1
fi

if [[ $args -ne 2 ]]; then
  echo "servicectl.sh: Invalid number of arguments" >&2
  printUsage
  exit 2
fi

if hash systemctl 2>/dev/null; then
    systemctl ${input_command} ${input_service}
else
    if [[ ${input_command} == "enable" ]]; then
        echo "enable is not supported for upstart" >&2
        exit 3
    fi
    service ${input_service} ${input_command}
fi
