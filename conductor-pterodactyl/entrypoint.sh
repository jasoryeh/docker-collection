#!/bin/bash

set -e

# for pterodactyl
cd /home/container

warn() {
    echo -e "--------------------------------------------------"
    echo -e "\nWARNING:\n"
    echo -e "$*\n"
    echo -e "--------------------------------------------------"
}

info() {
    echo -e "--------------------------------------------------"
    echo -e "\nINFO:\n"
    echo -e "$*\n"
    echo -e "--------------------------------------------------"
}

warn_soft() {
    echo -e "--------------------------------------------------"
    echo -e "\nWARNING:\n"
    echo -e "$*\n"
    echo -e "\nExecution will resume in 5 seconds.\n"
    echo -e "--------------------------------------------------"
    if [ -z ${CONDUCTOR_SKIP_WARN_DELAYS} ]; then
        sleep 5
    fi
}

debug_shell() {
    if [ ! -z "${CONDUCTOR_DEBUG}" ]; then
        warn "CONDUCTOR_DEBUG is enabled (Pre-Run)."
        sh
    fi
}

info "DEBUG START: The following output is to be used for debugging purposes."
java -version
info "DEBUG END: The above output is to be used for debugging purposes."

## reusing DL_PATH as a way to communicate a script or other thing to download
DL_TO_FILE=${DL_FILE}
if [ -z ${DL_TO_FILE} ]; then
    DL_TO_FILE="./conductor-dl.sh"
fi

if [ ! -z "${DL_PATH}" ]; then
    info "Downloading startup setup script from:\n\t${DL_PATH}\n..."
    rm -f $DL_TO_FILE && curl "${DL_PATH}" > $DL_TO_FILE
    if [ ! -z "${DL_PATH_EXEC}" ]; then
        info "Executing DL_PATH script..."
        bash $DL_TO_FILE
        info "Finished DL_PATH execution, result: $?"
    fi
    info "DL_PATH complete"
else
    info "DL_PATH not used."
fi

if [ ! -z ${CONDUCTOR_ENVFILE} ]; then
    ENVFILE=$CONDUCTOR_ENVFILE
else
    ENVFILE="conductor.env"
fi

# load conductor.env in work directory if present into environment
if [ -f "$ENVFILE" ]; then
	#export $(grep -v '^#' $ENVFILE | xargs -d '\n')  # 8-jdk slim images
	export $(cat $ENVFILE | xargs)  # 8-jre-alpine images
	info "Loaded '$ENVFILE'"
else
    warn_soft "A '$ENVFILE' file was not specified, no file-based environment variables were loaded!"
fi

# Check Pterodactyl variable: STARTUP
if [ -z "${STARTUP}" ]; then
    warn "STARTUP not found, please specify a run command (e.g. 'java -jar server.jar')"
    exit 1
else
    info "Startup command detected:\n\t${STARTUP}"
fi

# Check Pterodactyl variable: SERVER_PORT; and non-pterodactyl: PORT
if [ -z "${SERVER_PORT}" ]; then
    if [ ! -z "${PORT}" ]; then
        SERVER_PORT=$PORT
        warn_soft "SERVER_PORT was not specified, but a PORT was specified, copying this... (value: ${PORT})"
    else
        warn "SERVER_PORT is not specified! If a port is not configured already, the server will fail to launch."
        exit 1
    fi
    info "Server Port:\n\t${SERVER_PORT}"}
fi

# validation complete.

# expose IP as environment
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# convert "{{vars}}" to "${vars}"
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

# finds the below $CONDUCTOR_RUNTIMEFLAGS_PLACEHOLDER to replace with $CONDUCTOR_RUNTIMEFLAGS
if [ -z ${CONDUCTOR_RUNTIMEFLAGS_PLACEHOLDER} ]; then
    CONDUCTOR_RUNTIMEFLAGS_PLACEHOLDER="-Dconductor.runtime_flags=here"
fi
info "Runtime flags placeholder is '${CONDUCTOR_RUNTIMEFLAGS_PLACEHOLDER}' -> '${CONDUCTOR_RUNTIMEFLAGS}'"
# populate with runtime flags, if any "-Dsome.flag=some-value"

echo ":${PWD}$ ${MODIFIED_STARTUP}"

# always populate server_cnf.json if it's not there
if [ ! -f server_cnf.json ]; then
    cp /server_cnf.json server_cnf.json
fi

# preupdate, run after configuration is present.
if [ -f preupdate.sh ]; then
    bash preupdate.sh
fi

CONDUCTOR_CMD="java -Dfile.encoding=UTF-8 -Dterminal.jline=false -Dterminal.ansi=true -jar $CONDUCTOR_FLAGS /conductor-updater.jar"
if [ ! -z ${CONDUCTOR_EXEC} ]; then
    CONDUCTOR_CMD=${CONDUCTOR_EXEC}
fi

# go!
info "Startup Conductor...\n\tCONDUCTOR_FLAGS=${CONDUCTOR_FLAGS}"
eval ${CONDUCTOR_CMD}
info "Conductor finished running, status: $?"

if [ -f postupdate.sh ]; then
    bash postupdate.sh
fi

if [ -f prestart.sh ]; then
    bash prestart.sh
fi

# debug shell after setup
debug_shell

# add specialflags just before starting
if [ ! -z "${CONDUCTOR_RUNTIMEFLAGS}" ]; then
    MODIFIED_STARTUP=$(echo ${MODIFIED_STARTUP} | sed -e "s+$CONDUCTOR_RUNTIMEFLAGS_PLACEHOLDER+$CONDUCTOR_RUNTIMEFLAGS+g")
fi

# life
info "Starting Server... exec:\n\t${MODIFIED_STARTUP}"
eval ${MODIFIED_STARTUP}
EXEC_STATUS=$!
info "Execution finished, status: ${EXEC_STATUS}"

# debug shell after finishing
debug_shell

if [ -f poststart.sh ]; then
    info "Running post-start script...\n"
    bash poststart.sh
    info "\nPost-start script completed. Exit code: $?"
fi

exit ${EXEC_STATUS}
