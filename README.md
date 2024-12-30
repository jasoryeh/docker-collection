# Docker Image Collection
Collection of some potentially useful images that I use.

## Images:

### stun - SSH Tunnel
A simple container that houses an isolated OpenSSH server configured for quick-and-dirty SSH tunnels while isolating from your host server.

### registry-auth-proxy - Registry Authentication Proxy
Proxy for the Docker `registry` container with BASIC authentication configured using NGINX. Optional HTTPs configuration and credentials can be configured.

### pterodactyl-wings - Containerized Pterodactyl Wings
Containerized version of Pterodactyl Wings with the `docker:dind` (Docker-In-Docker) container as its base. This setup supports self-registration of the node to the panel using 3 environment variables (`PTERODACTYL_PANEL_URL`, `PTERODACTYL_TOKEN`, `PTERODACTYL_CREATE_NODE`)

### php-laravel - Laravel Container
PHP container with common dependencies pre-installed. Additional support tools for tools like Composer and Laravel Nova are bundled. This is not intended to be a slim image.

### jenkins-with-dockercli - Jenkins with Docker Tools
Jenkins container (`jenkins/jenkins`) with Docker tools installed + small fixes for quality-of-life improvements.

### disposable-minecraft - Ephemeral Minecraft Container
Starts a quick-and-easy Minecraft server with `stun` container support.

### conductor-pterodactyl - Conductor for Pterodactyl
Pterodactyl image with built-in Conductor.

### conductor - Conductor
Builds jasoryeh/conductor
