#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. You need to add the assetchain ticker as a parameter"
    echo "For example: ./create_services.sh MARTY"
    exit 1
fi

mkdir -p ~/logs

echo "Creating deamon service file for ${1}..."
cp services/TEMPLATE-deamon.service services/${1}-deamon.service
sed "s/COIN/${1}/g" -i "services/${1}-deamon.service"
sed "s/USERNAME/${USER}/g" -i "services/${1}-deamon.service"

echo "Creating explorer service file for ${1}..."
cp services/TEMPLATE-explorer.service services/${1}-explorer.service
sed "s/COIN/${1}/g" -i "services/${1}-explorer.service"
sed "s/USERNAME/${USER}/g" -i "services/${1}-explorer.service"

echo "Copying service files for ${1} to /etc/systemd/system/..."
sudo cp services/${1}-explorer.service /etc/systemd/system/${1}-explorer.service
sudo cp services/${1}-deamon.service /etc/systemd/system/${1}-deamon.service

cd /etc/systemd/system/
sudo systemctl enable ${1}-explorer.service
echo
echo "Deamon service created for ${1}. To run it, use 'sudo systemctl start ${1}-explorer.service'"
echo "Logs will go to ~/logs/${1}_explorer.log"
echo
sudo systemctl enable ${1}-deamon.service
echo "Explorer service created for ${1}."
echo "Edit it with 'sudo nano /etc/systemd/system/${1}-deamon.service' to add launch params and address/pubkey."
echo "To run it, use 'sudo systemctl start ${1}-deamon.service'"
echo "Logs will go to ~/logs/${1}_deamon.log"
echo
