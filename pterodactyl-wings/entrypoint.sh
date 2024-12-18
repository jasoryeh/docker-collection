#!/bin/bash

set -m

# verify env
function verifyenv {
	if [[ -z "$2" ]]; then
		echo "Unable to continue! $1 is not valid, value: '$2'"
		kill -9 $$
	fi
	echo "Valid $2: '$1'"
}
verifyenv "$PTERODACTYL_PANEL_URL" "PTERODACTYL_PANEL_URL"
verifyenv "$PTERODACTYL_TOKEN" "PTERODACTYL_TOKEN"
verifyenv "$PTERODACTYL_NODE_ID" "PTERODACTYL_NODE_ID"


function setup_wings {
    if [ -f /etc/pterodactyl/config.yml ]; then
        echo "Overwriting an existing daemon configuration (perhaps this instance was restarted?) at \`/etc/pterodactyl/config.yml\`"
		rm /etc/pterodactyl/config.yml
    fi
    echo "Auto configuring Wings with panel at ${PTERODACTYL_PANEL_URL} with token ${PTERODACTYL_TOKEN} with node ID #${PTERODACTYL_NODE_ID}"
	cd /etc/pterodactyl
	wings configure --panel-url ${PTERODACTYL_PANEL_URL} --token ${PTERODACTYL_TOKEN} --node ${PTERODACTYL_NODE_ID}
}

function modify_wings {
	echo "Configuring the daemon..."
	# A series of modifications to config.yml to add our current docker authentication to the image in wings

	if [ ! -z "$PTERODACTYL_DOCKER_REGISTRY" ]; then
		dockerroot=".docker.registries.\"$PTERODACTYL_DOCKER_REGISTRY\""
		# authorize wings with docker registry
		yq eval -i  "$dockerroot.username=\"$PTERODACTYL_DOCKER_REGISTRY_USERNAME\"" /etc/pterodactyl/config.yml
		yq eval -i  "$dockerroot.password=\"$PTERODACTYL_DOCKER_REGISTRY_PASSWORD\"" /etc/pterodactyl/config.yml
	fi

	# timezones to UTC by default
    yq eval -i  '.system.timezone="UTC"' /etc/pterodactyl/config.yml
    yq eval -i  '.allowed_origins[0]= "*"' /etc/pterodactyl/config.yml

    # shift wings pool downwards 1 (dind uses 172.18.0.1 which is what pterodactyl tried to use, so we set it to 172.19.0.1, and whatever seems right for ipv6 too)
    yq eval -i '.docker.network.interface = "172.19.0.1"' config.yml
    yq eval -i '.docker.network.interfaces.v4.subnet = "172.19.0.0/16"' config.yml
    yq eval -i '.docker.network.interfaces.v4.gateway = "172.19.0.1"' config.yml
    yq eval -i '.docker.network.interfaces.v6.subnet = "fdba:17c8:6c95::/64"' config.yml
    yq eval -i '.docker.network.interfaces.v6.gateway = "fdba:17c8:6c95::1011"' config.yml
}

function wait_wings {
	echo "Waiting for daemon to be ready"
	response="Connection refused"
	while [[ "$response" == *"Connection refused"* ]]; do
		echo "Waiting for daemon to actually accept connections..."
		response=$(eval "curl localhost:8080 2>&1")
		if [[ "$response" == *"Connection refused"* ]]; then
			sleep 5
		fi
	done
	echo "Daemon is ready"
}

function main {
    setup_wings
    modify_wings
	if [ -z ${SKIP_RUN} ]; then
		echo "Starting services..."
		dockerd-entrypoint.sh &
        bash /runwings.sh &
        wait_wings
		echo "Done!"
		jobs
		fg %2
		fg %1
	fi
}

echo "Starting up Wings..."
main
echo "Finished set up: $PTERODACTYL_NODE_ID"