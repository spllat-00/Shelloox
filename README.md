
# SHELLOOX
Welcome to the Shelloox Git repository!

Shelloox is a comprehensive collection of useful tools and scripts designed to enhance your workflow and simplify various tasks. The repository encompasses a wide range of functionalities and aims to be a one-stop solution for different automation and scripting needs.

## Prerequisites
Before getting started with Shelloox, ensure that you have the following prerequisites installed on your system:

- Nmap (for the automatic scanning script)
- Python (for the Python server script)
- Any additional dependencies mentioned in the individual script's documentation

## Installation:
To use Shelloox, follow these steps to set up the repository on your local machine:
### Automatic Setup
1. Clone the repository to your desired directory using the following command:
```bash
sudo git clone https://github.com/spllat-00/Shelloox.git /opt/Shelloox; cd /opt/Shelloox
```
2. Give permission to `setup.sh`
```bash
sudo chmod +x /opt/Shelloox/setup.sh
```
3. Run `setup.sh`
```bash
sudo /opt/Shelloox/setup.sh
```

### Manual Setup
1. Clone the repository to your desired directory using the following command:
```bash
sudo git clone https://github.com/spllat-00/Shelloox.git
```
2. Change directory into folder
```bash
cd <FULL_GIT_REPO_PATH>
```
3. Setup permissions (Warning: Run inside Git Repo)
```bash
sudo find . -type f -name 'script-*.sh' -exec chmod +x {} \;
```
OR
```bash
sudo find <FULL_GIT_REPO_PATH> -type f -name 'script-*.sh' -exec chmod +x {} \;
```
4. Optional : Setting up alias, in .zshrc or .bashrc
```bash
# nmap script
alias nms="<FULL_GIT_REPO_PATH>/nmap/script-nmap-auto.sh"

# python server
alias pyserver="<FULL_GIT_REPO_PATH>/PyServer/script-python-server.sh"

# Running as sudo
alias sudo="sudo "
```

### To access terminal
Either `restart the terminal` or else run:
```bash
source .zshrc
source .bashrc
```

### Confirm alias setup
```bash
alias | grep -E "nms|pyserver|sudo"
```

## Usage
Once you have set up Shelloox, you can start utilizing the available tools and scripts. Refer to the individual script's documentation, or else -h/--help for detailed usage instructions and examples.

## Screenshots
- Install Repo
![image](https://github.com/spllat-00/Shelloox/assets/50944153/8019d402-b35d-41fd-8199-72c1c8f9d516)

- Give executable permissions
  - Automatic
     - Permission
       ![image](https://github.com/spllat-00/Shelloox/assets/50944153/505e45b8-764d-43bd-9b00-41093323fcf5)
     - Run `setup.sh`
       ![image](https://github.com/spllat-00/Shelloox/assets/50944153/38b7e54e-aa40-478a-b9ca-a869e8be5c8e)
  - Manual
     - Give Permissions 
       ![image](https://github.com/spllat-00/Shelloox/assets/50944153/c99f82bc-fa95-418d-bc02-cbabc4d8fd77)
     - Add alias to `.zshrc` or `.bashrc`

- Confirm after setting up alias and restarting terminal
![image](https://github.com/spllat-00/Shelloox/assets/50944153/5e001466-edb9-4521-a6d6-bc13bef74b63)


## Contributing
We welcome contributions from the community to make Shelloox even more robust and feature-rich. If you have any bug fixes, improvements, or new additions to suggest, please follow the guidelines in the CONTRIBUTING.md file.

## Feedback and Support
If you encounter any issues, have questions, or need assistance with Shelloox, feel free to open an issue on the repository's GitHub page. We appreciate your feedback and will do our best to address any concerns.

Thank you for using Shelloox! We hope these tools and scripts streamline your tasks and enhance your productivity.

## TO DO
- [ ] Windows compatibility
- [x] ~~Check if an alias is set~~
- [x] ~~Help flag functionality~~
