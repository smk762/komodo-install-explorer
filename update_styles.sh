#!/bin/bash
echo "Updating logo..."

cp logo.png ${1}-explorer/node_modules/insight-ui-komodo/public/img/logo.png

echo "Setting currency to $1 and updating coin names..."
sed -i 's/KMD/${1}/g' ${1}-explorer/node_modules/insight-ui-komodo/public/js/main.min.js
sed -i 's/Komodo/${1}/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/src/js/config.js
sed -i 's/Komodo/${1}/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/index.html


echo "Modifying CSS..."
# Background
sed -i 's/#FFFFFF;/#050810;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#FFFFFF;/#050810;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Background 2 / border
sed -i 's/#F4F4F4;/#1c1e1c;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#F4F4F4;/#1c1e1c;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css
sed -i 's/#eee;/#363940;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#eee;/#363940;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Body Text 1
sed -i 's/#373d42;/#f9fcf9;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#373d42;/#f9fcf9;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Body Text 2
sed -i 's/#428bca;/#67b9ff;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#428bca;/#67b9ff;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Row background / hover
sed -i 's/#f9f9f9;/#101416;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#f9f9f9;/#101416;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css
sed -i 's/#F0F7E2;/#2c2a2c;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#F0F7E2;/#2c2a2c;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Table row borders
sed -i 's/#ddd;/#353c42;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#ddd;/#353c42;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Header bar / hover
sed -i 's/#ccded5;/#17191a;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#ccded5;/#17191a;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css
sed -i 's/#def0f2;/#0f1818;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#def0f2;/#0f1818;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Sub-header bar
sed -i 's/#def0f2;/#0f1818;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#def0f2;/#0f1818;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Sub-header text
sed -i 's/#2232c2;/#8084a0;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#2232c2;/#8084a0;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# primary button / border
sed -i 's/#8DC429;/#346464;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#8DC429;/#346464;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css
sed -i 's/#76AF0F;/#244242;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#76AF0F;/#244242;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css

# Sub-header text
sed -i 's/#bdc7c2;/#525252;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css
sed -i 's/#bdc7c2;/#525252;/gi' ${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css
