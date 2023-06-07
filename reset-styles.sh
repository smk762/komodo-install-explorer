#!/bin/bash

# Get coin name from command line argument or via input
if [[ -z ${coin} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

cp "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original" "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
cp "${coin}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css.original" "${coin}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

cp "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html.original" "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html"
cp "${coin}-explorer/node_modules/insight-ui-komodo/public/views/status.html.original" "${coin}-explorer/node_modules/insight-ui-komodo/public/views/status.html"
