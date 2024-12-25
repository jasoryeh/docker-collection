#!/bin/bash

# Documentation:
#
# DOCKER_REGISTRY - the user or repo of the container, the container will be pushed as such: $DOCKER_REGISTRY/$IMAGE_NAME
# MULTIARCH - whether or not to use buildx to create a container compatible with different architectures
#
# Usage to build multiarch to jasoryeh/my account: MULTIARCH=1 DOCKER_REGISTRY=jasoryeh bash build.sh

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
    IM_NAME=$1
    IM_VARIANT="Dockerfile"
    if [ ! -z ${2} ]; then
        IM_VARIANT="$2.Dockerfile"
    fi
    IM_TAG=""
    if [ ! -z ${2} ]; then
        IM_TAG=":$2"
    fi
    cd $1
    echo "Building $IM_NAME ($IM_VARIANT) to $REGISTRY/$IM_NAME$IM_TAG, Multiarch=$MULTIARCH"

    if [ ! -z ${MULTIARCH} ]; then
        if [ ! -z ${PUSH} ]; then
            docker buildx build --platform linux/amd64,linux/aarch64 --push -t $REGISTRY/$IM_NAME$IM_TAG --build-arg INTERMEDIATE_REPO=$REGISTRY -f $IM_VARIANT .
        else
            docker buildx build --platform linux/amd64,linux/aarch64 -t $REGISTRY/$IM_NAME$IM_TAG --build-arg INTERMEDIATE_REPO=$REGISTRY -f $IM_VARIANT .
        fi
    else
        docker build -t $REGISTRY/$IM_NAME$IM_TAG --build-arg INTERMEDIATE_REPO=$REGISTRY -f $IM_VARIANT .
        if [ ! -z ${PUSH} ]; then
            docker push $REGISTRY/$IM_NAME$IM_TAG
        fi
    fi
    
    cd $WORKING_DIR
}

build conductor-pterodactyl 8
build conductor-pterodactyl 17
build conductor-pterodactyl 21
build conductor-pterodactyl
build stun
build disposable-minecraft
build registry-auth-proxy
build jenkins-with-dockercli
build pterodactyl-wings
build php-laravel
