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