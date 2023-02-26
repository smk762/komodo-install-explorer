#!/bin/bash
echo $(pwd)
cd "/explorer/komodo-install-explorer"
ls -al
./update_styles.sh $1
echo "Making conf..."
python3 ./make_conf.py
echo "Starting Explorer..."
./$1-explorer-start.sh
