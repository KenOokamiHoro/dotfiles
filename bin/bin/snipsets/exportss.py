#!/usr/bin/env python3
import base64
import json
import qrcode
import subprocess
import socket
import sys
import time


def encode(method, passwd):
    '''Use encrypt method and password to encode.'''
    raw_string = "{}:{}".format(method, passwd)
    return base64.encodebytes(raw_string.encode()).decode().strip()


def detect_address(address):
    try:
        socket.inet_pton(socket.AF_INET6, address)
    except OSError:
        return False
    else:
        return True


def generate_link(config, name="Undefined"):
    '''Use config to create link'''
    link_template = "ss://{base64_text}@{address}:{port}{plugin}#{name}"

    if len(config['server'][0]) > 1:
        servers = config['server']
    else:
        servers = [config['server']]

    try:
        plugin = config['plugin']
        plugin_opts = config['plugin_opts']
    except KeyError:
        plugin_text = ""
    else:
        plugin_text = "?plugin={plugin};{plugin_opts}".format(
            plugin=plugin, plugin_opts=plugin_opts)
    finally:
        texts = [link_template.format(base64_text=encode(config['method'], config['password']),
                                      address="[{}]".format(server) if detect_address(server) else server,
                                      port=config['server_port'],
                                      plugin=plugin_text,
                                      name=name) for server in servers]
        return texts


def generate_qrcode(text):
    img = qrcode.make(text)
    filename = "/tmp/{}.png".format(time.time())
    img.save(filename)
    return filename


def open_qrcode(filename):
    subprocess.call(["xdg-open", filename])


def usage():
    ...


if __name__ == "__main__":
    json_file = open(sys.argv[1])
    for text in generate_link(json.load(json_file), "Unnamed"):
        open_qrcode(generate_qrcode(text))
