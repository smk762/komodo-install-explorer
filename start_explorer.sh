#!/bin/bash

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

echo $(pwd)
cd "/explorer/komodo-install-explorer"
ls -al
./update_styles.sh $1
echo "Making conf..."
python3 ./make_conf.py
echo "Starting Explorer..."
./$1-explorer-start.sh
