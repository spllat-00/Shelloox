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
	line_spacer
	echo -e "${YELLOW}[+]    Starting fast scan${NC}"
	# Fast scan
	nmap -T4 -F -Pn "$IP_ADDRESS" -oN "$FAST_OUTPUT_FILE"
	
	echo
	echo -e "${GREEN}Fast scan completed and results saved in $FAST_OUTPUT_FILE${NC}"
}

perform_full_scan(){
	line_spacer
	echo -e "${YELLOW}[+]    Starting full scan${NC}"
	# Full scan
	
	# Fix this, does catch few ports
	# Test sunday and refer to solved solution report for number of ports
	if ($split_scan && false ); then
		echo -e "\t${YELLOW}[-]    Searching open ports${NC}"
		ports=$(nmap --min-rate 5000 -Pn -p- -T4 "$IP_ADDRESS" -oN "$FULL_PORTS_FILE" | grep -E "[0-9]+/tcp" )
		n_ports=$(echo "$ports" | sed ':a;N;$!ba;s/\n/\n\t\t/g')
		ports=$(echo "$ports" | awk '{print $1}' | awk -F '/' '{print $1}' | sed ':a;N;$!ba;s/\n/, /g')
		echo -e "\tOpen Ports: \n\t\t$n_ports\n"
		echo -e "\t${YELLOW}[-]    Service Enumeration${NC}"
		nmap -sC -sV -Pn -p "$ports" "$IP_ADDRESS" -oN "$FULL_OUTPUT_FILE"
	else
		nmap --min-rate 5000 -sC -sV -T4 -Pn -p- --open "$IP_ADDRESS" -oN "$FULL_OUTPUT_FILE"
	fi
	
	echo
	echo -e "${GREEN}Full scan completed and results saved in $FULL_OUTPUT_FILE${NC}"
}

perform_udp_scan(){
	line_spacer
	echo -e "${YELLOW}[+]    UDP SCAN${NC}"
	
	if [[ (! (-e "$FAST_OUTPUT_FILE" || -e "$FULL_OUTPUT_FILE")) ]]; then
		if ! $tcp_ignore; then
			echo -e "\n---> Residual of TCP scan not found"
			echo -e "\n\t${RED}SUGGESTION${NC}"
			echo "Run ${LIGHT_MAGENTA}$0 -u <URL>${NC} first"
			echo -e "---> To ignore warning run, with \"${LIGHT_MAGENTA}-t${NC}\" flag"
			exit
		fi
	fi
	
	nmap -sU --top-ports 100 -Pn --max-rate 500 -T4 "$IP_ADDRESS" -oN "$UDP_OUTPUT_FILE"
	
	echo
	echo -e "${GREEN}UDP scan completed and results saved in $UDP_OUTPUT_FILE${NC}"
}

change_ownership(){
	line_spacer
	echo -e "${YELLOW}[+]    Ownership${NC}"
	current_directory=$(pwd)
	#echo "current_directory: $current_directory"
	path="${current_directory#/}"
	IFS='/' read -r -a parts <<< "$path"

	if [[ "${parts[0]}" == "home" ]]; then
		owner=$(ls -ld "/home/${parts[1]}" | awk '{print $3}')
		chown -R $owner:$owner $OUTPUT_DIR
		echo -e "Ownership changed from \"root\" to $owner"
	else
		line_spacer
		echo -e "New directory not in /home/xxx/\nOwnership will be kept to \"${RED}root${NC}\""
	fi
}

provide_suggestions(){
	line_spacer
	echo -e "==============================="
	echo "${YELLOW}Suggestions for further testing${NC}"
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
}

line_spacer(){
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
	declare -g FULL_PORTS_FILE=$OUTPUT_DIR/full-ports.txt
	declare -g FULL_OUTPUT_FILE=$OUTPUT_DIR/full-scan.txt
	declare -g UDP_OUTPUT_FILE=$OUTPUT_DIR/udp-scan.txt

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
		echo -e "${YELLOW}[+]    OS Discovery${NC} (Not accurate)"
		# ttl=$(echo "$ping_output" | grep -oP "(?<=ttl=)\d+")  # Using pcrepattern
		ttl=$(echo "$ping_output" | grep ttl | awk -F 'ttl' '{print $2}' | awk -F ' ' '{print $1}' | sed 's/=//g')

		if [[ $ttl -ge 63 && $ttl -lt 128 ]]; then
			msg="Operating System: Linux"
		elif [[ $ttl -ge 128 && $ttl -lt 255 ]]; then
			msg="Operating System: Windows"
		elif [[ $ttl -eq 255 ]]; then
			msg="Operating System: MacOS"
		else
			msg="TTL: $ttl\n\tOperating System: Unknown"
		fi

		echo -e "\tTTL: $ttl\n\t$msg"
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
	echo "  -U, --udp              Run UDP scan"
	echo "  -t, --tcp-ignore       Will skip TCP scan"
	echo "  -s, --split-scan       Split full scan, in 2: ports + full"
	echo -e "MISC:"
	echo "  --files                Show options for DIR, DNS buster"
	echo -e "EXAMPLE:"
	echo -e "   $0 -u <hostname>/<IP>"
	echo -e "   $0 -u shelloox.nms.org -fa"
	echo -e "   $0 -u shelloox.nms.org --files"
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
		echo -e "${RED}---- Default ----${NC}"
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
		echo -e "${RED}---- Default ----${NC}"
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
# Flag initialisation
selected_function=""
fast_scan=true
full_scan=true
udp_scan=false
tcp_ignore=false
split_scan=false

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
		-U|--udp)
			if [[ "$EUID" -ne 0 ]]; then
				echo -e "${RED}ERROR: UDP scans need 'sudo' privilege${NC}"
				exit
			fi
			udp_scan=true
		;;
		-s|--split-scan)
			split_scan=true
		;;
		-t|--tcp-ignore)
			tcp_ignore=true
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

# Banner
if $show_banner; then
	print_banner
else
	echo ""
fi

# Required checks
os_checks
prerequisites $url

# Fast Scan
if ! $tcp_ignore && $fast_scan; then
	#echo "fast_scan"
	perform_fast_scan
fi

# Suggestions
provide_suggestions

# Full Scan
if ! $tcp_ignore && $full_scan; then
	#echo "full_scan"
	perform_full_scan
fi

# UDP Scan
if $udp_scan; then
	#echo "udp_scan" 
	perform_udp_scan
	change_ownership
fi


# Calculate time difference using awk
end=$(date +%s.%N)
diff=$(awk "BEGIN {printf \"%.2f\", $end - $start}")

line_spacer
echo -e "Shelloox took: $diff seconds"



: << TODOs
[ ] Specific Ports Suggestions
[ ] Windows compatibility
[ ] Remove file search for DIR, DNS else make it faster
[ ] alias_check: check if an alias is set
[ ] hostname in /etc/hosts *(SUDO)
TODOs
