# Kuzzle Kickoff Boilerplate

a Simple boilerplate to kick start a Kuzzle server with SSL proxy on Ubuntu 18.04
It really does nothing fancy or complex, installs everything like you
would do it manually. Just neatly and tested.

The reason I made this, although the Docker method works, I like to have my stacks pretty simple and
accessible, I also like working on Linux in a more retro way. So I guess this is for the people who likes
less stacking.

This kickstart will get a production server going through an interactive bash terminal;

Full Kuzzle stack;
  - All required utilities
  - Elasticsearch
  - Redis

Optionally can also install;
  - Generate SSL certificates
  - Reverse proxy
  - Setup domain name for Nginx

Optionally can also install;

  - The Kuzzle Admin web service stack
  - Self hosted service
  - Generate SSL certificates
  - Reverse proxy
  - Setup domain name for Nginx

## Prerequisite

- Running Ubuntu 18.04 installation locally or on a VM.
- Have a user with sudo privilege.

You can create a user with sudo privilege with these commands [ON THE SERVER]:

    sudo useradd -m -s /bin/bash -c "Kuzzle Server" -U kuzzle
    sudo usermod -aG sudo kuzzle
    sudo passwd kuzzle
    # DigitalOcean
    rsync --archive --chown=[user]:[user] ~/.ssh /home/[user]

    # [user] is the intended user you just created that will install and run Kuzzle Backend.

## Copy Scripts and SSH keys to [SERVER] from local machine (only here for convenience).

For a successful installation you need to have the installation scripts on the server you
intend Kuzzle backend to run on.

From your local MacOSx or Linux machine;

This script copies the installation scripts and ssh login keys to server.

    git clone https://github.com/TitanKing/KuzzleKickoffBoilerplate.git
    cd KuzzleKickoffBoilerplate
    chmod -x first-upload.sh
    bash first-upload.sh

Now all your scripts are on the server and it will have logged you in.

NOTE: If you are installing from a Windows machine you can just run the commands
directly on the server machine.

## Installing Kuzzle on [SERVER]

NOTE: When entering Elasticsearch heap memory on a small vm instance with 2gb ram,
on a 2gb memory machine enter 512m memory else it will crash with an out of memory
error during installation.

You should be logged into your server now and the installation
scripts is copied to the server.

If you did NOT copy the script from you local machine you can do it directly on the server
from the user account you wish for it to be installed on:

    git clone https://github.com/TitanKing/KuzzleKickoffBoilerplate.git
    cd KuzzleKickoffBoilerplate/setup
    chmod -x install-kuzzle-stack.sh
    ./install-kuzzle-stack.sh

If you have used the first-upload.sh script you just need to run these commands.
Lets continue the installation (assuming install directory is kuzzle);

    cd kuzzle/setup
    ./install-kuzzle-stack.sh

Now follow the prompts carefully. And the installation should finish without errors.

## Optional: Install reverse proxy with encryption

REMEMBER to have SSL generate certificates successfully your domain must ALREADY point to the
server you are installing. Else SSL certificate generation will fail.

If you would like to install a reverse proxy with;

- Secure SSL nqinx server.
- Allows Websockets which Kuzzle operates on through special proxy parameters.
- Auto generate and automatically keep your certificates up to date.

Then simply run `install-kuzzle-ssl-proxy.sh`

## Optional: Install your own Kuzzle web administrator.

Although the Kuzzle team does provide a kuzzle admin that you can use freely, you can also install your own
deployment on your server by running `./install-kuzzle-ssl-webmin.sh` which installs:

- Secure SSL nqinx server.
- Sets up server host block.
- Auto generate and automatically keep your certificates up to date.

## Some side notes.

NOTE 1: All the services installed like Nginx config files will be in its appropriate /etc directory like you
would expect.

## Monitoring Commands

Check elasticsearch logs and services:

    journalctl systemctl -l -u elasticsearch
    sudo systemctl status redis

Check redis status:

    sudo systemctl status redis

## Changin SSH prompts

In general it is a good idea to change the SSH ports as millions of bots tries to log into the standard
port 22, then attempt to forced password attempts.

Edit the file below uncomment and change `# Port 22`

    sudo nano /etc/ssh/sshd_config

After changing the port restart openssh;

    systemctl restart sshd

Check if you are now listening on the correct port.

    netstat -tulpn | grep ssh

Connect to the new port this way:

    ssh -p 22000 192.168.1.100

## Adjusting firewall

Check status:

    ufw status verbose

Some other obvious commands:

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 7513
    ufw enable

Check for listening ports (before firewall blocks)

    sudo netstat -plnt

### Managing the Nginx Process

To stop your web server, type:

    sudo systemctl stop nginx

To start the web server when it is stopped, type:

    sudo systemctl start nginx

To stop and then start the service again, type:

    sudo systemctl restart nginx

If you are simply making configuration changes, Nginx can often reload without dropping connections. To do this, type:

    sudo systemctl reload nginx

By default, Nginx is configured to start automatically when the server boots. If this is not what you want, you can disable this behavior by typing:

    sudo systemctl disable nginx

To re-enable the service to start up at boot, you can type:

    sudo systemctl enable nginx

Also some tests you can run to test it

    ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'

### These articles helped me build this script correctly:

- [Initial Setup](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04).
- [Installing Redis](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04).
- [Installing Elasticsearch](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-18-04).
- [Installing Kuzzle](https://docs.kuzzle.io/guide/1/essentials/installing-kuzzle/)

## Fault finding

### For issue:
Permission denied (publickey)

### Solution:
Some people wondering may have set up ssh access to be key only on the root account then created a new user and not realised they need to

    ssh root@your-ip-address
    rsync --archive --chown=[user]:[user] ~/.ssh /home/[user]
    logout

Then try again. Replace [user] with your new user account.
This is common when setting up a new server on DigitalOcean when you've used ssh-keys on setup.
