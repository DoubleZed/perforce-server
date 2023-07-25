# ========================================================================= #
# This Dockerfile was built to experiment with perforce server on docker    #
# ========================================================================= #

FROM ubuntu:jammy AS helix-core
LABEL vendor="DoubleZed"
LABEL maintainer="DoubleZed (https://github.com/DoubleZed)"

# P4_PUBLIC_REPO should not be overridden
ARG P4_PUBLIC_REPO="deb http://package.perforce.com/apt/ubuntu jammy release"
# P4REPO is designed to be overridden
ARG P4REPO="deb http://package.perforce.com/apt/ubuntu jammy release"
ARG PKGV

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt install -y wget curl unzip vim gnupg zip lsb-release iputils-ping && \
  wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - && \
  echo "${P4_PUBLIC_REPO}\n" > /etc/apt/sources.list.d/perforce.list

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y -f helix-p4d helix-cli

# Switch to the package repository we want to get Helix from, which could be a development build.
RUN \
  echo "${P4REPO}\n" > /etc/apt/sources.list.d/perforce.list

# P4D configuration
ENV P4D_PORT              "ssl:perforce:1666"
ENV P4D_SUPER             "super"
ENV P4D_SUPER_PASSWD      ""
ENV P4D_ROOT              "/perforce-data"

COPY Version /opt/perforce/etc/Docker-Version

#COPY setup/configure-helix-p4d.sh /opt/perforce/sbin/configure-helix-p4d.sh
RUN  chmod 755 /opt/perforce/sbin/configure-helix-p4d.sh

# Simple Helix configuration
RUN echo "#${P4REPO}" > /etc/apt/sources.list.d/perforce.list && \
    echo "${P4_PUBLIC_REPO}" >> /etc/apt/sources.list.d/perforce.list

ENV P4DGRACE=$P4DGRACE

#COPY setup-perforce.sh setup-perforce.sh
#COPY ./setup-perforce.sh /usr/local/bin/setup-perforce.sh

#CMD /opt/perforce/sbin/configure-helix-p4d.sh
#CMD  /usr/local/bin/setup-perforce.sh



