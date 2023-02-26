import os
import time
import sys
import subprocess
from slickrpc import Proxy
from dotenv import load_dotenv
from lib_logger import logger

load_dotenv()

rpc_port = int(os.getenv('KMD_RPCPORT'))
rpcpass = os.getenv('KMD_RPCPASS')
rpcuser = os.getenv('KMD_RPCUSER')
ac_name = os.getenv('KMD_AC_NAME')

try:
    node_dir = f"/root/.komodo/{ac_name}"
    os.mkdir()
    open(f"{node_dir}/{ac_name}.conf", 'a').close()
    with open(f"{node_dir}/{ac_name}.conf", 'a') as conf:
        conf.write(f"rpcuser={rpcuser}\n")
        conf.write(f"rpcpassword={rpcpass}\n")
        conf.write(f"rpcport={rpc_port + i}\n")
except:
    logger.info(f"{node_dir} already exists, skipping conf append.")