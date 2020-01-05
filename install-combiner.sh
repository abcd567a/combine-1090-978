#!/bin/bash

INSTALL_FOLDER=/usr/share/combiner-1090-978

echo "Creating folder combiner-1090-978"
sudo mkdir ${INSTALL_FOLDER}
echo "Downloading modeSMixer2 file from Google Drive"
sudo wget -O ${INSTALL_FOLDER}/modesmixer2_rpi2-3_deb9_20190223.tgz "https://drive.google.com/uc?export=download&id=18DjTxitzZj9RsVPxt7lmnptfL5eZqHxJ"

echo "Unzipping downloaded file"
sudo tar xvzf ${INSTALL_FOLDER}/modesmixer2_rpi2-3_deb9_20190223.tgz -C ${INSTALL_FOLDER}

echo "Creating startup script file combiner.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/combiner.sh
sudo touch ${SCRIPT_FILE}
sudo chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file combiner.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/combiner.conf
${INSTALL_FOLDER}/modesmixer2 \${CONFIG}
EOM
sudo chmod +x ${SCRIPT_FILE}

echo "Creating config file combiner.conf"
CONFIG_FILE=${INSTALL_FOLDER}/combiner.conf
sudo touch ${CONFIG_FILE}
sudo chmod 777 ${CONFIG_FILE}
echo "Writing code to config file combiner.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--inConnectId 127.0.0.1:30005:ADSB
--inConnectId 127.0.0.1:30978:UAT
--outServer beast:32005
--web 8787
EOM
sudo chmod 644 ${CONFIG_FILE}

echo "Creating Service file combiner.service"
SERVICE_FILE=/lib/systemd/system/combiner.service
sudo touch ${SERVICE_FILE}
sudo chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# modesmixer2 (combiner of 1090 & 978) service for systemd
[Unit]
Description=ModeSMixer2 Combiner
Wants=network.target
After=network.target
[Service]
RuntimeDirectory=combiner
RuntimeDirectoryMode=0755
ExecStart=/bin/bash ${INSTALL_FOLDER}/combiner.sh
SyslogIdentifier=combiner
Type=simple
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=64
Nice=-5
[Install]
WantedBy=default.target

EOM

sudo chmod 644 ${SERVICE_FILE}
sudo systemctl enable combiner
sudo systemctl restart combiner

echo " "
echo " "
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32mINSTALLATION COMPLETED \e[39m"
echo -e "\e[33m The combined output of dump1090-fa and dump978-fa is  \e[39m"
echo -e "\e[33m available at port 32005, format Beast\e[39m"
echo -e "\e[33m In config files of Planeplotter, Flightradar24, \e[39m"
echo -e "\e[33m Radarbox24, and Planefinder, \e[39m" 
echo -e "\e[33m change port number from 30005 to 32005 \e[39m"
echo -e ""
echo -e "\e[32mTo see status\e[39m sudo systemctl status combiner"
echo -e "\e[32mTo restart\e[39m    sudo systemctl restart combiner"
echo -e "\e[32mTo stop\e[39m       sudo systemctl stop combiner"

echo -e "\e[32mTo edit config\e[39m sudo nano /usr/share/combiner-1090-978/combiner.conf"
echo -e "\e[32m=======================\e[39m"
echo -e ""





