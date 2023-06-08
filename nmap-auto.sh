#!/bin/bash
#@Spllat

print_banner(){
	# Define banner
	echo -e "${GREEN}███████╗██╗  ██╗███████╗██╗     ██╗      ██████╗  ██████╗ ██╗  ██╗"
	echo -e "██╔════╝██║  ██║██╔════╝██║     ██║     ██╔═══██╗██╔═══██╗╚██╗██╔╝"
	echo -e "███████╗███████║█████╗  ██║     ██║     ██║   ██║██║   ██║ ╚███╔╝ "
	echo -e "╚════██║██╔══██║██╔══╝  ██║     ██║     ██║   ██║██║   ██║ ██╔██╗ "
	echo -e "███████║██║  ██║███████╗███████╗███████╗╚██████╔╝╚██████╔╝██╔╝ ██╗"
	echo -e "╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝${NC}"
	echo -e "${YELLOW}                               By Sploot${NC}"
	echo 
	echo
}

perform_fast_scan(){
	echo -e "${YELLOW}[+]    Starting fast scan${NC}"
	# Fast scan
	nmap -T4 -F "$IP_ADDRESS" -oN "$FAST_OUTPUT_FILE"
	echo
	echo -e "${GREEN}Fast scan completed and results saved in $FAST_OUTPUT_FILE${NC}"
	echo
	echo
}

perform_full_scan(){
	echo -e "${YELLOW}[+]    Starting full scan${NC}"
	# Full scan
	nmap --min-rate 5000 -sC -sV -T4 -p- --open "$IP_ADDRESS" -oN "$FULL_OUTPUT_FILE"
	echo
	echo -e "${GREEN}Full scan completed and results saved in $FULL_OUTPUT_FILE${NC}"
	echo
	echo
}

provide_suggestions(){
	echo "==============================="
	echo -e "${YELLOW}Suggestions for further testing${NC}"
	echo "==============================="

	echo -e "  Use gobuster to search for ${DULL_YELLOW}hidden directories${NC}:"
	echo -e "    ${LIGHT_MAGENTA}gobuster dir -u http://$IP_ADDRESS -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 20${NC}"

	echo -e "  Use gobuster to search for ${DULL_YELLOW}virtual hosts${NC}:"
	echo -e "    ${LIGHT_MAGENTA}gobuster vhost -u http://$IP_ADDRESS -w /usr/share/seclists/SecLists-master/Discovery/DNS/subdomains-top1million-5000.txt -t 20${NC}"

	echo -e "  Use dnsenum to gather information about ${DULL_YELLOW}DNS${NC}:"
	echo -e "    ${LIGHT_MAGENTA}dnsenum $IP_ADDRESS${NC}"

	echo "==============================="
	echo
	echo
}

os_checks(){
	# Get the name of the operating system
	OS=$(uname -s)
	# Check if the OS is Windows
	if [[ "$OS" == "CYGWIN"* || "$OS" == "MINGW"* ]]; then
		echo "==============================="
		echo -e "${BOLD_RED}ERROR: This script cannot be run on $OS.${NC}"
		exit 1
	fi

	# Print the name of the operating system if it is not Windows
	# echo "==============================="
	# echo -e "The operating system is ${GREEN}$OS${NC}."
	# echo "==============================="
}

prerequisites(){
	if [ $# -eq 0 ]
	then
		echo -e "${BOLD_RED}Please provide an IP address/URL as an argument${NC}"
		echo -e "    ${BOLD_RED}${BACKGROUND_YELLOW}nms <IP_ADDRESS>${NC}"
		exit 1
	fi

	declare -g IP_ADDRESS=$1
	declare -g OUTPUT_DIR=$IP_ADDRESS
	declare -g FAST_OUTPUT_FILE=$OUTPUT_DIR/fast-scan.txt
	declare -g FULL_OUTPUT_FILE=$OUTPUT_DIR/full-scan.txt

	ip_validity

	if [ ! -d "$OUTPUT_DIR" ]; then
		mkdir "$OUTPUT_DIR"
	fi
}

ip_validity(){
	# Check if IP address is valid
	#if [[ ! $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	#	echo -e "${BOLD_RED}Invalid IP address: $IP_ADDRESS${NC}"
	#	exit 1
	#fi
	
	if ping -c 1 "$IP_ADDRESS" >/dev/null; then
		echo ""
	else
		echo -e "${BOLD_RED}Invalid IP address: $IP_ADDRESS${NC}"
		exit 1
	fi
	
}

#--------------------------MAIN SCANS--------------------------

start=$(date +%s.%N)
# Define ANSI color variables
C=$(printf '\033')
RED='\033[0;31m'
LIGHT_RED='\033[1;31m'
BOLD_RED='\033[1;31m'
YELLOW="${C}[1;33m"
DULL_YELLOW='\033[0;33m'
BLUE="${C}[1;34m"
LIGHT_MAGENTA="${C}[1;95m"
GREEN="${C}[1;32m"
LIGHT_CYAN="${C}[1;96m"
NC='\033[0m'
origIFS="${IFS}"
ITALIC="${C}[3m"
BACKGROUND_YELLOW='\033[43m'


print_banner
os_checks
prerequisites $1

perform_fast_scan
provide_suggestions
perform_full_scan


end=$(date +%s.%N)

# Calculate time difference using awk
diff=$(awk "BEGIN {printf \"%.2f\", $end - $start}")

echo "Shelloox took: $diff seconds"
