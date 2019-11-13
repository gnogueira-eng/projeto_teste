import os
import sys
import subprocess

#svnlook location
LOOK='svnlook'

def get_commit_info( repo, revision ):
	log = svn_look('log', repo, '-r', revision)
	author = svn_look('author', repo, '-r', revision)
	repo_name = repo.split('/')
	payload = {'revision' : 'repo: ' + repo_name[-1] + '\nrevision: ' + revision, 
	'log' : 'commit message: \n' + log, 
	'author': '\nauthor: ' + author}
	return payload

def svn_look( *args ):
	p = subprocess.Popen(' '.join([LOOK] + list(args)), stdout=subprocess.PIPE, shell=True, stderr=subprocess.STDOUT )
	out, err = p.communicate()
	return out

if __name__ == '__main__':
	get_commit_info