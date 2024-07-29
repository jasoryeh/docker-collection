#!/bin/bash

# create the user and remove any existing passwords
adduser $STUN_USER -D && passwd -d $STUN_USER

# associate the new password if it is set
if [[ ! -z $TUNNEL_PASSWORD ]]; then
    echo "$STUN_USER:$TUNNEL_PASSWORD" | chpasswd
    echo "stun user $STUN_USER account password set!"
fi

# any scripts to run on startup
echo "$TUNNEL_LOG_SCRIPT" > /stun-login-script.sh

# log a startup event, and setup the stun.log file's permissions to be permissive, then monitor stun.log on the container logs
echo "STUN Started $(date) $(user) \n$(export)" >> /stun.log
chmod 777 /stun.log
tail -f -n 5 /stun.log &

# ssh setup
echo "* generate hostkeys"
ssh-keygen -A

# some user variables that might be used in the forced command
echo $PORT > /stun/envs_PORT
echo $STUN_USER > /stun/envs_USER

# information to the log for a quick reference
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

# start the sshd server
echo "* start sshd on :${PORT}"
/usr/sbin/sshd -D -p ${PORT} -e $SSHD_ARGS
