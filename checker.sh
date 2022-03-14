#!/bin/bash

cd $(dirname "$0")

CONFIG_DIR=$1

if [ -f "${CONFIG_DIR}/notification.sh" ]; then
    source ${CONFIG_DIR}/notification.sh
fi

notify () {
    local MESSAGE=$1 

    # Send notification message to notification service. "send_notification_message" should be implemented in the '${CONFIG_DIR}/notification.sh'
    if [[ $(type -t send_notification_message) == function ]]; then
        send_notification_message "${MESSAGE}"
    fi    
}

source $CONFIG_DIR/config.sh

PORT_ACCESS=$(nc -zvw1 ${NODE_ADDRESS} ${P2P_PORT} > /dev/null 2>&1 ; echo $?)

if [ "$PORT_ACCESS" -eq "0" ]; then
    eval "${KILL_COMMAND}"

    local MESSAGE=$(cat <<-EOF
<b>[Success] Chain node was stopped</b>

Hostname: <b>$(hostname)</b>
Command: <b>${KILL_COMMAND}</b>

Please examine <b>debug.log</b>.
EOF
)

    notify "${MESSAGE}"
fi
