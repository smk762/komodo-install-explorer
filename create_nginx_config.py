#!/usr/bin/env python3
import os
import sys
import time
from dotenv import load_dotenv
from lib_logger import logger
import lib_helper as helper

load_dotenv()

def create_conf(coin, subdomain=False):
    home = os.path.expanduser("~")
    webroot = os.getenv(f'{coin}_WEBROOT')
    if not webroot:
        webroot = f"{home}/insight"
        os.makedirs(webroot, exist_ok=True)

    proxy_host = os.getenv(f'{coin}_PROXY_PASS_HOST')
    if not proxy_host:
        proxy_host = '127.0.0.1'

    if not subdomain:
        subdomain = get_subdomain(coin)

    explorer_port = os.getenv(f'{coin}_EXPLORER_PORT')
    if not explorer_port:
        explorer_port = check_webaccess(coin)
    if not explorer_port:
        explorer_port = input(f"Enter the {coin} explorer's port: ")

    create_serverblock(coin, webroot, proxy_host, subdomain, explorer_port)


def get_subdomain(coin):
    subdomain = os.getenv(f'{coin}_SUBDOMAIN')
    if not subdomain:
        subdomain = input(f"Enter the {coin} explorer's subdomain name: ")
    return subdomain


def check_webaccess(coin):
    script_path = os.path.realpath(os.path.dirname(__file__))
    if not os.path.exists(f'{script_path}/{coin}-webaccess'):
        return None
    with open(f"{script_path}/{coin}-webaccess", "r") as r:
        for line in r.readlines():
            if line.find("webport") > -1:
                return line.split("=")[1]


def create_serverblock(coin, webroot, proxy_host, subdomain, explorer_port):
    home = os.path.expanduser("~")
    script_path = os.path.realpath(os.path.dirname(__file__))
    blockname = f"{script_path}/nginx/{coin}-explorer.serverblock"
    with open(f"{script_path}/nginx/TEMPLATE.serverblock", "r") as r:
        with open(blockname, "w") as w:
            for line in r.readlines():
                line = line.replace("COIN", coin)
                line = line.replace("HOMEDIR", home)
                line = line.replace("WEBROOT", webroot)
                line = line.replace("SUBDOMAIN", subdomain)
                line = line.replace("PROXY_HOST", proxy_host)
                line = line.replace("EXPLORER_PORT", explorer_port)
                w.write(f"{line}")
    print(f"NGINX config saved to {blockname}")
    print(f"Activate it with 'sudo ln -s {blockname} /etc/nginx/sites-enabled/{coin}-explorer.serverblock'")
    print(f"Then restart nginx with 'sudo systemctl restart nginx'")


if __name__ == "__main__":
    
    if len(sys.argv) > 1:
        coin = sys.argv[1]
    else:
        coin = os.getenv('COIN')
        if not coin:
            coin = input(f"Enter the coin's ticker: ")

    if len(sys.argv) > 2:
        if sys.argv[2] == "get_subdomain":
            get_subdomain(coin)
        else:
            create_conf(coin, sys.argv[2])

    else:
        create_conf(coin)
