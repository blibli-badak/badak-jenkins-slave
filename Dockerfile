FROM alpine:edge
LABEL org.opencontainers.image.authors="Badak Team Blibli.com <argo.triwidodo@gdn-commerce.com>"

ARG VERSION=4.11.2
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Add user jenkins to the image and add Alpine Edge Testing repositores
RUN adduser -D jenkins
RUN echo http://dl-2.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk --no-cache add shadow && usermod -a -G root jenkins

# Make sure the package repository is up to date.
RUN apk update
RUN apk upgrade
RUN apk add --update git curl openjdk11 nodejs npm maven openjfx

# Install a basic SSH server
RUN apk add openssh
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd
RUN apk add --no-cache openrc
RUN rc-update add sshd
RUN apk del openrc

# Change Timezone To jakarta
ENV TZ=Asia/Jakarta
RUN apk add --update tzdata && \
    cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
    echo "Asia/Jakarta" > /etc/timezone && \
    apk del tzdata

# Download Jenkins slave
RUN curl --create-dirs -o /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Clean up apk cache
RUN rm -rf /var/cache/apk/*

# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.m2
RUN chown -R jenkins:jenkins /home/jenkins/.m2/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

# Install chromium
RUN apk add chromium

# Setup path for npm
WORKDIR /usr/app
COPY ./ /usr/app

# Handling ERR! code UNABLE_TO_GET_ISSUER_CERT_LOCALLY
RUN npm config set strict-ssl=false

# Install lhci
RUN npm install -D @lhci/cli
