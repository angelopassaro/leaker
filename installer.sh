#!/bin/bash

pip3 install emailfinder

# Fix fonts for emailfinder
sudo wget http://www.figlet.org/fonts/cosmic.flf -O /usr/share/figlet/cosmic.flf
sudo wget http://www.figlet.org/fonts/epic.flf -O /usr/share/figlet/epic.flf
sudo wget http://www.figlet.org/fonts/speed.flf -O /usr/share/figlet/speed.flf
sudo wget http://www.figlet.org/fonts/graffiti.flf -O /usr/share/figlet/graffiti.flf




sudo git clone https://github.com/rix4uni/EmailFinder.git /opt/EmailFinder
cd /opt/EmailFinder
sudo rm -rf Emails
sudo chmod +x email_finder.sh
sudo ln -s /opt/EmailFinder/email_finder.sh /usr/local/bin/email_finder



sudo git clone https://github.com/JoelGMSec/LeakSearch /opt/LeakSearch 
cd /opt/LeakSearch 
python3 -m pip install -r requirements
sudo chmod +x LeakSearch.py 
sudo mv /opt/LeakSearch/LeakSearch.py  /usr/local/bin/LeakSearch 
sudo rm -rf /opt/LeakSearch 


pip3 install shodan

python3 -m pip install porch-pirate

sudo git clone https://github.com/UndeadSec/SwaggerSpy.git /opt/SwaggerSpy
cd SwaggerSpy
python3 -m pip install -r requirements.txt
sudo chmod +x swaggerspy.py
sudo mv swaggerspy.py /usr/local/bin/
sudo rm -rf /opt/SwaggerSpy



sudo git clone https://github.com/six2dez/dorks_hunter /opt/dorks_hunter
cd dorks_hunter
python3 -m pip install -r requirements.txt
chmod +x dorks_hunter.py
sudo mv dorks_hunter.py /usr/local/bin/dorks_hunter.py
sudo rm -rf /opt/dorks_hunter


git clone https://github.com/trufflesecurity/trufflehog.git
cd trufflehog
go install
sudo mv ~/go/bin/trufflehog /usr/local/bin
