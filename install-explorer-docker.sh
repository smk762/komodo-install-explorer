#!/bin/bash

#
# (c) Decker, 2018; Modified by smk 2023
#
DEBIAN_FRONTEND=noninteractive

CUR_DIR=$(pwd)
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'
TICKER=$1

# Setup NodeJS
echo -e "$STEP_START[ * ]$STEP_END Loading NVM and Node 4..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use v4

# Install Bitcore
echo -e "$STEP_START[ * ]$STEP_END Installing Bitcore node for $TICKER..."
if [ ! -d "${HOME}/notary_docker_main/komodo-install-explorer/${TICKER}-explorer" ]; then
  mkdir -p node_modules
  $CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create ${TICKER}-explorer
fi

# Install Insight API and UI
echo -e "$STEP_START[ * ]$STEP_END Installing Insight API and Insight UI for $TICKER..."
if [ ! -d "${HOME}/notary_docker_main/komodo-install-explorer/${TICKER}-explorer/node_modules/insight-api-komodo" ]; then
  cd ${TICKER}-explorer
  $CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
  cd $CUR_DIR
fi

# Configure explorer
echo -e "$STEP_START[ * ]$STEP_END Configuring explorer for $TICKER..."
./configure-docker.py ${TICKER}

# Patch the explorer to display notarization data
cd $CUR_DIR
echo -e "$STEP_START[ * ]$STEP_END Patching the installation to display notarization data..."
if [ ! -d "$CUR_DIR/explorer-notarized" ]; then
  echo -e "$STEP_START[ * ]$STEP_END Cloning the repository containing the notarisation patch"
  echo 
  success=0
  count=1
  while [ $success -eq 0 ]; do
    echo "[Try $count] Cloning the explorer installer repository"
    git clone https://github.com/gcharang/explorer-notarized && success=1 || success=0
    sleep 4
    count=$((count+1))
  done
else
  echo "A directory named 'explorer-notarized' already exists; assuming it is cloned from the repo: https://github.com/gcharang/explorer-notarized , trying to update and patch the explorer using it"
  cd $CUR_DIR/explorer-notarized
  git pull
fi
cd $CUR_DIR/explorer-notarized
./patch.sh ${TICKER}

# Update Insight UI styles and logos
echo -e "$STEP_START[ * ]$STEP_END Updating Insight UI styles and logos for ${TICKER}..."
cd $CUR_DIR/
./update-styles.sh "${TICKER}"


echo -e "$STEP_START[ * ]$STEP_END Done!"