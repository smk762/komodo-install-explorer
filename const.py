#!/usr/bin/env python3
import os
import getpass 

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
# RPC port of ticker daemon
RPC_PORT = os.getenv(f'RPC_PORT')
# ZMQ port of ticker daemon
ZMQ_PORT = os.getenv(f'ZMQ_PORT')
# Web port for explorer
WEB_PORT = os.getenv(f'WEB_PORT')
print(f'CONF_PATH: {CONF_PATH}')
print(f'TICKER: {TICKER}')
print(f'TICKER_IP: {TICKER_IP}')
print(f'RPC_PORT: {RPC_PORT}')
print(f'ZMQ_PORT: {ZMQ_PORT}')
print(f'WEB_PORT: {WEB_PORT}')
