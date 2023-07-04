#!/usr/bin/env python3
import os
import sys
import json
import const
import requests
from pathlib import Path
from dotenv import load_dotenv
from logger import logger
load_dotenv()

class Utils:
    def __init__(self):
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.project_root = Path(self.script_path).parent

    def get_my_ip(self):
        return requests.get("https://ifconfig.me").text

    def get_coin_conf(self, coin_conf_file):
        conf_data = {}
        if os.path.exists(coin_conf_file):
            with open(coin_conf_file, "r") as f:
                lines = f.readlines()
                for line in lines:
                    k, v = line.split("=")
                    conf_data.update({k.strip(): v.strip()})
        return conf_data


class ConfigExplorer:
    def __init__(self, ticker):
        self.coin = const.TICKER
        self.home = const.HOME_PATH
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.project_root = Path(self.script_path).parent
        self.utils = Utils()

    def create_launcher(self):
        launcher = f"{self.coin}-explorer-start.sh"
        with open(launcher, "w") as f:
            f.write("#!/bin/bash\n")
            f.write(f'export NVM_DIR="{self.home}/.nvm"\n')
            f.write(
                f'[ -s "{self.home}/.nvm/nvm.sh" ] && . "{self.home}/.nvm/nvm.sh" # This loads nvm\n'
            )
            f.write(f"cd {self.coin}-explorer\n")
            f.write(
                "nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start\n"
            )
        os.chmod(launcher, 0o755)

    def save_bitcore_conf(self):
        bitcore_conf = f"{self.script_path}/{self.coin}-explorer/bitcore-node.json"
        conf = self.utils.get_coin_conf(const.CONF_PATH)
        logger.info(f"coin: {self.coin}")
        logger.info(f"bitcore_conf: {bitcore_conf}")
        rpcip = conf["rpcip"]
        rpcport = conf["rpcport"]
        rpcuser = conf["rpcuser"]
        rpcpassword = conf["rpcpassword"]
        zmqport = const.ZMQ_PORT
        webport = const.WEB_PORT

        logger.info(f"webport: {webport}")
        logger.info(f"rpcip: {rpcip}")
        logger.info(f"rpcport: {rpcport}")
        logger.info(f"rpcuser: {rpcuser}")
        logger.info(f"rpcpassword: {rpcpassword}")
        logger.info(f"zmqport: {zmqport}")
        
        with open(bitcore_conf, "w+") as f:
            config = {
                "network": "mainnet",
                "port": webport,
                "services": [
                    "bitcoind",
                    "insight-api-komodo",
                    "insight-ui-komodo",
                    "web",
                ],
                "servicesConfig": {
                    "bitcoind": {
                        "connect": [
                            {
                                "rpchost": rpcip,
                                "rpcport": rpcport,
                                "rpcuser": rpcuser,
                                "rpcpassword": rpcpassword,
                                "zmqpubrawtx": f"tcp://{rpcip}:{zmqport}",
                            }
                        ]
                    },
                    "insight-api-komodo": {
                        "rateLimiterOptions": {
                            "whitelist": [f"::ffff:{rpcip}", rpcip],
                            "whitelistLimit": 500000,
                            "whitelistInterval": 3600000,
                        }
                    }
                }
            }
            json.dump(config, f, indent=4)
            logger.info(f"Updated {bitcore_conf} for {self.coin}")


def main():
    option = sys.argv[1]
    ticker = sys.argv[2]
    logger.info(f"Running step: {option} on {ticker}")
    script_path = os.path.dirname(os.path.abspath(__file__))

    config = ConfigExplorer(ticker)

    if option == "create_explorer_conf":
        config.create_explorer_conf()
        config.create_launcher()

    elif option == "create_webaccess":
        logger.info(f"Creating webaccess file with noweb=False")
        config.create_webaccess(False)


if __name__ == "__main__":
    main()
