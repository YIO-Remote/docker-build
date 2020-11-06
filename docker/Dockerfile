FROM ubuntu:20.04

ARG UBUNTU_MIRROR="http://mirror.init7.net"
ARG YIO_REMOTE_UID=1000
ARG YIO_REMOTE_GID=1000

ENV YIO_SRC=/yio-remote/src
ENV BUILDROOT_OUTPUT=/yio-remote/buildroot/output
ENV BR2_DL_DIR=/yio-remote/buildroot/dl
ENV BR2_CCACHE_DIR=/yio-remote/buildroot/ccache

# Set timezone instead of UTC
ENV TZ=Europe/Zurich
# noninteractive is required to install tzdata package without user prompt
ENV DEBIAN_FRONTEND=noninteractive

# Only required if the base image isn't updated on a regular basis:
#RUN apt-get update -qq && apt-get dist-upgrade -y

RUN groupadd -g ${YIO_REMOTE_GID} yio \
    && useradd -u ${YIO_REMOTE_UID} -m -d /yio -g ${YIO_REMOTE_GID} yio

RUN sed --in-place "s@http://archive\.ubuntu\.com@$UBUNTU_MIRROR@g" /etc/apt/sources.list && \
    sed --in-place "s@http://security\.ubuntu\.com@$UBUNTU_MIRROR@g" /etc/apt/sources.list && \
    apt-get update -q \
    && apt-get install --no-install-recommends -y \
    bc \
    build-essential \
    ca-certificates \
    cpio \
    curl \
    file \
    g++ \
    gettext \
    git \
    gzip \
    libncurses5-dev \
    libssl-dev \
    libtool \
    mc \
    nano \
    npm \
    patch \
    python \
    rsync \
    tar \
    texinfo \
    tzdata \
    dos2unix \
    unzip \
    wget \
	&& apt-get clean \
	&& npm i npm@latest -g

# create directories where the Docker volumes will be mounted, otherwise they will be owned by root!
RUN mkdir -p /yio-remote/target /yio-remote/src /yio-remote/buildroot/dl /yio-remote/buildroot/ccache \
    && chown -R yio:yio /yio-remote

USER yio

# Git projects
VOLUME /yio-remote/src
# built artefacts
VOLUME /yio-remote/target
# Buildroot downloads and ccache
VOLUME /yio-remote/buildroot

WORKDIR /yio-remote

COPY --chown=yio:yio scripts/yio.sh /usr/local/bin/yio

ENTRYPOINT ["/usr/local/bin/yio"]

# Labels, see: https://github.com/opencontainers/image-spec/blob/master/annotations.md
ARG BUILD_DATE
ARG VERSION
ARG REVISION
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.authors="markus.zehnder@trivadis.com"
LABEL org.opencontainers.image.url="https://github.com/YIO-Remote/docker-build/tree/master"
LABEL org.opencontainers.image.source="https://github.com/YIO-Remote/docker-build.git"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.vendor="YIO"
LABEL org.opencontainers.image.title="YIO Build Image"
LABEL org.opencontainers.image.description="Buildroot cross compile image for YIO remote-os running on Raspberry Pi 0 W"
# END Labels
