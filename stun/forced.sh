#!/bin/sh

# The tunnel user $STUN_USER will be flashed info on info.sh and forced to run this script.

while true; do
    #clear
    sh /stun/info.sh
    #lsof -i | grep ssh --color=none
    #sleep 3
    sleep infinity
done

sleep infinity