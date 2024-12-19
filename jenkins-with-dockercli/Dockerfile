FROM jenkins/jenkins
USER root

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get update && \
      apt-get -y --no-install-recommends install apt-transport-https \
            ca-certificates \
            curl \
            gnupg2 \
            software-properties-common \
            maven \
            patch && \
      install -m 0755 -d /etc/apt/keyrings && \
      curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg -o /etc/apt/keyrings/docker.asc && \
      chmod a+r /etc/apt/keyrings/docker.asc && \
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list && \
      apt-get update && \
      apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin && \
      apt-get clean && \
      usermod -aG docker jenkins

USER jenkins