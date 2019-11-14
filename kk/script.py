import subprocess
import sys, os

DELETED_FILE_TOKEN = "D\t"

def execute_cmd(full_cmd, cwd=None):
    """Execute a git command"""

    process = subprocess.Popen(full_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=cwd)
    (stdoutdata, stderrdata) = process.communicate(None)
    if 0 != process.wait():
        raise Exception("Could not execute git command")

    return (stdoutdata.strip(), stderrdata.strip())

def get_last_commit_hash():
    """Get the hash of the last commited commit"""
    return execute_cmd("git log -n 1 HEAD --pretty=format:\"%H\"")[0]

def get_commit_file_list(hash):
    """Get the list of files impacted by a commit, each file is preceded by
    x\t where x can be A for added, D for deleted, M for modified"""
    file_list = execute_cmd("git show --pretty=\"format:\" --name-status "+hash)[0]
    return file_list.split("\n");

def remove_unwanted_files(file_list):
    """remove the x\t from the file names and remove the file that have
    been deleted"""
    cleaned_file_list = list()
    for file in file_list:
        if not file[:2] == DELETED_FILE_TOKEN:
            cleaned_file_list.append(file[2:])
    return cleaned_file_list

def get_script_current_path():
    """get the scrypt current path (to lacalise the repository and open files)"""
    pathname = os.path.dirname(sys.argv[0])
    return os.path.abspath(pathname)    

def get_hash():
    """Allow you to launch the script in command line with any hash"""
if len(sys.argv) > 1:
    return sys.argv[1]
else:
    return get_last_commit_hash()

hash = get_hash();
file_list = get_commit_file_list(hash)
file_list = remove_unwanted_files(file_list)

#here file_list contains the modified and added files
