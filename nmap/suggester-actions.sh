#!/bin/bash

# =======================================================
#           NOTE TO DEVELOPER
# --------------------------------
# --- If creating a function or using echo function
# --- use "$tee_command" to store the output in
# --- OUTPUT_DIR/suggester_log.txt
# =======================================================

# =======================================================
#           Functions
# =======================================================
port_80_443(){
	mediumDirectory=$(locate -r '.*directory-list.*medium.' | grep -m 1 -v 'lowercase')
	subdomain5000=$(locate -r .*DNS.*subdomains-top1million-5000.txt | head -n 1)
	echo -e "\t\tTo know other files for \"$LIGHT_MAGENTA-w$NC\", try running: ${RED}$0 --files${NC}\n" | $tee_command

	# ------ DIR Busting ------
	if ! [[ -n "$mediumDirectory" ]]; then
		mediumDirectory="<PATH_TO_DIR/subdomains-top1million-5000.txt>"
	fi
	echo -e "\t\tUse gobuster to search for ${DULL_YELLOW}hidden directories${NC}:" | $tee_command
	echo -e "\t\t ${LIGHT_MAGENTA}gobuster dir -u http://$IP_ADDRESS${1:+:}$1 -w $mediumDirectory -t 20 -o $OUTPUT_DIR/gobuster-dir${1:+:}$1.out${NC}" | $tee_command

	# ------ VHOST ------
	if ! [[ -n "$subdomain5000" ]]; then
		subdomain5000="<PATH_TO_DNS/subdomains-top1million-5000.txt>"
	fi
	echo -e "\t\tUse gobuster to search for ${DULL_YELLOW}virtual hosts${NC}:" | $tee_command
	echo -e "\t\t ${LIGHT_MAGENTA}gobuster vhost -u http://$IP_ADDRESS${1:+:}$1 -w $subdomain5000 -t 20 -o $OUTPUT_DIR/gobuster-vhost${1:+:}$1.out${NC}" | $tee_command

	# ------ DNS ------
	echo -e "\t\tUse ffuf to gather information about ${DULL_YELLOW}DNS${NC}:" | $tee_command
	echo -e "\t\t   Check for various filters: ${RED}ffuf -h${NC} => Useful: ${DULL_YELLOW}-f*${NC} / ${DULL_YELLOW}-m*${NC}" | $tee_command
	if $IS_DOMAIN; then
		echo -e "\t\t ${LIGHT_MAGENTA}ffuf -u http://$IP_ADDRESS/ -H \"HOST: FUZZ.$IP_ADDRESS\" -w $subdomain5000 -o $OUTPUT_DIR/ffuf.out${NC}" | $tee_command
	else
		echo -e "\t\t   ${RED}Need domain name${NC}" | $tee_command
		echo -e "\t\t ${LIGHT_MAGENTA}ffuf -u http://$IP_ADDRESS/ -H \"HOST: FUZZ.${RED}domain_name.goes_here${LIGHT_MAGENTA}\" -w $subdomain5000 -o $OUTPUT_DIR/ffuf.out${NC}" | $tee_command
	fi

}

# ================================
#           Messages
# ================================
declare -A PORT_MESSAGES
# --------------------------------
PORT_MESSAGES[21]="\t${RED}Port 21${NC}: FTP (File Transfer Protocol)
		${LIGHT_MAGENTA}ftp $IP_ADDRESS${NC}
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-ftp${NC}
	----------------------------------------------------------"
	
PORT_MESSAGES[111]="\t${RED}Port 111${NC}: RPCBind (Network File System)
		${LIGHT_MAGENTA}Check if Port 2049${NC}
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-rpcbind${NC}
	----------------------------------------------------------"

PORT_MESSAGES[80]="\t${RED}Port 80${NC}: Web Application (Internet Communication Protocol)
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-web${NC}\n"

PORT_MESSAGES[139]="\t${RED}Port 139${NC}: NetBios (NBT over IP)
		${LIGHT_MAGENTA}smbclient -L //${IP_ADDRESS}${NC}
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb${NC}
	----------------------------------------------------------"

PORT_MESSAGES[443]="\t${RED}Port 443${NC}: Web Application (Internet Communication Protocol)
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-web${NC}
	----------------------------------------------------------"

PORT_MESSAGES[445]="\t${RED}Port 445${NC}: NetBios (SMB over IP)
		${LIGHT_MAGENTA}nmap --script smb-vuln-* -p 445 -Pn ${IP_ADDRESS}${NC}
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb${NC}
	----------------------------------------------------------"

PORT_MESSAGES[2049]="\t${RED}Port 2049${NC}: NFS (Network File System)
		${LIGHT_MAGENTA}nmap --script nfs-* -p 2049 -Pn $IP_ADDRESS${NC}
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/nfs-service-pentesting${NC}
	----------------------------------------------------------"
	
PORT_MESSAGES[8080]="\t${RED}Port 8080${NC}: Web Application (Internet Communication Protocol)
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/pentesting-web${NC}
	----------------------------------------------------------"
	
PORT_MESSAGES[27017]="\t${RED}Port 27017${NC}: MongoDB
		${LIGHT_MAGENTA}nmap -sV --script \"mongo* and default\" -p 27017 $IP_ADDRESS${NC}
		Visit ${BLUE}https://book.hacktricks.xyz/network-services-pentesting/27017-27018-mongodb${NC}
	----------------------------------------------------------"
