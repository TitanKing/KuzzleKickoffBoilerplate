#!/bin/bash

echo "------------------------------"
echo "- Install hosting admin      -"
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
  installUtils
  echo -e "${end_of_line}"
  installNode
  echo -e "${end_of_line}"
  installNginx
  echo -e "${end_of_line}"
  adjustingFireWall
  echo -e "${end_of_line}"
  setupDomain
  echo -e "${end_of_line}"
  installCertbot
  echo -e "${end_of_line}"
  generateSSLCertificates
  echo -e "${end_of_line}"
}

function updateAndUpgrade() {
  echo "[🚀] Updating and upgrading repositories and software."

  sudo apt-get update
  sudo apt-get upgrade
}

function installUtils() {
  echo "[⚙️] Installing utilities..."
  sudo apt install git
  sudo apt install build-essential
  sudo apt install gdb
  sudo apt install python2.7
  sudo apt install libkrb5-dev
  sudo apt install libzmq3-dev
  echo "[✅] Utils installed."
}

function installNode() {
  echo "[🐤] Installing Node..."
  # curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
  # sudo bash nodesource_setup.sh

  sudo apt install nodejs
  sudo apt install npm
  # sudo npm install -g pm2

  echo "[✅] Node installed."
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

  cp -rf "${current_dir}/templates/webadmin.nqinx" "${current_dir}"
  sed -i "s/{domain}/${domain}/" "${current_dir}/webadmin.nqinx"
  mv "${current_dir}/webadmin.nqinx" "${domain}"
  sudo mkdir -p /var/www/${domain}
  sudo chown -R $USER:$USER /var/www/${domain}
  sudo chmod -R 755 /var/www/${domain}
  sudo cp -rf "${current_dir}/${domain}" /etc/nginx/sites-available/
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo rm -f /etc/nginx/sites-enabled/${domain}
  sudo ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/
  sudo nginx -t
  sudo systemctl restart nginx
}

function installCertbot() {
  echo "[👮🏻] Installing Certbot..."
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt install python-certbot-nginx
  echo "[✅] Certbot installation complete."
}

function generateSSLCertificates() {
  echo "[💼] Requesting SSL Certificates..."
  sudo certbot --nginx -d ${domain}
  sudo certbot renew --dry-run
  sudo nginx -t
  sudo systemctl restart nginx
  echo "[✅] Certbot setup complete."
}

function includeDependencies() {
    # shellcheck source=./setupLibrary.sh
    echo "[⚡️] Including script vars: ${current_dir}/vars.sh"
    source "${current_dir}/vars.sh"
}

main