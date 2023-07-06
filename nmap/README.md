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
![image](https://github.com/spllat-00/Shelloox/assets/50944153/4229d740-e8f4-4aee-bced-8580a14fd98a)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/b9d97deb-232d-4228-993a-36b389c508cc)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/b58cbc45-307a-420e-b5cc-2945a58f1e3c)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/0218a13f-37b3-47b9-8f32-d4b1777540ee)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/5f2d0c57-f050-4cf3-8406-41a89b25602d)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/167a4970-9242-4f48-8809-b60f20c3b3cf)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/2d5329ed-e796-4947-b6ca-14f4c59c326c)

---
