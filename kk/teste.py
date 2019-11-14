import os
import sys
import subprocess
import os.path

def create():
    """Get the hash of the last commited commit"""
    message = os.popen("git log -n 1 master --pretty=format:\"%H\"").read()

    commit_hash = message
    msg = """
    git show --pretty=\"format:\" --name-only {commit_hash}\""
    """.format(commit_hash=commit_hash)
    sys_msg = os.system(msg)
    return sys_msg


if  __name__ == '__main__':
    create()


def get_commit_info( repo, revision ):
	log = svn_look('log', repo, '-r', revision)
	author = svn_look('author', repo, '-r', revision)
	repo_name = repo.split('/')
	payload = {'revision' : 'repo: ' + repo_name[-1] + '\nrevision: ' + revision, 
	'log' : 'commit message: \n' + log, 
	'author': '\nauthor: ' + author}
	return payload

if __name__ == '__main__':
	get_commit_info(payload)