#!/bin/bash

# Usage: ./script_name.sh <remote_host> [port]
# Example: ./script_name.sh example.com
# Example: ./script_name.sh 192.168.1.1 80

REMOTE_HOST="$1"
PORT="$2"

if [ -z "$REMOTE_HOST" ]; then
    echo "Usage: $0 <remote_host> [port]"
    echo "You must specify a remote host IP or hostname."
    exit 1
fi

# Resolve hostname to IP if necessary
if [[ ! "$REMOTE_HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    REMOTE_IP=$(getent hosts "$REMOTE_HOST" | awk '{ print $1 }')
    if [ -z "$REMOTE_IP" ]; then
        echo "Failed to resolve hostname to IP."
        exit 1
    fi
else
    REMOTE_IP=$REMOTE_HOST
fi

# Building the command
CMD="ss -tunap | grep 'ESTAB.*$REMOTE_IP'"
if [ ! -z "$PORT" ]; then
    CMD+=" | grep ':$PORT'"
fi

# Execute the command
echo "Listing all sockets to $REMOTE_IP on port $PORT:"
eval $CMD