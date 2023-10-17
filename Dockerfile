FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="Badak Team Blibli.com <argo.triwidodo@gdn-commerce.com>"

ARG VERSION=4.9
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Make sure the package repository is up to date.
#RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get -y upgrade
RUN apt install -y git
RUN apt-get install -y curl && curl -sL https://deb.nodesource.com/setup_16.x | bash - && apt install -y nodejs
RUN apt-get install -y build-essential

# Install a basic SSH server
RUN apt install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Install Open JDK 11 (latest edition)
RUN apt install -y openjdk-11-jdk && apt install -y curl && apt install -y unzip

# Install Maven
RUN apt-get install -y maven

# Add user jenkins to the image
RUN adduser --quiet jenkins
RUN usermod -a -G root jenkins

# Change Timezone To jakarta
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN echo "Asia/Jakarta" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN date

# Download Jenkins slave
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar
  
# Add Java FX
RUN apt-get update && apt-get install -y --no-install-recommends openjfx && rm -rf /var/lib/apt/lists/*

# Add GCloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin -y
RUN gke-gcloud-auth-plugin --version
RUN apt-get install -y jq

# Download and install Apache JMeter
RUN wget -qO- https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.1.tgz | tar xvz -C /opt && \
    ln -s /opt/apache-jmeter-5.4.1 /opt/jmeter && \
    rm -rf /opt/jmeter/docs

# Set environment variables
ENV JMETER_HOME /opt/jmeter
ENV PATH $JMETER_HOME/bin:$PATH

# Download and extract JMeter plugin from ZIP
RUN wget -O /tmp/bzm-parallel-0.11.zip https://jmeter-plugins.org/files/packages/bzm-parallel-0.11.zip && \
    unzip /tmp/bzm-parallel-0.11.zip -d /opt/jmeter/lib/ && \
    rm /tmp/bzm-parallel-0.11.zip

# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.m2
#ADD settings.xml /home/jenkins/.m2/
RUN chown -R jenkins:jenkins /home/jenkins/.m2/
# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
