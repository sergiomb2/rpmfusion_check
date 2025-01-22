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
first_arg = sys.argv[1]
if not (first_arg.isdigit() and 6 <= len(first_arg) <= 7):
    print(f"The argument '{first_arg}' is not a number with 6 or 7 digits.")
    sys.exit(1)
if len(sys.argv) < 2:
    print("Por favor, forneça um argumento.")
    sys.exit(1)

html = requests.get( f"https://koji.rpmfusion.org/koji/taskinfo?taskID={first_arg}")
str_mx = re.compile('Build Tag:.*=(.*)"')
str_mx2 = re.compile('Parent.*?taskID=(.*?)"', re.DOTALL)
res = str_mx.findall(html.text)
# print(res)
res2 = str_mx2.findall(html.text)
# print(res2)
cmd = f"koji-rpmfusion regen-repo {res[0]}"
print(cmd)
run(cmd)
cmd = f"koji-rpmfusion resubmit {res2[0]}"
print(cmd)
run(cmd)

sys.exit(1)
