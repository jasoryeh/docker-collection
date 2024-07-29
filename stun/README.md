# stun
STUN stands for Secure TUNnel. This container contains a SSH server configured to enable remote and local port forwarding over SSH. Containerizing the SSH service will allow running an isolated SSH instance dedicated to tunneling without the potential of exposing the host.

## Configuration
`STUN_USER`: The username for STUN.
`HOSTNAME`: The hostname you're using (to show on the prompt when running the container).
`TUNNEL_PASSWORD`: The password for the `$STUN_USER` account (e.g. `tun@hostname`'s password).
`PORT`: The port the SSH server will be listening on.

## Running
To use this container, start it with either HOST networking mode or specify all the ports allowed for tunneling on top of the SSH port manually.

For more info, see `entrypoint.sh` and `info.sh`.

```sh
docker run -d -it --net=host -e "HOSTNAME=tunnel.example.com" -e "PORT=23" -e "TUNNEL_PASSWORD=password123" jasoryeh/stun
```

## Using

### To tunnel:
To use: 'ssh -p $PORT <args> $STUN_USER@$HOSTNAME'

```sh
ssh -p $PORT \
    -o 'StrictHostKeyChecking no' \
    -o 'UserKnownHostsFile=/dev/null' \
    <MORE ARGUMENTS HERE>
    $STUN_USER@$HOSTNAME
```

Strict Host Key Checks: SSH uses host key checking to validate that a server you connect to is the same as the one you connected to before by sending a challenge to the server to verify it's identity.

Since STUN is built in Docker, we are assuming you may sometimes re-create this container, you might want to avoid the pain of removing the host key from your collection with these arguments:

```
-o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null'
```

Disabling 'StrictHostKeyChecking' disables checking keys of the server with the one in your `known_hosts` file. Setting `UserKnownHostsFile` prevents storing the server's keys into `known_hosts`. Setting `-p` changes the port from the default(22).

#### Tunneling Out
Tunneling out - expose a service accessible on your computer through the server:
```
YOUR PC <-- SERVER <-- INTERNET <-- OTHER COMPUTERS
```
e.g. Making a web server on your computer accessible from the internet via your server's IP address

Arguments:
```
-R <PORT ON SERVER>:<ADDRESS ON PC (usually 127.0.0.1)>:<PORT ON PC>
```

#### Tunneling in
Tunneling in - expose a service accessible on your server through your computer: 
```
YOUR PC --> SERVER --> RESOURCES
```
e.g. Accessing a redis server on your server that is not exposed to the internet

Arguments: 
```
-L <PORT ON PC>:<ADDRESS ON SERVER (usually 127.0.0.1)>:<PORT ON SERVER>
```


### Examples
Example for exposing a Minecraft Server (port 25565) to the internet via your server:
```
ssh -p 23 -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null' -R 25565:localhost:12345 tun@tunnelserver.example.com
```
The above command will make the server running at 'localhost:12345' on your computer also accessible at 'tunnelserver.example.com:25565'
