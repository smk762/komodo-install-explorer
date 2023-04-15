#!/usr/bin/env python3
import socket

def get_my_ip():
    hostname = socket.gethostname()
    return socket.gethostbyname(hostname)
