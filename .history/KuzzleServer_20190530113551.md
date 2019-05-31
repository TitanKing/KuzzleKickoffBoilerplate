# Initial Setup

Please see [initial setup](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04).

## Requirements

- Ubuntu 18.04 LTS

`$ sudo apt-get update`

`$ sudo apt install openjdk-8-jdk-headless`

`$ sudo sysctl -w vm.max_map_count=262144` *Todo:* Make this permanent.

`$ sudo apt-get install build-essential && sudo apt-get install gdb`

`$ sudo apt-get install python2.7`

## Installing Nodejs

`$ sudo apt install nodejs`
`$ sudo apt install npm`
`$ sudo npm install -g pm2`

## Installing Redis 3.2.9

Please see [initial setup](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04).

`$ sudo apt-get install redis`

`$ sudo nano /etc/redis/redis.conf`

    Change to `superviced systemd`

`$ sudo systemctl restart redis.service`

`$ sudo systemctl status redis` // Test if running

// Alternative

`$ mkdir redis && cd redis`

`$ wget http://download.redis.io/releases/redis-3.2.9.tar.gz`

`$ tar xzf redis-3.2.9.tar.gz`

`$ cd redis-3.2.9 && make`

`$ cd src/redis-server` // To start server.

## Installing elasticsearch

Please see [initial setup](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-18-04).

`$ wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -`

`$ echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list`

`$ sudo apt update && sudo apt install elasticsearch`

`$ sudo nano /etc/elasticsearch/jvm.options` // To set JVM memory usage.

## Installing kuzzle

Please see [initial setup](https://docs.kuzzle.io/guide/1/essentials/installing-kuzzle/).

## Some useful commands

`$ journalctl -u elasticsearch` *// To see logs on a specific service*