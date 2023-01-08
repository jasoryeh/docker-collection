#!/bin/sh

set -x

cd /workdir

if [[ -z $JARFILE_URL ]]; then
    JARFILE_URL="https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/371/downloads/paper-1.19.3-371.jar"
fi

echo "By continuing, you agree to Mojang's EULA for using Minecraft Server software."
curl -SL $JARFILE_URL -o server.jar
echo "eula=true" > /workdir/eula.txt
/usr/bin/supervisord -c /supervisord.conf

