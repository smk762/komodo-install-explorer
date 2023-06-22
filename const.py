#!/usr/bin/env python3
import os
from dotenv import load_dotenv
load_dotenv()

# User who is running the script
USERNAME = os.getlogin()
# Default install path, can customise to run multiple instances
KMD_CONF_PATH = os.getenv(f'KMD_CONF_PATH')
# Address to be used for daemon
KMD_ADDRESS = os.getenv(f'KMD_ADDRESS')
# Pubkey to be used for daemon
KMD_PUBKEY = os.getenv(f'KMD_PUBKEY')
# User home path
HOME_PATH = os.getenv(f'HOME_PATH')
# User home path
LOCALHOST_ONLY = os.getenv(f'LOCALHOST_ONLY') in ['true', True]
if not HOME_PATH:
    HOME_PATH = f'/home/{USERNAME}/'
if not KMD_CONF_PATH:
    KMD_CONF_PATH = f'/home/{USERNAME}/.komodo'
if not KMD_ADDRESS:
    # S7 Dragonhound_DEV main notary address
    KMD_ADDRESS = "RHi882Amab35uXjqBZjVxgEgmkkMu454KK"
if not KMD_PUBKEY:
    # S7 Dragonhound_DEV main notary pubkey
    KMD_PUBKEY = "02f9a7b49282885cd03969f1f5478287497bc8edfceee9eac676053c107c5fcdaf"
if not LOCALHOST_ONLY:
    LOCALHOST_ONLY = False