#! /bin/bash

#запускаем инстанс из образа reddit-base
gcloud compute instances create reddit-app \
	--image-family reddit-base\
	--tags puma-server\
	--restart-on-failure

#создаем правило firewall
gcloud compute firewall-rules create default-puma-server2 \
	--allow=tcp:9292 \
	--target-tags="puma-server"

echo "completed"


