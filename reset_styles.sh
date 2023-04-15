#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. You need to add the assetchain ticker as a parameter"
    echo "For example: ./reset_styles.sh MARTY"
    exit 1
fi

cp "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original" "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
cp "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css.original" "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

cp "${1}-explorer/node_modules/insight-ui-komodo/public/views/index.html.original" "${1}-explorer/node_modules/insight-ui-komodo/public/views/index.html"
cp "${1}-explorer/node_modules/insight-ui-komodo/public/views/status.html.original" "${1}-explorer/node_modules/insight-ui-komodo/public/views/status.html"
