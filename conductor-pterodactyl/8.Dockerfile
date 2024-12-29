FROM azul/zulu-openjdk-alpine:8-latest

ENV TZ=America/Los_Angeles
RUN apk add --no-cache --update curl ca-certificates openssl git tar bash sqlite fontconfig jq \
    && adduser --disabled-password --home /home/container container

USER container
ENV  USER=container HOME=/home/container

WORKDIR /home/container
COPY . /files

COPY ./entrypoint.sh /base_entrypoint.sh
COPY ./entrypoint.sh /entrypoint.sh
COPY ./server_cnf.json /server_cnf.json


COPY --from=jasoryeh/conductor /conductor.jar /conductor-updater.jar

CMD ["/bin/bash", "/base_entrypoint.sh"]
