#!/usr/bin/env python3
import os
import os.path
import sys
import stat
import json
import string
import secrets
import requests
import const
from dotenv import load_dotenv

load_dotenv()
home = os.path.expanduser("~")


def get_random_string(length=16):
    char_pool = string.ascii_uppercase + string.ascii_lowercase + string.digits
    return ''.join(secrets.choice(char_pool) for i in range(length))


def get_my_ip():
    return requests.get("https://ifconfig.me").text


def create_launcher(ticker):
    with open(f"{ticker}-explorer-start.sh", 'w') as f:
        f.write('#!/bin/bash\n')
        f.write(f'export NVM_DIR="{home}/.nvm"\n')
        f.write(f'[ -s "{home}/.nvm/nvm.sh" ] && . "{home}/.nvm/nvm.sh" # This loads nvm\n')
        f.write(f'cd {ticker}-explorer\n')
        f.write('nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start\n')
    os.chmod(f"{ticker}-explorer-start.sh", stat.S_IRWXU)


def get_explorers():
    try:
        with open(f"{script_path}/explorers.json", "r") as f:
            return json.load(f)
    except:
        return {}

def create_conf_file(ticker):
    explorers = get_explorers()
    explorer_index = len(explorers)
    print(f"{explorer_index} existing explorers")

    with open(f"{script_path}/explorers.json", "w+") as f:
        if ticker not in explorers:
            rpcport = 46857 + explorer_index
            zmqport = 50501 + explorer_index
            webport = 8091 + explorer_index
            explorers.update({
                ticker: {
                    "rpcip": "127.0.0.1",
                    "rpcport": rpcport,
                    "rpcuser": get_random_string(),
                    "rpcpassword": get_random_string(32),
                    "webport": webport,
                    "zmqport": zmqport
                }
            })
            json.dump(explorers, f, indent=4)

            rpcip = explorers[ticker]["rpcip"]
            rpcport = explorers[ticker]["rpcport"]
            rpcpassword = explorers[ticker]["rpcpassword"]
            rpcuser = explorers[ticker]["rpcuser"]
            webport = explorers[ticker]["webport"]
            zmqport = explorers[ticker]["zmqport"]
            
            if ticker == "KMD":
                coin_conf_path = const.KOMODO_CONF_PATH
                coin_conf_file = f"{const.KOMODO_CONF_PATH}/komodo.conf"
            else:
                coin_conf_path = f"{const.KOMODO_CONF_PATH}/{ticker}"
                coin_conf_file = f"{const.KOMODO_CONF_PATH}/{ticker}/{ticker}.conf"

            if not os.path.exists(coin_conf_path):
                os.makedirs(coin_conf_path)

            print(f"Updating {coin_conf_file}")
            with open(coin_conf_file, 'w') as f:
                f.write("addressindex=1\n")
                f.write(f"rpcallowip={rpcip}\n")
                f.write(f"rpcpassword={rpcpassword}\n")
                f.write(f"rpcport={rpcport}\n")
                f.write(f"rpcuser={rpcuser}\n")
                f.write("rpcworkqueue=256\n")
                f.write("server=1\n")
                f.write("showmetrics=0\n")
                f.write("spentindex=1\n")
                f.write("timestampindex=1\n")
                f.write("txindex=1\n")
                f.write("uacomment=bitcore\n")
                f.write(f"whitelist={rpcip}\n")
                f.write(f"zmqpubhashblock=tcp://{rpcip}:{zmqport}\n")
                f.write(f"zmqpubrawtx=tcp://{rpcip}:{zmqport}\n")


def create_explorer_conf(ticker):
    explorers = get_explorers()

    if ticker not in explorers:
        print("Ticker is not in explorers.json! Run `./configure.py create_ticker_conf` first.")
        sys.exit(0)
    else:
        rpcip = explorers[ticker]["rpcip"]
        rpcport = explorers[ticker]["rpcport"]
        rpcpassword = explorers[ticker]["rpcpassword"]
        rpcuser = explorers[ticker]["rpcuser"]
        webport = explorers[ticker]["webport"]
        zmqport = explorers[ticker]["zmqport"]

    with open(f"{script_path}/{ticker}-explorer/bitcore-node.json", "w+") as f:
        config = {
            "network": "mainnet",
            "port": webport,
            "services": [
                "bitcoind",
                "insight-api-komodo",
                "insight-ui-komodo",
                "web"
            ],
            "servicesConfig": {
                "bitcoind": {
                    "connect": [{
                        "rpchost": rpcip,
                        "rpcport": rpcport,
                        "rpcuser": rpcuser,
                        "rpcpassword": rpcpassword,
                        "zmqpubrawtx": f"tcp://{rpcip}:{zmqport}"
                    }]
                },
                "insight-api-komodo": {
                    "rateLimiterOptions": {
                        "whitelist": [f"::ffff:{rpcip}",rpcip],
                        "whitelistLimit": 500000,
                        "whitelistInterval": 3600000
                    }
                }
            }
        }
        json.dump(config, f, indent=4)


def create_webaccess(ticker, noweb):
    explorers = get_explorers()
    if ticker not in explorers:
        print("Ticker is not in explorers.json! Run `./configure.py create_ticker_conf` first.")
        sys.exit(0)
    else:
        rpcip = explorers[ticker]["rpcip"]
        rpcport = explorers[ticker]["rpcport"]
        rpcpassword = explorers[ticker]["rpcpassword"]
        rpcuser = explorers[ticker]["rpcuser"]
        webport = explorers[ticker]["webport"]
        zmqport = explorers[ticker]["zmqport"]
    if noweb:
        ip = 'localhost'
        print(f"The webport hasn't been opened; To access the explorer through the internet, open the port: {webport} by executing the command 'sudo ufw allow {webport}'")
    else:
        ip = get_my_ip()

    print(f"Visit http://{ip}:{webport} from another computer to access the explorer after starting it")
    with open(f'{ticker}-webaccess', 'w') as f:
        f.write(f"url=http://{ip}:{webport}\n")
        f.write(f"webport={webport}")


def clean(ticker):
    explorers = get_explorers()
    with open(f"{script_path}/explorers.json", "w+") as f:
        if ticker in explorers:
            del explorers[ticker]
            json.dump(explorers, f, indent=4)


class NginxConfig:
    def __init__(self, coin, subdomain=""):
        self.coin = coin
        self.subdomain = subdomain
        if self.subdomain == "":
            self.subdomain = self.get_subdomain(coin)

    def create_conf(self):
        home = os.path.expanduser("~")
        webroot = os.getenv(f'{self.coin}_WEBROOT')
        if not webroot:
            webroot = f"{home}/insight"
            os.makedirs(webroot, exist_ok=True)

        proxy_host = os.getenv(f'{self.coin}_PROXY_PASS_HOST')
        if not proxy_host:
            proxy_host = '127.0.0.1'

        explorer_port = os.getenv(f'{self.coin}_EXPLORER_PORT')
        if not explorer_port:
            explorer_port = self.check_webaccess()
        if not explorer_port:
            explorer_port = input(f"Enter the {self.coin} explorer's port: ")

        self.create_serverblock(webroot, proxy_host, self.subdomain, explorer_port)

    def get_subdomain(self):
        subdomain = os.getenv(f'{self.coin}_SUBDOMAIN')
        if not subdomain:
            subdomain = input(f"Enter the {self.coin} explorer's subdomain name: ")
        return subdomain

    def check_webaccess(self):
        script_path = os.path.realpath(os.path.dirname(__file__))
        if not os.path.exists(f'{script_path}/{self.coin}-webaccess'):
            return None
        with open(f"{script_path}/{self.coin}-webaccess", "r") as r:
            for line in r.readlines():
                if line.find("webport") > -1:
                    return line.split("=")[1]

    def create_serverblock(self, webroot, proxy_host, subdomain, explorer_port):
        home = os.path.expanduser("~")
        script_path = os.path.realpath(os.path.dirname(__file__))
        blockname = f"{script_path}/nginx/{self.coin}-explorer.serverblock"
        with open(f"{script_path}/nginx/TEMPLATE.serverblock", "r") as r:
            with open(blockname, "w") as w:
                for line in r.readlines():
                    line = line.replace("COIN", self.coin)
                    line = line.replace("HOMEDIR", home)
                    line = line.replace("WEBROOT", webroot)
                    line = line.replace("SUBDOMAIN", subdomain)
                    line = line.replace("PROXY_HOST", proxy_host)
                    line = line.replace("EXPLORER_PORT", explorer_port)
                    w.write(f"{line}")
        print(f"NGINX config saved to {blockname}")
        print(f"Activate it with 'sudo ln -s {blockname} /etc/nginx/sites-enabled/{self.coin}-explorer.serverblock'")
        print(f"Then restart nginx with 'sudo systemctl restart nginx'")



if __name__ == '__main__':
    # TODO: Update .env file?
    if len(sys.argv) > 1:
        ticker = sys.argv[1]
    else:
        ticker =input("Enter chain ticker: ")

    if len(sys.argv) > 2:
        step = sys.argv[2]
    else:
        step = "create_ticker_conf"

    if len(sys.argv) > 3:
        domain_name = sys.argv[3]
    else:
        domain_name = ""

    print(f"Running step: {step} on {ticker}")

    script_path = os.path.dirname(os.path.abspath(__file__))
    if step == "create_ticker_conf":
        create_conf_file(ticker)
    elif step == "create_nginx_conf":
        nginx = NginxConfig(ticker, domain_name)
        nginx.create_conf()
    elif step == "create_explorer_conf":
        create_explorer_conf(ticker)
        create_launcher(ticker)
    elif step == "create_webaccess":
        noweb = False
        if len(sys.argv) > 3:
            if sys.argv[3] == "noweb":
                noweb = True
        create_webaccess(ticker, noweb)
    elif step == "clean":
        clean(ticker)
    else:
        print(f"{step} is not a valid option. Try one of ['create_ticker_conf', 'create_explorer_conf', 'create_webaccess', 'clean']")
