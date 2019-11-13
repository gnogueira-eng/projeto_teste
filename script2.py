#!/usr/bin/env python3

import os

def create():

   # commit_hash = os.popen("git log -n 1 master --pretty=format:\"%H\"").read()
   # msg = """
   # git show --pretty=\"format:\" --name-only {commit_hash}\""
   # """.format(commit_hash=commit_hash)
   # sys_msg = os.system(msg)
   # return sys_msg

   teste = os.popen("git diff --cached --name-status | cut -f2").read().splitlines()
   print (teste)

   for i in range (len(teste)):
   	path = os.popen(" readlink -f "+teste[i]).read()
   	print(path)

if  __name__ == '__main__':
    create()

