FROM ubuntu:18.04
MAINTAINER Badak Team Blibli.com <argo.triwidodo@gdn-commerce.com>

ARG VERSION=3.28
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Make sure the package repository is up to date.
#RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get -y upgrade
RUN apt install -y git
RUN apt-get install -y maven
RUN apt-get install -y curl && curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt install -y nodejs

# Install a basic SSH server
RUN apt install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Install JDK 8 (latest edition)
RUN apt install -y openjdk-8-jdk && apt install -y curl
# Add user jenkins to the image
RUN adduser --quiet jenkins
RUN usermod -a -G root jenkins

# Download Jenkins slave
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar
  
# Add Java FX
RUN apt-get update && apt-get install -y --no-install-recommends openjfx && rm -rf /var/lib/apt/lists/*

# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.m2
#ADD settings.xml /home/jenkins/.m2/
RUN chown -R jenkins:jenkins /home/jenkins/.m2/
# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
