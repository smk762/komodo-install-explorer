#!/bin/bash

#
# (c) Decker, 2018; Modified by smk 2023
#
DEBIAN_FRONTEND=noninteractive
CUR_DIR=$(pwd)
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

echo "Preparing the current directory: $CUR_DIR"
echo "This script needs to be run only once in a directory. It installs dependencies and komodo's flavour of bitcore-node"

echo -e "$STEP_START[ * ]$STEP_END Installing apt dependencies, might require 'sudo' password"
sudo apt update
sudo apt --yes install unzip git curl build-essential pkg-config jq ufw wget m4 autoconf libtool ntp ntpdate
sudo apt --yes install g++-multilib libc6-dev libevent-dev libncurses5-dev zlib1g-dev libboost-all-dev
sudo apt --yes install bsdmainutils automake libprotobuf-dev protobuf-compiler libqrencode-dev
sudo apt --yes install libssl-dev libcurl4-gnutls-dev libsodium-dev libzmq3-dev libdb++-dev
sudo apt --yes install python python2 python3 python3-pip python3-venv nginx libcurl4-openssl-dev
sudo ln -s $(which python2) /usr/bin/python

# Install snap and certbot
sudo apt update
sudo apt install -y snapd
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Install python dependencies
echo -e "$STEP_START[ * ]$STEP_END Installing Python dependencies"
pip3 install -r requirements.txt

# install nvm
nvm_version=$(nvm -v)
if [[ ! "$nvm_version" = "0.39.3" ]]; then
    echo -e "$STEP_START[ * ]$STEP_END Installing NodeJS"
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.39.3/install.sh | bash
fi
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
echo $(which make)
echo $(python -V)

if [ ! -d "${HOME}/notary_docker_main/komodo-install-explorer/node_modules/bitcore-node-komodo" ]; then
    # switch node setup with nvm
    echo -e "$STEP_START[ * ]$STEP_END Installing Bitcore Node"
    nvm install v4
    mkdir -p node_modules
    npm install git+https://git@github.com/DeckerSU/bitcore-node-komodo # npm install bitcore
fi

