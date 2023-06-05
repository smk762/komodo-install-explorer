#!/usr/bin/env python3
import os
from dotenv import load_dotenv
load_dotenv()

KOMODO_CONF_PATH = os.getenv(f'KOMODO_CONF_PATH')
KMD_RPCPORT = os.getenv(f'KMD_RPCPORT')
KMD_RPCPASS = os.getenv(f'KMD_RPCPASS')
KMD_RPCUSER = os.getenv(f'KMD_RPCUSER')
KMD_AC_NAME = os.getenv(f'MARTY')
USER = os.getlogin()

if not KOMODO_CONF_PATH:
    KOMODO_CONF_PATH = f'/home/{USER}/.komodo/'
if not KMD_RPCPORT:
    KMD_RPCPORT = 7771
if not KMD_RPCPASS:
    KMD_RPCPASS = 'rpcpassword'
if not KMD_RPCUSER:
    KMD_RPCUSER = 'rpcuser'
if not KMD_AC_NAME:
    KMD_AC_NAME = 'MARTY'
