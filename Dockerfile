FROM centos:7
MAINTAINER Badak Team Blibli.com <argo.triwidodo@gdn-commerce.com>

ARG VERSION=3.28
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Make sure the package repository is up to date.
#RUN add-apt-repository ppa:openjdk-r/ppa
RUN yum -y update
RUN yum -y upgrade
RUN yum install -y git
# Install JDK 8 (latest edition)
RUN yum install -y java-1.8.0-openjdk && yum install -y curl && yum install -y wget

# start install node JS
RUN wget http://nodejs.org/dist/v0.10.30/node-v0.10.30.tar.gz
RUN tar xzvf node-v* && cd node-v*
RUN yum install -y gcc gcc-c++ && ./configure && make && make install

# Install a basic SSH server
RUN yum install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd


# Add user jenkins to the image
RUN adduser --quiet jenkins
RUN usermod -a -G root jenkins

# Download Jenkins slave
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.m2
#ADD settings.xml /home/jenkins/.m2/
RUN chown -R jenkins:jenkins /home/jenkins/.m2/
RUN yum install -y maven
# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]