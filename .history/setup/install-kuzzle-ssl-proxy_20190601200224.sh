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
  installNginx
  echo -e "${end_of_line}"
  setupDomain
  echo -e "${end_of_line}"
  adjustingFireWall
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
  sudo ufw allow $kuzzle_port
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

  echo "[ℹ️] Remember Kuzzle will listen internally on port 127.0.0.1:7512 - "
  echo "[ℹ️] The port entered here will be the one it will listen for externally - "
  read -rp "[💥] Enter the external port for the kuzzle server [${KUZZLE_LISTENING_PORT}]: " kuzzle_port

  if [[ "$kuzzle_port" == "" ]]; then
    kuzzle_port="${KUZZLE_LISTENING_PORT}"
    echo "[⭐️] Using default port: ${kuzzle_port}"
  else
    echo "[👍] Using port: ${kuzzle_port}"
  fi

  cp -rf "${current_dir}/templates/reverseproxy.nginx" "${current_dir}"
  sed -i "s/{domain}/${domain}/" "${current_dir}/reverseproxy.nginx"
  sed -i "s/{kuzzle_port}/${kuzzle_port}/" "${current_dir}/reverseproxy.nginx"
  mv "${current_dir}/reverseproxy.nqinx" "${domain}"
  # sudo mkdir -p /var/www/${domain}
  # sudo chown -R $USER:$USER /var/www/${domain}
  # sudo chmod -R 755 /var/www/${domain}
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