#!/bin/bash

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

CUR_DIR=$(pwd)
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

echo -e "$STEP_START[ * ]$STEP_END Backing up old styles for ${coin}..."
if [ ! -f "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original" ]; then
    echo "Backing up original css..."
    cp "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css" "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css.original"
    cp "${coin}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css" "${coin}-explorer/node_modules/insight-ui-komodo/public/css/common.min.css.original"
fi
if [ ! -f "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html.original" ]; then
    echo "Backing up original css..."
    cp "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html" "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html.original"
    cp "${coin}-explorer/node_modules/insight-ui-komodo/public/views/status.html" "${coin}-explorer/node_modules/insight-ui-komodo/public/views/status.html.original"
fi

echo -e "$STEP_START[ * ]$STEP_END Creating logo and favicon for ${coin}..."
if [ -f "logos/${coin}-logo.png" ]; then
    echo "${coin} logo already exists, skipping..."
else
    echo "Downloading ${coin} logo..."
    cd logos
    coin_lower=$(echo "$coin" | awk '{print tolower($0)}');
    wget https://raw.githubusercontent.com/KomodoPlatform/coins/master/icons/${coin_lower}.png -O ${coin}-logo.png
    cd ..
fi
if [ -f "logos/${coin}-favicon.ico" ]; then
    echo "${coin} favicon already exists, skipping..."
else
    echo "Creating ${coin} favicon..."
    cd logos
    ./make_favicon.sh ${coin}
    cd ..
fi


echo -e "$STEP_START[ * ]$STEP_END Updating logos..."
# TODO: try and download the logos from the coins repo and generate the favicon.ico and resized logo.png
cp logos/${coin}-favicon.ico ${coin}-explorer/node_modules/insight-ui-komodo/public/img/icons/favicon.ico
cp logos/${coin}-logo.png ${coin}-explorer/node_modules/insight-ui-komodo/public/img/logo.png
cp logos/Horizontal-Light.png ${coin}-explorer/node_modules/insight-ui-komodo/public/img/komodoplatform.png

echo -e "$STEP_START[ * ]$STEP_END Setting currency to $1 and updating coin names..."
sed "s/KMD/${coin}/g" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/js/main.min.js"
sed "s/Komodo/${coin}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/src/js/config.js"
sed "s/Komodo/${coin}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/index.html"
sed "s|<h2 translate>Komodo node information</h2>|<h2 translate style='margin-top: 5px;'>${coin} node information</h2>|gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/views/status.html"
sed 's|<a class="twitter-timeline" href="https://twitter.com/KomodoPlatform">Tweets by KomodoPlatform</a>|<ul style="display: flex; justify-content:space-evenly; padding:0; margin-top:20px; margin-bottom:0px; width:60%; margin-left: auto; margin-right: auto;"><li style="list-style: none;"><a class="social-links" style="list-style-type: none;" href="https://twitter.com/KomodoPlatform"><svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-twitter" viewBox="0 0 16 16"><path d="M5.026 15c6.038 0 9.341-5.003 9.341-9.334 0-.14 0-.282-.006-.422A6.685 6.685 0 0 0 16 3.542a6.658 6.658 0 0 1-1.889.518 3.301 3.301 0 0 0 1.447-1.817 6.533 6.533 0 0 1-2.087.793A3.286 3.286 0 0 0 7.875 6.03a9.325 9.325 0 0 1-6.767-3.429 3.289 3.289 0 0 0 1.018 4.382A3.323 3.323 0 0 1 .64 6.575v.045a3.288 3.288 0 0 0 2.632 3.218 3.203 3.203 0 0 1-.865.115 3.23 3.23 0 0 1-.614-.057 3.283 3.283 0 0 0 3.067 2.277A6.588 6.588 0 0 1 .78 13.58a6.32 6.32 0 0 1-.78-.045A9.344 9.344 0 0 0 5.026 15z"></path></svg></a></li><li style="list-style: none;"><a class="social-links" style="list-style-type: none;" href="https://www.github.com/KomodoPlatform"><svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-github" viewBox="0 0 16 16"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg></a></li><li style="list-style: none;"><a class="social-links" style="list-style-type: none;" href="https://t.me/KomodoPlatform_Official"><svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-telegram" viewBox="0 0 16 16"><path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.287 5.906c-.778.324-2.334.994-4.666 2.01-.378.15-.577.298-.595.442-.03.243.275.339.69.47l.175.055c.408.133.958.288 1.243.294.26.006.549-.1.868-.32 2.179-1.471 3.304-2.214 3.374-2.23.05-.012.12-.026.166.016.047.041.042.12.037.141-.03.129-1.227 1.241-1.846 1.817-.193.18-.33.307-.358.336a8.154 8.154 0 0 1-.188.186c-.38.366-.664.64.015 1.088.327.216.589.393.85.571.284.194.568.387.936.629.093.06.183.125.27.187.331.236.63.448.997.414.214-.02.435-.22.547-.82.265-1.417.786-4.486.906-5.751a1.426 1.426 0 0 0-.013-.315.337.337 0 0 0-.114-.217.526.526 0 0 0-.31-.093c-.3.005-.763.166-2.984 1.09z"/></svg></a></li><li style="list-style: none;"><a class="social-links" style="list-style-type: none;" href="https://komodoplatform.com/discord"><svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-discord" viewBox="0 0 16 16"><path d="M13.545 2.907a13.227 13.227 0 0 0-3.257-1.011.05.05 0 0 0-.052.025c-.141.25-.297.577-.406.833a12.19 12.19 0 0 0-3.658 0 8.258 8.258 0 0 0-.412-.833.051.051 0 0 0-.052-.025c-1.125.194-2.22.534-3.257 1.011a.041.041 0 0 0-.021.018C.356 6.024-.213 9.047.066 12.032c.001.014.01.028.021.037a13.276 13.276 0 0 0 3.995 2.02.05.05 0 0 0 .056-.019c.308-.42.582-.863.818-1.329a.05.05 0 0 0-.01-.059.051.051 0 0 0-.018-.011 8.875 8.875 0 0 1-1.248-.595.05.05 0 0 1-.02-.066.051.051 0 0 1 .015-.019c.084-.063.168-.129.248-.195a.05.05 0 0 1 .051-.007c2.619 1.196 5.454 1.196 8.041 0a.052.052 0 0 1 .053.007c.08.066.164.132.248.195a.051.051 0 0 1-.004.085 8.254 8.254 0 0 1-1.249.594.05.05 0 0 0-.03.03.052.052 0 0 0 .003.041c.24.465.515.909.817 1.329a.05.05 0 0 0 .056.019 13.235 13.235 0 0 0 4.001-2.02.049.049 0 0 0 .021-.037c.334-3.451-.559-6.449-2.366-9.106a.034.034 0 0 0-.02-.019Zm-8.198 7.307c-.789 0-1.438-.724-1.438-1.612 0-.889.637-1.613 1.438-1.613.807 0 1.45.73 1.438 1.613 0 .888-.637 1.612-1.438 1.612Zm5.316 0c-.788 0-1.438-.724-1.438-1.612 0-.889.637-1.613 1.438-1.613.807 0 1.451.73 1.438 1.613 0 .888-.631 1.612-1.438 1.612Z"/></svg></a></li></ul>|gi' -i "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html"
sed "s|<h2 translate>What is Komodo?</h2>|<h2 style='margin-top: 5px' translate>What is Komodo?</h2>|gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/views/index.html"

echo -e "$STEP_START[ * ]$STEP_END Updating CSS files..."
# Footer background
sed "s/#footer{background-color:#373D42;color:#fff;height:51px;overflow:hidden}/#footer{background-color:#1e2124;color:#fff;height:51px;overflow:hidden}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Secondary background
sed "s/.col-gray{-moz-border-radius:5px;-webkit-border-radius:5px;background-color:#F4F4F4;border-radius:5px;padding:14px;border:1px solid #eee}/.col-gray{-moz-border-radius:5px;-webkit-border-radius:5px;background-color:#131416;border-radius:5px;padding:14px;border:1px solid #363940}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Nav bar
sed "s/navbar-default{background-color:#ccded5;margin:0;border:0}/navbar-default{background-color:#151516;margin:0;border:0}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.navbar-nav>.active>a:hover{background-color:#fff;color:#797979}/.navbar-nav>.active>a:hover{background-color:#182c2c;color:#d5d9ed}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Misc
sed "s/#wrap>.container{padding:70px 15px 0}/#wrap>.container{padding:80px 15px 0}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.col-gray-fixed{margin-top:15px;/.col-gray-fixed{margin-top:60px;/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.col-gray{/.col-gray{margin-top:60px;/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/btn-default{color:#333;background-color:#fff;border-color:#ccc}/btn-default{color:#8a9fae;background-color:#0b1605;border-color:#403f3f}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-size:80px;width:100%/background-size:200px;width:100%/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/a{background-repeat:no-repeat;background-position:center center;display:inline-block;float:left;height:45px}/a{background-repeat:no-repeat;background-position:center center;display:inline-block;float:left;height:54px}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/text-muted{color:#999}/text-muted{color:#e2efef}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/txvalues-not-notarized{background-color:#e9c85e}/txvalues-not-notarized{background-color:#0c2336}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/txvalues-success{background:0;color:#2FA4D7}/txvalues-success{background:0;color:#00a4c9}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/txvalues-default{background-color:#EBEBEB;color:#333}/txvalues-default{background-color:#103232;color:#eaf2f7}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/txvalues-success{background-color:#2FA4D7}/txvalues-success{background-color:#004802}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/panel-body{padding:.7em;word-wrap:break-word}/panel-body{padding:.7em;word-wrap:break-word;color:#e2efef;}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/block-tx{-moz-border-radius:2px;-webkit-border-radius:2px;background-color:#F4F4F4;border-radius:2px;margin:20px 0 10px;overflow:hidden;padding:15px;border:1px solid #eee}/block-tx{-moz-border-radius:2px;-webkit-border-radius:2px;background-color:#081212;border-radius:2px;margin:20px 0 10px;overflow:hidden;padding:15px;border:1px solid #363940}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/well{min-height:20px;padding:19px;margin-bottom:20px;background-color:#f5f5f5;border:1px solid #e3e3e3;border-radius:4px;-webkit-box-shadow:inset 0 1px 1px rgba(0,0,0,.05);box-shadow:inset 0 1px 1px rgba(0,0,0,.05)}/well{min-height:20px;padding:19px;margin-bottom:20px;background-color:#002020;border:1px solid #5e5e5e;border-radius:4px;-webkit-box-shadow:inset 0 1px 1px rgba(0,0,0,.05);box-shadow:inset 0 1px 1px rgba(0,0,0,.05)}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/.text-success{color:#3c763d}/.text-success{color:#25a728}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/btn-expand:hover{color:#000;text-decoration:none}/btn-expand:hover{color:#6fa787;text-decoration:none}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/panel-default{border-color:#ddd}/panel-default{border-color:#363636}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/line-bot{border-bottom:2px solid #EAEAEA;padding:0 0 10px}/line-bot{border-bottom:2px solid #0c2a26;padding:0 0 10px}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/line-top{border-top:1px solid #EAEAEA;padding:15px 0 0}/line-top{border-top:1px solid #0c2a26;padding:15px 0 0}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Borders
sed "s/border:1px solid #eee}/border:1px solid #363940}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:2px solid #ccc;/border:2px solid #363940;/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:1px solid #eee;/border:1px solid #363940;/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:3px solid #FFF;/border:2px solid #363940;/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border:2px solid #76AF0F/border:2px solid #192222/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-top:1px solid #eee/border-top:1px solid #555/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-top:1px solid #ddd/border-top:1px solid #555/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-bottom:1px solid #eee/border-bottom:1px solid #555/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/border-bottom:2px solid #ddd/border-bottom:1px solid #555/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/rgba(255,255,255,.41)/color:rgba(84,84,84,.41)/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/secondary_navbar{width:100%;background:#fff;position:fixed;top:64px;left:0;text-align:center;z-index:1000;margin:0 auto;-moz-box-shadow:0 1px 4px 0 rgba(0,0,0,.20);-webkit-box-shadow:0 1px 4px 0 rgba(0,0,0,.20);box-shadow:0 1px 4px 0 rgba(0,0,0,.20)}/secondary_navbar{width:100%;background:#fff;position:fixed;top:80px;left:0;text-align:center;z-index:1000;margin:0 auto;-moz-box-shadow:0 1px 4px 0 rgba(0,0,0,.20);-webkit-box-shadow:0 1px 4px 0 rgba(0,0,0,.20);box-shadow:0 1px 4px 0 rgba(0,0,0,.20)}/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

#txvalues{display:inline-block;padding:.7em 2em;font-size:13px;text-transform:uppercase;font-weight:100;color:#fff;text-align:center;white-space:nowrap;vertical-align:baseline;border-radius:.25em}
#txvalues-primary{background-color:#8DC429}
#txvalues-default{background-color:#EBEBEB;color:#333}
#txvalues-success{background-color:#2FA4D7}
#txvalues-not-notarized{background-color:#e9c85e}
#txvalues-danger{background-color:#AC0015}
#txvalues-normal{background-color:transparent;text-transform:none;color:#333;font-size:14px;font-weight:400}

# Backgrounds
sed "s/color:#333;background-color:#fff/color:#333;background-color:#192328/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#6C9032!important/background-color:#0c3c14/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#346464/background-color:#1f5454/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#def0f2/background-color:#172c2c/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#8DC429/background-color:#194040/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Row shading
#sed "s/background-color:#f9f9f9/background-color:#121212/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#f9f9f9/background-color:#202b30/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Row shading hover
sed "s/background-color:#F0F7E2/background-color:#1b2e36/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#373D42/background-color:#386262/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#E7E7E7/background-color:#1f5453/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#f4f4f4/background-color:#1f5454/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#f5f5f5/background-color:#1f5455/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#bdc7c2/background-color:#383838/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background-color:#fff/background-color:#0c2a26/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/background:#fff/background:#0c2a26/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# Text (after background color)
sed "s/color:#373D42/color:#84b4b4/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#428bca/color:#25bbbb/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

# hyperlink hover
sed "s/color:#2a6496/color:#2ae9be/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#2232c2/color:#85a6a6/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#346464/color:#48a3a3/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#262626/color:#bdbdbd/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#999/color:#48a3a2/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#555/color:#25bbba/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/color:#333/color:#25bbbc/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"
sed "s/top:63px/color:top:79px/gi" -i "${coin}-explorer/node_modules/insight-ui-komodo/public/css/main.min.css"

echo -e "$STEP_START[ * ]$STEP_END Done! To undo these changes, run $STEP_START ./reset-styles.sh $STEP_END"
