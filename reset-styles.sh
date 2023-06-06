#!/bin/bash

# Get coin name from command line argument or via input
if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

cp "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original" "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
cp "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css.original" "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

cp "${1}-explorer/node_modules/insight-ui-komodo/public/views/index.html.original" "${1}-explorer/node_modules/insight-ui-komodo/public/views/index.html"
cp "${1}-explorer/node_modules/insight-ui-komodo/public/views/status.html.original" "${1}-explorer/node_modules/insight-ui-komodo/public/views/status.html"
