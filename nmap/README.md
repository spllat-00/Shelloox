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

## Screenshots
- Complete Scan with UDP

![image](https://github.com/spllat-00/Shelloox/assets/50944153/395b933a-5aa6-4132-99b0-ae603062d5cd)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/7e18522b-3330-4719-8f82-eda92d987908)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/a3a50510-f956-4862-bf28-f449ad44e173)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/4d046f39-ef2d-41a1-b249-4c6d2530c5d2)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/46de12ce-4cdd-484b-992a-c2d05ca615ec)
