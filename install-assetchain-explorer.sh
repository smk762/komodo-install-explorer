#!/bin/bash

#
# (c) Decker, 2018
#

if [ $# -eq 0 ]; then
    echo "No arguments provided. You need to add the assetchain ticker as a parameter"
    echo "For example: ./install-assetchain-explorer.sh TOKEL"
    exit 1
fi

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

ac=$1

CUR_DIR=$(pwd)
echo "Installing an explorer for $ac in the current directory: $CUR_DIR"

./configure_chain_explorer.py $ac create_ticker_conf

echo -e "$STEP_START[ * ]$STEP_END Installing explorer for $ac"

$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create ${ac}-explorer
cd ${ac}-explorer
$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
cd $CUR_DIR

./configure_chain_explorer.py $ac create_explorer_conf
./configure_chain_explorer.py $ac create_webaccess $2

echo "Patching the installation to display notarization data"

if [ ! -d "$CUR_DIR/explorer-notarized" ]; then
  echo "Cloning the repository cointaining the patch"
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
./patch.sh ${ac}
