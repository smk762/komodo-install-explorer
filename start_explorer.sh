#!/bin/bash
echo $(pwd)
python3 ./make_conf.py
echo "FIND $1-explorer-start.sh-------------------------------------------------------"
echo $(find / | grep explorer-start)
echo $(pwd)
pwd
ls -al
./$1-explorer-start.sh
