#!/bin/bash

sudo su
apt update

sudo apt-get install apt-transport-https
sudo apt install -y postgresql postgresql-contrib wget rsync unzip gnupg python3-pip


sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-ssd1
sudo mkdir -p /mnt/disks/sdb
sudo mount -o discard,defaults /dev/disk/by-id/google-ssd1 /mnt/disks/sdb
sudo chmod a+w /mnt/disks/sdb


# insert postgres data
cd /tmp
wget https://github.com/morenoh149/postgresDBSamples/archive/refs/heads/master.zip
unzip master
cd postgresDBSamples-master/chinook-1.4/
sudo -u postgres createdb -E UTF8 chinook
sudo -u postgres psql -f Chinook_PostgreSql_utf8.sql -d chinook
rm /tmp/master.zip
# sudo systemctl stop postgresql

sudo rsync -av /var/lib/postgresql /mnt/disks/sdb

# done copy postgres data to external disk

# mongo start
chmod -R 777 /tmp  # mongo got permission error for some reason
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt update
apt install mongodb-org -y

cd /tmp
wget https://github.com/neelabalan/mongodb-sample-dataset/archive/refs/heads/main.zip
unzip main
cd mongodb-sample-dataset-main/sample_airbnb

mongoimport --db=airbnb --collection=listingsAndReviews --file=listingsAndReviews.json
sudo rsync -av /var/lib/mongodb /mnt/disks/sdb


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

wget https://gist.githubusercontent.com/masudur-rahman-niloy/8270f01beb1d85ef568dbce9871dcb32/raw/778559e5ba426ef705f2bd491c56595c7524393d/es_insert.py
wget https://gist.githubusercontent.com/masudur-rahman-niloy/b1570cca2930cb1029c5c7ffcab966b4/raw/df0fb4c85863f70d0d6f5b013dc4f1ef31daf784/es_get.py

/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b -s | xargs python3 es_insert.py

# /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b -s | xargs python3 es_get.py
sudo rsync -av /var/lib/elasticsearch /mnt/disks/sdb