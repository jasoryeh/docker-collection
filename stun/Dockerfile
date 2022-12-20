FROM alpine:latest

USER root

ENV PORT 22

RUN apk add bash openssh
RUN adduser tun -D && passwd -d tun

COPY . /stun
RUN cat /stun/sshd_add.conf > /etc/ssh/sshd_config

CMD [ "/bin/bash", "/stun/entrypoint.sh" ]
