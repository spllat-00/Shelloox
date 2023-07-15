#!/bin/bash
#@Spllat

# Function to handle Ctrl+C
ctrl_c(){
	echo -e "\n\nExit Command Detected. Stopping the python-server..."
	# Add any cleanup or additional actions you need here
	exit 0
}

directory_exists(){
	# Check if the directory exists
	if [ ! -d "$directory" ]; then
		echo "Directory '$directory' does not exist."
		echo "To create a directory, use:"
		echo -e "${DULL_RED}\tmkdir ${directory}${NC}"
		exit 1
	fi
}

print_files(){
	local dir="$1"
	local indent="$2"
	#supported_extensions=("py" "c" "cpp" "php")

	# Iterate over the files and folders in the directory
	for item in "$dir"/*; do
		local name=$(basename "$item")
		local extension="${name##*.}"
		
		if [ -f "$item" ]; then
			case "$extension" in
				sh)
					# Shell script - print in green color
					echo -e "${indent}└── ${CYAN}$name${NC}"
					;;
				py | c | php)
					# Files with extensions py, c, php - print in purple color
					echo -e "${indent}└── ${PURPLE}$name${NC}"
					;;
				*)
					# Regular file - print in default color
					echo -e "${indent}└── $name"
					;;
			esac

			
		elif [ -d "$item" ]; then
			# Directory - print in yellow color and recursively print its contents
			echo -e "${indent}├── ${DULL_YELLOW}$name${NC}"
			print_files "$item" "${indent}│   "
		fi
	done
}

directory_printing(){
	echo -e "${ORANGE}[+]    Directory Tree${NC}\n"
	echo -e "$folderName"
	print_files "$directory" ""
	echo
	# printf "\n=========================\n\n"
}

common_links(){
	echo -e "${ORANGE}[+]    Common Links${NC}\n"
	if [[ $script_path != $directory ]]; then
		echo "${DULL_RED}Default path${NC} may contain useful files: "
	else
		script_path="http://$ip_address:${port}"
	fi
	echo -e "${script_path}/privEsc/linpeas.sh"
	echo ""
}

# Function to display available network interfaces
display_interfaces() {
    echo "Available network interfaces:"
    interfaces=($(ip -o link show | awk '/state UP/ || /state UNKNOWN/ {print $2}' | tr -d ':'))
    indentation="    "  # Specify the desired indentation here
    for ((i = 0; i < ${#interfaces[@]}; i++)); do
        interface=${interfaces[i]}
        ip_address=$(ip -o -4 addr show dev "$interface" | awk '{split($4, a, "/"); print a[1]}')
        echo -e "${indentation}$((i + 1)). $interface\t\t$ip_address"
    done
}

# Function to select a network interface
select_interface() {
    echo "Please select your preference number:"
    display_interfaces
    echo -n "Enter number: "
    read -r selected_index
    echo ""
    if [[ $selected_index =~ ^[0-9]+$ ]]; then
        selected_index=$((selected_index - 1))
        if ((selected_index >= 0 && selected_index < ${#interfaces[@]})); then
            interface=${interfaces[selected_index]}
        else
            echo "Error: Invalid selection."
            exit 1
        fi
    else
        echo "Error: Invalid input."
        exit 1
    fi
}

ip_fetcher(){
	echo -e "${ORANGE}[+]    IP Selection${NC}"
	# Default interface selection logic
	if [ -z "$interface" ]; then
		tun_interfaces=($(ip -o link show | awk '/tun[0-9]+/ && (/state UP/ || /state UNKNOWN/) {print $2}' | tr -d ':'))

		if [[ ${#tun_interfaces[@]} -gt 1 || $ask_interface ]]; then
			[ -z "$ask_interface" ] && echo "${DULL_YELLOW}Multiple TUNnels found${NC}"
			select_interface
		elif [[ ${#tun_interfaces[@]} -eq 1 ]]; then
			interface=${tun_interfaces[0]}
		else
			interface="eth0"
		fi
	fi

	ip_address=$(ip addr show dev "$interface" 2>/dev/null | awk '$1 == "inet" { split($2, ip, "/"); print ip[1] }')
	if [ -z "$ip_address" ]; then
		echo -e "No IP address found for interface $interface."
		exit 1
	fi
	echo -e "Selected: $interface\t$ip_address\n"
}

check_port_status(){
	# Check if given port is open
	# nc -z -v -w 5 "$1" "$2" 2>/dev/null
	
	pid=$(lsof -i :"$port" -t)
	
	if [[ -n "$pid" ]]; then
		command=$(ps -p $pid -o args --no-headers)
		echo "$command" # Port is closed
		echo "$pid"
	else
		echo "OPEN" # Port is open
	fi

}

start_server(){
	# Change to the specified directory
	# cd "$directory" || exit
	echo -e "${ORANGE}[+]    Starting server${NC}"
	
	start_server=false
	
	while [[ "$start_server" != true ]]; do
		result=$(check_port_status "$ip_address" "$port")
		#echo "RESULT: {$result}"
		command=${result%$'\n'*} # Restore Command
		pid=${result#*$'\n'} # Restore PID
		
		if [[ $result == "OPEN" ]]; then
			start_server=true # Port is available to use
		else
			#echo "Something is using the port: ${RED}$res${NC}" # Port is unavailable to use
			start_server=false
		fi
		
		# Asking user if they want to kill the existing port usage
		if ! $start_server; then
			echo -e "The port $port, is already being used by:\n\t${RED}$command${NC}"
			echo "Select user's choice:"
			echo -e "\t1. Kill PID"
			echo -e "\t2. Use another PORT"
			echo -e "\t3. Exit"
			read -p "Enter your choice (1-3): " choice

			case $choice in
				1)
					kill "$pid"
					if [[ $? -eq 0 ]]; then
						echo "${DULL_YELLOW}Successfully killed process with PID $pid${NC}"
						start_server=true
					else
						echo "${RED}Something went wrong while killing PID $pid${NC}"
					fi
				;;
				2)
					read -p "    Which port should be used: " port
					echo
					#start_server=true
				;;
				*)
					echo "Exiting..."
					exit 0
				;;
			esac
		fi
	done
	
	if $start_server; then
		# Pre start server prints
		echo -e "Link: ${BLUE}http://$ip_address:$port${NC}"
		echo "Serving files from directory: $directory" # [TODO] Print out the absolute path of the provided path
		printf "\n"
		
		# Start the server
		python3 -m http.server "$port" --directory "$directory" --bind "$ip_address" 2>/dev/null
		
		# [TODO] Implement a fail check
		# CONDITION:
		# 	If the PORT is running by root or different user
	fi

}

get_path(){
	echo "Path of directory where the python server be hosted?"
	read -p "Path: " directory
	echo "Path set for: $directory"
}

display_help() {
	echo "Usage:"
	echo "  $0"
	echo
	echo "Optional Options:"
	echo "  -h, --help                     Shows this help menu"
	echo "  -n, --interface NAME[optional] Will prompt user to select Network Interface"
	echo "  -p, --port                     Port to run on"
	echo "  -d, --directory                Directory path for the file server"
	echo
	echo "EXAMPLE:"
	echo "   $0"
	echo "   $0 -n"
	echo "   $0 -n eth0"
}

#--------------------------RUNNER CODE--------------------------

interface=""
port=9092

scriptFilePath=$(realpath "$0")
folderName="files"
directory="${scriptFilePath%/*}/$folderName" # Change for custom directory
script_path=$directory

# Flag handling using getopts
while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			display_help
			exit 0
		;;
		-n|--interface)
			ask_interface=true
			if ! [ -z "$2" ]; then
				interface=$2
				shift
			fi
		;;
		-p|--port)
			if ! [ -z "$2" ]; then
				port=$2
				shift
			else
				echo -e "Port number not specified\t$0 -p 9092\n"
				display_help
				exit 1
			fi
		;;
		-d|--directory)
			if ! [ -z "$2" ]; then
				directory=$2
				shift
			else
				get_path
			fi
		;;
		*)
			echo "Error: Invalid option: $1"
			exit 1
		;;
	esac
	shift
done



#--------------------------MAIN CODE--------------------------

# Define ANSI color variables

C=$(printf '\E')
DULL_RED="${C}[0;31m"
RED="${C}[1;31m"
PURPLE="${C}[1;35m"
DULL_YELLOW="${C}[0;33m"
ORANGE="${C}[1;33m"
CYAN="${C}[1;32m"
BLUE="${C}[1;34m"
NC="${C}[0m"

# Trap the SIGINT signal (Ctrl+C)
trap ctrl_c SIGINT

ip_fetcher

directory_exists
directory_printing
common_links
start_server
