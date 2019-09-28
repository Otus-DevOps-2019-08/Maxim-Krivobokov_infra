#!/bin/bash

#copying code of Reddit from github
git clone -b monolith https://github.com/express42/reddit.git
#echo "reddit cloned succesfully"
cd reddit
# installing dependencies of the program
sudo -u bundle install
# starting puma server
puma -d
# echo "Puma server must be staarted above this message"
# checking that  server has started succesfully
ps aux | grep puma >> test.txt
# echo "if you don't see anything about puma above, smth bad has happened =("

cat <<EOF > reddit-app.service
	[Unit]
	Description=Puma HTTP Server with reddit-app
	After=network.target
	[Service]
	Type=forking
	User=appuser
	WorkingDirectory=/home/appuser/reddit
	ExecStart=/usr/local/bin/puma --pidfile /home/appuser/reddit/reddit-app.pid --daemon
	ExecStop=/usr/local/bin/pumactl --pidfile /home/appuser/reddit/reddit-app.pid stop
	PIDFile= /home/appuser/reddit/reddit-app.pid
	Restart=on-failure
	RemainAfterExit=no
	[Install]
	WantedBy=multi-user.target
	EOF

mv reddit-app.service /etc/systemd/system/
	
systemctl daemon-reload
systemctl enable reddit-app.service

