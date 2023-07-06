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

## Screenshots
- With multiple TUNnels open
![image](https://github.com/spllat-00/Shelloox/assets/50944153/29807315-50c5-4e95-ac43-f3f73f3b72ab)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/5769eafa-1db5-4141-be41-2f90b0e079c4)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/72dcfe1c-59f7-4f0e-9515-78258045c125)
![image](https://github.com/spllat-00/Shelloox/assets/50944153/eda1b93c-8b0a-45f4-b42b-d618175578ab)

---
