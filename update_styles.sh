#!/bin/bash
echo "Updating logo..."


cp favicon.ico ${1}-explorer/node_modules/insight-ui-komodo/public/img/icons/favicon.ico
cp logo.png ${1}-explorer/node_modules/insight-ui-komodo/public/img/logo.png

echo "Setting currency to $1 and updating coin names..."
sed "s/KMD/${1}/g" -i "${1}-explorer/node_modules/insight-ui-komodo/public/js/main.min.js"
sed "s/Komodo/${1}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/src/js/config.js"
sed "s/Komodo/${1}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/index.html"


echo "Modifying CSS..."
# Background
sed "s/#FFFFFF;/#050810;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#FFFFFF;/#050810;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"
sed "s/#FFF;/#050810;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#FFF;/#050810;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"
echo "Modifying CSS..."
# Background 2 / border
sed "s/#F4F4F4;/#1c1e1c;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#F4F4F4;/#1c1e1c;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"
sed "s/#eee;/#363940;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#eee;/#363940;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Body Text 1
sed "s/#373d42;/#f9fcf9;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#373d42;/#f9fcf9;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Body Text 2
sed "s/#428bca;/#67b9ff;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#428bca;/#67b9ff;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Row background / hover
sed "s/#f9f9f9;/#101416;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#f9f9f9;/#101416;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"
sed "s/#F0F7E2;/#2c2a2c;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#F0F7E2;/#2c2a2c;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Table row borders
sed "s/#ddd;/#353c42;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#ddd;/#353c42;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Header bar / hover
sed "s/#ccded5;/#17191a;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#ccded5;/#17191a;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"
sed "s/#def0f2;/#0f1818;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#def0f2;/#0f1818;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Sub-header bar
sed "s/#def0f2;/#0f1818;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#def0f2;/#0f1818;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Sub-header text
sed "s/#2232c2;/#8084a0;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#2232c2;/#8084a0;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# primary button / border
sed "s/#8DC429;/#346464;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#8DC429;/#346464;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"
sed "s/#76AF0F;/#244242;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#76AF0F;/#244242;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

# Sub-header text
sed "s/#bdc7c2;/#525252;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/#bdc7c2;/#525252;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css"

