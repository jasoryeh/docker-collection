#!/bin/bash

if [ ! -z ${DOCKER_GID} ]; then
    groupmod -g 995 systemd-journal
    groupmod -g $DOCKER_GID docker
fi

if [ ! -z ${PRERUN} ]; then
    exec "$PRERUN"
fi

su -c "/usr/local/bin/jenkins.sh $*" jenkins
