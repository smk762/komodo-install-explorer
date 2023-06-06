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
from dotenv import load_dotenv
from logger import logger

load_dotenv()

class Utils:
    def __init__(self):
        self.script_path = os.path.realpath(os.path.dirname(__file__))

    def get_random_string(self, length=16):
        char_pool = string.ascii_uppercase + string.ascii_lowercase + string.digits
        return ''.join(secrets.choice(char_pool) for i in range(length))

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
        try:
            with open(f"{self.script_path}/explorers.json", "r") as f:
                return json.load(f)
        except:
            return {}


class ConfigExplorer:
    def __init__(self, ticker):
        self.ticker = ticker
        self.utils = Utils()
        self.home = os.path.expanduser("~")
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.explorers = self.utils.get_explorers()

    def create_launcher(self):
        with open(f"{self.ticker}-explorer-start.sh", 'w') as f:
            f.write('#!/bin/bash\n')
            f.write(f'export NVM_DIR="{self.home}/.nvm"\n')
            f.write(f'[ -s "{self.home}/.nvm/nvm.sh" ] && . "{self.home}/.nvm/nvm.sh" # This loads nvm\n')
            f.write(f'cd {self.ticker}-explorer\n')
            f.write('nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start\n')
        os.chmod(f"{self.ticker}-explorer-start.sh", stat.S_IRWXU)

    def create_daemon_conf(self):
        explorer_index = len(self.explorers)
        logger.info(f"{explorer_index} existing explorers")

        with open(f"{self.script_path}/explorers.json", "w+") as f:
            if self.ticker not in self.explorers:
                rpcport = 46857 + explorer_index
                zmqport = 50501 + explorer_index
                webport = 8091 + explorer_index
                self.explorers.update({
                    self.ticker: {
                        "rpcip": "127.0.0.1",
                        "rpcport": rpcport,
                        "rpcuser": self.utils.get_random_string(),
                        "rpcpassword": self.utils.get_random_string(32),
                        "webport": webport,
                        "zmqport": zmqport
                    }
                })
                json.dump(self.explorers, f, indent=4)

                rpcip = self.explorers[self.ticker]["rpcip"]
                rpcport = self.explorers[self.ticker]["rpcport"]
                rpcpassword = self.explorers[self.ticker]["rpcpassword"]
                rpcuser = self.explorers[self.ticker]["rpcuser"]
                webport = self.explorers[self.ticker]["webport"]
                zmqport = self.explorers[self.ticker]["zmqport"]
                
                if self.ticker == "KMD":
                    coin_conf_path = const.KMD_CONF_PATH
                    coin_conf_file = f"{const.KMD_CONF_PATH}/komodo.conf"
                else:
                    coin_conf_path = f"{const.KMD_CONF_PATH}/{self.ticker}"
                    coin_conf_file = f"{const.KMD_CONF_PATH}/{self.ticker}/{self.ticker}.conf"

                if not os.path.exists(coin_conf_path):
                    os.makedirs(coin_conf_path)

                logger.info(f"Updating {coin_conf_file}")
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

    def create_explorer_conf(self):
        if self.ticker not in self.explorers:
            self.create_daemon_conf(self.ticker)

        rpcip = self.explorers[self.ticker]["rpcip"]
        rpcport = self.explorers[self.ticker]["rpcport"]
        rpcpassword = self.explorers[self.ticker]["rpcpassword"]
        rpcuser = self.explorers[self.ticker]["rpcuser"]
        webport = self.explorers[self.ticker]["webport"]
        zmqport = self.explorers[self.ticker]["zmqport"]

        with open(f"{self.script_path}/{self.ticker}-explorer/bitcore-node.json", "w+") as f:
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

    def create_webaccess(self, noweb=False):
        if self.ticker not in self.explorers:
            self.create_daemon_conf(self.ticker)

        rpcip = self.explorers[self.ticker]["rpcip"]
        rpcport = self.explorers[self.ticker]["rpcport"]
        rpcpassword = self.explorers[self.ticker]["rpcpassword"]
        rpcuser = self.explorers[self.ticker]["rpcuser"]
        webport = self.explorers[self.ticker]["webport"]
        zmqport = self.explorers[self.ticker]["zmqport"]

        if noweb:
            ip = 'localhost'
            logger.info(f"The webport hasn't been opened. To access the explorer through the internet,")
            logger.info(f"open the port: {webport} by executing the command 'sudo ufw allow {webport}'")
        else:
            ip = self.utils.get_my_ip()

        logger.info(f"Visit http://{ip}:{webport} from another computer to access the explorer after starting it")
        with open(f'{self.ticker}-webaccess', 'w') as f:
            f.write(f"url=http://{ip}:{webport}\n")
            f.write(f"webport={webport}")

    def remove(self):
        with open(f"{self.script_path}/explorers.json", "w+") as f:
            if self.ticker in self.explorers:
                del self.explorers[self.ticker]
                json.dump(self.explorers, f, indent=4)
                logger.info(f"{self.ticker} removed from {self.script_path}/explorers.json")
        for file in [f'{self.ticker}-webaccess', f'{self.ticker}-explorer-start.sh']:
            try:
                os.remove(file)
            except OSError as e:
                logger.info(f"{file} does not exist, skipping...")
                pass
        try:
            os.remove(f'{self.ticker}-webaccess')
        except OSError as e:
            logger.info(f"{f'{self.ticker}-webaccess'} does not exist, skipping...")
        try:
            shutil.rmtree(f'{self.ticker}-explorer')
        except OSError as e:
            logger.info(f"{self.ticker}-explorer does not exist, skipping...")


class ConfigNginx:
    def __init__(self, coin, subdomain=""):
        self.coin = coin
        self.subdomain = subdomain
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.explorers = self.utils.get_explorers()
        if self.subdomain == "":
            self.subdomain = self.get_subdomain(self.coin)

    def setup(self):
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
            explorer_port = self.explorers[self.ticker]["webport"]
        if not explorer_port:
            explorer_port = self.check_webaccess()
        if not explorer_port:
            explorer_port = input(f"Enter the {self.coin} explorer's port: ")

        self.update_webaccess(self.subdomain, explorer_port)
        self.update_explorers_config(self.subdomain, explorer_port)
        self.create_serverblock(webroot, proxy_host, self.subdomain, explorer_port)

    def update_webaccess(self, port):
        with open(f'{self.ticker}-webaccess', 'w') as f:
            f.write(f"url=http://{self.subdomain}:{self.explorer_port}\n")
            f.write(f"webport={port}")

    def check_webaccess(self):
        if not os.path.exists(f'{self.script_path}/{self.coin}-webaccess'):
            return None
        with open(f"{self.script_path}/{self.coin}-webaccess", "r") as r:
            for line in r.readlines():
                if line.find("webport") > -1:
                    return line.split("=")[1]

    def create_serverblock(self, webroot, proxy_host, subdomain, explorer_port):
        blockname = f"{self.script_path}/nginx/{self.coin}-explorer.serverblock"
        with open(f"{self.script_path}/nginx/TEMPLATE.serverblock", "r") as r:
            with open(blockname, "w") as w:
                for line in r.readlines():
                    line = line.replace("COIN", self.coin)
                    line = line.replace("HOMEDIR", self.home)
                    line = line.replace("WEBROOT", webroot)
                    line = line.replace("SUBDOMAIN", subdomain)
                    line = line.replace("PROXY_HOST", proxy_host)
                    line = line.replace("EXPLORER_PORT", explorer_port)
                    w.write(f"{line}")


class ConfigServices:
    def __init__(self, coin, address, pubkey):
        self.coin = coin
        self.address = address
        self.pubkey = pubkey
        self.utils = Utils()
        self.launch_params = f"{self.utils.get_launch_params(self.coin)} -pubkey=${self.pubkey}"
        self.script_path = os.path.realpath(os.path.dirname(__file__))
        self.explorers = self.utils.get_explorers()
        if not os.path.exists(f"{const.HOME_PATH}/logs"):
            os.makedirs(f"{const.HOME_PATH}/logs")

    def create_daemon_service(self):
        with open(f"{self.script_path}/services/TEMPLATE-daemon.service", "r") as f:
            lines = f.readlines()
            with open(f"{self.script_path}/services/{self.coin}-daemon.service", "w") as f:
                for line in lines:
                    line = line.replace("COIN", self.coin)
                    line = line.replace("ADDRESS", const.KMD_ADDRESS)
                    line = line.replace("USERNAME", const.USERNAME)
                    line = line.replace("LAUNCH_PARAMS", self.launch_params)
                    f.write(line)

    def create_explorer_service(self):
        with open(f"{self.script_path}/services/TEMPLATE-explorer.service", "r") as f:
            lines = f.readlines()
            with open(f"{self.script_path}/services/{self.coin}-explorer.service", "w") as f:
                for line in lines:
                    line = line.replace("COIN", self.coin)
                    line = line.replace("USERNAME", const.USERNAME)
                    f.write(line)

def main():
    # TODO: Update .env file?
    options = [
        "create_nginx_conf", "create_services", "create_ticker_conf",
        "create_explorer_conf", "create_webaccess", "get_launch_params",
        "remove", "exit"        
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
                logger.warning(f"Invalid option - must be an integer between 1 and {len(options)}")

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
            subdomain = os.getenv(f'{ticker}_SUBDOMAIN')
        if not subdomain:
            subdomain = input(f"Enter the {ticker} explorer's subdomain name (e.g. kmd.explorer.io): ")
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
        if option == "create_ticker_conf":
            config.create_daemon_conf()

        elif option == "create_explorer_conf":
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


if __name__ == '__main__':
    main()
