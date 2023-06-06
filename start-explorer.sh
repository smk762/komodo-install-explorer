#!/bin/bash

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

./update-styles.sh $1

echo -e '\e[1;88;42m'
echo Once it is ready, you can view the Insight UI at $(cat ${coin}-webaccess)
echo -e '\e[0m'
./$1-explorer-start.sh