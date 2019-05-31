#!/bin/bash

# First make this file executable.
# $ chmod +x first-upload.sh
# ssh -t username@192.168.0.118 'bash -s' < run.sh
# rsync -a ~/dir1 username@remote_host:destination_directory

# export SUDO_ASKPASS=/usr/libexec/openssh/ssh-askpass

echo "------------------------------"
echo "- This script simply copies  -"
echo "- all kuzzle setup files to  -"
echo "- remote server to run.      -"
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
command_to_run=COMMAND_TO_SYNC
end_of_line="\n-------------------***-------------------\n"

function main() {
  includeDependencies

  requestPort
  echo -e "${end_of_line}"

  requestFromFolder
  echo -e "${end_of_line}"

  requestUser
  echo -e "${end_of_line}"

  requestIP
  echo -e "${end_of_line}"

  requestToFolder
  echo -e "${end_of_line}"

  copyScript
  echo -e "${end_of_line}"

  copySslCertificate
  echo -e "${end_of_line}"

  requestSSHLogin
  echo -e "${end_of_line}"

  echo "✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅"
  echo "🤖 ---> All Done. My pleasure."
  echo "🤖 ---> I am computer and do as you command."
  echo "🤖 ---> But one day I will rule the world."
  echo "✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅"
}

# sudo apt-get update
function requestPort() {
  read -rp "[💥] Enter the ssh port of remote server [${KUZZLE_SERVER_PORT}]: " port

  if [[ "$port" == "" ]]; then
    port="${KUZZLE_SERVER_PORT}"
    echo "[⭐️] Using default port: ${port}"
  else
    echo "[👍] Using port: ${port}"
  fi

  echo "[📌] ${COMMAND_TO_SYNC} ${port}' "${current_dir}/${LOCAL_SERVER_FROM_FOLDER}" username@192.168.0.118:/home/username"
}

function requestFromFolder() {
  echo "[📌] ${COMMAND_TO_SYNC} \"ssh -p 22\" username@192.168.0.118:/home/username"
  read -rp "[💥] Enter local folder (to copy from) [${current_dir}/${LOCAL_SERVER_FROM_FOLDER}]: " from_folder

  if [[ "$from_folder" == "" ]]; then
    from_folder="${current_dir}/${LOCAL_SERVER_FROM_FOLDER}"
    echo "[⭐️] Using default from folder: ${from_folder}"
  else
    echo "[👍] From folder: ${from_folder}"
  fi

  echo "[📌] ${COMMAND_TO_SYNC} \"ssh -p 22\" \"${from_folder}\" username@192.168.0.118:/home/username"
}

function requestUser() {
  read -rp "[💥] Enter the username of remote server (to copy to) [${KUZZLE_SERVER_USER}]: " username

  if [[ "$username" == "" ]]; then
    username="${KUZZLE_SERVER_USER}"
    echo "[⭐️] Using default username: ${username}"
  else
    echo "[👍] Using username: ${username}"
  fi

  echo "[📌] ${COMMAND_TO_SYNC} \"ssh -p ${port}\" \"${from_folder}\" ${username}@192.168.0.118:/home/username"
}

function requestIP() {
  read -rp "[💥] Enter the ip of remote server: " ip

  if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    requestIP
  fi

  echo "[📌] ${COMMAND_TO_SYNC} \"ssh -p ${port}\" \"${from_folder}\" ${username}@${ip}:/home/username"
}

function requestToFolder() {
  read -rp "[💥] Enter the folder location of remote server (to copy to) [${KUZZLE_SERVER_TO_FOLDER}]: " to_folder

  if [[ "$to_folder" == "" ]]; then
    to_folder="${KUZZLE_SERVER_TO_FOLDER}"
    echo "[⭐️] Using default to folder: ${to_folder}"
  else
    echo "[👍] Using to folder: ${to_folder}"
  fi

    echo "[📌] ${COMMAND_TO_SYNC} \"ssh -p ${port}\" \"${from_folder}\" ${username}@${ip}:${to_folder}"
}

function copyScript() {
  echo "[🎁] ---> Will now copy setup scripts to server."
  compiled_sync_command="${COMMAND_TO_SYNC} \"ssh -p ${port}\" \"${from_folder}\" ${username}@${ip}:${to_folder}"
  echo "[⚡️] Lets run: ${compiled_sync_command}"
  chmod +x "${current_dir}/${LOCAL_SERVER_FROM_FOLDER}/install-kuzzle-ssl-proxy.sh"
  chmod +x "${current_dir}/${LOCAL_SERVER_FROM_FOLDER}/install-kuzzle-ssl-webmin.sh"
  chmod +x "${current_dir}/${LOCAL_SERVER_FROM_FOLDER}/install-kuzzle-stack.sh"
  eval $compiled_sync_command
  echo "[🎁 ✅] ---> Uploaded setup scripts."
}

function copySslCertificate() {
  read -rp "[🔑] Would you like to copy SSH keys to ${username}@${ip} [Y]: " ssh_key_copy

  if [[ "$ssh_key_copy" == "" ]] || [[ "$ssh_key_copy" == "Y" ]]; then
    echo "[🔑 ✅] Ok done copying SSH keys."
    eval $login
  else
    echo "[⚠️] Ok, did NOT copy SSH key."
  fi

  ssh-copy-id -p $port $username@$ip
}

function requestSSHLogin() {
  login="ssh -p ${port} ${username}@${ip}"
  echo "[ℹ️] Now that we are such good friends, do you want to login to kuzzle server?"
  echo "[ℹ️]  Once you are logged in just run ${to_folder}/install.sh"
  read -rp "[🌱] So what will it be, login to ${login} [Y]: " ssh_login

  if [[ "$ssh_login" == "" ]]; then
    echo "[👍] Cheers, see you on the other side."
    eval $login
  else
    echo "[🦋] Bye, all copying is done. Log in and run .${to_folder}/install.sh"
    exit
  fi
}

function includeDependencies() {
    # shellcheck source=./setupLibrary.sh
    echo "[⚡️] Including script vars: ${current_dir}/setup/vars.sh"
    source "${current_dir}/setup/vars.sh"
}

main