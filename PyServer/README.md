# Python Server
---
## Features
- Hosts a server, to pull files with `wget` or `curl`
- Will host on TCP if `tun` exists.
- Multiple `tun` will result in a prompt to user, for selecting which Network Interface to use

## Usage
- Normal Usage
```bash
./python-server.sh
```

- Fixed Network Interface
```bash
./python-server.sh -n <Network_Interface_name>
```

- Other details can be checked with `-h / --help`

## Output
A server will be hosted on diven Network Interface, which can be accessed to retrieve files

## Suggestion
Use an alias, which will make life simpler and script easier to use
```bash
alias sudo="sudo "
alias pyserver="/opt/Shelloox/PyServer/python-server.sh"
```

## To Do
- [ ] Upload useful files to ./PythonServer
- [x] ~~Directory printing~~
