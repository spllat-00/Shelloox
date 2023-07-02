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

	mediumDirectory=$(locate -r '.*directory-list.*medium.' | grep -m 1 -v 'lowercase')
	subdomain5000=$(locate -r .*DNS.*subdomains-top1million-5000.txt | head -n 1)
	
	if [[ -n "$subdomain5000" || -n "$mediumDirectory" ]]; then
		echo -e "To know other files for \"$LIGHT_MAGENTA-w$NC\", try running: ${RED}$0 --files${NC}\n"
	fi
	
	# ------ DIR Busting ------
	if ! [[ -n "$mediumDirectory" ]]; then
		mediumDirectory="<PATH_TO_DIR/subdomains-top1million-5000.txt>"
	fi
	echo -e "  Use gobuster to search for ${DULL_YELLOW}hidden directories${NC}:"
	echo -e "    ${LIGHT_MAGENTA}gobuster dir -u http://$IP_ADDRESS -w $mediumDirectory -t 20${NC}"


	# ------ VHOST ------
	if ! [[ -n "$subdomain5000" ]]; then
		subdomain5000="<PATH_TO_DNS/subdomains-top1million-5000.txt>"
	fi
	echo -e "  Use gobuster to search for ${DULL_YELLOW}virtual hosts${NC}:"
	echo -e "    ${LIGHT_MAGENTA}gobuster vhost -u http://$IP_ADDRESS -w $subdomain5000 -t 20${NC}"

	# ------ DNS ------
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

	ping_output=$(ping -c 1 "$IP_ADDRESS")
	if [[ $? -eq 0 ]]; then
		# ttl=$(echo "$ping_output" | grep -oP "(?<=ttl=)\d+")  # Using pcrepattern
		ttl=$(echo "$ping_output" | grep ttl | awk -F ' ' '{print $6}' | awk -F '=' '{print $2}')

		if [[ $ttl -ge 63 && $ttl -lt 128 ]]; then
			msg="Operating System: Linux"
		elif [[ $ttl -ge 128 && $ttl -lt 255 ]]; then
			msg="Operating System: Windows"
		elif [[ $ttl -eq 255 ]]; then
			msg="Operating System: MacOS"
		else
			msg="TTL: $ttl\n\tOperating System: Unknown"
		fi
		
		echo -e "${YELLOW}[+]    OS Discovery${NC}"
		echo -e "\t$msg\n\n"
	else
		echo -e "${BOLD_RED}Invalid IP address: $IP_ADDRESS${NC}"
		exit 1
	fi
}

display_help(){
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "  -h, --help             Shows help"
	echo "  -u, --url              URL Field (required)"
	echo "  -q, --quiet            Do not print the banner on startup"
	echo "  -fa, --fast-scan       Only fast scan"
	echo "  -fu, --full-scan       Only full scan"
	echo -e "MISC:"
	echo "  --files                Show options for DIR, DNS buster"
	echo -e "EXAMPLE:"
	echo -e "   $0 -u 10.0.0.8"
	echo -e "   $0 -u shelloox.nms.org"
}

show_files(){
	echo ""

	# DIR
	strDIR='.*directory-list.*medium.'
	
	mediumDirectory=$(locate -r $strDIR | grep -m 1 -v 'lowercase')
	
	restDirFile=$(locate -r $strDIR | tail -n +2 )
	restDirFile="$(echo -e "$restDirFile" | sed 's/^/\t/')"

	seclistURL="https://github.com/danielmiessler/SecLists"

	echo -e "${YELLOW}[+]    DIR Busting${NC}"
	echo -e "--------------------------------"
	if ! [[ -n "$mediumDirectory" ]]; then

		echo -e "No files present with normal name"
		echo -e "\nSuggestions:\n\t${underline}danielmiessler/SecLists${NC}: ${seclistURL} "
	else
		echo -e "${RED}---- Default ----"
		echo -e "\t${GREEN}${mediumDirectory}${NC}"
		echo -e "${RED}---Other Options Found---${NC}"
		echo -e "${restDirFile}"
	fi


	# DNS
	strDNS='.*DNS.*subdomains-top1million-5000.txt'
	
	firstDnsFile=$(locate -r $strDNS | head -n 1)
	
	restDnsFile=$(locate -r $strDNS | tail -n +2)
	restDnsFile="$(echo -e "$restDnsFile" | sed 's/^/\t/')"
	
	echo -e "\n${YELLOW}[+]    DNS Busting${NC}"
	echo -e "--------------------------------"
	if ! [[ -n "$firstDnsFile" ]]; then
		echo -e "No files present with normal name"
		echo -e "\nSuggestions:\n\t${underline}danielmiessler/SecLists${NC}: ${seclistURL} "
	else
		echo -e "${RED}---- Default ----"
		echo -e "\t${GREEN}${firstDnsFile}${NC}"
		echo -e "${RED}---Other Options Found---${NC}"
		echo -e "${restDnsFile}"
	fi
}

: << COMMENT_TO_DO
alias_check(){
	# Function should check if a alias has been set
	# for nmap-auto.sh for easier use. 
	# If no alias is set, the script will prompt 
	# user to add alias or will ask for the user
	# if it can set a alias with "User given keyword" 
	echo "HI"
	command="nmap-auto.sh"
}
COMMENT_TO_DO

# --------------------------MAIN START--------------------------

start=$(date +%s.%N)

# Define ANSI color variables
C=$(printf '\E')
RED="${C}[0;31m"
BOLD_RED="${C}[1;31m"
YELLOW="${C}[1;33m"
DULL_YELLOW="${C}[0;33m"
BLUE="${C}[1;34m"
LIGHT_MAGENTA="${C}[1;95m"
GREEN="${C}[1;32m"
LIGHT_CYAN="${C}[0;36m"
NC="${C}[0m"
ITALIC="${C}[3m"
BACKGROUND_YELLOW="${C}[43m"
BLINK_YELLOW="${C}[5;33m"

underline="${C}[4m"

# --------------------------RUNNER CODE--------------------------
# Flag variable
selected_function=""
fast_scan=true
full_scan=true

# Flag handling using getopts
while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			display_help
			exit 0
		;;
		-u|--url)
			shift
			if [[ -n $1 ]]; then
				url=$1
			else
				echo "Error: URL parameter is missing."
				exit 1
			fi
		;;
		-q|--quiet)
			show_banner=false
		;;
		-v)
			verbosity=false
		;;
		-fa|--fast-scan)
			fast_scan=true
			full_scan=false
			if [[ -n $selected_function ]]; then
				echo -e "${RED}ERROR: -fa and -fu cannot be provided together${NC}"
				exit 1
			fi
			selected_function="fa"
		;;
		-fu|--full-scan)
			full_scan=true
			fast_scan=false
			if [[ -n $selected_function ]]; then
				echo -e "${RED}ERROR: -fa and -fu cannot be provided together${NC}"
				exit 1
			fi
			selected_function="fu"
		;;
		--files)
			show_files
			exit 0
		;;
		*)
			echo "Error: Invalid option: $1"
			exit 1
		;;
	esac
	shift
done


if [[ -z $url ]]; then
  display_help
  exit 1
fi


# --------------------------START SCANS--------------------------

if $show_banner; then
	print_banner
else
	echo ""
fi


os_checks
prerequisites $url

if $fast_scan;then
	perform_fast_scan
fi

provide_suggestions

if $full_scan;then
	perform_full_scan
fi

end=$(date +%s.%N)

# Calculate time difference using awk
diff=$(awk "BEGIN {printf \"%.2f\", $end - $start}")

echo "Shelloox took: $diff seconds"



: << TODOs
[ ] UDP scans *(SUDO)
[ ] Specific Ports Suggestions
[ ] Windows compatibility
[ ] Remove file search for DIR, DNS else make it faster
[ ] alias_check: check if an alias is set
[ ] hostname in /etc/hosts *(SUDO)
TODOs
