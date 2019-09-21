# Maxim-Krivobokov_infra
Maxim-Krivobokov Infra repository

#Homework 3 - знакомство с облачной ифнраструктурой

bastion_IP = 35.240.16.5
someinternalhost_IP = 10.132.0.3

что сделано:

* Создан аккаунт GCP
*  Созданы 2 виртуальные машины
* Настроены параметры сети:  ip адреса и правила Firewall, доступ по SSH
* Настроен VPN сервер на базе Pritunl (создана организация, пользователь, создан и настроен сервер, прикреплен к организации)
* В настройках сети GCP открыт порт udp для сервера Pritunl

* Соединение по SSH к хосту someinternalhost одной командой:
````bash
 ssh -i ~/.ssh/Maxim -A Maxim@35.240.16.5 -tt 10.132.0.3
 ````
 
 *  Настроен файл .ssh config для создание alias someinternalhost
 ````bash
	Host someinternalhost
	HostName 10.132.0.3
	User Maxim
	IdentityFile ~/.ssh/Maxim
	ProxyCommand ssh -A 35.240.16.5 nc %h %p
 ````
 
 
 
 