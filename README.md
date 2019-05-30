# Kuzzle Kickoff Boilerplate

a Simple boilerplate to kick start a Kuzzle instance on Ubuntu 18.04

This kickstart will get a production server going through an interactive bash terminal;

Full Kuzzle stack;
  - All required utilities
  - Elasticsearch
  - Redis

Optionally can also install;
  - Generate SSL certificates
  - Reverse proxy
  - Setup domain name

## Prerequisite

- Running Ubuntu 18.04 installation locally or on a VM.
- Have a user with sudo privilage.

You can create a user with sudo privilage with these commands [ON THE SERVER]:

    sudo useradd -m -s /bin/bash -c "Kuzzle Server" -U kuzzle
    sudo usermod -aG sudo kuzzle
    sudo passwd kuzzle

## Installing Kuzzle

For a supposed successful installation follow these instructions.

From your local MacOSx or Linux machine;

This script copies the installation scripts and ssh login keys to server.

    git clone https://github.com/TitanKing/KuzzleKickoffBoilerplate.git
    cd KuzzleKickoffBoilerplate
    chmod -x first-upload.sh
    ./first-upload.sh

Now all your scripts are on the server and it will have logged your right in.

NOTE: If you are installing from a windows machine you can just run the commands
directly on the server machine.


## Requirements



## Monitorting Commands

Check elasticsearch logs and services:

    journalctl systemctl -l -u elasticsearch
    sudo systemctl status redis

Check redis status:

    sudo systemctl status redis