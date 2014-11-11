#!/bin/bash
#Setup the box
if [[ $(hostname) != "kendubox" ]]
then
    exit 1
fi
export DEBIAN_FRONTEND=noninteractive

#Add repos:
#Docker repo:
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sh -c "echo deb https://get.docker.com/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"

#Install stuff
apt-get update
apt-get upgrade --yes --force-yes
apt-get install --yes --force-yes \
    wget \
    curl \
    git \
    nginx \
    php5 \
    php5-fpm \
    php5-common \
    php5-curl \
    php5-gmp \
    php5-imagick \
    php5-intl \
    php5-json \
    php5-mcrypt \
    php5-memcache \
    php5-pgsql \
    php5-readline \
    php5-sqlite \
    php5-xdebug \
    php5-cli \
    php5-readline \
    lxc-docker \
    python-pip \
    python-dev

apt-get clean
pip install -U fig

#add vagrant to docker group
gpasswd -a vagrant docker

#Remove an annoying bug:
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile