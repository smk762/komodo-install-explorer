#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Not enough arguments provided. You need to add the assetchain ticker and subdomin as parameters"
    echo "For example: ./setup_ssl.sh MARTY marty.explorer.com"
    exit 1
fi

sudo certbot certonly -d ${2}

./create_nginx_config.py ${1} ${2}