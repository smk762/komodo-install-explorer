#!/bin/bash

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

rm -rf $1-explorer $1-explorer-start.sh $1-webaccess 

./configure_chain_explorer.py $1 clean