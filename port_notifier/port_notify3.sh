#!/bin/bash

# Configuration
HOST="192.168.6.189"
INTERVAL=60 # Check every 60 seconds
EXCLUDE_PORTS="3306,53,22,33060,25,8088,68,5353" # Ports to exclude
LOG_FILE="/var/log/port_scan.log"

# Function to log results
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Main monitoring loop
while true; do
    # Scan with nmap for open ports and attempt to identify the service/version
    results=$(nmap -sT -p- --open --exclude-ports $EXCLUDE_PORTS $HOST -T2 -v)

    # Extract just the open ports and the service information
    mapfile -t OPEN_PORTS < <(echo "$results" | grep ^[0-9] | awk '{ print $1 " (" $3 " " $4 " " $5 " " $6 ")" }')

    if [ ${#OPEN_PORTS[@]} -eq 0 ]; then
        log_message "No new open ports detected."
    else
        for entry in "${OPEN_PORTS[@]}"; do
            port=$(echo $entry | cut -d '/' -f 1)
            service=$(echo $entry | sed 's/^[0-9]*\/tcp //g' | sed 's/^[0-9]*\/udp //g')
            log_message "Port $port is open on $HOST. Service: $service"
            notify-send "Port $port is open on $HOST. Service: $service"
        done
    fi
    
    log_message "All ports scanned. Going to sleep for $INTERVAL seconds."
    notify-send "All ports scanned. Going to sleep for $INTERVAL seconds."
    sleep $INTERVAL
done
