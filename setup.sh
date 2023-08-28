#!/bin/bash
#@Spllat

print_banner(){
        echo -e "${BLUE_GREEN}███████╗██╗  ██╗███████╗██╗     ██╗      ██████╗  ██████╗ ██╗  ██╗"
        echo -e "██╔════╝██║  ██║██╔════╝██║     ██║     ██╔═══██╗██╔═══██╗╚██╗██╔╝"
        echo -e "███████╗███████║█████╗  ██║     ██║     ██║   ██║██║   ██║ ╚███╔╝ "
        echo -e "╚════██║██╔══██║██╔══╝  ██║     ██║     ██║   ██║██║   ██║ ██╔██╗ "
        echo -e "███████║██║  ██║███████╗███████╗███████╗╚██████╔╝╚██████╔╝██╔╝ ██╗"
        echo -e "╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝${NC}"
        echo -e "${YELLOW}                               By Sploot${NC}"
}

function_add_zsh_bash(){
	sudo sh -c "echo \"alias $1\" >> /etc/zsh/zshrc"
	sudo sh -c "echo \"alias $1\" >> /etc/bash.bashrc"
	echo -e "\t\tAlias: ${ORNAGE_BROWN}$1${NC} will be set."
	echo -e "\t\tUser can access the alias with ${GREEN}$2${NC}"
	aliasChanged=true
}

function_comment_alias(){
	to_be_replaced_command="#$1\n"
	sed -i "s|$1|$to_be_replaced_command|" /etc/zsh/zshrc
	sed -i "s|$1|$to_be_replaced_command|" /etc/bash.bashrc
}

function_nms_check(){
	echo -e "\t${YELLOW}[-]    NMS Check${NC}"
	if [[ $1 ]]; then
		if [[ $1 = "alias nms='/opt/Shelloox/nmap/script-nmap-auto.sh'" ]]; then
			echo -e "\t\t${GREEN}Alias Present.${NC} No need to add alias for: ${GREEN}nms${NC}"
			
		else
			echo -e "\t\t${RED_PINK}Alias \`${LIGHT_MAGENTA}nms${NC}${RED_PINK}\` is already present.${NC}"
			echo -e "\t\tCurrent Value: ${LIGHT_MAGENTA}$2${NC}"
			
			while true; do
				echo -en "\t\tDo you want to overwrite the existing nms? (Y/N): "
				read -r overwrite_response
				if [[ "$overwrite_response" == "Y" || "$overwrite_response" == "y" ]]; then
					echo -e "\t\t\tOverwriting nms..."
					alias_message="nms='/opt/Shelloox/nmap/script-nmap-auto.sh'"
					function_overwrite_alias "$2" "$alias_message"
					break
				elif [[ "$overwrite_response" == "N" || "$overwrite_response" == "n" ]]; then

					echo -e "\t\t\tExisting \`nms\` won't be overwritten."
				
					while true; do
						echo -en "\t\t\tWhat should the alternate alias for 'nms' be called: "
						read -r nms_response

						if [[ ! "$nms_response" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
							echo -e "\t\t\t\t${ORNAGE_BROWN}Invalid input. Please use only letters, numbers, and underscores.${NC}"
						elif [[ "$nms_response" = "nms" ]]; then
							echo -e "\t\t\t\t${ORNAGE_BROWN}The new alias cannot be \`${BOLD}nms${NC}${ORNAGE_BROWN}\`${NC}"
						else
							break
						fi
					done

					echo -e "\t\t\tThe alias for 'nms' will be called ${GREEN}$nms_response${NC}"
					break
				
				else
					echo -e "\t\tInvalid input. Please enter Y for Yes or N for No."
				fi
			done
			
			nms_response="${nms_response:-nms}"
			alias_message="$nms_response='/opt/Shelloox/nmap/script-nmap-auto.sh'"
			function_add_zsh_bash $alias_message $nms_response
		fi
	else
		echo -e "\t\tAlias \`${LIGHT_MAGENTA}nms${NC}\` doesn't exist"
		alias_message="nms='/opt/Shelloox/nmap/script-nmap-auto.sh'"
		function_add_zsh_bash $alias_message "nms"
	fi
	
}

function_pyserver_check(){
	echo -e "\t${YELLOW}[-]    PyServer Check${NC}"
	
	if [[ $1 ]]; then
		if [[ $1 = "alias pyserver='/opt/Shelloox/PyServer/script-python-server.sh'" ]]; then
			echo -e "\t\t${GREEN}Alias Present.${NC} No need to add alias for: ${GREEN}pyserver${NC}"
		else
			echo -e "\t\t${RED_PINK}Alias \`${LIGHT_MAGENTA}pyserver${NC}${RED_PINK}\` is already present.${NC}"
			echo -e "\t\tCurrent Value: ${LIGHT_MAGENTA}$2${NC}"
			
			while true; do
				echo -en "\t\tDo you want to overwrite the existing PyServer? (Y/N): "
				read -r overwrite_response
				if [[ "$overwrite_response" == "Y" || "$overwrite_response" == "y" ]]; then
					echo -e "\t\t\tOverwriting PyServer..."
					alias_message="pyserver='/opt/Shelloox/PyServer/script-python-server.sh'"
					function_overwrite_alias "$2" "$alias_message"
					break
				elif [[ "$overwrite_response" == "N" || "$overwrite_response" == "n" ]]; then
					echo -e "\t\t\tExisting \`pyserver\` won't be overwritten."
					while true; do
						echo -en "\t\t\tWhat should the alternate alias for 'pyserver' be called: "
						read -r pyserver_response

						if [[ ! "$pyserver_response" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
							echo -e "\t\t\t\t${ORNAGE_BROWN}Invalid input. Please use only letters, numbers, and underscores.${NC}"
						elif [[ "$pyserver_response" = "pyserver" ]]; then
							echo -e "\t\t\t\t${ORNAGE_BROWN}The new alias cannot be \`${BOLD}pyserver${NC}${ORNAGE_BROWN}\`${NC}"
						else
							break
						fi
					done

					echo -e "\t\t\tThe alias for 'pyserver' will be called ${GREEN}$pyserver_response${NC}"
					break
				
				else
					echo -e "\t\tInvalid input. Please enter Y for Yes or N for No."
				fi
			done
			
			pyserver_response="${pyserver_response:-pyserver}"
			alias_message="$pyserver_response='/opt/Shelloox/PyServer/script-python-server.sh'"
			function_add_zsh_bash $alias_message "pyserver_response"
		fi
	else
		echo -e "\t\tAlias \`${LIGHT_MAGENTA}pyserver${NC}\` doesn't exist"
		alias_message="pyserver='/opt/Shelloox/PyServer/script-python-server.sh'"
		function_add_zsh_bash $alias_message "pyserver"
	fi
}

function_sudo_check(){
	echo -e "\t${YELLOW}[-]    Sudo Check${NC}"
	if [[ $1 ]]; then
		if [[ $1 = "alias sudo='sudo '" ]]; then
			echo -e "\t\t${GREEN}Alias Present.${NC} No need to add alias for: ${GREEN}sudo${NC}"
		fi
	else
		echo -e "\t\tAlias \`${LIGHT_MAGENTA}sudo${NC}\` doesn't exist"
		alias_message="sudo='sudo '"
		function_add_zsh_bash "$alias_message" "sudo"
	fi
	
}

alias_setup(){
	topic_spacer
	echo -e "${YELLOW}[+]    Alias Setup${NC}"

	nms_check=$(bash -i -c "alias | grep -E 'nms' | grep -vE '^#'") # NMS check
	pyserver_check=$(bash -i -c "alias | grep -E 'pyserver' | grep -vE '^#'") # PYSERVER check
	sudo_check=$(bash -i -c "alias | grep -E 'sudo' | grep -vE '^#'") # sudo check

	function_nms_check "$nms_check"
	echo
	function_pyserver_check "$pyserver_check"
	echo
	function_sudo_check "$sudo_check"

}

topic_spacer(){
	echo
	echo
}

give_permissions(){
	topic_spacer
	echo -e "${YELLOW}[+]    File Permissions${NC}"
	#find /opt/Shelloox -type f -name 'script-*.sh' -exec chmod +x {} \;
	#sudo find /opt/Shelloox -type f -name 'script-*.sh' -exec chmod +x {} \; -exec echo -e "\tUpdated: ${GREEN}{}${NC}" \;
	for file in $(find /opt/Shelloox -type f -name 'script-*.sh'); do
		if [ -x "$file" ]; then
			echo -e "\t${GREY}File '$file' already has executable mode.${NC}"
		else
			chmod +x "$file"
			echo -e "\tUpdated: ${GREEN}$file${NC} (given executable permission)."
		fi
	done
}

reload_help(){
	if $aliasChanged; then
		topic_spacer
		echo -e "${YELLOW}[+]    Reload Terminal${NC}"
		echo -e "\t${GREEN}Please reload the terminal${NC}"
	fi
}

print_help(){
	topic_spacer
	echo -e "${YELLOW}[+]    Shelloox Setup${NC}"
	echo -e "\tThis script will do the following"
	echo -e "\t\t1. Setup aliases for easy access"
	echo -e "\t\t2. Set required permissions for the required files"
}


# --------------------------MAIN START--------------------------
# Define ANSI color variables
C=$(printf '\E')

RED="${C}[0;31m"
BOLD_RED="${C}[1;31m"
RED_PINK="${C}[38;5;197m"
BLINK_RED="${C}[5;31m"
ORNAGE_BROWN="${C}[38;5;166m"

LIGHT_MAGENTA="${C}[1;95m"

YELLOW="${C}[1;33m"
DULL_YELLOW="${C}[0;33m"
FAINT_YELLOW="${C}[38;5;227m"
BACKGROUND_YELLOW="${C}[43m"

BLUE="${C}[1;34m"
LIGHT_CYAN="${C}[0;36m"
BLUE_GREEN="${C}[1;32m"
GREEN="${C}[38;5;47m"

GREY="${C}[38;5;247m"

BOLD="${C}[1m"
ITALIC="${C}[3m"
UNDERLINE="${C}[4m"
NC="${C}[0m"


# --------------------------RUNNER CODE--------------------------

# Global Variables
aliasChanged=false

print_banner
print_help

if [ "$EUID" -ne 0 ]; then
	topic_spacer
	echo -e "${YELLOW}[+]    Sudo Failed${NC}"
	echo -e "\t${BOLD_RED}This script must be run with sudo or as root.${NC}"
	exit 1
fi

alias_setup

give_permissions

reload_help
