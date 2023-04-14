#!/bin/bash

rm -rf $1-explorer $1-explorer-start.sh $1-webaccess 

./configure_chain_explorer.py $1 clean