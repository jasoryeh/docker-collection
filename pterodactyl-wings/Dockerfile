FROM docker:dind

MAINTAINER Jason Ho <docker@hogt.me>

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

# See https://github.com/docker-library/docker/pull/166
# also because something went wrong and default settings cant find the dind daemon
ENV DOCKER_HOST=tcp://127.0.0.1:2375
ENV DOCKER_DRIVER=overlay2
ENV DOCKER_TLS_CERTDIR=""
# security
RUN sed -i 's/0.0.0.0/127.0.0.1/g' /usr/local/bin/dockerd-entrypoint.sh

# https://github.com/docker-library/docker/issues/55
#RUN addgroup -g 2999 docker
RUN apk add bash curl unzip tar yq jq git go
# change following if upgrading wings
RUN WINGS_VERSION=1.11.13 && \
    mkdir -p /etc/pterodactyl && \
    curl -L -o /tmp/wings.tar.gz https://github.com/pterodactyl/wings/archive/refs/tags/v${WINGS_VERSION}.tar.gz && \
    cd /tmp && \
    tar -xzvf wings.tar.gz && \
    cd wings-${WINGS_VERSION} && \
    go build && mv /tmp/wings-${WINGS_VERSION}/wings /usr/local/bin/wings && \
    chmod u+x /usr/local/bin/wings

ADD . .

# EXPOSE xxx
EXPOSE 8080 2022

COPY ./entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
