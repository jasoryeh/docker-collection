#!/bin/sh

# get the hostname to display to the users
if [ -z "${HOSTNAME}" ]; then
    LOCATION="tunnel.example.com"
else
    LOCATION="${HOSTNAME}"
fi

# acquire any stun variables
IAM=$(whoami)
PORT=$(cat /stun/envs_PORT)

# log a stun event
echo "CONNECTION=$(date) User='$USER' Client='$SSH_CLIENT' Connection='$SSH_CONNECTION' Command='$SSH_ORIGINAL_COMMAND'" >> /stun.log
echo "$(export)" >> /stun.log
if [ -f /stun-login-script.sh ]; then
    eval "$(cat /stun-login-script.sh)"
fi

# debug: clear the console if necessary
if [ -z /stun/envs_NOCLEAR ]; then
    clear
fi

# dispaly info to tunnel user
echo ""
echo ">>> Location: $LOCATION"
echo "If you are tunneling, your tunnels should be active right now!"
echo ""
echo "To use: 'ssh -p $PORT <args> $IAM@$LOCATION'"
echo ""
echo "Tunnel types:"
echo "    Tunneling out - expose a service accessible on your computer through the server:"
echo "      e.g. Making a web server on your computer accessible from the internet via your server's IP address"
echo "        YOUR PC <-- SERVER <-- INTERNET <-- OTHER COMPUTERS"
echo ""
echo "      ARGs: -R <PORT ON SERVER>:<ADDRESS ON PC (usually 127.0.0.1)>:<PORT ON PC>"
echo ""
echo "    Tunneling in - expose a service accessible on your server through your computer: "
echo "      e.g. Accessing a redis server on your server that is not exposed to the internet"
echo "        YOUR PC --> SERVER --> RESOURCES"
echo ""
echo "      ARGs: -L <PORT ON PC>:<ADDRESS ON SERVER (usually 127.0.0.1)>:<PORT ON SERVER>"
echo ""
echo "Strict Host Key Checks: SSH uses host key checking to validate that a server you connect to is the same as"
echo "  the one you connected to before by sending a challenge to the server to verify it's identity."
echo "      Since STUN is build in Docker, we are assuming you may sometimes re-create this container, you might want"
echo "        to avoid the pain of removing the host key from your collection with these arguments:"
echo ""
echo "      ARG: -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null'"
echo ""
echo "Example for exposing a Minecraft Server (port 25565) to the internet via your server:"
echo "      ssh -p $PORT -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile=/dev/null' -R 25565:localhost:25565 $IAM@$LOCATION"
echo "The above command will make the server running at 'localhost:25565' on your computer"
echo "  also accessible at '$LOCATION:25565'"
echo ""
echo "Installing SSH:"
echo "     On Windows: "
echo "       With Chocolatey: https://chocolatey.org/install"
echo "         then run:"
echo "         -> 'choco install git.install --params \"/NoAutoCrlf /NoShellIntegration /Editor:Nano\" -y --force'"
echo "       With Git for Windows: https://git-scm.com/downloads"
echo "     On Linux: Install OpenSSH with your favorite package manager"
echo "     On macOS: SSH should be installed already?"
echo ""
echo "'CTRL + C' (Windows) or 'Command + C' (macOS) to quit this tunnel session. All connections will be closed."
echo ""