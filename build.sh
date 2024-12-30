#!/bin/bash

# Documentation:
#
# DOCKER_REGISTRY - the user or repo of the container, the container will be pushed as such: $DOCKER_REGISTRY/$IMAGE_NAME
# MULTIARCH - whether or not to use buildx to create a container compatible with different architectures
#
# Usage to build multiarch to jasoryeh/my account: MULTIARCH=1 DOCKER_REGISTRY=jasoryeh PUSH=1 bash build.sh

set -e

WORKING_DIR=$PWD

if [ ! -z ${DOCKER_REGISTRY} ]; then
    REGISTRY=${DOCKER_REGISTRY}
fi

if [ -z "$REGISTRY" ]; then
    echo "No registry found, please specify a 'DOCKER_REGISTRY' environment variable!"
    exit 1
fi

EXP_CLEANUP() {
    echo "Cleaning up build environment..."
    docker buildx rm -f images-builder
}

if [ ! -z ${MULTIARCH} ]; then
    echo "Configuring a ./buildx.toml to support multiarch builds!"
    echo "" > buildx.toml
    if [ ! -z ${INSECURE_REGISTRY} ]; then
        echo "[registry.\"$REGISTRY\"]" >> ./buildx.toml
        echo "  http = true" >> ./buildx.toml
        echo "  insecure = true" >> ./buildx.toml
    fi
    trap EXP_CLEANUP EXIT
    docker buildx create --name images-builder --config ./buildx.toml --driver-opt network=host --use --bootstrap
fi

function build {
    PUSH=$PUSH MULTIARCH=$MULTIARCH REGISTRY=$REGISTRY bash builder.sh $1 $1 ${2:-Dockerfile} $2
}

function fbuild {
    PUSH=$PUSH MULTIARCH=$MULTIARCH REGISTRY=$REGISTRY bash builder.sh $*
}

set -e

if [ ! -d $WORKING_DIR/conductor ]; then
    git clone https://github.com/jasoryeh/conductor.git $WORKING_DIR/conductor
else
    cd $WORKING_DIR/conductor && git pull -f && cd $WORKING_DIR
fi

build conductor
build conductor-pterodactyl 8.Dockerfile
build conductor-pterodactyl 17.Dockerfile
build conductor-pterodactyl 21.Dockerfile
fbuild conductor-pterodactyl conductor-pterodactyl 21.Dockerfile
build stun
build disposable-minecraft
build registry-auth-proxy
build jenkins-with-dockercli
build pterodactyl-wings
build php-laravel
