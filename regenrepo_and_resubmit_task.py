#!/usr/bin/python3

""" Warning not complete """

import sys
import re
import os
import subprocess
import requests

def runme(cmd):
    try:
        result = subprocess.run(cmd , shell=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        sys.stderr.write('%s failed: %s\n' % (cmd, e))
        return 1
    return result


def run(cmd):
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in process.stdout:
        print(line, end="")
    process.wait()
    if process.returncode == 0:
        print("\nCommand executed successfully!")
    else:
        print("\nError while executing the command.")


if len(sys.argv) < 2:
    print("Please provide an argument.")
    sys.exit(1)

args = sys.argv[1:]
for arg in args:

    if not (arg.isdigit() and 6 <= len(arg) <= 7):
        print(f"The argument '{arg}' is not a number with 6 or 7 digits.")
        sys.exit(1)

    html = requests.get( f"https://koji.rpmfusion.org/koji/taskinfo?taskID={arg}")
    str_mx0 = re.compile(r'taskinfo\?taskID=(.*?)"')
    res0 = str_mx0.findall(html.text)
    print(res0[1])

    html = requests.get( f"https://koji.rpmfusion.org/koji/taskinfo?taskID={res0[1]}")
    str_mx = re.compile('Build Tag:.*=(.*)"')
    # str_mx2 = re.compile('Parent.*?taskID=(.*?)"', re.DOTALL)
    res = str_mx.findall(html.text)
    print(res[0])
    #res2 = str_mx2.findall(html.text)
    # print(res2)
    cmd = f"koji-rpmfusion regen-repo {res[0]}"
    print(cmd)
    run(cmd)
    cmd = f"koji-rpmfusion resubmit {arg}"
    print(cmd)
    run(cmd)

sys.exit(0)
