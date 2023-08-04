FROM python:3.7.16
LABEL org.opencontainers.image.authors="Badak Team Blibli.com <malvin.wikarsa@gdn-commerce.com>"

ARG VERSION=4.9
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN apt-get update

# Install a basic SSH server
RUN apt install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Install Java
RUN apt install -y openjdk-11-jdk && apt install -y curl

# Add user
RUN adduser --quiet jenkins
RUN usermod -a -G root jenkins

# change time zone
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN echo "Asia/Jakarta" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN date

# Download Jenkins slave
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.m2
#ADD settings.xml /home/jenkins/.m2/
RUN chown -R jenkins:jenkins /home/jenkins/.m2/
# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

WORKDIR /home

RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | cat > /etc/apt/apt.conf.d/10no--check-valid-until

RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      g++ \
      git \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      openmpi-bin \
      wget \
      python3-tk && \
    rm -rf /var/lib/apt/lists/*

COPY requirement.txt .

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirement.txt
