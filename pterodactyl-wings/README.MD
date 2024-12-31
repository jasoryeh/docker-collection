# Pterodactyl Wings
A container for Pterodactyl Wings to be auto-configured on a Linux host. This container is not completely self-contained, and requires privileged access.

## Requirements
Host:
- Docker installation (to run this container)

External:
- Pterodactyl Panel install
- Node token and ID from the panel in the Configuration tab for the node

## Running: manually created node
```sh
docker run -d --net=host \
    --name pterodactyl-wings \
    --privileged \
    --volume /etc/pterodactyl:/etc/pterodactyl \
    --volume /var/lib/pterodactyl:/var/lib/pterodactyl \
    --volume /var/log/pterodactyl:/var/log/pterodactyl \
    --volume /tmp/pterodactyl:/tmp/pterodactyl \
    -e "PTERODACTYL_PANEL_URL=https://pterodactyl.example.com" \
    -e "PTERODACTYL_TOKEN=ptd" \
    -e "PTERODACTYL_NODE_ID=123" \
    jasoryeh/pterodactyl-wings
```
- `/etc/pterodactyl` wings configurations
- `/var/lib/pterodactyl` storage for the server containers

# Running: let the container handle creating the node
With Docker run:
```sh
docker run -d --net=host \
    --name pterodactyl-wings \
    --privileged \
    --volume /etc/pterodactyl:/etc/pterodactyl \
    --volume /var/lib/pterodactyl:/var/lib/pterodactyl \
    --volume /var/log/pterodactyl:/var/log/pterodactyl \
    --volume /tmp/pterodactyl:/tmp/pterodactyl \
    -e "PTERODACTYL_PANEL_URL=https://pterodactyl.example.com" \
    -e "PTERODACTYL_TOKEN=ptd" \
    -e "PTERODACTYL_CREATE_NODE=1"
    jasoryeh/pterodactyl-wings
```

Same thing but with Docker compose and additional environment variables that could be used:
```yaml
services:
  wings:
    container_name: wings
    image: wings
    environment:
      PTERODACTYL_TOKEN: ptla_tokenhere
      PTERODACTYL_PANEL_URL: https://ptd.example.com
      PTERODACTYL_CREATE_NODE: 1
#      PTERODACTYL_DELETE_NODE: 1
#      PTERODACTYL_NODE_FQDN: 111.222.111.222
#      PTERODACTYL_NODE_SCHEME: http
#      SKIP_DOCKER: true
#      DOCKER_HOST: 'unix:///var/run/docker.sock'
    volumes:
      - './tmp/pterodactyl:/tmp/pterodactyl'
      - './var/lib/pterodactyl:/var/lib/pterodactyl'
      - './var/log/pterodactyl:/var/log/pterodactyl'
      - './etc/pterodactyl:/etc/pterodactyl'
    network_mode: host
    privileged: true
```
