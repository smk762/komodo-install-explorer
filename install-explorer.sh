#!/bin/bash

#
# (c) Decker, 2018; Modified by smk 2023
#

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=${1}
fi

if [[ -z ${2} ]]; then
    noweb=${2}
else
    noweb="yesweb"
fi

CUR_DIR=$(pwd)
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

echo -e "$STEP_START[ * ]$STEP_END Stopping ${coin} daemon..."
komodo-cli -ac_name=${coin} stop

echo -e "$STEP_START[ * ]$STEP_END Loading NVM and Node 4..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm use v4

echo -e "$STEP_START[ * ]$STEP_END Installing Bitcore node for $coin..."
if [ ! -d "${HOME}/notary_docker_main/komodo-install-explorer/${coin}-explorer" ]; then
  mkdir -p node_modules
  $CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create ${coin}-explorer
fi

echo -e "$STEP_START[ * ]$STEP_END Installing Insight API and Insight UI for $coin..."
if [ ! -d "${HOME}/notary_docker_main/komodo-install-explorer/${coin}-explorer/node_modules/insight-api-komodo" ]; then
  cd ${coin}-explorer
  $CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
  cd $CUR_DIR
fi

echo -e "$STEP_START[ * ]$STEP_END Configuring explorer for $coin..."
./configure.py create_explorer_conf ${coin}
./configure.py create_webaccess ${coin} $noweb

echo -e "$STEP_START[ * ]$STEP_END Creating systemd service files for $coin..."
./configure.py create_services $coin

echo "Copying service files for ${coin} to /etc/systemd/system/..."
sudo cp services/$coin-explorer.service /etc/systemd/system/$coin-explorer.service
sudo cp services/$coin-daemon.service /etc/systemd/system/$coin-daemon.service
cd /etc/systemd/system/
sudo systemctl enable $coin-explorer.service
echo
echo "daemon service created for $coin."
echo "To run it, use 'sudo systemctl start $coin-explorer.service'"
echo "Logs will go to ~/logs/${coin}-explorer.log"
echo
sudo systemctl enable $coin-daemon.service
echo "Explorer service created for $coin."
echo "To run it, use 'sudo systemctl start $coin-daemon.service'"
echo "Logs will go to ~/logs/${coin}-daemon.log"
echo

cd $CUR_DIR
echo -e "$STEP_START[ * ]$STEP_END Patching the installation to display notarization data..."
if [ ! -d "$CUR_DIR/explorer-notarized" ]; then
  echo -e "$STEP_START[ * ]$STEP_END Cloning the repository cointaining the notarisation patch"
  echo 
  success=0
  count=1
  while [ $success -eq 0 ]; do
    echo "[Try $count] Cloning the explorer installer repository"
    git clone https://github.com/gcharang/explorer-notarized && success=1 || success=0
    sleep 4
    count=$((count+1))
  done
else
  echo "A directory named 'explorer-notarized' already exists; assuming it is cloned from the repo: https://github.com/gcharang/explorer-notarized , trying to update and patch the explorer using it"
  cd $CUR_DIR/explorer-notarized
  git pull
fi
cd $CUR_DIR/explorer-notarized
./patch.sh ${coin}

echo -e "$STEP_START[ * ]$STEP_END Updating Insight UI styles and logos for ${coin}..."
cd $CUR_DIR/
./update-styles.sh "${coin}"

launch=$(./configure.py get_launch_params "${coin}")

echo -e "Done! The next steps are optional..."
echo -e "To generate SSL certificates, run $STEP_START ./setup-ssl.sh $STEP_END"
echo -e "To generate an NGINX serverblock config, run $STEP_START ./configure.py create_nginx_conf ${coin} $STEP_END"
echo -e "To start the explorer, run $STEP_START ./start-explorer.sh ${coin} $STEP_END "
echo -e "Dont forget to relaunch the ${coin} daemon with the following launch parameters:"
echo -e $STEP_START $launch $STEP_END
