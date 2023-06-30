# See https://github.com/phusion/baseimage-docker
FROM phusion/baseimage:jammy-1.0.1

LABEL org.opencontainers.image.authors="derek@asterius.io"

# No Debian that's a bad Debian! We don't have an interactive prompt don't fail
ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init
# https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
ENTRYPOINT ["/sbin/my_init", "--"]

# Where we build
RUN mkdir -p /var/build
WORKDIR /var/build
# workaround HOME ignore. see https://github.com/phusion/baseimage-docker/issues/119
RUN echo /var/build > /etc/container_environment/HOME && mkdir -p /etc/my_init.d

# utilize my_init from the baseimage to create the user for us
# the reason this is dynamic is so that the caller of the container
# gets the UID:GID they need/want made for them
COPY create-user.sh /etc/my_init.d/create-user.sh

# bitbake wrapper to drop root perms
COPY bitbake.sh /usr/local/bin/bitbake
COPY bitbake.sh /usr/local/bin/bitbake-diffsigs
COPY bitbake.sh /usr/local/bin/bitbake-dumpsig
COPY bitbake.sh /usr/local/bin/bitbake-layers
COPY bitbake.sh /usr/local/bin/bitbake-prserv
COPY bitbake.sh /usr/local/bin/bitbake-selftest
COPY bitbake.sh /usr/local/bin/bitbake-worker
COPY bitbake.sh /usr/local/bin/bitdoc
COPY bitbake.sh /usr/local/bin/image-writer
COPY bitbake.sh /usr/local/bin/toaster
COPY bitbake.sh /usr/local/bin/toaster-eventreplay


# ensure our rebuilds remain stable
ENV APT_GET_UPDATE 2023-06-30

# Yocto's depends
# plus some debugging utils
# hadolint ignore=DL3008
RUN apt-get --quiet --yes update && \
    apt-get --quiet --no-install-recommends --yes install gawk wget git-core diffstat unzip \
        texinfo build-essential chrpath socat cpio python3\
        python3-pip python3-pexpect xz-utils debianutils iputils-ping \
        libsdl1.2-dev xterm sudo curl libssl-dev tmux strace ltrace file && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the default shell to bash instead of dash
# hadolint ignore=DL4006
RUN echo "dash dash/sh boolean false" | debconf-set-selections && dpkg-reconfigure dash

# If you need to add more packages, just do additional RUN commands here
# this is so that layers above to not have to be regenerated.
