#!/usr/bin/env python

#### DO NOT MODIFY THIS FILE #####

import paramiko
import time
import re
import json
import sys


#Temporary List to store value of thumbprint
aa = []
# Temporary list to remove new line at the end of the list
bb = []
# Dictionary to store values of thumbprint in format of key = ip address , value = thumbprint
host_dict = {}

# Function to strip extra spaces from variables being passed by TF
def strip_lines():
    return {a.strip() for a in sys.stdin}

lines = strip_lines()

for line in lines:
    data = json.loads(line)

# Extract variables value from TF

user = data["username"]
password = data["password"]
hosts = data["hosts"].split(" ")

for ip in hosts:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(ip,username=user,password=password,timeout=10)
    connection=ssh.invoke_shell()
    time.sleep(1)
    connection.send('openssl x509 -in /etc/vmware/ssl/rui.crt -fingerprint -sha1 -noout \n')
    time.sleep(1)
    output = connection.recv(5000)
    thumb_temp = re.search(r"(SHA1 Fingerprint=)(.+)",output)
    if thumb_temp:
        aa.append(thumb_temp.group(2))
    for each in aa: 
        bb.append(each.replace("\r", "")) 
    for each in bb:
        host_dict[ip] = each
d = json.dumps(host_dict)
print d

