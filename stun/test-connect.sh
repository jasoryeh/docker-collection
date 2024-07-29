#!/bin/bash

STUN_USER=asdf-random-cantbeguessed

ssh -p 23 -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null' $STUN_USER@localhost $*
