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

sudo apt update
sudo apt install -y snapd
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot certonly -d ${domain_name} --nginx --non-interactive 

./configure.py create_nginx_conf ${coin} ${domain_name}

sudo cp nginx/${coin}-explorer.serverblock /etc/nginx/sites-available/${coin}-explorer.serverblock
sudo ln -s /etc/nginx/sites-available/${coin}-explorer.serverblock /etc/nginx/sites-enabled/${coin}-explorer.serverblock
sudo systemctl restart nginx
