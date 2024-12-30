#!/bin/bash

# Usage:
# PUSH=1/<empty> MULTIARCH=1/<empty> REGISTRY=registry.example.com/<empty> builder.sh <directory> <image name> <Dockerfile file> [image tag]

CONTAINER_DIR=$1
IM_NAME=$2
IM_FILE=$3
IM_VARIANT=$4
if [ ! -z ${IM_VARIANT} ]; then
    IM_VARIANT=":${IM_VARIANT}"
fi

# optional
IM_REGISTRY=$REGISTRY
if [ ! -z ${IM_REGISTRY} ]; then
    IM_REGISTRY_INTAG="${IM_REGISTRY}/"
fi

# Build tag
IM_TAG=${IM_REGISTRY_INTAG}${IM_NAME}${IM_VARIANT}

echo "Building container in '${CONTAINER_DIR}' to ${IM_TAG} (multi-architecture?: ${MULTIARCH})"

if [ ! -z ${MULTIARCH} ]; then
    BUILDX_ARGS=""
    if [ ! -z ${PUSH} ]; then
        BUILDX_ARGS="--push"
    else
        BUILDX_ARGS="--output type=image"
    fi
    docker buildx build --platform ${IM_PLATFORMS:-linux/amd64,linux/aarch64} $BUILDX_ARGS --build-arg INTERMEDIATE_REPO=$IM_REGISTRY \
        -t ${IM_TAG} -f $CONTAINER_DIR/$IM_FILE $CONTAINER_DIR
else
    docker build --build-arg INTERMEDIATE_REPO=$IM_REGISTRY \
        -t ${IM_TAG} -f $CONTAINER_DIR/$IM_FILE $CONTAINER_DIR
    if [ ! -z ${PUSH} ]; then
        docker push ${IM_TAG}
    fi
fi
