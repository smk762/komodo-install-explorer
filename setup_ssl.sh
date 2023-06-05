#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Not enough arguments provided. You need to add the assetchain ticker and subdomin as parameters"
    echo "For example: ./setup_ssl.sh MARTY marty.explorer.com"
    exit 1
fi

if [[ -z ${2} ]]; then
    read -p "Enter coin ticker: " coin
    read -p "Enter domain name for explorer (e.g. kmd.explorer.io): " domain_name
else
    coin=$1
    domain_name=$2
fi

sudo certbot certonly -d ${domain_name}

./create_nginx_config.py ${coin} ${domain_name}
