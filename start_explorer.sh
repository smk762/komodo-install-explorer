#!/bin/bash

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

./update_styles.sh $1
./$1-explorer-start.sh
