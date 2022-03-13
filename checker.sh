#!/bin/bash

cd $(dirname "$0")

#CONFIG_DIR=$1

#source $CONFIG_DIR/config.sh

# Move to config
NODE_ADDRESS=$1
P2P_PORT=$2
KILL_COMMAND=$3

PORT_ACCESS=$(nc -zvw1 ${NODE_ADDRESS} 26656 > /dev/null 2>&1 ; echo $?)
HOST_ACCESS=$(ping -c 1 ${NODE_ADDRESS} > /dev/null 2>&1 ; echo $?)

if [ "$PORT_ACCESS" -eq "0" -a "$HOST_ACCESS" -eq "0" ]; then
    echo "${KILL_COMMAND}"
fi
