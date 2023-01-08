FROM alpine

RUN mkdir -p /workdir && cd /workdir

WORKDIR /workdir

RUN apk add bash curl openssh nano htop supervisor openjdk8 openjdk17

COPY /server.sh /server.sh
COPY /tunnel.sh /tunnel.sh
COPY /supervisord.conf /supervisord.conf
COPY /entrypoint.sh /entrypoint.sh

CMD [ "/bin/sh", "/entrypoint.sh" ]
