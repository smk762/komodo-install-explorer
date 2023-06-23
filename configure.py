#!/usr/bin/env python3
import os
import os.path
import sys
import stat
import json
import shutil
import string
import secrets
import requests
import const
from pathlib import Path
from dotenv import load_dotenv
from logger import logger

load_dotenv()


class Utils:
    def __init__(self):
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.project_root = Path(self.script_path).parent

    def get_random_string(self, length=16):
        char_pool = string.ascii_uppercase + string.ascii_lowercase + string.digits
        return "".join(secrets.choice(char_pool) for i in range(length))

    def get_my_ip(self):
        return requests.get("https://ifconfig.me").text

    def get_launch_params(self, coin):
        with open(f"{self.script_path}/launch_params.json", "r") as f:
            launch_params = json.load(f)
            if coin not in launch_params:
                logger.info(f"Launch params for {coin} not found.")
                launch_params = self.update_launch_params(coin)
                if launch_params is None:
                    logger.info(f"Launch params for {coin} not found.")
                    return None
            return launch_params[coin]

    def update_launch_params(self, coin):
        launch_params = self.get_launch_params(coin)
        if coin in launch_params:
            q = None
            while q.lower() not in ["y", "n"]:
                q = input(f"Launch params for {coin} already exist. Update? [y/n]")
            if q.lower() == "n":
                logger.info(f"Launch params for {coin} not updated.")
                return None
        params = input(f"Enter launch params for {coin} (without `/path/to/komodod`): ")
        launch_params.update({coin: params})
        try:
            with open(f"{self.script_path}/launch_params.json", "w") as f:
                return json.dump(launch_params, f, indent=4)
        except:
            return {}

    def get_explorers(self):
        print(f"{self.project_root}/coin_ports.json")
        with open(f"{self.project_root}/coin_ports.json", "r") as f:
            coin_ports = json.load(f)
        try:
            with open(f"{self.script_path}/explorers.json", "r") as f:
                explorers = json.load(f)
                for coin in explorers:
                    if coin in coin_ports:
                        explorers[coin].update(
                            {
                                "rpcport": coin_ports[coin]["rpcport"],
                                "zmqport": coin_ports[coin]["zmqport"],
                                "webport": coin_ports[coin]["webport"],
                            }
                        )
                return explorers
        except:
            return {}

    def get_coin_conf(self, coin):
        coin_conf_file = self.get_coin_conf_file(coin)
        conf_data = {}
        if os.path.exists(coin_conf_file):
            with open(coin_conf_file, "r") as f:
                lines = f.readlines()
                for line in lines:
                    k, v = line.split("=")
                    conf_data.update({k.strip(): v.strip()})
        return conf_data

    def get_coin_conf_file(self, coin):
        if coin == "KMD":
            coin_conf_path = const.KMD_CONF_PATH
            coin_conf_file = f"{const.KMD_CONF_PATH}/komodo.conf"
        else:
            coin_conf_path = f"{const.KMD_CONF_PATH}/{coin}"
            coin_conf_file = f"{const.KMD_CONF_PATH}/{coin}/{coin}.conf"
        if not os.path.exists(coin_conf_path):
            os.makedirs(coin_conf_path)
        return coin_conf_file


class ConfigExplorer:
    def __init__(self, ticker):
        self.coin = ticker
        self.home = const.HOME_PATH
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.project_root = Path(self.script_path).parent
        self.utils = Utils()
        self.explorers = self.utils.get_explorers()

    def create_launcher(self):
        with open(f"{self.coin}-explorer-start.sh", "w") as f:
            f.write("#!/bin/bash\n")
            f.write(f'export NVM_DIR="{self.home}/.nvm"\n')
            f.write(
                f'[ -s "{self.home}/.nvm/nvm.sh" ] && . "{self.home}/.nvm/nvm.sh" # This loads nvm\n'
            )
            f.write(f"cd {self.coin}-explorer\n")
            f.write(
                "nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start\n"
            )
        os.chmod(f"{self.coin}-explorer-start.sh", stat.S_IRWXU)

    def create_explorer_conf(self):
        conf_data = self.utils.get_coin_conf(self.coin)
        rpcuser = conf_data["rpcuser"]
        rpcpassword = conf_data["rpcpassword"]

        with open(f"{self.project_root}/coin_ports.json", "w+") as f:
            coin_ports = json.load(f)
            rpcport = coin_ports["rpcport"]
            zmqport = coin_ports["zmqport"]
            webport = coin_ports["webport"]

        if self.coin not in self.explorers:
            self.explorers.update({self.coin: {}})
        rpcip = "127.0.0.1"
        with open(f"{self.script_path}/explorers.json", "w+") as f:
            self.explorers[self.coin].update(
                {
                    "rpcip": rpcip,
                    "rpcport": rpcport,
                    "rpcuser": rpcuser,
                    "rpcpassword": rpcpassword,
                    "webport": webport,
                    "zmqport": zmqport,
                }
            )
            json.dump(self.explorers, f, indent=4)
            explorer_index = len(self.explorers)
            logger.info(f"{explorer_index} explorers configured")

        with open(
            f"{self.script_path}/{self.coin}-explorer/bitcore-node.json", "w+"
        ) as f:
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
                    },
                },
            }
            json.dump(config, f, indent=4)

    def create_webaccess(self, noweb=False):
        conf_data = self.utils.get_coin_conf(self.coin)
        rpcuser = conf_data["rpcuser"]
        rpcpassword = conf_data["rpcpassword"]

        with open(f"{self.project_root}/coin_ports.json", "w+") as f:
            coin_ports = json.load(f)
            rpcport = coin_ports["rpcport"]
            zmqport = coin_ports["zmqport"]
            webport = coin_ports["webport"]

        rpcip = "127.0.0.1"

        if noweb:
            ip = "localhost"
            logger.info(
                f"The webport hasn't been opened. To access the explorer through the internet,"
            )
            logger.info(
                f"open the port: {webport} by executing the command 'sudo ufw allow {webport}'"
            )
        else:
            ip = self.utils.get_my_ip()

        logger.info(
            f"Visit http://{ip}:{webport} from another computer to access the explorer after starting it"
        )
        with open(f"{self.coin}-webaccess", "w") as f:
            f.write(f"url=http://{ip}:{webport}\n")
            f.write(f"webport={webport}")

    def remove(self):
        with open(f"{self.script_path}/explorers.json", "w+") as f:
            if self.coin in self.explorers:
                del self.explorers[self.coin]
                json.dump(self.explorers, f, indent=4)
                logger.info(
                    f"{self.coin} removed from {self.script_path}/explorers.json"
                )
        for file in [f"{self.coin}-webaccess", f"{self.coin}-explorer-start.sh"]:
            try:
                os.remove(file)
            except OSError as e:
                logger.info(f"{file} does not exist, skipping...")
                pass
        try:
            os.remove(f"{self.coin}-webaccess")
        except OSError as e:
            logger.info(f"{f'{self.coin}-webaccess'} does not exist, skipping...")
        try:
            shutil.rmtree(f"{self.coin}-explorer")
        except OSError as e:
            logger.info(f"{self.coin}-explorer does not exist, skipping...")


class ConfigNginx:
    def __init__(self, coin, subdomain=""):
        self.coin = coin
        self.subdomain = subdomain.lower()
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.project_root = Path(self.script_path).parent
        self.utils = Utils()
        self.explorers = self.utils.get_explorers()
        if self.subdomain == "":
            self.subdomain = input(f"Enter the {self.coin} explorer's subdomain: ")

    def setup(self):
        home = os.path.expanduser("~")

        conf_data = self.utils.get_coin_conf(self.coin)
        rpcuser = conf_data["rpcuser"]
        rpcpassword = conf_data["rpcpassword"]

        with open(f"{self.project_root}/coin_ports.json", "w+") as f:
            coin_ports = json.load(f)
            rpcport = coin_ports["rpcport"]
            zmqport = coin_ports["zmqport"]
            webport = coin_ports["webport"]

        rpcip = "127.0.0.1"
        webroot = f"{home}/insight"
        os.makedirs(webroot, exist_ok=True)
        proxy_host = "127.0.0.1"

        self.update_webaccess(webport)
        explorer = ConfigExplorer(self.coin)
        explorer.create_explorer_conf()
        self.create_serverblock(webroot, proxy_host, webport)

    def update_webaccess(self, port):
        with open(f"{self.coin}-webaccess", "w") as f:
            f.write(f"url=http://{self.subdomain}:{port}\n")
            f.write(f"webport={port}")

    def check_webaccess(self):
        if not os.path.exists(f"{self.script_path}/{self.coin}-webaccess"):
            return None
        with open(f"{self.script_path}/{self.coin}-webaccess", "r") as r:
            for line in r.readlines():
                if line.find("webport") > -1:
                    return line.split("=")[1]

    def create_serverblock(self, webroot, proxy_host, explorer_port):
        blockname = f"{self.script_path}/nginx/{self.coin}-explorer.serverblock"
        with open(f"{self.script_path}/nginx/TEMPLATE.serverblock", "r") as r:
            with open(blockname, "w") as w:
                for line in r.readlines():
                    line = line.replace("COIN", self.coin)
                    line = line.replace("HOMEDIR", const.HOME_PATH)
                    line = line.replace("WEBROOT", webroot)
                    line = line.replace("SUBDOMAIN", self.subdomain)
                    line = line.replace("PROXY_HOST", proxy_host)
                    line = line.replace("EXPLORER_PORT", str(explorer_port))
                    w.write(f"{line}")


class ConfigServices:
    def __init__(self, coin, address, pubkey):
        self.coin = coin
        self.address = address
        self.pubkey = pubkey
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.project_root = Path(self.script_path).parent
        self.utils = Utils()
        self.launch_params = (
            f"{self.utils.get_launch_params(self.coin)} -pubkey=${self.pubkey}"
        )
        self.explorers = self.utils.get_explorers()
        if not os.path.exists(f"{const.HOME_PATH}/logs"):
            os.makedirs(f"{const.HOME_PATH}/logs")

    def create_daemon_service(self):
        with open(f"{self.script_path}/services/TEMPLATE-daemon.service", "r") as f:
            lines = f.readlines()
            with open(
                f"{self.script_path}/services/{self.coin}-daemon.service", "w"
            ) as f:
                for line in lines:
                    line = line.replace("COIN", self.coin)
                    line = line.replace("ADDRESS", const.KMD_ADDRESS)
                    line = line.replace("USERNAME", const.USERNAME)
                    line = line.replace("LAUNCH_PARAMS", self.launch_params)
                    f.write(line)

    def create_explorer_service(self):
        with open(f"{self.script_path}/services/TEMPLATE-explorer.service", "r") as f:
            lines = f.readlines()
            with open(
                f"{self.script_path}/services/{self.coin}-explorer.service", "w"
            ) as f:
                for line in lines:
                    line = line.replace("COIN", self.coin)
                    line = line.replace("USERNAME", const.USERNAME)
                    f.write(line)


def main():
    # TODO: Update .env file?
    options = [
        "create_nginx_conf",
        "create_services",
        "create_explorer_conf",
        "create_webaccess",
        "get_launch_params",
        "remove",
        "exit",
    ]
    option = None
    if len(sys.argv) > 1:
        option = sys.argv[1]
        if option not in options:
            logger.warning(f"Invalid option: {option}. Must be one of {options}")
            option = None

    if option is None:
        while True:
            for i in range(len(options)):
                logger.debug(f"{i+1}: {options[i]}")
            try:
                i = int(input("Select an option: ")) - 1
                option = options[i]
            except:
                logger.warning(
                    f"Invalid option - must be an integer between 1 and {len(options)}"
                )

    if len(sys.argv) > 2:
        ticker = sys.argv[2]
    else:
        ticker = input("Enter chain ticker: ")

    logger.info(f"Running step: {option} on {ticker}")
    script_path = os.path.dirname(os.path.abspath(__file__))
    if option == "create_nginx_conf":
        if len(sys.argv) > 3:
            subdomain = sys.argv[3]
        else:
            subdomain = os.getenv(f"{ticker}_SUBDOMAIN")
        if not subdomain:
            subdomain = input(
                f"Enter the {ticker} explorer's subdomain name (e.g. kmd.explorer.io): "
            )
        nginx = ConfigNginx(ticker, subdomain)
        nginx.setup()

    elif option == "get_launch_params":
        utils = Utils()
        print(f"komodod {utils.get_launch_params(ticker)} -pubkey=${const.KMD_PUBKEY}")

    elif option == "create_services":
        services = ConfigServices(ticker, const.KMD_ADDRESS, const.KMD_PUBKEY)
        services.create_daemon_service()
        services.create_explorer_service()

    else:
        config = ConfigExplorer(ticker)

        if option == "create_explorer_conf":
            config.create_explorer_conf()
            config.create_launcher()

        elif option == "create_webaccess":
            noweb = const.LOCALHOST_ONLY
            if len(sys.argv) > 3:
                if sys.argv[3] == "noweb":
                    noweb = True
            logger.info(f"Creating webaccess file with noweb={noweb}")
            config.create_webaccess(noweb)

        elif option == "remove":
            config.remove()
            logger.info("Done!")

        elif option == "exit":
            logger.info("Goodbye!")
            sys.exit(0)


if __name__ == "__main__":
    main()
