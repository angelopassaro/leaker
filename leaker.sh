#!/bin/bash


CYAN="\e[0;36m"
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW="\033[0;33m"
NC='\033[0m'

emails_tmp=$(pwd)/emails.tmp
emails=$(pwd)/emails.txt
leaked=$(pwd)/leaked.txt


echo -e "${CYAN} __       _______     ___       __  ___  _______ .______      ${NC}";
echo -e "${CYAN}|  |     |   ____|   /   \     |  |/  / |   ____||   _  \     ${NC}";
echo -e "${CYAN}|  |     |  |__     /  ^  \    |  '  /  |  |__   |  |_)  |    ${NC}";
echo -e "${CYAN}|  |     |   __|   /  /_\  \   |    <   |   __|  |      /     ${NC}";
echo -e "${CYAN}|  \`----.|  |____ /  _____  \  |  .  \  |  |____ |  |\  \----.${NC}";
echo -e "${CYAN}|_______||_______/__/     \__\ |__|\__\ |_______|| _| \`._____|${NC}";
echo -e "${CYAN}                                                              ${NC}";



usage() {
  echo -e "Usage: $0 <domain> <number of interactions>" 1>&2
}

exit_abnormal() {
  usage
  exit 1
}

if [ $# -eq 0 ]; then
  usage
  exit_abnormal
fi

domain=$1
interactions=$2

echo -e "${YELLOW}[-] Start email enumeration${NC}"
for _ in {1..$interactions};
do
    sleep 5
    emailfinder -d $domain | grep "@" | grep -v "Author"  >> $emails_tmp
    emailfinder -d $(echo $domain |cut -d "." -f1 ) | grep "@" | grep -v "Author"  >> $emails_tmp

done

email_finder $domain >> $emails_tmp
sort -u $emails_tmp > $emails
rm $emails_tmp
echo -e "${GREEN}[+] Email enumeration completed. Result saved in:${NC} ${CYAN}$emails${NC}"

echo -e "${YELLOW}[-] Search for leaked credentials${NC}"
LeakSearch -k $domain -n 1000 > $leaked
echo -e "${GREEN}[+] Searching for leaked credentials completed. Result saved in:${NC} ${CYAN}$leaked${NC}"
