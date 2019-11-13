#!/usr/bin/env python3

import os


def create():
    """Get the hash of the last commited commit"""

    commit_hash = os.popen("git log -n 1 master --pretty=format:\"%H\"").read()
    msg = """
    git show --pretty=\"format:\" --name-only {commit_hash}\""
    """.format(commit_hash=commit_hash)
    sys_msg = os.system(msg)
    return sys_msg


if  __name__ == '__main__':
    create()
