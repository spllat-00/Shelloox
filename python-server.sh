#!/bin/bash
#@Spllat

# Function to handle Ctrl+C
ctrl_c() {
	echo -e "\nExit Command Detected. Stopping the server..."
	# Add any cleanup or additional actions you need here
	exit 0
}

directory_exists(){
	# Check if the directory exists
	if [ ! -d "$directory" ]; then
		echo "Directory '$directory' does not exist."
		echo "To create a driectory, use:"
		echo -e "${DULL_RED}\tmkdir ${directory}${NC}"
		exit 1
	fi
}

print_files() {
	local dir="$1"
	local indent="$2"

	# Iterate over the files and folders in the directory
	for item in "$dir"/*; do
		local name=$(basename "$item")
		
		if [ -f "$item" ]; then
			# File - print in purple color
			echo -e "${indent}└── ${PURPLE}$name${NC}"
		elif [ -d "$item" ]; then
			# Directory - print in yellow color and recursively print its contents
			echo -e "${indent}├── ${DULL_YELLOW}$name${NC}"
			print_files "$item" "${indent}│   "
		fi
	done
}

directory_printing(){
	echo "Directory Tree:"
	echo ""
	print_files "$directory" ""
	printf "\n=========================\n\n"
}

common_links(){
	if [ -z "$ip_address" ]; then
		backup_link=$(ip -o -4 addr show eth0 | awk '{print $4}' | cut -d '/' -f 1)
		ip_address=$backup_link
		echo -e "${RED}tun0 doesn't exists, using eth0${NC}"
	fi
	echo "Showing commonly used links"
	echo "-------------------------"
	echo -e "${DULL_RED}http://${ip_address}:${port}/privEsc/linpeas.sh${NC}"
	echo ""
}

start_server(){
	# Change to the specified directory
	# cd "$directory" || exit
	echo "Starting HTTP server on port $port"
	echo "Serving files from directory: $directory"
	printf "\n"
	# Start the server
	python3 -m http.server "$port" --directory "$directory"
}

#--------------------------MAIN CODE--------------------------

# Define ANSI color variables
DULL_RED='\033[0;31m'
RED='\033[1;31m'
PURPLE='\033[1;35m'
DULL_YELLOW='\033[0;33m'
NC='\033[0m'

# Trap the SIGINT signal (Ctrl+C)
trap ctrl_c SIGINT

port=9092
directory="/home/kali/Documents/important" # Change for custom directory

# tun0 fetcher
ip_address=$(ip -o -4 addr show tun0 2>/dev/null | awk '{print $4}' | cut -d '/' -f 1)

directory_exists
directory_printing
common_links
start_server
