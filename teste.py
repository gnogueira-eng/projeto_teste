import os
import sys
import subprocess

import urllib
import urllib2
import json


#Set slack info
TOKEN = ''  #api token for slack integration
DOMAIN = 'your_team_name.slack.com' #add your team's slack URL here  

#svnlook location
LOOK='svnlook'



def main(argv):

	import os.path
	stream = sys.stderr or sys.stdout

	status = 0
	result = 'posted commit to slack'
	payload = get_commit_info(argv[1], argv[2])

	try: 
		notify_slack(DOMAIN, TOKEN, payload)
	except:
		status += 1
		result = sys.exc_info()[0]
		raise

	stream.write(result)
	sys.exit(status)

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


def notify_slack(domain, token, payload ):
	#create request url
	url = 'https://' + domain + '/services/hooks/subversion?token=' + token
	#urlencode and post
	urllib2.urlopen( url, urllib.urlencode( { 'payload' : json.dumps( payload ) } ) )


if __name__ == '__main__':
	main(sys.argv)