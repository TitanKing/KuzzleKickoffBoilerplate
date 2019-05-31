#!/bin/bash

echo "------------------------------"
echo "- Install hosting services   -"
echo "- to have kuzzle running     -"
echo "- on a server.               -"
echo "-                            -"
echo "- Ubuntu 18.04 LTS Required  -"
echo "------------------------------"
echo "- V 1.0.0                    -"
echo "------------------------------"

set -e

function getCurrentDir() {
    local current_dir="${BASH_SOURCE%/*}"
    if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
    echo "${current_dir}"
}

current_dir=$(getCurrentDir)
command_to_run=COMMAND_TO_INSTALL
end_of_line="\n-------------------***-------------------\n"

function main() {
  includeDependencies
  echo -e "${end_of_line}"
  updateAndUpgrade
  echo -e "${end_of_line}"
  adjustingFireWall
  echo -e "${end_of_line}"
  installJava
  echo -e "${end_of_line}"
}

function updateAndUpgrade() {
  echo "[🚀] Updating and upgrading repositories and software."

  sudo apt-get update
  sudo apt-get upgrade
}

function installNginx() {
  echo "[🍄] Installing Nginx..."
  sudo apt install nginx
  systemctl status nginx
  echo "[✅] Java installed."
}

function adjustingFireWall() {
  sudo ufw allow 'Nginx Full'
  sudo ufw status
}

function includeDependencies() {
    # shellcheck source=./setupLibrary.sh
    echo "[⚡️] Including script vars: ${current_dir}/setup/vars.sh"
    source "${current_dir}/setup/vars.sh"
}

main