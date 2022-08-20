#!/bin/bash

sudo su
apt update

sudo apt-get install apt-transport-https
sudo apt install -y postgresql postgresql-contrib wget rsync unzip gnupg python3-pip



sudo mkdir -p /mnt/disks/sdb
# sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-ssd1
# sudo mount -o discard,defaults /dev/disk/by-id/google-ssd1 /mnt/disks/sdb
# sudo chmod a+w /mnt/disks/sdb


# mongo start
chmod -R 777 /tmp  # mongo got permission error for some reason
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt update
apt install mongodb-org -y


cd /tmp
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
apt update
apt install elasticsearch -y 
pip3 install elasticsearch

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo systemctl status elasticsearch.service

wget https://gist.githubusercontent.com/masudur-rahman-niloy/b1570cca2930cb1029c5c7ffcab966b4/raw/df0fb4c85863f70d0d6f5b013dc4f1ef31daf784/es_get.py


# /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b -s | xargs python3 es_get.py
