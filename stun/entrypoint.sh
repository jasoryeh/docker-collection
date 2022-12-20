#!/bin/bash

echo "* generate hostkeys"
ssh-keygen -A

echo $PORT > /stun/envs_PORT

echo ""
echo ">> stun!"
echo ""
echo "See instructions for usage by issuing 'ssh tun@${HOSTNAME}'"
echo "  (notes)"
echo "    * if this stun instance is ephemeral, use instead: "
echo "        'ssh -p $PORT -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null' tun@${HOSTNAME}'"
echo "      to avoid key check failures with reuse."
echo "  (container options)"
echo "    * Change the port the container listens to by specifying '-e PORT=#' where # is the port number"
echo "    * If you would like to change the hostname (${HOSTNAME}), please change it for the docker container"
echo "    * Ensure host networking (or your networking choice) is enabled if you'd like all tunnels to be accessible"
echo "        OR pass the ports with option '-p'"
echo ""

echo "* start sshd on :${PORT}"
/usr/sbin/sshd -D -p ${PORT} -e
