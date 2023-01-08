#!/bin/sh

set -x

if [[ -z $JAVA_VERSION ]]; then
    JAVA_VERSION="17"
fi

if [[ -z $JAVA_CMD ]]; then
    JAVA_CMD="/usr/lib/jvm/java-$JAVA_VERSION-openjdk/bin/java"
fi

cd /workdir
bash -c "$JAVA_CMD -jar server.jar"
