#!/bin/bash

# Mongodb 3.0.9 (32bit) for Raspberry Pi (Jessie)
# Content derived from Andy Felong's work
# ref: http://andyfelong.com/2016/01/mongodb-3-0-9-binaries-for-raspberry-pi-2-jessie/

echo "Run this script under sudo"

echo "Downloading files from Andy Felong's site"
cd 
mkdir mongo_setup
cd mongo_setup
wget http://andyfelong.com/downloads/core_mongodb.tar.gz
wget http://andyfelong.com/downloads/tools_mongodb.tar.gz

echo "Adding mongodb user"
adduser --ingroup nogroup --shell /etc/false --disabled-password --gecos "" --no-create-home mongodb

echo "unzipping setup files"
tar zxvf core_mongodb.tar.gz
tar zxvf tools_mongodb.tar.gz

echo "set ownership & permissions"
chown root:root mongo*
chmod 755 mongo*
strip mongo*
cp -p mongo* /usr/bin

echo "create log file directory with appropriate owner & permissions"
mkdir /var/log/mongodb
chown mongodb:nogroup /var/log/mongodb

echo "create the DB data directory with convenient access perms"
sudo mkdir /var/lib/mongodb
sudo chown mongodb:root /var/lib/mongodb
sudo chmod 775 /var/lib/mongodb


echo "create the mongodb.conf file and copy to /etc"
rm mongodb.conf
cat >>"mongodb.conf" <<EOF
# /etc/mongodb.conf
# minimal config file (old style)
# Run mongod --help to see a list of options

bind_ip = 127.0.0.1
quiet = true
dbpath = /var/lib/mongodb
logpath = /var/log/mongodb/mongod.log
logappend = true
storageEngine = mmapv1
EOF

cp mongodb.conf /etc

echo "create systemd/service file and copy to /lib/systemd/system"
rm mongodb.service
cat >>"mongodb.service" <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongodb.conf

[Install]
WantedBy=multi-user.target
EOF

cp mongodb.service /lib/systemd/system

echo "Starting service"
systemctl enable mongodb.service
service mongodb start

echo "Check status"
service mongodb status

echo "Uncomment next line to stop service"
#service mongodb stop
