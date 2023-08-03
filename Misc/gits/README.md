# Misc/gits
---

This Python script is a command-line tool to upload a specified file to a GitHub repository using the GitHub API. It reads command-line arguments, and verifies the repository's existence before uploading the file. The script requires environment variables (REPO_OWNER and ACCESS_TOKEN) specified in a .env file for authentication.

## Features
- Create / Update git files
  - Can update file inside folder
  - Can create file inside folder

## Prerequisites
- Python V3 installed
- `requests` and `python-dotenv` library

## Usage
- Create .env file using template and update the values
- Install libraries
  - `pip install requests`
  - `pip install python-dotenv`
- Minimilist Options:
  - Will create/update the `test.md` in repository `testGit`
```bash
python ./gitPush.py -f test.md -r testGit
```

- All Options
  - Will use following parameters
    - File to be uploaded: `test.md`
    - Location of current file (local machine): `../../Test/testing/`
    - Repository Name: `testGit`
    - Username: `tester`
    - Access Token: `ghp_AccessToken`
    - Commit Message: `Created file test.md`
    - Folder on Github: `VeryImportant`
```bash
python ./gitPush.py -f test.md --f-path ../../Test/testing/ -r testGit -u tester -t ghp_AccessToken -m "Created file test.md" -fo "VeryImportant"
```

- Details with `-h / --help`

## Tasks
- [ ] File deletion
- [ ] Folder Create/Update/Delete
