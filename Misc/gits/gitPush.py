# ANSI escape codes for text colors
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
ORANGE = "\033[33m"
MAGENTA = "\033[95m"
RESET = "\033[0m"
# ----------------------------------------------

# Internal Libraries
import base64
import argparse
import os
# ----------------------------------------------

# External Libraries
error = False
try:
    import requests
except ModuleNotFoundError:
    error = True
    print(f"{RED}Module requests not found, RUN: '{YELLOW}pip install requests{RED}'{RESET}")

try:
    from dotenv import load_dotenv
except ModuleNotFoundError:
    error = True
    print(f"{RED}Module dotenv not found, RUN: '{YELLOW}pip install python-dotenv{RED}'{RESET}")

if error:
    exit(1)
# ----------------------------------------------

# Load the environment variables from .env file
load_dotenv()
# ----------------------------------------------

# Get base64
def read_file_content(full_path):
    try:
        with open(full_path, 'rb') as file:
            content_bytes = file.read()
            return base64.b64encode(content_bytes).decode()
    except FileNotFoundError:
        print(f"{RED}The file path: {ORANGE}{full_path}{RED} does not exist!!!{RESET}")
        exit(1)
# ----------------------------------------------

# Get SHA
def get_file_sha(repo_owner, repo_name, file_name, access_token, git_folder):
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/contents/{git_folder}{file_name}"
    headers = {
        "Authorization": f"token {access_token}",
        "Accept": "application/vnd.github.v3+json"
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        return response.json().get('sha')
    else:
        return None
# ----------------------------------------------

# Upload file to github
def add_file_to_github_repo(repo_owner, repo_name, full_path, file_name, commit_message, access_token, git_folder):
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/contents/{git_folder}{file_name}"
    
    headers = {
        "Authorization": f"token {access_token}",
        "Accept": "application/vnd.github.v3+json"
    }
    file_content = read_file_content(full_path)
    file_sha = get_file_sha(repo_owner, repo_name, file_name, access_token, git_folder)
    
    data = {
        "message": commit_message,
        "content": file_content,
        "sha": file_sha
    }

    response = requests.put(url, headers=headers, json=data)
    status_code=response.status_code
    response = response.json()

    if status_code in {200, 201}:
        print(f"{GREEN}File '{file_name}' {'updated' if status_code == 200 else 'created'} successfully to the repository with tag: {YELLOW}{response['commit']['sha']}{RESET}")
    else:
        print(f"{RED}Failed to add file to the repository. Status code: {YELLOW}{status_code}{RESET}")
        print(f"JSON: {response}")
# ----------------------------------------------

# Repo Exists?
def check_repo_exists(repo_owner, repo_name, access_token):
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}"
    headers = {
        "Authorization": f"token {access_token}",
        "Accept": "application/vnd.github.v3+json"
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        return True
    elif response.status_code == 404:
        return False
    else:
        print(f"Failed to check repository existence. Status code: {response.status_code}")
        print(response.json())
        return None
# ----------------------------------------------

# Starter Template
def starter():
    print("-------------------------")
    print(f"{MAGENTA}Welcome to {os.path.basename(__file__)} script{RESET}")
    print("-------------------------")
# ----------------------------------------------


# Runner Code
if __name__ == "__main__":
    starter()

    # Variable init
    parser = argparse.ArgumentParser(description='Add a file to a GitHub repository.')
    parser.add_argument('--f-name', '-f', dest='file_name',      help='Name of the file to be added', required=True)
    parser.add_argument('--f-path',        dest='folder_path',      help='Name of the folder from which file has to be uploaded')
    parser.add_argument('--folder', '-fo', dest='git_folder',      help='Name of the folder in which to be added', default='')
    parser.add_argument('--r-name', '-r',  dest='repo_name',      help='Name of the GitHub repository', required=True)
    parser.add_argument('--r-user', '-u',  dest='repo_owner',          help='Username of the GitHub repository', default=os.getenv('REPO_OWNER'))
    parser.add_argument('--token',  '-t',  dest='access_token',        help='Token of GitHub', default=os.getenv('ACCESS_TOKEN'))
    parser.add_argument('--msg',    '-m',  dest='commit_message', help='Commit message', default="Pushed using script")
    args = parser.parse_args()
    # Assign variable values
    file_name = args.file_name
    folder_path = args.folder_path
    full_path = folder_path+file_name
    git_folder = args.git_folder+'/' if args.git_folder else ''
    repo_owner = args.repo_owner
    repo_name = args.repo_name
    commit_message = args.commit_message
    access_token = args.access_token
    # Check defaults
    if repo_owner and access_token:
        pass
    else:
        print(f"{RED}Default values don't exist. Check .env file{RESET}")
        exit(1)

    # Check repo and run else exit
    if check_repo_exists(repo_owner, repo_name, access_token):
        add_file_to_github_repo(repo_owner, repo_name, full_path, file_name, commit_message, access_token, git_folder)
    else:
        print(f"{RED}Repository '{YELLOW}{repo_owner}/{repo_name}{RED}' does not exist.{RESET}")
        exit(1)