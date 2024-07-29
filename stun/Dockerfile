FROM alpine:latest

USER root

ENV PORT=22
ENV STUN_USER=tun

RUN apk add bash openssh
#RUN adduser ${STUN_USER} -D && passwd -d ${STUN_USER}

COPY . /stun
RUN cat /stun/sshd_add.conf > /etc/ssh/sshd_config

CMD [ "/bin/bash", "/stun/entrypoint.sh" ]
