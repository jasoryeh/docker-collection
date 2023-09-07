FROM jenkins/jenkins
USER root

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get update && \
    apt-get -y --no-install-recommends install apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common \
      maven && \
   apt-get clean

RUN DOCKER_VERSION=24.0.6 && \
      curl -fsSLO https://download.docker.com/linux/static/stable/$(lscpu | awk '/Architecture:/{print $2}')/docker-${DOCKER_VERSION}.tgz && \
      tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 -C /usr/local/bin docker/docker && \
      rm docker-${DOCKER_VERSION}.tgz

USER jenkins
