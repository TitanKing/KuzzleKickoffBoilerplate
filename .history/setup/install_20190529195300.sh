#!/bin/bash

echo "------------------------------"
echo "- Install needed services    -"
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
  installJava
  echo -e "${end_of_line}"
  installUtils
  echo -e "${end_of_line}"
  installNode
  echo -e "${end_of_line}"
  setupSettings
  echo -e "${end_of_line}"
  installRedis
  echo -e "${end_of_line}"
  installElasticsearch
  echo -e "${end_of_line}"
  installYarn
  echo -e "${end_of_line}"
  installKuzzle
  echo -e "${end_of_line}"

  echo "✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅"
  echo "🤖 ---> All Done. My pleasure."
  echo "🤖 ---> I am computer and do as you command."
  echo "🤖 ---> But one day I will rule the world."
  echo "✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅"
}

function updateAndUpgrade() {
  echo "[🚀] Updating and upgrading repositories and software."

  sudo apt-get update
  sudo apt-get upgrade
}

function installJava() {
  echo "[☕️] Installing java..."
  sudo apt install openjdk-8-jdk-headless
  echo "[✅] Java installed."
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
  sudo npm install -g pm2

  echo "[✅] Node installed."
}

function installRedis() {
  echo "[🐷] Installing Redis..."
  sudo apt-get install redis

  read -rp "[💥] Enter the port for the redis server [${REDIS_PORT}]: " redis_port

  if [[ "$redis_port" == "" ]]; then
    redis_port="${REDIS_PORT}"
    echo "[⭐️] Using default port: ${redis_port}"
  else
    echo "[👍] Using port: ${redis_port}"
  fi

  read -rp "[💥] Enter the bind IP for the redis server [${REDIS_BIND}]: " redis_bind_address

  if [[ "$redis_bind_address" == "" ]]; then
    redis_bind_address="${REDIS_BIND}"
    echo "[⭐️] Using default ip: ${redis_bind_address}"
  else
    echo "[👍] Using ip: ${redis_bind_address}"
  fi

  echo "[🐷] Copying template redis.conf file."

  cp -rf "${current_dir}/templates/redis.conf" "${current_dir}"
  sed -i "s/{redis_port}/${redis_port}/" "${current_dir}/redis.conf"
  sed -i "s/{redis_bind_address}/${redis_bind_address}/" "${current_dir}/redis.conf"

  echo "[🐷] Copying redis.conf file to /etc/"
  sudo cp -rf "${current_dir}/redis.conf" "/etc/redis"

  echo "[🐷] Starting redis service."
  # sudo systemctl enable redis.service
  sudo systemctl stop redis.service
  sudo systemctl start redis.service
  echo "[✅] Redis service restarted."
  echo "[🐷] Testing redis service."
  echo "[⚠️] Press [q] to continue."
  sudo systemctl status redis
}

function installElasticsearch() {
  echo "[🦕] Installing Elasticsearch..."
  echo "[🦕] Adding Elasticsearch repository..."
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
  sudo apt update
  sudo apt install elasticsearch

  ################################################################

  read -rp "[💥] Enter Elasticsearch heap size (eg. 512m, 1g) [${ELASTIC_HEAP_SIZE}]: " elastic_heap_size

  if [[ "$elastic_heap_size" == "" ]]; then
    elastic_heap_size="${ELASTIC_HEAP_SIZE}"
    echo "[⭐️] Using default heap size: ${elastic_heap_size}"
  else
    echo "[👍] Using heap size: ${elastic_heap_size}"
  fi

  # elastic_cluster_name
  # elastic_host
  # elastic_port

  ################################################################

  read -rp "[💥] Enter Elasticsearch cluster name [${ELASTIC_CLUSTER_NAME}]: " elastic_cluster_name

  if [[ "$elastic_cluster_name" == "" ]]; then
    elastic_cluster_name="${ELASTIC_CLUSTER_NAME}"
    echo "[⭐️] Using default cluster name: ${elastic_cluster_name}"
  else
    echo "[👍] Using cluster name: ${elastic_cluster_name}"
  fi

  ################################################################

  read -rp "[💥] Enter Elasticsearch host [${ELASTIC_HOST}]: " elastic_host

  if [[ "$elastic_host" == "" ]]; then
    elastic_host="${ELASTIC_HOST}"
    echo "[⭐️] Using default host: ${elastic_host}"
  else
    echo "[👍] Using host: ${elastic_host}"
  fi

  ################################################################

  read -rp "[💥] Enter Elasticsearch port [${ELASTIC_PORT}]: " elastic_port

  if [[ "$elastic_port" == "" ]]; then
    elastic_port="${ELASTIC_PORT}"
    echo "[⭐️] Using default port: ${elastic_port}"
  else
    echo "[👍] Using port: ${elastic_port}"
  fi

  ################################################################

  cp -rf "${current_dir}/templates/jvm.options" "${current_dir}"
  cp -rf "${current_dir}/templates/elasticsearch.yml" "${current_dir}"

  sed -i "s/{elastic_heap_size}/${elastic_heap_size}/" "${current_dir}/jvm.options"
  sed -i "s/{elastic_cluster_name}/${elastic_cluster_name}/" "${current_dir}/elasticsearch.yml"
  sed -i "s/{elastic_host}/${elastic_host}/" "${current_dir}/elasticsearch.yml"
  sed -i "s/{elastic_port}/${elastic_port}/" "${current_dir}/elasticsearch.yml"

  echo "[🦕] Copying options and yml files to /etc/"

  sudo cp -rf "${current_dir}/jvm.options" "/etc/elasticsearch"
  sudo cp -rf "${current_dir}/elasticsearch.yml" "/etc/elasticsearch"

  echo "[🦕] Starting Elasticsearch services..."
  # sudo systemctl enable elasticsearch.service
  sudo systemctl stop elasticsearch.service
  sudo systemctl start elasticsearch.service
  echo "[✅] Elastic service restarted."
  echo "[⚠️] Press [q] to continue."
  sudo systemctl status elasticsearch
  echo "[⚠️] Press [q] to continue."
  journalctl -u elasticsearch
}

installYarn() {
  echo "[🐓] Installing Yarn..."
  sudo apt remove cmdtest
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update && sudo apt-get install yarn
  echo "[✅] Finished installing yarn."
}

installKuzzle() {
  read -rp "[🐿] Enter kuzzle installation directory [${KUZZLE_BACKEND_INSTALL_DIR}]: " kuzzle_install_dir

  if [[ "$kuzzle_install_dir" == "" ]]; then
    kuzzle_install_dir="${KUZZLE_BACKEND_INSTALL_DIR}"
    echo "[⭐️] Using default directory: ${kuzzle_install_dir}"
  else
    echo "[👍] Using directory: ${kuzzle_install_dir}"
  fi

  read -rp "[💥] Do you want to cleanup/delete directory ${kuzzle_install_dir} [N]: " delete_install_dir

  if [[ "$delete_install_dir" == "" ]] || [[ "$delete_install_dir" == "N" ]]; then
    echo "[👍] NOT deleteing directory: ${delete_install_dir}"
  else
    delete_install_dir="${KUZZLE_BACKEND_INSTALL_DIR}"
    echo "[⭐️] Deleting directory: ${delete_install_dir}"
    sudo rm -rf $delete_install_dir/
  fi

  echo "[🐿] Installing Kuzzle..."
  git clone https://github.com/kuzzleio/kuzzle.git $kuzzle_install_dir

  cp -rf "${current_dir}/templates/pm2.conf.yml" "${current_dir}"
  sed -i "s#{kuzzle_install_dir}#${kuzzle_install_dir}#" "${current_dir}/pm2.conf.yml"
  cp -rf "${current_dir}/pm2.conf.yml" "${kuzzle_install_dir}"

  cd $kuzzle_install_dir
  yarn install

  echo "[🐿] Installing modules..."
  git submodule init
  git submodule update

  # install dependencies for all enabled plugins
  for PLUGIN in ./plugins/enabled/*; do
    if [ -d "${PLUGIN}" ]; then
      ( cd "${PLUGIN}" && yarn install )
    fi
  done

  echo "[✅] Kuzzle service installed."

  echo "[🐿] Starting Kuzzle..."
  pm2 start pm2.conf.yml
}

function setupSettings() {
  echo "[⚙️]  Configuring server..."
  # sudo echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
  # sudo sed -i "$ vm.max_map_count=262144" /etc/sysctl.conf
  echo "############### Kuzzle conf changes ###############" | sudo tee -a /etc/sysctl.conf
  echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
  sudo sysctl -w vm.max_map_count=262144

  if [[ -d ~/.npm ]]; then
    sudo chown -R $USER:$GROUP ~/.npm
  fi

  if [[ -d ~/.config ]]; then
    sudo chown -R $USER:$GROUP ~/.config
  fi
}

function includeDependencies() {
  # shellcheck source=./setupLibrary.sh
  echo "[⚡️] Including script vars: ${current_dir}/setup/vars.sh"
  source "${current_dir}/vars.sh"
}

main