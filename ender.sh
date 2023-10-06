#!/bin/bash
GREEN="\033[0;32m"
RESET="\033[0m"
RED="\033[0;31m"
BLUE="\033[0;34m"
TICK="\e[32m\u2713\e[0m"
FAIL="\e[31m\u2717\e[0m"

if [ $# -eq 0 ]; then
	echo -e "Usage: $0 [${BLUE}+${RESET}]website[${BLUE}+${RESET}]"
	exit 1
fi

#Checking the internet connection
echo -e "[${BLUE}+${RESET}]Checking the Internet Connection ..."
ping 8.8.8.8 -c 1 > /dev/null
#"$?" stores the status code of above line
if [[ $"$?" -eq 1 ]]; then
	echo -e "Internet Check Failed[${RED}${FAIL}${RESET}]"
	exit 1
else 
	echo -e "Internet Check Done [${TICK}]${RESET}"
fi

url="$1"
folder=trj_output
domain=$(echo "$url" | cut -d'.' -f1)
sleep 1

# verify the domain
echo -e "[${BLUE}+${RESET}]Checking the Domain."
ping $url -c 1 >/dev/null
if [[ $"$?" -eq 0 ]]; then
	echo -e "Domain Check Done[${TICK}${RESET}]"
else
	echo -e "Domain Check Failed![${RED}${FAIL}${RESET}]"
	exit 1
fi

# Specify the name of the tool
t1="uro"
t2="gau"

# Check if uro is installed
pip list 2>/dev/null | grep uro &>/dev/null
if [ $"$?" -eq 1 ]; then
	echo -e "${RED}[+]${RESET}URO is not Installed... Please Install it and rerun this Script..."
	exit 1
fi

if ! command -v "$t2"&>/dev/null; then
    echo -e "${BLUE}[+]${RESET}$t2 is not installed. Installing $t2 ..."
    wget -q https://github.com/lc/gau/releases/download/v2.1.2/gau_2.1.2_linux_amd64.tar.gz>/dev/null
    tar xvf gau_2.1.2_linux_amd64.tar.gz>/dev/null
    echo -e "${BLUE}[+]${RESET}ENTER THE ROOT PASSWORD TO COPY ESSENTIAL FILES"
    sudo mv gau /usr/bin/gau
    rm gau_2.1.2_linux_amd64.tar.gz
fi
if ! command -v "$t2"&>/dev/null; then
	echo -e "[${RED}+${RESET}]Please Install GAU Manually!"
fi
sleep 2
	#echo -e "[${GREEN}+${RESET}]Everything is Configured! Moving UP.."
sleep 3
# Run the echo command and store the output in params.txt
echo -e "[${BLUE}+${RESET}]Gathering The End-Points for ${green}$url${RESET}"
#Checking the Domain Folder Exists or not
if [ ! -d $folder ]; then
	mkdir $folder
fi
echo $url | gau | uro | grep "?" | sed "s/=.*/=A\'/" | uniq > $folder/$domain.txt

# Pause for 5 seconds
sleep 5

#Checking if the file exists or not
cd $folder
if [[ -f "${domain}.txt" ]]; then
        echo -e "[${GREEN}+${RESET}]EndPoints Gathered! Now Analyzing ${domain}.txt"
	if [[ ! -s "${domain}.txt" ]]; then
		echo -e "[${RED}${FAIL}${RESET}]No EndPoints Found"
		echo -e "[${BLUE}${TICK}${RESET}Exiting"; sleep 1
		exit -1
	fi
sleep 2

# Run the cat command
	echo -e "[${GREEN}+${RESET}]Searching The SQL parameters From The Input File $domain.txt."
	cat $domain.txt | httpx -mr ".*SQL.*syntax.*|.*SQL.*error.*"&>/dev/null | tee final.$domain.txt
	if [ -s final.$domain.txt ]; then
		echo -e "[${BLUE}+${RESET}]All The Juicy URLs are stored under final.$domain.txt."
	else
		echo -e "[${RED}-${RESET}]Found Zero SQL Errors in the $domain"
		rm final.$domain.txt
		fi
else
	echo "${domain}.txt not found"
fi
