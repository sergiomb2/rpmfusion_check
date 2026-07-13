#!/usr/bin/python3

""" Warning not complete """

import sys
import os
import koji

session = koji.ClientSession('https://koji.rpmfusion.org/kojihub')
cert_path = os.path.expanduser('~/.rpmfusion.cert')
session.ssl_login(cert_path, None, None)


def tag_build(tag_name, nvr):
    print(f"Tagging build '{nvr}' into tag '{tag_name}'...")
    task_id = session.tagBuild(tag_name, nvr)
    from koji_cli.lib import watch_tasks
    ret = watch_tasks(session, [task_id], quiet=False, poll_interval=10)
    return ret == 0


def wait_repo(tag_name, nvr):
    print(f"Waiting for repo '{tag_name}' to include build '{nvr}'...")
    watcher = koji.RepoWatcher(session, tag_name, nvrs=[nvr], poll_interval=10)
    repo_info = watcher.waitrepo(timeout=3600)
    if repo_info:
        print(f"Repo '{tag_name}' now includes build '{nvr}' (repo id {repo_info['id']}).")
        return True
    print(f"Timeout waiting for repo '{tag_name}' to include '{nvr}'.")
    return False


def get_build_and_tag_from_buildinfo(build_id):
    build_info = session.getBuild(int(build_id))
    if not build_info:
        return None, None
    nvr = build_info['nvr']

    tags = session.listTags(build=int(build_id))
    candidate_tag = None
    for t in tags:
        if t['name'].endswith('-updates-candidate'):
            candidate_tag = t['name']
            break
    return nvr, candidate_tag


def main():
    if len(sys.argv) < 2:
        print("Please provide an argument.")
        sys.exit(1)

    args = sys.argv[1:]
    for arg in args:
        if not (arg.isdigit() and 5 <= len(arg) <= 6):
            print(f"The argument '{arg}' is not a number with 5 or 6 digits.")
            sys.exit(1)

        build_id = int(arg)
        nvr, candidate_tag = get_build_and_tag_from_buildinfo(build_id)
        if not nvr or not candidate_tag:
            print(f"Could not determine NVR/tag for build {build_id}.")
            continue

        print(f"Build: {nvr}, candidate tag: {candidate_tag}")

        tag_override = candidate_tag.replace("updates-candidate", "override")
        tag_build_name = candidate_tag.replace("updates-candidate", "build")

        if not tag_build(tag_override, nvr):
            print(f"Failed to tag {nvr} into {tag_override}, skipping.")
            continue

        wait_repo(tag_build_name, nvr)


if __name__ == '__main__':
    main()
