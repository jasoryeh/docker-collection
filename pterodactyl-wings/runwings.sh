#!/bin/bash

until [[ -f /var/run/docker.pid ]]
do
    echo "Waiting for docker..."
    sleep 1
done

until docker ps;
do
    echo "Waiting for docker to become available..."
    sleep 1
done

# TODO: Properly wait for docker to properly initialize
echo "Timing out for docker to initialize properly..."
sleep 5

echo "Running wings..."
wings --debug
