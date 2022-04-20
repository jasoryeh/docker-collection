FROM nginx:latest

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -y update && apt -y install \
    python \
    apache2-utils && \
    apt autoremove --purge -y && apt autoclean -y && apt clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

# workdir setup
WORKDIR /home/container

COPY . /home/container/config/
COPY entrypoint.sh /entrypoint.sh

# Configurable stuff if using default config
EXPOSE 80

CMD [ "/bin/bash", "/entrypoint.sh" ]
