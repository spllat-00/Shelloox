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

# Fast Scan
perform_fast_scan(){
	line_spacer
	echo -e "${YELLOW}[+]    Starting fast scan${NC}"
	nmap -T4 -F -Pn "$IP_ADDRESS" -oN "$FAST_OUTPUT_FILE"

	#fast_ports=$(less $FAST_OUTPUT_FILE | grep -E "[0-9]+/tcp")
	#fast_ports=$(echo "$fast_ports" | awk '{print $1}' | awk -F '/' '{print $1}' | sed ':a;N;$!ba;s/\n/, /g')
	#OPEN_PORTS="$fast_ports"

	open_ports_grep $FAST_OUTPUT_FILE "tcp"

	echo
	echo -e "${GREEN}Fast scan completed and results saved in $FAST_OUTPUT_FILE${NC}"
}

# Full Scan
perform_full_scan(){
	line_spacer
	echo -e "${YELLOW}[+]    Starting full scan${NC}"

	all_ports_finder
	full_ports_scan

	echo
	echo -e "${GREEN}Ports scan: $FULL_PORTS_FILE${NC}"
	echo -e "${GREEN}Full scan: $FULL_OUTPUT_FILE${NC}"
}

# Quick Scan
all_ports_finder(){
	echo -e "\t${YELLOW}[-]    Searching open ports${NC}"
	nmap --min-rate 5000 -Pn -p- -T4 "$IP_ADDRESS" -oN "$FULL_PORTS_FILE"

	open_ports_grep $FULL_PORTS_FILE "tcp" "full"

	echo -e "\t${GREEN}Ports scan completed and results saved in $FULL_PORTS_FILE${NC}\n"
}

# Full Scan from Quick Scan
full_ports_scan(){
	echo -e "\t${YELLOW}[-]    Service Enumeration${NC}" >&2

	nmap -sC -sV -Pn -p "$OPEN_PORTS_FULL" "$IP_ADDRESS" -oN "$FULL_OUTPUT_FILE"
	echo -e "\t${GREEN}Full scan completed and results saved in $FULL_OUTPUT_FILE${NC}"
}

# UDP Scan
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

	open_ports_grep $UDP_OUTPUT_FILE "udp"

	echo
	echo -e "${GREEN}UDP scan completed and results saved in $UDP_OUTPUT_FILE${NC}"
}

# open_ports_grepper
open_ports_grep(){
	if [[ -z "$1" || -z "$2" ]]; then
		echo "Empty Argument, need file"
	else
		open_ports=$(less $1 | grep -E "[0-9]+/$2")
		open_ports=$(echo "$open_ports" | awk '{print $1}' | awk -F '/' '{print $1}' | sed ':a;N;$!ba;s/\n/, /g')
		if [[ $3 == "full" ]]; then
			OPEN_PORTS_FULL=$open_ports
		fi
		if [[ -z $OPEN_PORTS ]]; then
			OPEN_PORTS="$open_ports"
		else
			OPEN_PORTS="$OPEN_PORTS, $open_ports"
		fi
	fi
}

# Folder Ownership
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

# Suggestions
suggester(){
	line_spacer

	source "${suggester_action_script}/suggester-actions.sh"

	echo -e "${YELLOW}[+]    Suggester${NC}"
	
	if [[ -z "$OPEN_PORTS" ]]; then
		if $tcp_ignore && ! $udp_scan; then
			echo -e "\t${RED}Atleast do any one of the following:${NC}
		${RED}1. Fast Scan ( -fa )${NC}
		${RED}2. Full Scan ( -fu )${NC}
		${RED}3. UDP scan  ( -U  )${NC}"
		else
			echo -e "\t${RED}Sorry! Quick Ports scan Failed.\n\tCreate an issue on GitHub: ( ${GITHUB}/issues ) preferred with screenshot of output${NC}"
		fi
		echo -e "\tSuggestion not provided"
	else
		IFS=', ' read -ra num_array  <<< "$OPEN_PORTS"
		suggested_ports=""
		suggested=0

		declare -A exclusion_ports

		exclusion_ports[80]=false
		exclusion_ports[139]=false

		for num in "${num_array[@]}"; do
			if [[ $suggested_ports == *"$num,"* || $suggested_ports == *" $num"* ]]; then
				#echo "Skipping for $num"
				continue
			fi
			
			suggested_ports="$suggested_ports, $num"
			if [[ -v PORT_MESSAGES[$num] ]]; then
				(( suggested++ ))
				echo -e "${PORT_MESSAGES[$num]}"
				
				if [[ ($num == 80 || $num == 443 || $num == 8080) && ${exclusion_ports[80]} == "false" ]]; then
					if [[ $num == 8080 ]]; then
						port_80_443 "8080"
					else
						port_80_443
					fi 
					exclusion_ports[80]=true
					echo -e "\t----------------------------------------------------------"
				elif [[ ($num == 139 || $num == 445) && ${exclusion_ports[139]} == "false" ]]; then
					exclusion_ports[139]=true
				fi
			fi
		done
		if [[ $suggested == 0 ]]; then
			echo -e "\tOpen Ports: $OPEN_PORTS"
			echo -e "\tSorry! The above ports are not yet added in our database."
			echo -e "\tCreate an issue with tag:\"${DULL_YELLOW}requried port${NC}\" on ${DULL_YELLOW}${GITHUB}/issues${NC}"
		fi
	fi
}

# Spacer
line_spacer(){
	echo
	echo
}

# OS Compatibility
user_os_checks(){
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

# Startup Sequences
prerequisites(){
	if [ $# -eq 0 ]
	then
		echo -e "${BOLD_RED}Please provide an IP address/URL as an argument${NC}"
		echo -e "    ${BOLD_RED}${BACKGROUND_YELLOW}nms <IP_ADDRESS>${NC}"
		exit 1
	fi

	# Global Variable Declarations
	declare -g IP_ADDRESS=$1
	declare -g OUTPUT_DIR=$IP_ADDRESS
	declare -g IS_DOMAIN
	declare -g FAST_OUTPUT_FILE=$OUTPUT_DIR/fast-scan.txt
	declare -g FULL_PORTS_FILE=$OUTPUT_DIR/full-ports.txt
	declare -g FULL_OUTPUT_FILE=$OUTPUT_DIR/full-scan.txt
	declare -g UDP_OUTPUT_FILE=$OUTPUT_DIR/udp-scan.txt
	declare -g OPEN_PORTS=""
	declare -g OPEN_PORTS_FULL=""

	suggester_action_script="$(dirname "$(readlink -f "$0")")"
	declare -g -A SUGGEST_ACTION_SCRIPT=$suggester_action_script

	# ip_validity

	if [ ! -d "$OUTPUT_DIR" ]; then
		mkdir "$OUTPUT_DIR"
	fi
}

# Check Availability IP/Domain
ip_validity(){
	ping_output=$(timeout 5s ping -c 1 "$IP_ADDRESS" 2>/dev/null)
	if [[ $? -eq 0 ]]; then
		echo -e "${YELLOW}[+]    OS Discovery${NC} (Not accurate)"
		# ttl=$(echo "$ping_output" | grep -oP "(?<=ttl=)\d+")  # Using pcrepattern
		ttl=$(echo "$ping_output" | grep ttl | awk -F 'ttl' '{print $2}' | awk -F ' ' '{print $1}' | sed 's/=//g')

		if [[ $ttl -le 64 ]]; then
			msg="Operating System: Linux"
			expected_ttl=64
		elif [[ $ttl -gt 64 && $ttl -le 128 ]]; then
			msg="Operating System: Windows"
			expected_ttl=128
		elif [[ $ttl -gt 128 && $ttl -le 255 ]]; then
			msg="Operating System: cannot be determined just by TTY"
			expected_ttl=$ttl
		else
			msg="TTL: $ttl\n\tOperating System: Unknown"
			expected_ttl=$ttl
		fi

		echo -e "\tTTL: $ttl"
		routers=$((expected_ttl - ttl)); [ $routers -ne 0 ] && echo -e "\tNumber of routers between user and $IP_ADDRESS: $routers"
		echo -e "\t$msg"

		# Check if IP address or Domain
		if [[ $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
			IS_DOMAIN=false
		else
			IS_DOMAIN=true
		fi
	else
		echo -e "${BOLD_RED}Invalid IP address: $IP_ADDRESS${NC}"
		exit 1
	fi
}

# Help
display_help(){
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "  -h, --help             Shows help"
	echo "  -u, --url              URL Field (required)"
	echo "  -q, --quiet            Do not print the banner on startup"
	echo "  -fa, --fast-scan       Only fast scan"
	echo "  -fu, --full-scan       Only full scan"
	echo "  -U, --udp              Run UDP scan"
	echo "  -ti, --tcp-ignore       Will skip TCP scan"
	echo "  -s, --split-scan       Split full scan, in 2: ports + full"
	echo -e "MISC:"
	echo "  --files                Show options for DIR, DNS buster"
	echo -e "EXAMPLE:"
	echo -e "   $0 -u <hostname>/<IP>"
	echo -e "   $0 -u shelloox.nms.org -fa"
	echo -e "   $0 -u shelloox.nms.org --files"
}

# Print Files
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

# Alias set for easy of use
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
BLINK_RED="${C}[5;31m"

underline="${C}[4m"

# --------------------------RUNNER CODE--------------------------
# Flag initialisation
selected_function=""
fast_scan=true
full_scan=true
udp_scan=false
tcp_ignore=false
split_scan=false

# Variables
GITHUB="https://github.com/spllat-00/Shelloox"

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
		-ti|--tcp-ignore)
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

# URL Required
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
user_os_checks
prerequisites $url

# Call Fast Scan
if ! $tcp_ignore && $fast_scan; then
	#echo "fast_scan"
	perform_fast_scan
fi

# Call Full Scan
if ! $tcp_ignore && $full_scan; then
	#echo "full_scan"
	perform_full_scan
fi

# Call UDP Scan
if $udp_scan; then
	#echo "udp_scan" 
	perform_udp_scan
	change_ownership
fi

# Call Suggester
suggester

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
