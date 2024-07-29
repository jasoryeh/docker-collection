#!/bin/bash

docker build -t stun . --no-cache && docker run --hostname test-local -it -d -p 23:23 --env "PORT=23" --name stun stun && docker exec -it stun bash; docker rm -f stun
