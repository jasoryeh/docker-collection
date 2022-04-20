# registry-auth-proxy
Uses NGINX to proxy the docker registry at `DOCKER_REGISTRY`, accepts BASIC authentication using the credentials specified in `AUTH_CREDENTIALS`.

`AUTH_CREDENTIALS` example: "USERNAME:PASSWORD;someOtherUname:pass;abc:123"
