FROM openjdk:8-jdk-alpine
MAINTAINER Badak Team Blibli.com <argo.triwidodo@gdn-commerce.com>

ARG VERSION=3.28
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV HOME /home/${user}
RUN addgroup -g ${gid} ${group}
RUN adduser -h $HOME -u ${uid} -G ${group} -D ${user}
LABEL Description="This is a Badak Slave image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN apk add --update --no-cache curl bash git openssh-client openssl procps \
  && curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar \
  && apk del curl

# Open SSH
RUN apk add --update openssh \
&& rm  -rf /tmp/* /var/cache/apk/*
ADD docker-entrypoint.sh /usr/local/bin
RUN chown -R ${user} /usr/local/bin
#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
# Generate SSH Key
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN ssh-keygen -A
RUN mkdir -p /var/run/sshd
# CHOWN
RUN chown -R ${user} /etc/ssh/

# Git
RUN apk add git
# Maven
RUN mkdir /home/${user}/.m2
# ADD settings.xml /home/${user}/.m2/
RUN chown -R jenkins:jenkins /home/${user}/.m2/
RUN apk add maven
RUN apk add nodejs

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

# End Jenkins

# Run SSH
EXPOSE 22
# ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D"]