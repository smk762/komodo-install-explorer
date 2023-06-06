#!/bin/bash

# Run this after pulling new changes from the repo upstream
if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

if [[ -z ${2} ]]; then
    if [[ $2="noweb" ]]; then
        web="noweb"
    else
        web="yesweb"
    fi
fi

./configure.py clean ${1}
./install-explorer.sh ${1} ${web}
./${1}-explorer-start.sh
