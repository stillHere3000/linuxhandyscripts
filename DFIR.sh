#!/bin/bash

sudo kill $(sudo lsof -t -i:3000)
lsof | grep -e COMMAND -e '\(deleted\)'
find /proc/*/fd -ls | grep  '(deleted)'

ss --udp state CLOSE-WAIT --kill
 ss --tcp state CLOSE-WAIT --kill

 sudo ls -alR /proc/*/fd 2> /dev/null | grep "memfd:.*\(deleted\)"


ps auxwf | grep "\["
# no parent avbailable is a potential indicator of a hidden process

# check for hidden files
find / -type f -name ".*" -exec ls -l {} \;

ps auxww | grep \\[ | awk '{print $2}' | xargs -I % sh -c 'echo PID: %; cat /proc/%/maps' 2> /dev/null
# check for hidden processes and maps files

#This simple command just shows any [PID] that is not 
#a child off kthreadd. It's simple, but it works and gets 
# you onto the problem fast. 

ps auxwf | grep \\[ | grep -v "\_" | grep -v kthreadd