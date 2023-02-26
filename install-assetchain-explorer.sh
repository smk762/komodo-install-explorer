#!/bin/bash

#
# (c) Decker, 2018
#

if [ $# -eq 0 ]; then
    echo "No arguments provided. You need to add the assetchain ticker as a parameter"
    echo "For example: ./install-assetchain-explorer.sh TOKEL"
    exit 1
fi

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

ac=$1

CUR_DIR=$(pwd)
echo "Installing an explorer for $ac in the current directory: $CUR_DIR"

declare -a kmd_coins=$ac

$zmqport
rpcip=${KMD_RPCIP:-"127.0.0.1"}
rpcuser=${KMD_RPCUSER:-rpc_username}
rpcpassword=${KMD_RPCPASS:-rpc_password}
rpcport=${KMD_RPCPORT:-7000}
zmqport=$((rpcport+2))
webport=${EXPLORER_PORT:-8090}

rm $conf_path
mkdir -p $conf_dir
touch $conf_path
cat <<EOF > $conf_path
    server=1
    whitelist=$rpcip
    txindex=1
    addressindex=1
    timestampindex=1
    spentindex=1
    zmqpubrawtx=tcp://$rpcip:$zmqport
    zmqpubhashblock=tcp://$rpcip:$zmqport
    rpcallowip=$rpcip
    rpcport=$rpcport
    rpcuser=$rpcuser
    rpcpassword=$rpcpassword
    uacomment=bitcore
    showmetrics=0
    rpcworkqueue=256
EOF

echo -e "$STEP_START[ * ]$STEP_END Installing explorer for $ac"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm use v4

$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create ${ac}-explorer
cd ${ac}-explorer
$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
cd $CUR_DIR

cat << EOF > $CUR_DIR/${ac}-explorer/bitcore-node.json
{
  "network": "mainnet",
  "port": $webport,
  "services": [
    "bitcoind",
    "insight-api-komodo",
    "insight-ui-komodo",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "connect": [
        {
          "rpchost": "$rpcip",
          "rpcport": $rpcport,
          "rpcuser": "$rpcuser",
          "rpcpassword": "$rpcpassword",
          "zmqpubrawtx": "tcp://$rpcip:$zmqport"
        }
      ]
    },
  "insight-api-komodo": {
    "rateLimiterOptions": {
      "whitelist": ["::ffff:$rpcip","$rpcip"],
      "whitelistLimit": 500000,
      "whitelistInterval": 3600000
    }
  }
  }
}

EOF

# creating launch script for explorer
cat << EOF > $CUR_DIR/${ac}-explorer-start.sh
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
cd ${ac}-explorer
nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start
EOF
chmod +x ${ac}-explorer-start.sh

ip=$(curl ifconfig.me)

echo -e "$STEP_START[ * ]$STEP_END Execute ${ac}-explorer-start.sh to start the explorer"
if [ $# -eq 2 ]; then
  if [ "$2" = "noweb" ]; then
    echo "The webport hasn't been opened; To access the explorer through the internet, open the port: $webport by executing the command 'sudo ufw allow $webport' "
    touch ${ac}-webaccess
    echo "url=http://localhost:$webport" >> ${ac}-webaccess
    echo "webport=$webport" >> ${ac}-webaccess
  fi
else
  echo -e "$STEP_START[ * ]$STEP_END Visit http://$ip:$webport from another computer to access the explorer after starting it"
  touch ${ac}-webaccess
  echo "url=http://$ip:$webport" >> ${ac}-webaccess
  echo "webport=$webport" >> ${ac}-webaccess
fi
echo -e "$STEP_START[ * ]$STEP_END Visit http://localhost:$webport on your computer to access the explorer after starting it"

echo "Patching the installation to display notarization data"

if [ ! -d "$CUR_DIR/explorer-notarized" ]; then
  echo "Cloning the repository cointaining the patch"
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
./patch.sh ${ac}
