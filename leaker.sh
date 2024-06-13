#!/bin/bash


CYAN="\e[0;36m"
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW="\033[0;33m"
NC='\033[0m'

emails_tmp=$(pwd)/emails.tmp
emails=$(pwd)/emails.txt
leaked=$(pwd)/leaked.txt
dork_tmp=$(pwd)/dork_tmp
result=$(pwd)/result.txt
result_google=$(pwd)/google_dork.txt
postman=$(pwd)/postman.txt
swagger=$(pwd)/swagger.txt
secrets=$(pwd)/secrets.txt




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

email(){
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
  if [ ! -s $emails ];then
    echo -e "${GREEN}[-] Email enumeration completed.${NC}${RED}No results${NC}"
  else
    echo -e "${GREEN}[+] Email enumeration completed. Result saved in:${NC} ${CYAN}$emails${NC}"
  fi
}

cred_leak(){
  echo -e "${YELLOW}[-] Search for leaked credentials${NC}"
  LeakSearch -k $domain -n 1000 > $leaked
  if [ ! -s $leaked ];then
    echo -e "${GREEN}[+] Search for leaked credentials completed.${NC}${RED}No results${NC}"
  else
    echo -e "${GREEN}[+] Search for leaked credentials completed. Result saved in:${NC} ${CYAN}$leaked${NC}"
  fi
}


shodan_dork(){
  partial_domain=$(echo $domain |cut -d "." -f1)
  echo -e "${YELLOW}[-] Search for leaked info${NC}"
  cat dork.txt | sed "s/PLACEHOLDER/$partial_domain/g" > $dork_tmp   

  while IFS= read -r line;
  do
      line_no_space=$(echo $line | tr -d '[:blank:]')
      shodan download --fields ip_str,port,data $line_no_space "$line" >/dev/null
      sleep 5
      if [ ! -n "$(zcat "$line_no_space.json.gz" | head -c 1 | tr '\0\n' __)" ]; then
          rm "$line_no_space.json.gz"     
      fi
        zcat *.gz | jq .data | perl -MHTML::Entities -pe 'decode_entities($_);' 2>/dev/null > $result
  done  < $dork_tmp

  rm $dork_tmp
  if [ ! -s $result ];then
    echo -e "${GREEN}[+] Search for leaked info completed.${NC}${RED}No Results${NC}"
  else
    echo -e "${GREEN}[+] Search for leaked info completed. Result saved in:${NC}${CYAN}$result${NC}"
  fi
}


google_dork() {
  echo -e "${YELLOW}[-] Search for google dork${NC}"
  dorks_hunter.py -d $domain | grep -v "#" > $result_google
  if [ ! -s $result_google ];then
    echo -e "${GREEN}[+] Search for google dork completed${NC}${RED}No Results${NC}"
  else
    echo -e "${GREEN}[+] Search for google dork completed. Result saved in:${NC}${CYAN}$result_google${NC}"
  fi
}

api_leak(){
  echo -e "${YELLOW}[-] Search for leaked in API${NC}"
  porch-pirate -s "$domain" --dump >$postman 
  swaggerspy.py $domain | grep -i "[*]\|URL" >$swagger
  if [ ! -s $postman ] && [ ! - $swagger ];then
    echo -e "${GREEN}[+] Search for leaked in API completed${NC}${RED}No Results${NC}"
  else
    echo -e "${GREEN}[+] Search for leaked in API completed. Result saved in:${NC}${CYAN}$postman${NC}and${CYAN}$swagger${NC}"
  fi
}


trufflehog_check() {
  echo -e "${YELLOW}[-] Search for secret ${NC}"
  if [ -s $result ];then
    trufflehog filesystem $(zcat *.gz) 2>/dev/null >> $secrets
  fi
  if [ -s $postman ];then
    trufflehog filesystem $postman 2>/dev/null >> $secrets
  fi
  if [ -s $swagger ];then
    trufflehog filesystem $swagger 2>/dev/null >>  $secrets
  fi

  if [ ! -s $secret ];then
    echo -e "${GREEN}[+] Search for secret completed${NC}${RED}No Results${NC}"
  else
    echo -e "${GREEN}[+] Search for secret completed. Result saved in:${NC}${CYAN}$secrets${NC}"
  fi

}


email
cred_leak
shodan_dork
google_dork
api_leak
trufflehog_check
