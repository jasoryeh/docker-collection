# Pterodactyl Wings
A container for Pterodactyl Wings to be auto-configured on a Linux host. This container is not completely self-contained, and requires privileged access.

## Requirements
Host:
- Docker installation (to run this container)

External:
- Pterodactyl Panel install
- Node token and ID from the panel in the Configuration tab for the node

## Running Minimal
```sh
docker run -d --net=host \
    --name pterodactyl-wings \
    --privileged \
    --restart=unless-stopped \
    --volume /etc/pterodactyl:/etc/pterodactyl \
    --volume /var/lib/pterodactyl/volumes:/var/lib/pterodactyl/volumes \
    -e "PTERODACTYL_PANEL_URL=https://pterodactyl.example.com" \
    -e "PTERODACTYL_TOKEN=ptd" \
    -e "PTERODACTYL_NODE_ID=123" \
    jasoryeh/pterodactyl-wings
```
- `/etc/pterodactyl` wings configurations
- `/var/lib/pterodactyl` storage for the server containers

# Running All features
```sh
docker run -d --net=host \
    --name pterodactyl-wings \
    --privileged \
    --volume /run/dbus/system_bus_socket:/run/dbus/system_bus_socket:ro \
    --restart=unless-stopped \
    --volume /etc/pterodactyl:/etc/pterodactyl \
    --volume /etc/letsencrypt:/etc/letsencrypt \
    --volume /var/lib/pterodactyl/volumes:/var/lib/pterodactyl/volumes \
    --volume /tmp:/tmp \
    -e "PTERODACTYL_PANEL_URL=https://pterodactyl.example.com" \
    -e "PTERODACTYL_TOKEN=ptd" \
    -e "PTERODACTYL_NODE_ID=123" \
    -e "PTERODACTYL_DOCKER_REGISTRY=registry.example.com"
    -e "PTERODACTYL_DOCKER_REGISTRY_USERNAME=user"
    -e "PTERODACTYL_DOCKER_REGISTRY_PASSWORD=pass"
    jasoryeh/pterodactyl-wings
```