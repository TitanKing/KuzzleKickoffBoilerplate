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
  # includeDependencies
  echo -e "${end_of_line}"
  # updateAndUpgrade
  echo -e "${end_of_line}"
  # installNginx
  echo -e "${end_of_line}"
  # adjustingFireWall
  echo -e "${end_of_line}"
  setupDomain
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
  ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'
  echo "[✅] Nginx installed."
}

function adjustingFireWall() {
  echo "[🔥] Setting up UFW Firewall..."
  sudo ufw app list
  sudo ufw allow 'Nginx Full'
  sudo ufw allow 'OpenSSH'
  sudo ufw status
  echo "[✅] Firewall setup."
}

function setupDomain() {
  read -rp "[💥] Enter domain name without www eg. example.com: " domain

  if [[ "$domain" == "" ]]; then
    setupDomain
    echo "[😲] You must enter a domain, you silly you!"
  else
    echo "[👍] Using domain: ${domain}"
  fi

  cp -rf "${current_dir}/templates/reverse.proxy" "${current_dir}"
  sed -i "s/{domain}/${domain}/" "${current_dir}/reverse.proxy"
  mv "${current_dir}/reverse.proxy" "${domain}"

}

function includeDependencies() {
    # shellcheck source=./setupLibrary.sh
    echo "[⚡️] Including script vars: ${current_dir}/vars.sh"
    source "${current_dir}/vars.sh"
}

main