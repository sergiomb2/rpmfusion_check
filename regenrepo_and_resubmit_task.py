#!/usr/bin/python3

""" Warning not complete """

import sys
import re
import os
import koji
from koji_cli.lib import watch_tasks

if len(sys.argv) < 2:
    print("Please provide an argument.")
    sys.exit(1)

processed = set()
args = sys.argv[1:]
session = koji.ClientSession('https://koji.rpmfusion.org/kojihub')
cert_path = os.path.expanduser('~/.rpmfusion.cert')
session.ssl_login(cert_path, None, None)

for task_id in args:

    if not (task_id.isdigit() and 6 <= len(task_id) <= 7):
        print(f"The argument '{task_id}' is not a number with 6 or 7 digits.")
        sys.exit(1)

    task_info = session.getTaskInfo(task_id, request=True)
    target = task_info.get("request")[1]
    target_info = session.getBuildTarget(target)
    build_tag = target_info['build_tag_name']
    if build_tag not in processed:
        processed.add(build_tag)
        new_task_id = session.newRepo(build_tag)
        ret = watch_tasks(session, [new_task_id], quiet=False, poll_interval=10)
        if ret != 0:
            print("newRepo failed exiting with error")
            sys.exit(2)

    new_task_id = session.resubmitTask(task_id)
    print(f"Resubmitted as task: {new_task_id}")
    ret = watch_tasks(session, [new_task_id], quiet=False, poll_interval=10)
    if ret == 0:
        print("OK")


