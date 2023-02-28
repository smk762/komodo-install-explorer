#!/bin/bash
echo "Updating logo..."

if [ ! -f "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original" ]; then
    echo "Backing up original css..."
    cp "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css" "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original"
    cp "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css" "${1}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css.original"
fi

cp favicon.ico ${1}-explorer/node_modules/insight-ui-komodo/public/img/icons/favicon.ico
cp logo.png ${1}-explorer/node_modules/insight-ui-komodo/public/img/logo.png
cp Horizontal-Light.png ${1}-explorer/node_modules/insight-ui-komodo/public/img/komodoplatform.png

echo "Setting currency to $1 and updating coin names..."
sed "s/KMD/${1}/g" -i "${1}-explorer/node_modules/insight-ui-komodo/public/js/main.min.js"
sed "s/Komodo/${1}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/src/js/config.js"
sed "s/Komodo/${1}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/index.html"


echo "Modifying CSS..."

# footer background
sed "s/#footer{background-color:#373D42;color:#fff;height:51px;overflow:hidden}/#footer{background-color:#1e2124;color:#fff;height:51px;overflow:hidden}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"


# Secondary background
sed "s/.col-gray{-moz-border-radius:5px;-webkit-border-radius:5px;background-color:#F4F4F4;border-radius:5px;padding:14px;border:1px solid #eee}/.col-gray{-moz-border-radius:5px;-webkit-border-radius:5px;background-color:#131416;border-radius:5px;padding:14px;border:1px solid #363940}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"


# Nav bar
sed "s/navbar-default{background-color:#ccded5;margin:0;border:0}/navbar-default{background-color:#151516;margin:0;border:0}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.navbar-nav>.active>a:hover{background-color:#fff;color:#797979}/.navbar-nav>.active>a:hover{background-color:#182c2c;color:#d5d9ed}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"


# Misc
sed "s/#wrap>.container{padding:70px 15px 0}/#wrap>.container{padding:80px 15px 0}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.col-gray-fixed{margin-top:15px;/.col-gray-fixed{margin-top:60px;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.col-gray{/.col-gray{margin-top:60px;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/btn-default{color:#333;background-color:#fff;border-color:#ccc}/btn-default{color:#8a9fae;background-color:#0b1605;border-color:#403f3f}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-size:80px;width:100%/background-size:200px;width:100%/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/a{background-repeat:no-repeat;background-position:center center;display:inline-block;float:left;height:45px}/a{background-repeat:no-repeat;background-position:center center;display:inline-block;float:left;height:54px}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/text-muted{color:#999}/text-muted{color:#e2efef}/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"


# Borders
sed "s/border:2px solid #ccc;/border:2px solid #363940;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:1px solid #eee;/border:1px solid #363940;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:3px solid #FFF;/border:2px solid #363940;/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:2px solid #76AF0F/border:2px solid #192222/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-top:1px solid #eee/border-top:1px solid #555/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-top:1px solid #ddd/border-top:1px solid #555/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-bottom:1px solid #eee/border-bottom:1px solid #555/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-bottom:2px solid #ddd/border-bottom:1px solid #555/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/rgba(255,255,255,.41)/color:rgba(84,84,84,.41)/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"





# Backgrounds
sed "s/color:#333;background-color:#fff/color:#333;background-color:#192328/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#6C9032!important/background-color:#0c3c14/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#346464/background-color:#1f5454/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#def0f2/background-color:#172c2c/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#8DC429/background-color:#194040/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#f9f9f9/background-color:#121212/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#373D42/background-color:#386262/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#F0F7E2/background-color:#0d1814/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#E7E7E7/background-color:#1f5453/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#f4f4f4/background-color:#1f5454/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#f5f5f5/background-color:#1f5455/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#bdc7c2/background-color:#383838/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#fff/background-color:#1e4235/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"


# Text (keep after background color)
sed "s/color:#373D42/color:#4e7c7c/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#428bca/color:#5bd2d3/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#2a6496/color:#0089ff/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#2232c2/color:#85a6a6/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#346464/color:#48a3a3/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#262626/color:#bdbdbd/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#999/color:#48a3a2/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#555/color:#0596ff/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#333/color:#0596fe/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

sed "s/top:63px/color:top:79px/gi" -i "${1}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
