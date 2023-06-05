#!/bin/bash

# Run this after pulling new changes from the repo upstream
if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

./cleanup.sh $1
./install-assetchain-explorer.sh $1 noweb
./$1-explorer-start.sh
