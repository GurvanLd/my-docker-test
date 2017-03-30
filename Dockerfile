FROM ubuntu:16.04
MAINTAINER Viral Parikh "https://gitlab.mycom-osi.com/vparikh"

######################################################
# OS
######################################################

## set up some os level pre-reqs
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --fix-missing
RUN apt-get install openssh-server -y
RUN apt-get install net-tools -y 
RUN apt-get install curl vim unzip -y
RUN apt-get install iputils-ping -y
RUN apt-get install netcat-traditional -y

## set up the locales
RUN apt-get install locales -y 
RUN dpkg-reconfigure -f noninteractive locales
RUN locale-gen en_US.utf8
RUN /usr/sbin/update-locale LANG=C.UTF-8 
RUN echo "en_US.utf8-8 UTF-8" >> /etc/locale.gen
RUN locale-gen
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## set up python 
RUN apt-get update 
RUN apt-get -y --no-install-recommends install python-yaml
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

######################################################
# JAVA
######################################################
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=111
ARG JAVA_BUILD_NUMBER=14
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}

#http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz

ENV PATH $PATH:$JAVA_HOME/bin
RUN echo "installing jave to $JAVA_HOME"

RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/jdk-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $JAVA_HOME /usr/java \
  && rm -rf $JAVA_HOME/man

######################################################
# TOMCAT
######################################################
# Run tomcat as root or create another user/group?

ARG TOMCAT_MAJOR=8
ARG TOMCAT_VERSION=8.5.12
ARG TOMCAT_HOME=/opt/tomcat
ARG TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

RUN mkdir -p ${TOMCAT_HOME}
RUN cd /tmp
RUN curl -S -O ${TOMCAT_URL} && \
    tar xzvf apache-tomcat-*.tar.gz -C ${TOMCAT_HOME} --strip-components=1 && \
    rm apache-tomcat-*.tar.gz

ENV CATALINA_HOME ${TOMCAT_HOME}
ENV CATALINA_PID ${TOMCAT_HOME}/temp/tomcat.pid
ENV PATH $PATH:$CATALINA_HOME/bin

EXPOSE 8080

WORKDIR ${CATALINA_HOME}
CMD ["catalina.sh", "run"]
