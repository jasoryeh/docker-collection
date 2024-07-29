#!/bin/bash

ssh -p 23 -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null' tun@localhost $*
