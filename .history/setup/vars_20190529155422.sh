#!/bin/bash

export COMMAND_TO_SYNC="rsync -a -e"
export COMMAND_TO_INSTALL=""
export LOCAL_SERVER_FROM_FOLDER="setup"
export KUZZLE_SERVER_USER="kuzzle"
export KUZZLE_SERVER_PORT="22"
export KUZZLE_SERVER_TO_FOLDER="/home/kuzzle/kuzzle"
export REDIS_PORT="6379"
export REDIS_BIND="127.0.0.1 ::1"
export ELASTIC_HEAP_SIZE="2g"
export ELASTIC_CLUSTER_NAME="kuzzle"
export ELASTIC_HOST="127.0.0.1"
export ELASTIC_PORT="9200"
export KUZZLE_BACKEND_INSTALL_DIR=$KUZZLE_SERVER_TO_FOLDER/server