#!/bin/bash

#adding keys and repo for MongoDB 
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D68FA50FEA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
#update idex of available pockets and install mongodb 
sudo apt update
sudo apt install -y mongodb-org
echo "MongoDB installation process complete. Check for error messages"
#starting MongoDb service
sudo systemctl start mongod
#adding to autostart
sudo  systemctl enable mongod
#checking status of mongodb service
sudo systemctl status mongod
echo "Check for Loaded - enabled and Avtive: active (running)"
