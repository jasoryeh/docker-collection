#!/bin/bash

set -m

# verify env
function verifyenv {
	if [ -z ${1} ]; then
		echo "Unable to continue! $2 is not valid, value: '$1'"
		exit 1
	fi
	echo "Valid $2: '$1'"
}
verifyenv "$PTERODACTYL_PANEL_URL" "PTERODACTYL_PANEL_URL"
verifyenv "$PTERODACTYL_TOKEN" "PTERODACTYL_TOKEN"

function destroy_created_node {
	if [ -z ${PTERODACTYL_NODE_ID} ]; then
		exit 0
	fi
	if [ -z ${PTERODACTYL_DELETE_NODE} ]; then
		echo "Not deleting node on shutdown because PTERODACTYL_DELETE_NODE wasn't defined"
		exit 0
	fi
	echo "Destroying node $PTERODACTYL_NODE_ID"
	RESPONSE=$(curl "${PTERODACTYL_PANEL_URL}/api/application/nodes/$PTERODACTYL_NODE_ID" \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer ${PTERODACTYL_TOKEN}" \
		-X DELETE)
	echo "Destroyed node!"
}
trap destroy_created_node 0

function create_node {
	if [ -z ${PTERODACTYL_NODE_FQDN} ]; then
		PTERODACTYL_NODE_FQDN=$(curl http://api.ipify.org)
		echo "FQDN was not specified, using IP address instead: ${PTERODACTYL_NODE_FQDN}"
		if [ -z ${PTERODACTYL_NODE_SCHEME} ]; then
			PTERODACTYL_NODE_SCHEME=http
			echo "Setting PTERODACTYL_NODE_SCHEME to http because FQDN was not provided"
		fi
	fi
	if [[ -z "${PTERODACTYL_NODE_MEMORY}" ]]; then
		PTERODACTYL_NODE_MEMORY=$(awk '/MemTotal/ {printf( "%.0f\n", $2 / 1024 )}' /proc/meminfo)
		if [ $PTERODACTYL_NODE_MEMORY -le 0 ]; then
			echo "Warning: Detected an invalid memory size, forcing it to 2000 MB (${PTERODACTYL_NODE_MEMORY})"
			PTERODACTYL_NODE_MEMORY=2000
		fi
		echo "Memory limit not defined, detecting it instead. Found: ${PTERODACTYL_NODE_MEMORY}"
	fi
	if [[ -z "${PTERODACTYL_NODE_DISK}" ]]; then
		PTERODACTYL_NODE_DISK=$(df -Pk . | tail -1 | awk '{print $4}')
		if [ $PTERODACTYL_NODE_DISK -le 0 ]; then
			echo "Warning: Detected an invalid disk size, forcing it to 10000 MB (${PTERODACTYL_NODE_DISK})"
			PTERODACTYL_NODE_DISK=10000
		fi
		echo "Disk limit not defined, detecting it instead. Found: ${PTERODACTYL_NODE_DISK}"
	fi
	POST_BODY="{
			\"name\": \"Auto - ${PTERODACTYL_NODE_NAME:-Unknown $(date +"%Y-%m-%d %H_%M_%S")}\",
			\"location_id\": ${PTERODACTYL_NODE_LOCATION:-1},
			\"fqdn\": \"${PTERODACTYL_NODE_FQDN:-unknown.hogt.me}\",
			\"scheme\": \"${PTERODACTYL_NODE_SCHEME:-https}\",
			\"memory\": ${PTERODACTYL_NODE_MEMORY:-2000},
			\"memory_overallocate\": ${PTERODACTYL_NODE_MEMORY_OVERALLOCATE:--1},
			\"disk\": ${PTERODACTYL_NODE_DISK:-100000},
			\"disk_overallocate\": ${PTERODACTYL_NODE_DISK_OVERALLOCATE:--1},
			\"upload_size\": ${PTERODACTYL_NODE_UPLOAD_SIZE:-1000},
			\"daemon_sftp\": ${PTERODACTYL_NODE_SFTP_PORT:-2022},
			\"daemon_listen\": ${PTERODACTYL_NODE_PORT:-8080}
		}"
	echo "Create Node: POST $POST_BODY"
	RESPONSE=$(curl "${PTERODACTYL_PANEL_URL}/api/application/nodes" \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer ${PTERODACTYL_TOKEN}" \
		-X POST \
		-d "$POST_BODY")
	echo "Response: $RESPONSE"
	PTERODACTYL_NODE_ID=$(echo "$RESPONSE" | jq -e ".attributes.id")
	if [ "$PTERODACTYL_NODE_ID" == "null" ]; then
		echo "Could not create a node automatically! There was no node ID returned."
		exit 1
	fi
}

if [ -z ${PTERODACTYL_CREATE_NODE} ]; then
	verifyenv "$PTERODACTYL_NODE_ID" "PTERODACTYL_NODE_ID"
	if [ -z ${PTERODACTYL_NODE_ID} ]; then
		echo "PTERODACTYL_NODE_ID is empty but PTERODACTYL_CREATE_NODE is not set!"
		exit 1
	fi
else
	if [ -z ${PTERODACTYL_NODE_ID} ]; then
		echo "Will create node to populate Node ID."
		create_node
		echo "Node created: $PTERODACTYL_NODE_ID"
	else
		echo "Node ID is already specified! ($PTERODACTYL_NODE_ID) Won't create a new node."
	fi
fi

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

function run_wings {
	echo "Running wings..."
	until [[ -f /var/run/docker.pid ]]; do
		echo "Waiting for docker..."
		sleep 1
	done

	until docker ps;
	do
		echo "Waiting for docker to become available..."
		sleep 1
	done

	# TODO: Properly wait for docker to properly initialize
	echo "Timing out for docker to initialize properly..."
	sleep 5

	echo "Running wings..."
	wings --debug
}

function main {
    setup_wings
    modify_wings
	if [ -z ${SKIP_RUN} ]; then
		echo "Starting services..."

		dockerd-entrypoint.sh &
		PID_DOCKER=$!

        run_wings
	fi
}

echo "Starting up Wings..."
main
echo "Finished set up: $PTERODACTYL_NODE_ID"