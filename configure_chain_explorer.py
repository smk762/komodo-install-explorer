#!/usr/bin/env python3
import os
import os.path
import sys
import stat
import json
import string
import random
import secrets
import requests

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
        

        conf_dir = f"{home}/.komodo/{ticker}"
        if not os.path.exists(f"{home}/.komodo/{ticker}"):
            os.makedirs(f"{home}/.komodo/{ticker}")

        conf_path = f"{home}/.komodo/{ticker}/{ticker}.conf"
        print(f"Updating {conf_path}")
        with open(conf_path, 'w') as f:
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
        print("Ticker is not in explorers.json! Run `./configure_chain_explorer.py create_ticker_conf` first.")
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
        print("Ticker is not in explorers.json! Run `./configure_chain_explorer.py create_ticker_conf` first.")
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

if __name__ == '__main__':
    if len(sys.argv) > 1:
        ticker = sys.argv[1]
    else:
        ticker =input("Enter chain ticker: ")

    if len(sys.argv) > 2:
        step = sys.argv[2]
    else:
        step = "create_ticker_conf"

    print(f"Running step: {step} on {ticker}")

    home = os.path.expanduser("~")
    script_path = os.path.dirname(os.path.abspath(__file__))

    if step == "create_ticker_conf":
        create_conf_file(ticker)
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
