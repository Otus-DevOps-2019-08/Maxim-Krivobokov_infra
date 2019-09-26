#!/bin/bash

#copying code of Reddit from github
git clone -b monolith https://github.com/express42/reddit.git
echo "reddit cloned succesfully"
cd reddit
#installing dependencies of the program
sudo bundle install
#starting puma server
puma -d
echo "Puma server must be staarted above this message"
#checking that  server has started succesfully
ps aux | grep puma
echo "if you don't see anything about puma above, smth bad has happened =("

