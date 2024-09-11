#!/bin/bash

# Runs as service check_ports.service on systemd to have real time threat monitoring.

# Configuration
HOST="192.168.6.189"
INTERVAL=60 # Check every 60 seconds
EXCLUDE_PORTS=(3306 53 22 33060 25 8088 68 5353) # Ports to exclude
OPEN_PORTS=() # Array to store open ports


# Function to check if a port is in the exclude list
is_excluded() {
    for excluded_port in "${EXCLUDE_PORTS[@]}"; do
        if [[ $1 -eq $excluded_port ]]; then
            return 0 # 0 means true in bash, port is excluded
        fi
    done
    return 1 # 1 means false in bash, port is not excluded
}

while true; do
    # Check all ports except those in the exclude list
    OPEN_PORTS=() # Reset the array
    for (( PORT=1; PORT<=65535; PORT++ )); do

        if is_excluded $PORT; then
            #echo "Port $PORT is excluded from checking."
            #notify-send "Port $PORT is excluded from checking."
            continue
        fi

        # Use netcat to check the port
        nc -z $HOST $PORT > /dev/null 2>&1
        result=$?

        # Check if the port is open
        if [ $result -eq 0 ]; then
            echo "Port $PORT is open on $HOST."
            notify-send "Port $PORT is open on $HOST."
            OPEN_PORTS+=($PORT) # Add the open port to the array
            # You can add additional commands here, e.g., to send a notification
        #else
            #echo "Port $PORT is not open on $HOST."        
        fi

        
    done
    notify-send "Open ports: ${OPEN_PORTS[@]}"
    notify-send "All ports scanned. Going to sleep for $INTERVAL seconds."
    # Wait before checking the next port
    sleep $INTERVAL
done