FROM jenkins/inbound-agent:latest-jdk17 as inbound-stage

FROM ubuntu:22.04

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN apt-get update
RUN apt-get -y upgrade
RUN apt install -y git
RUN apt-get install -y curl && curl -sL https://deb.nodesource.com/setup_16.x | bash - && apt install -y nodejs
RUN apt-get install -y build-essential
RUN apt install -y openjdk-17-jdk && apt install -y curl
RUN apt-get install -y maven
RUN adduser --quiet jenkins
RUN usermod -a -G root jenkins

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN echo "Asia/Jakarta" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN date

RUN apt-get update && apt-get install -y --no-install-recommends openjfx && rm -rf /var/lib/apt/lists/*

RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.m2

RUN chown -R jenkins:jenkins /home/jenkins/.m2/

COPY --from=inbound-stage /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=inbound-stage /usr/share/jenkins /usr/share/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]