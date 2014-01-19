# base
FROM stackbrew/ubuntu:raring

MAINTAINER github.com/jottr
# based on https://github.com/Runnable/dockerfiles

## Speed and Space
# see https://gist.github.com/jpetazzo/6127116
# this forces dpkg not to call sync() after package extraction and speeds up install
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
# we don't need and apt cache in a container
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# REPOS
RUN apt-get -y update 
RUN apt-get install -y -q software-properties-common
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get -y update

# SHIMS

## Hack for initctl
## See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# ENVIRONMENT
ENV TZ Europe/Berlin

### PACKAGES ###

# EDITORS
RUN apt-get install -y -q vim-tiny

# TOOLS
RUN apt-get install -y -q git make wget curl


## SUPERVISOR
RUN apt-get install -y -q supervisor

## SSH 
RUN apt-get install -y -q openssh-server
RUN mkdir -p /var/run/sshd

# CONFIGURATION & FILES


ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf


## CREDENTIALS
RUN echo "root:root" | chpasswd

## PORTS
EXPOSE 22


CMD /usr/bin/supervisord -n 
