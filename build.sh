#!/bin/bash

set -e

WORKING_DIR=$PWD

EXP_CLEANUP() {
    echo "(Experimental) Cleaning up build environment..."
    docker buildx rm -f images-builder
}

if [ ! -z ${MULTIARCH} ]; then
    trap EXP_CLEANUP EXIT
    docker buildx create --name images-builder --driver-opt network=host --use --bootstrap
fi


REGISTRY="127.0.0.1:5000"
if [ ! -z ${DOCKER_REGISTRY} ]; then
    REGISTRY=${DOCKER_REGISTRY}
fi


function build {
    IM_NAME=$1
    cd $1
    echo "Building $IM_NAME to $REGISTRY/$IM_NAME, Multiarch=$MULTIARCH"

    if [ ! -z ${MULTIARCH} ]; then
        docker buildx build --platform linux/amd64,linux/aarch64 --push -t $REGISTRY/$IM_NAME -f Dockerfile .
    else
        docker build -t $REGISTRY/$IM_NAME -f Dockerfile .
        docker push $REGISTRY/$IM_NAME
    fi
    
    cd $WORKING_DIR
}


build stun
build disposable-minecraft
build registry-auth-proxy
build php-laravel
