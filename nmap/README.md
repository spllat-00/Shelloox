# Nmap Scanner
---
## Features
- 3 types of scanning
  - Fast Scanning
  - Full Scanning
  - UDP Scanning (top 100 ports)
- Suggestions to check for with nmap scanning

## Usage
- Complete scanning ( requries `sudo` )
```bash
sudo ./nmap-auto.sh -u <hostname>/<IP> -U
```

- Only fast scan
```bash
./nmap-auto.sh -u <hostname>/<IP> -fa
```

- Only full scan
```bash
./nmap-auto.sh -u <hostname>/<IP> -fu
```

- Only UDP scan
```bash
sudo ./nmap-auto.sh -u <hostname>/<IP> -U -t
```

- Other details can be checked with `-h / --help`

## Output
1. A directory with the name give to <URL_PARAMETER> will be created.
1. Depending on the scanning types, respective files will be made
   1. Fast Scan: fast-scan.txt
   1. Full Scan: full-scan.txt
   1. UDP  Scan: udp-scan.txt
1. Suggestions will be given for steps after nmap 

## Suggestion
Use an alias, which will make life simpler and script easier to use
```bash
alias sudo="sudo "
alias nms="/opt/Shelloox/nmap/nmap-auto.sh"
```

## Tasks
- [ ] Specific Ports Suggestions
- [ ] Remove file search for DIR, DNS else make it faster
- [ ] hostname in /etc/hosts *(SUDO)
- [x] ~~nmap automation script (fast/full scan)~~
- [x] ~~IP validity check~~
- [x] ~~OS discovery~~
- [x] ~~UDP scans *(SUDO)~~