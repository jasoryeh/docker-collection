#!/bin/sh

set -x

if [[ -z $TUNNEL_SERVER_PORT ]]; then
    TUNNEL_SERVER_PORT=22
fi

if [[ ! -z $TUNNEL_SERVER_AT ]]; then
    echo "SSH tunnel is enabled."
    ssh -o "StrictHostKeyChecking no" -p $TUNNEL_SERVER_PORT -R 25565:localhost:25565 $TUNNEL_SERVER_AT
else
    echo "SSH tunnel is not enabled."
fi
#ps -ef | grep ssh | grep -v grep | awk '{print $1}' | xargs kill -9
