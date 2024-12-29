# Conductor for Pterodactyl
A container for executing Conductor prior to launching your game servers.

## Environment and Configuration
This container includes a couple variables that support the deployment of a Conductor-configured server or application. Some of these must be defined at container start in the container environment, whereas others can be defined later.

`*` indicates required variables.

### Container Configurable
- `DL_PATH` - A resource to download, used in setup script to indicate a URL to a `server.jar` to use. Since Conductor can handle this for the user, this is repurposed to assist in downloading configuration or setup scripts to the `DL_TO_FILE` file.
- `DL_TO_FILE` - The location to download the file at `DL_PATH` to, where `./file.txt` is `/home/container/file.txt` (or `server directory`/`file.txt`).
- `DL_PATH_EXEC` - Should this file be executed as a `bash` script after downloading?
### Script Configurable
- `STARTUP`* - (Pterodactyl) The startup command configured in the panel (e.g. `java -jar server.jar`)
- `SERVER_PORT`* (Pterodactyl) or `PORT` - The port to configure the server with, this is automatically provided via allocations and communicated to the container using `SERVER_PORT` by Pterodactyl Wings. This container will fall back to the `PORT` variable if not found for greater compatibility. 
- `CONDUCTOR_FLAGS` - Java flags `-Dflag.key=flag_value` for running the Conductor program.
- `CONDUCTOR_EXEC` - Alternative command for executing conductor, `CONDUCTOR_FLAGS` will be ignored.
- `CONDUCTOR_DEBUG` - Enables a shell prior to starting the server (after Conductor), and just after the server finishes.
- `CONDUCTOR_RUNTIMEFLAGS` - Substitutes `-Dconductor.runtime_flags=here` in `STARTUP` to this value.
- `CONDUCTOR_ENVFILE` - A env file to load, defaults to `conductor.env`.

## Scripts
The container is also configured to use 4 scripts during the setup process:
1. `preupdate.sh` - Executed prior to a Conductor run.
2. `postupdate.sh` - Executed after a Conductor run.
3. `prestart.sh` - Executed before server execution.
4. `poststart.sh` - Executed after server execution.

