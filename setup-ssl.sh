#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Not enough arguments provided. You need to add the assetchain ticker and subdomin as parameters"
    echo "For example: ./setup-ssl.sh MARTY marty.explorer.com"
    exit 1
fi

if [[ -z ${2} ]]; then
    read -p "Enter coin ticker: " coin
    read -p "Enter domain name for explorer (e.g. kmd.explorer.io): " domain_name
else
    coin=$1
    domain_name=$2
fi

sudo certbot certonly -d ${domain_name} --nginx --non-interactive 

./configure.py create_nginx_conf ${coin} ${domain_name}
if sudo test -f "/etc/letsencrypt/live/${domain_name}/fullchain.pem"; then
    sudo cp nginx/${coin}-explorer.serverblock /etc/nginx/sites-available/${coin}-explorer.serverblock
    sudo ln -s /etc/nginx/sites-available/${coin}-explorer.serverblock /etc/nginx/sites-enabled/${coin}-explorer.serverblock
    sudo systemctl restart nginx
else
    echo "SSL certificate [/etc/letsencrypt/live/${domain_name}/fullchain.pem] not found. Please check if the domain name [${domain_name}] is correct and if the certificate was created."
fi
