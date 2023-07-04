#!/usr/bin/env python3
import os
import getpass 
from dotenv import load_dotenv
load_dotenv()

# User who is running the script
USERNAME = 'komodian'
# User home path
HOME_PATH = f'/home/komodian/'
# Default install path, can customise to run multiple instances
CONF_PATH = os.getenv(f'CONF_PATH')
# Ticker of coin to install
TICKER = os.getenv(f'TICKER')
# IP of ticker daemon
TICKER_IP = os.getenv(f'TICKER_IP')
# ZMQ port of ticker daemon
ZMQ_PORT = os.getenv(f'ZMQ_PORT')
# Web port for explorer
WEB_PORT = os.getenv(f'WEB_PORT')
