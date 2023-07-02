
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

1. Clone the repository to your desired directory using the following command:
```bash
sudo git clone https://github.com/kalePayas/Shelloox.git /opt/Shelloox; cd /opt/Shelloox
```
2. Setup permissions
```bash
sudo chmod -R +x *.sh
```
3. Optional : Setting up alias, in .zshrc orelse .bashrc
```bash
# nmap script
alias nms="/opt/Shelloox/nmap-auto.sh"

# python server
alias pyserver="/opt/Shelloox/python-server.sh"

# Restart/Refresh terminal
source .zshrc
source .bashrc
```

## Usage
Once you have set up Shelloox, you can start utilizing the available tools and scripts. Refer to the individual script's documentation, or else -h/--help for detailed usage instructions and examples.

## Contributing
We welcome contributions from the community to make Shelloox even more robust and feature-rich. If you have any bug fixes, improvements, or new additions to suggest, please follow the guidelines in the CONTRIBUTING.md file.

## Feedback and Support
If you encounter any issues, have questions, or need assistance with Shelloox, feel free to open an issue on the repository's GitHub page. We appreciate your feedback and will do our best to address any concerns.

Thank you for using Shelloox! We hope these tools and scripts streamline your tasks and enhance your productivity.

## TO DO
- [ ] Windows compatibility
- [ ] Check if an alias is set
- [x] ~~Help flag functionality~~

## TO DO nmap-auto

- [ ] UDP scans *(SUDO)
- [ ] Specific Ports Suggestions
- [ ] Remove file search for DIR, DNS else make it faster
- [ ] hostname in /etc/hosts *(SUDO)
- [x] ~~nmap automation script (fast/full scan)~~
- [x] ~~IP validity check~~
- [x] ~~OS discovery~~

## TO DO python-server
- [ ] Upload useful files to ./PythonServer
- [x] ~~Directory printing~~