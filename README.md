# Install a Block Explorer for a Komodo Smart Chain

This repository simply modifies Decker's script from https://github.com/DeckerSU/komodo-explorers-install to work for a individual Smart Chains.


## Instructions

This branch and others with similar name are intended to be used as sumbodules in https://github.com/smk762/notary_docker_main
These are grouped into docker containers, and launched with docker-compose.
There are a few branches to spread the load, each with a branch name like `notary-explorer-group-NUMBER` in this repo, with an accompanying branch with the same name in https://github.com/smk762/notary_docker_main

### Explorer installation

- Stop the Smart Chain you want to add an explorer for (if it is running).
- Clone this repository in your home directory and navigate into it.

```bash
cd ~
git clone https://github.com/smk762/komodo-install-explorer -b ${BRANCH_NAME} # replace ${BRANCH_NAME} with the branch name for the explorer group you want to use
cd komodo-install-explorer
```

- Run the script: `./setup-explorer-directory.sh` to install Insight Explorer dependencies. It should create a subdirectory named `node_modules`.
- Run the script: `./install-explorer.sh TICKER` with the Smart Chain's name as the argument. This will:
  - Install a bitcore node for your TICKER.
  - Create a `TICKER-webaccess` file with the Smart Chain's name and the url to access the explorer from the internet. 
  - Create a `TICKER-explorer` subfolder to contain the Insight API and Insight UI files.
  - Configure the Insight API and UI to use the Smart Chain's daemon.
  - Create a `TICKER-explorer-start.sh` script to use for launching the explorer.
  - Create a daemon config file for the Smart Chain.
  - Create and enable (but not start) systemd service files for the explorer and the Smart Chain daemon.
  - Apply a patch to show notarisations in the Insight UI.
- Next, restart the Smart Chain daemon. Once the daemon is ready for RPC calls, run `./TICKER-explorer-start.sh` to manually start the explorer.


#### Optional Extras

- To run additional explorers for other Smart Chains, repeat the above steps with a different Smart Chain ticker. Port mapping will automatically increment for each subsequent explorer.
- To remove an explorer, run `./configure.py remove TICKER`. This will remove the explorer's directory, launch script and the webaccess file. You will need to manually remove filewall rules, the nginx serverblock and systemd service files (if used).
- Use the `noweb` option like so: `./install-explorer.sh TICKER noweb` if you intend to only run the explorer locally (i.e. not on the public internet)
- To generate SSL certificates for running the explorer on the public internet, run `./setup-ssl.sh TICKER your.domain.com`. This will:
  - Creat an NGINX serverblock file.
  - Create a sumbolic link from this file to the "/etc/nginx/sites-enabled" folder
  - Restart NGINX.

#### User Interface Customisation

The Insight UI code is located in `TICKER-explorer/node_modules/insight-ui-komodo`.
For convenience, you can use these scripts for quick theme updates:
- `./update-styles.sh` will update logos, the currency variable and css colors.
- `./reset-styles.sh` will return the theme to default.

To further customise the UI, refer to the code within `./update-styles.sh` to change colors, or see which files and css selectors to edit. This script is run automatically when you install an explorer, but it you modify it it will need to run it again for changes to take effect.

#### TODO
- Run `./setup-docker.sh` to configure a daemon, insight explorer and electrumx server to run in docker containers.
- For electrums (long term, the docker container should manage the daemon, insight explorer and electrumx server):
  - sudo cp ~/electrumx-1/contrib/systemd/electrumx.service /etc/systemd/system/electrumx_KMD.service
  - sudo nano /etc/systemd/system/electrumx_KMD.service

