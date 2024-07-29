#!/bin/bash

adduser $STUN_USER -D && passwd -d $STUN_USER

if [[ ! -z $TUNNEL_PASSWORD ]]; then
    echo "$STUN_USER:$TUNNEL_PASSWORD" | chpasswd
    echo "stun user $STUN_USER account password set!"
fi

echo "$TUNNEL_LOG_SCRIPT" > /stun-login-script.sh
echo "STUN Started $(date) $(user) \n$(export)" >> /stun.log
chmod 777 /stun.log
tail -f -n 5 /stun.log &

echo "* generate hostkeys"
ssh-keygen -A

echo $PORT > /stun/envs_PORT
echo $STUN_USER > /stun/envs_USER

echo ""
echo ">> stun!"
echo ""
echo "See instructions for usage by issuing 'ssh ${STUN_USER}@${HOSTNAME}'"
echo "  (notes)"
echo "    * if this stun instance is ephemeral, use instead: "
echo "        'ssh -p $PORT -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null' ${STUN_USER}@${HOSTNAME}'"
echo "      to avoid key check failures with reuse."
echo "  (container options)"
echo "    * Change the port the container listens to by specifying '-e PORT=#' where # is the port number"
echo "    * If you would like to change the hostname (${HOSTNAME}), please change it for the docker container"
echo "    * Ensure host networking (or your networking choice) is enabled if you'd like all tunnels to be accessible"
echo "        OR pass the ports with option '-p'"
echo "    * If you would like to set a password for the 'tun' account, please specify TUNNEL_PASSWORD"
echo ""

echo "* start sshd on :${PORT}"
/usr/sbin/sshd -D -p ${PORT} -e $SSHD_ARGS
