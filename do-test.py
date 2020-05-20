#!/usr/bin/env python3

import sys
import json
import requests
from requests.exceptions import HTTPError

actions = ["add", "remove"]
data_template = '''
{
  "name": "secure-ssh",
  "inbound_rules": [],
  "outbound_rules": [],
  "droplet_ids": [],
  "tags": []
}
'''

try:
    action = sys.argv[1]
    if action not in actions:
        print(usage("invalid action argument"))
        sys.exit(1)

    token = sys.argv[2]
except IndexError:
    print(usage("argument action or token is missing"))
    sys.exit(1)


endpoint = "https://api.digitalocean.com/v2/firewalls/"
headers = {"Authorization": "Bearer %s".format(token)}
response = requests.get(endpoint, headers=headers).json()
firewalls = response["firewalls"]
firewall_ids = []


def usage(message):
    usage = f"""
    ERROR: {message}:
    The script requires 3 arguments.
        1. action
        2. token
        3. ip
    eg: {sys.argv[0]} add/remove <token> 1.2.3.4
    """
    return usage

def get_firewall_details(firewall_endpoint):
    response = requests.get(firewall_endpoint, headers=headers).json()
    firewalls_details = response["firewall"]
    return firewalls_details

def update_firewall(firewall_endpoint, data):
    try:
        response = requests.put(firewall_endpoint, headers=headers, json=data)
        response.raise_for_status()
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print(f'Other error occurred: {err}')
    else:
        print('Success!')

for firewall in firewalls:
    if "secure-access" in firewall["name"]:
        firewall_ids.append(firewall["id"])

if action == "add":
    try:
        my_ip = sys.argv[3]
    except IndexError:
        print(usage("argument IP is missing"))
        sys.exit(1)
    for firewall_id in firewall_ids:
        changed = False
        data = json.loads(data_template)
        firewall_endpoint = endpoint + firewall_id
        firewall_details = get_firewall_details(firewall_endpoint)
        firewall_name = firewall_details["name"]
        droplet_id = firewall_details["droplet_ids"]
        inbound_rules = firewall_details["inbound_rules"]
        for rule in inbound_rules:
            access_ips = []
            firewall_port = rule["ports"]
            access_ips.extend(
                rule["sources"]["addresses"]
            )
            if my_ip in access_ips:
                print("your IP: " + my_ip + " is already listed for port " + firewall_port + " in " + firewall_name)
            else:
                print("adding your IP: " + my_ip +" for port: "+ firewall_port + " to " + firewall_name)
                changed = True
                access_ips.append(my_ip)
            rule['sources']['addresses'] = access_ips
            data['inbound_rules'].append(rule)
        data['name'] = firewall_name
        data['droplet_ids'] = droplet_id
        if changed:
            update_firewall(firewall_endpoint, data)
else:
    for firewall_id in firewall_ids:
        data = json.loads(data_template)
        firewall_endpoint = endpoint + firewall_id
        firewall_details = get_firewall_details(firewall_endpoint)
        firewall_name = firewall_details["name"]
        droplet_id = firewall_details["droplet_ids"]
        inbound_rules = firewall_details["inbound_rules"]
        coviam_ips = ["182.73.36.82", "182.74.255.66", "182.73.36.84", "182.74.20.126"]
        for rule in inbound_rules:
            firewall_port = rule["ports"]
            rule['sources']['addresses'] = coviam_ips
            data['inbound_rules'].append(rule)
        data['name'] = firewall_name
        data['droplet_ids'] = droplet_id
        print("Cleaning firewall: " + firewall_name)
        update_firewall(firewall_endpoint, data)
