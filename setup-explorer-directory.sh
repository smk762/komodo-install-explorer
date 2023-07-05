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

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm use 4

if [ ! -d "${HOME}/notary_docker_main/komodo-install-explorer/node_modules/bitcore-node-komodo" ]; then
    # switch node setup with nvm
    echo -e "$STEP_START[ * ]$STEP_END Installing Bitcore Node"
    mkdir -p node_modules
    npm install git+https://git@github.com/DeckerSU/bitcore-node-komodo # npm install bitcore
fi

